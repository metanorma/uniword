# frozen_string_literal: true

module Uniword
  module Themes
    # Value object representing a media file (image, etc.) from a theme package
    #
    # Responsibility: Hold immutable media file data with proper metadata
    #
    # This class follows the Value Object pattern:
    # - Immutable (frozen after initialization)
    # - Value-based equality
    # - Self-validating
    #
    # @example Create media file from theme
    #   media = MediaFile.new(
    #     filename: 'image1.jpeg',
    #     content: binary_data,
    #     content_type: 'image/jpeg'
    #   )
    class MediaFile
      # Media filename (e.g., 'image1.jpeg')
      attr_reader :filename

      # Binary content data
      attr_reader :content

      # MIME content type (e.g., 'image/jpeg', 'image/png')
      attr_reader :content_type

      # Original path in theme package (e.g., 'theme/media/image1.jpeg')
      attr_reader :source_path

      # Create a new MediaFile
      #
      # @param attributes [Hash] Media file attributes
      # @option attributes [String] :filename Required filename
      # @option attributes [String] :content Required binary content
      # @option attributes [String] :content_type Optional MIME type (auto-detected if not provided)
      # @option attributes [String] :source_path Optional original path
      # @raise [ArgumentError] if required attributes missing
      def initialize(attributes = {})
        @filename = attributes[:filename]
        @content = attributes[:content]
        @content_type = attributes[:content_type] || detect_content_type(@filename)
        @source_path = attributes[:source_path]

        validate!
        freeze # Immutable
      end

      # Get file size in bytes
      #
      # @return [Integer] Size of content in bytes
      def size
        content&.bytesize || 0
      end

      # Check if this is an image file
      #
      # @return [Boolean] true if image
      def image?
        content_type&.start_with?("image/")
      end

      # Get file extension
      #
      # @return [String, nil] File extension without dot
      def extension
        return nil unless filename

        File.extname(filename)[1..]
      end

      # Value-based equality
      #
      # @param other [Object] Object to compare
      # @return [Boolean] true if equal
      def ==(other)
        return false unless other.is_a?(self.class)

        filename == other.filename &&
          content == other.content &&
          content_type == other.content_type
      end

      alias eql? ==

      # Hash code for value-based hashing
      #
      # @return [Integer] hash code
      def hash
        [filename, content, content_type].hash
      end

      # Validate required attributes
      #
      # @return [void]
      # @raise [ArgumentError] if invalid
      def validate!
        if filename.nil? || filename.empty?
          raise ArgumentError,
                "filename is required"
        end
        raise ArgumentError, "content is required" if content.nil?
        unless filename.is_a?(String)
          raise ArgumentError,
                "filename must be a string"
        end
      end

      private

      # Detect content type from filename extension
      #
      # @param filename [String] The filename
      # @return [String] MIME content type
      def detect_content_type(filename)
        return "application/octet-stream" unless filename

        ext = File.extname(filename).downcase

        case ext
        when ".jpeg", ".jpg" then "image/jpeg"
        when ".png" then "image/png"
        when ".gif" then "image/gif"
        when ".bmp" then "image/bmp"
        when ".tiff", ".tif" then "image/tiff"
        when ".svg" then "image/svg+xml"
        else "application/octet-stream"
        end
      end
    end
  end
end
