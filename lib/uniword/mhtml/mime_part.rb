# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Mhtml
    # Base class for MIME parts in an MHTML document.
    #
    # Each MIME part has headers (Content-Type, Content-Location,
    # Content-Transfer-Encoding) and a body (raw_content, always in
    # DECODED form: the wire encoding declared by
    # content_transfer_encoding is applied by MimePackager and removed
    # by MimeParser, never here).
    #
    # Subclasses: HtmlPart, XmlPart, ImagePart, FileListPart, HeaderPart
    class MimePart < Lutaml::Model::Serializable
      attribute :content_type, :string
      attribute :content_location, :string
      attribute :content_transfer_encoding, :string
      attribute :content_id, :string
      attribute :raw_content, :string

      def decoded_content
        raw_content
      end

      def decoded_content=(value)
        self.raw_content = value
      end

      def filename
        return nil unless content_location

        location = content_location.sub(/^cid:/i, "")
        if (match = location.match(%r{([^/\\]+\.[a-z0-9]+)$}i))
          match[1]
        end
      end

      def text_content?
        content_type.to_s.start_with?("text/")
      end

      def xml_content?
        content_type.to_s.match?(%r{text/xml|application/xml})
      end

      def html_content?
        content_type.to_s.include?("text/html")
      end

      def image_content?
        content_type.to_s.start_with?("image/")
      end

      def theme_content?
        content_type.to_s.include?("officetheme")
      end
    end
  end
end
