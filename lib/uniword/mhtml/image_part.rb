# frozen_string_literal: true

module Uniword
  module Mhtml
    # Image MIME part — embedded image (PNG, JPEG, GIF, etc.)
    class ImagePart < MimePart
      def image_data
        decoded_content
      end

      def image_data=(value)
        self.raw_content = value
      end

      def image_format
        case content_type
        when /png/i then :png
        when /jpeg|jpg/i then :jpeg
        when /gif/i then :gif
        when /bmp/i then :bmp
        when /tiff/i then :tiff
        when /svg/i then :svg
        when /webp/i then :webp
        else :unknown
        end
      end
    end
  end
end
