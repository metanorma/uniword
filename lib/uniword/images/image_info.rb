# frozen_string_literal: true

module Uniword
  module Images
    # Value object describing a single image in a document.
    #
    # Immutable snapshot of image metadata: name, path, content type,
    # byte size, and pixel dimensions (when available).
    #
    # @example Create from raw data
    #   info = ImageInfo.new(
    #     name: "image1.png",
    #     path: "word/media/image1.png",
    #     content_type: "image/png",
    #     size: 4782,
    #     width: 200,
    #     height: 150
    #   )
    class ImageInfo
      attr_reader :name, :path, :content_type, :size, :width, :height

      # @param name [String] File name (e.g., "image1.png")
      # @param path [String] Full path within the package (e.g., "word/media/image1.png")
      # @param content_type [String] MIME type (e.g., "image/png")
      # @param size [Integer] File size in bytes
      # @param width [Integer, nil] Pixel width
      # @param height [Integer, nil] Pixel height
      def initialize(name:, path:, content_type:, size:, width: nil,
height: nil)
        @name = name
        @path = path
        @content_type = content_type
        @size = size
        @width = width
        @height = height
        freeze
      end

      # Human-readable representation.
      #
      # @return [String]
      def to_s
        dims = width && height ? " #{width}x#{height}" : ""
        "#{name} (#{content_type}, #{size} bytes#{dims})"
      end
    end
  end
end
