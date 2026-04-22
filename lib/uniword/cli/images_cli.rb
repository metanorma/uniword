# frozen_string_literal: true

require "thor"
require "json"
require_relative "helpers"

module Uniword
  # Images subcommands for Uniword CLI.
  #
  # Provides commands for listing, extracting, inserting, and removing
  # images in DOCX documents.
  #
  # Examples:
  #   $ uniword images list document.docx
  #   $ uniword images list document.docx --json
  #   $ uniword images extract document.docx ./output_images
  #   $ uniword images insert document.docx photo.png -o out.docx
  #   $ uniword images remove document.docx image1.png -o out.docx
  class ImagesCLI < Thor
    include CLIHelpers

    desc "list FILE", "List images in a document"
    long_desc <<~DESC
      Display all images embedded in a document with name, type, size,
      and dimensions.

      Examples:
        $ uniword images list document.docx
        $ uniword images list document.docx --json
    DESC
    option :json, type: :boolean, default: false, desc: "Output as JSON"
    def list(path)
      doc = load_document(path)
      manager = Images::ImageManager.new(doc)
      images = manager.list

      if images.empty?
        say "No images found.", :yellow
        return
      end

      if options[:json]
        data = images.map do |img|
          {
            name: img.name,
            path: img.path,
            content_type: img.content_type,
            size: img.size,
            width: img.width,
            height: img.height
          }
        end
        puts JSON.pretty_generate(data)
      else
        say "Images (#{images.count}):", :green
        images.each_with_index do |img, idx|
          dims = img.width && img.height ? " #{img.width}x#{img.height}" : ""
          say "  #{idx + 1}. #{img.name}"
          say "     Type:  #{img.content_type}"
          say "     Size:  #{img.size} bytes#{dims}"
          say "     Path:  #{img.path}"
        end
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "extract FILE OUTPUT_DIR", "Extract images from document"
    long_desc <<~DESC
      Extract all embedded images to a directory on disk.

      Examples:
        $ uniword images extract document.docx ./output_images
        $ uniword images extract document.docx ./output_images --verbose
    DESC
    option :verbose, aliases: "-v", desc: "Show extracted file names",
                     type: :boolean, default: false
    def extract(path, output_dir)
      doc = load_document(path)
      manager = Images::ImageManager.new(doc)
      count = manager.extract(output_dir)

      if count.positive?
        say "Extracted #{count} image(s) to #{output_dir}", :green
      else
        say "No images to extract.", :yellow
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "insert FILE IMAGE_PATH", "Insert image into document"
    long_desc <<~DESC
      Insert an image file into a DOCX document at a given paragraph
      position (appended at the end by default).

      Examples:
        $ uniword images insert document.docx photo.png -o out.docx
        $ uniword images insert document.docx logo.png -o out.docx --width 6in --height 4in
        $ uniword images insert document.docx chart.png -o out.docx --position 2
    DESC
    option :output, aliases: "-o", required: true, desc: "Output file path",
                    type: :string
    option :position, type: :numeric, desc: "Paragraph position index"
    option :width, type: :string, desc: "Width (e.g., '6in', '15cm', '400px')"
    option :height, type: :string, desc: "Height (e.g., '4in', '10cm')"
    option :description, type: :string, desc: "Alt text / description"
    def insert(path, image_path)
      doc = load_document(path)

      unless File.exist?(image_path)
        say "Image not found: #{image_path}", :red
        exit 1
      end

      manager = Images::ImageManager.new(doc)
      insert_options = {}
      insert_options[:position] = options[:position] if options[:position]
      insert_options[:width] = options[:width] if options[:width]
      insert_options[:height] = options[:height] if options[:height]
      insert_options[:description] = options[:description] if options[:description]

      r_id = manager.insert(image_path, **insert_options)
      doc.save(options[:output])

      say "Inserted image (#{r_id}) into #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "remove FILE IMAGE_NAME", "Remove image from document"
    long_desc <<~DESC
      Remove an embedded image by filename from a document.

      Examples:
        $ uniword images remove document.docx image1.png -o out.docx
    DESC
    option :output, aliases: "-o", required: true, desc: "Output file path",
                    type: :string
    def remove(path, image_name)
      doc = load_document(path)
      manager = Images::ImageManager.new(doc)

      unless manager.remove(image_name)
        say "Image '#{image_name}' not found.", :red
        exit 1
      end

      doc.save(options[:output])
      say "Removed '#{image_name}' from #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end
  end
end
