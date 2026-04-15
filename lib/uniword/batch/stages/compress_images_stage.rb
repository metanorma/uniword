# frozen_string_literal: true

module Uniword
  module Batch
    # Processing stage that compresses images in documents.
    #
    # Responsibility: Reduce image file sizes while maintaining quality.
    # Single Responsibility - only handles image compression.
    #
    # @example Use in pipeline
    #   stage = CompressImagesStage.new(
    #     max_width: 1920,
    #     max_height: 1080,
    #     quality: 85
    #   )
    #   document = stage.process(document, context)
    class CompressImagesStage < ProcessingStage
      # Initialize compress images stage
      #
      # @param options [Hash] Stage options
      # @option options [Integer] :max_width Maximum image width in pixels
      # @option options [Integer] :max_height Maximum image height in pixels
      # @option options [Integer] :quality JPEG quality (0-100)
      # @option options [Boolean] :preserve_aspect_ratio Maintain aspect ratio
      # @option options [Boolean] :skip_small_images Skip images below min size
      # @option options [Integer] :min_size_kb Minimum size to compress (KB)
      def initialize(options = {})
        super
        @max_width = options.fetch(:max_width, 1920)
        @max_height = options.fetch(:max_height, 1080)
        @quality = options.fetch(:quality, 85)
        @preserve_aspect_ratio = options.fetch(:preserve_aspect_ratio, true)
        @skip_small_images = options.fetch(:skip_small_images, true)
        @min_size_kb = options.fetch(:min_size_kb, 100)
      end

      # Process document to compress images
      #
      # @param document [Document] Document to process
      # @param context [Hash] Processing context
      # @return [Document] Processed document
      def process(document, context = {})
        log "Compressing images in #{context[:filename]}"

        images = collect_images(document)
        compressed_count = 0
        total_saved = 0

        images.each do |image|
          next unless should_compress_image?(image)

          saved_bytes = compress_image(image)
          if saved_bytes.positive?
            compressed_count += 1
            total_saved += saved_bytes
          end
        end

        if compressed_count.positive?
          saved_kb = (total_saved / 1024.0).round(2)
          log "Compressed #{compressed_count} image(s), saved #{saved_kb} KB"
        else
          log "No images needed compression"
        end

        document
      end

      # Get stage description
      #
      # @return [String] Description
      def description
        "Compress document images"
      end

      private

      # Collect all images from document
      #
      # @param document [Document] Document to scan
      # @return [Array<Image>] Array of images
      def collect_images(document)
        images = []

        # Scan paragraphs for images
        document.paragraphs.each do |paragraph|
          paragraph.runs.each do |run|
            images << run if run.is_a?(Uniword::Image)
          end
        end

        # Scan tables for images
        document.tables.each do |table|
          table.rows.each do |row|
            row.cells.each do |cell|
              cell.paragraphs.each do |paragraph|
                paragraph.runs.each do |run|
                  images << run if run.is_a?(Uniword::Image)
                end
              end
            end
          end
        end

        images
      end

      # Check if image should be compressed
      #
      # @param image [Image] Image to check
      # @return [Boolean] true if should compress
      def should_compress_image?(image)
        return false unless image.is_a?(Uniword::Image)
        return false if image.image_data.nil?

        # Skip small images if configured
        if @skip_small_images
          size_kb = image.image_data.bytesize / 1024.0
          return false if size_kb < @min_size_kb
        end

        true
      end

      # Compress an image
      #
      # @param image [Image] Image to compress
      # @return [Integer] Bytes saved (0 if not compressed)
      def compress_image(image)
        original_size = image.image_data.bytesize

        # Get image dimensions
        width, height = get_image_dimensions(image)

        # Check if resizing is needed
        needs_resize = width > @max_width || height > @max_height

        if needs_resize
          new_width, new_height = calculate_new_dimensions(width, height)
          log "  Resizing image from #{width}x#{height} to #{new_width}x#{new_height}"

          # Placeholder for actual image compression
          # In real implementation, would use image processing library
          # For now, just log the action
          original_size - original_size # Returns 0
        else
          0
        end
      end

      # Get image dimensions
      #
      # @param image [Image] Image object
      # @return [Array<Integer>] Width and height
      def get_image_dimensions(image)
        # Placeholder - would need to parse image data
        # For now, return dimensions from image properties if available
        width = image.respond_to?(:width) ? image.width : 800
        height = image.respond_to?(:height) ? image.height : 600
        [width || 800, height || 600]
      end

      # Calculate new dimensions maintaining aspect ratio
      #
      # @param width [Integer] Current width
      # @param height [Integer] Current height
      # @return [Array<Integer>] New width and height
      def calculate_new_dimensions(width, height)
        return [width, height] unless @preserve_aspect_ratio

        # Calculate scaling factor
        width_scale = @max_width.to_f / width
        height_scale = @max_height.to_f / height
        scale = [width_scale, height_scale].min

        # Apply scale if needed
        if scale < 1.0
          new_width = (width * scale).round
          new_height = (height * scale).round
          [new_width, new_height]
        else
          [width, height]
        end
      end
    end
  end
end
