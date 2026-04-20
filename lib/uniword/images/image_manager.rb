# frozen_string_literal: true

require "fileutils"
require "stringio"

module Uniword
  module Images
    # Orchestrator for image operations on a DocumentRoot.
    #
    # Works with the document's +image_parts+ hash (populated during DOCX
    # loading) and the package ZIP to enumerate, extract, insert, and
    # remove images.
    #
    # @example List images
    #   doc = Uniword::DocumentFactory.from_file("report.docx")
    #   manager = ImageManager.new(doc)
    #   manager.list  # => [#<ImageInfo ...>, ...]
    #
    # @example Extract images to a directory
    #   count = manager.extract("/tmp/images")
    #
    # @example Insert a new image
    #   manager.insert("/path/photo.png", position: 3, width: "6in")
    #
    # @example Remove an image by name
    #   manager.remove("image1.png")
    class ImageManager
      # Pixels per EMU at 96 DPI.
      EMU_PER_PX = 9525

      # Inches per EMU.
      EMU_PER_INCH = 914_400

      # Centimeters per EMU.
      EMU_PER_CM = 360_000

      # @param document [Uniword::Wordprocessingml::DocumentRoot] The document
      def initialize(document)
        @document = document
      end

      # List all images in the document.
      #
      # Returns one +ImageInfo+ per entry in +document.image_parts+.
      # When pixel dimensions cannot be determined from the binary data,
      # +width+ and +height+ will be +nil+.
      #
      # @return [Array<ImageInfo>]
      def list
        parts = @document.image_parts
        return [] unless parts && !parts.empty?

        parts.map do |_r_id, entry|
          data = entry[:data]
          px_w, px_h = detect_pixel_dimensions(data) if data
          name = File.basename(entry[:target].to_s)

          ImageInfo.new(
            name: name,
            path: "word/#{entry[:target]}",
            content_type: entry[:content_type].to_s,
            size: data ? data.bytesize : 0,
            width: px_w,
            height: px_h
          )
        end
      end

      # Extract all images to a directory on disk.
      #
      # Creates +output_dir+ if it does not exist. Each image is written
      # using the filename from the package entry.
      #
      # @param output_dir [String] Target directory
      # @return [Integer] Number of images extracted
      def extract(output_dir)
        FileUtils.mkdir_p(output_dir)

        parts = @document.image_parts
        return 0 unless parts && !parts.empty?

        parts.each_value do |entry|
          data = entry[:data]
          next unless data

          filename = File.basename(entry[:target].to_s)
          File.binwrite(File.join(output_dir, filename), data)
        end

        parts.size
      end

      # Insert an image into the document.
      #
      # Reads the file at +image_path+, registers it in the document's
      # +image_parts+, and appends a new paragraph containing an inline
      # image Drawing at the specified position (or at the end).
      #
      # @param image_path [String] Path to the image file on disk
      # @param options [Hash] Insertion options
      # @option options [Integer] :position  Paragraph index (nil = append)
      # @option options [String]  :width     Width string (e.g., "6in", "15cm")
      # @option options [String]  :height    Height string (e.g., "4in", "10cm")
      # @option options [String]  :description  Alt text / description
      # @return [String] Relationship ID assigned to the new image
      def insert(image_path, **options)
        raise ArgumentError, "Image file not found: #{image_path}" unless File.exist?(image_path)

        width_emu = parse_dimension(options[:width])
        height_emu = parse_dimension(options[:height])

        # Register image part via the existing ImageBuilder infrastructure
        r_id = Builder::ImageBuilder.register_image(@document, image_path)

        # Determine pixel dimensions for fallback EMU conversion
        px_w, px_h = Builder::ImageBuilder.read_dimensions(image_path)
        width_emu ||= px_w * EMU_PER_PX
        height_emu ||= px_h * EMU_PER_PX

        # Build the Drawing element
        drawing = Builder::ImageBuilder.create_drawing(
          @document, image_path,
          width: width_emu,
          height: height_emu,
          alt_text: options[:description]
        )

        # Wrap in a Run and Paragraph, then insert
        run = Wordprocessingml::Run.new
        run.drawings << drawing

        paragraph = Wordprocessingml::Paragraph.new
        paragraph.runs << run

        body = @document.body ||= Wordprocessingml::Body.new
        body.paragraphs ||= []

        position = options[:position]
        if position && position < body.paragraphs.size
          body.paragraphs.insert(position, paragraph)
        else
          body.paragraphs << paragraph
        end

        r_id
      end

      # Remove an image by filename from the document.
      #
      # Removes the matching entry from +image_parts+.
      # Does NOT remove Drawing references in the document XML;
      # callers should handle that separately if needed.
      #
      # @param image_name [String] Filename (e.g., "image1.png")
      # @return [Boolean] true if an entry was removed
      def remove(image_name)
        parts = @document.image_parts
        return false unless parts && !parts.empty?

        key = parts.find do |_k, entry|
          File.basename(entry[:target].to_s) == image_name
        end&.first

        return false unless key

        parts.delete(key)
        true
      end

      private

      # Detect pixel dimensions from binary image data.
      #
      # @param data [String] Binary image data
      # @return [Array(Integer, Integer), nil] [width, height] or nil
      def detect_pixel_dimensions(data)
        return nil unless data && data.bytesize >= 24

        header = data.byteslice(0, 32)

        if header.start_with?("\x89PNG".b)
          # PNG: width/height at bytes 16-23 (big-endian uint32)
          w = header.byteslice(16, 4).unpack1("N")
          h = header.byteslice(20, 4).unpack1("N")
          [w, h]
        elsif header.start_with?("\xFF\xD8".b)
          # JPEG: minimal SOF parsing
          detect_jpeg_dimensions(data)
        else
          nil
        end
      end

      # Parse JPEG SOF marker for dimensions.
      #
      # @param data [String] Full JPEG binary data
      # @return [Array(Integer, Integer), nil] [width, height]
      def detect_jpeg_dimensions(data)
        io = StringIO.new(data)
        io.read(2) # SOI marker

        loop do
          marker = io.read(2)
          break unless marker && marker.getbyte(0) == 0xFF

          byte1 = marker.getbyte(1)
          length_str = io.read(2)
          break unless length_str

          length = length_str.unpack1("n")
          payload = io.read(length - 2)
          break unless payload

          # SOF0..SOF3, SOF5..SOF7, SOF9..SOF11, SOF13..SOF15
          if (byte1 >= 0xC0 && byte1 <= 0xC3) ||
             (byte1 >= 0xC5 && byte1 <= 0xC7) ||
             (byte1 >= 0xC9 && byte1 <= 0xCB) ||
             (byte1 >= 0xCD && byte1 <= 0xCF)
            h = payload.byteslice(0, 2).unpack1("n")
            w = payload.byteslice(2, 2).unpack1("n")
            return [w, h]
          end
        end

        nil
      end

      # Parse a dimension string to EMU (English Metric Units).
      #
      # @param value [String, nil] Dimension string (e.g., "6in", "15cm", "400px")
      # @return [Integer, nil] EMU value, or nil if input is nil/blank
      def parse_dimension(value)
        return nil unless value && !value.strip.empty?

        stripped = value.strip.downcase
        if stripped.end_with?("in")
          (stripped.to_f * EMU_PER_INCH).round
        elsif stripped.end_with?("cm")
          (stripped.to_f * EMU_PER_CM).round
        elsif stripped.end_with?("px") || stripped.end_with?("pt")
          stripped.to_i * EMU_PER_PX
        elsif stripped.match?(/\A\d+\z/)
          stripped.to_i # assume EMU when unit-less integer
        else
          nil
        end
      end
    end
  end
end
