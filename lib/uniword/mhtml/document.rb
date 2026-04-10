# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Mhtml
    # MHTML Document — top-level model for .mht/.mhtml/.doc files.
    #
    # This is COMPLETELY SEPARATE from OOXML Wordprocessingml::DocumentRoot.
    # MHTML uses MIME multipart format with HTML content, not ZIP + OOXML XML.
    #
    # Structure:
    #   Mhtml::Document
    #     ├── html_part (HtmlPart) — main document HTML
    #     ├── parts[] (MimePart) — all MIME parts (images, XML, theme, etc.)
    #     ├── document_properties (Metadata::DocumentProperties)
    #     ├── word_document_settings (Metadata::WordDocumentSettings)
    #     └── filelist_xml (String)
    class Document < Lutaml::Model::Serializable
      # MIME headers
      attribute :mime_version, :string, default: -> { '1.0' }
      attribute :boundary, :string

      # Main HTML part (first/largest text/html part)
      attribute :html_part, HtmlPart

      # All MIME parts (including the HTML part)
      attribute :parts, :array, default: -> { [] }

      # Parsed metadata from HTML head XML blocks
      attribute :document_properties, Metadata::DocumentProperties
      attribute :office_document_settings, Metadata::OfficeDocumentSettings
      attribute :word_document_settings, Metadata::WordDocumentSettings
      attribute :latent_styles_raw, :string

      # Convenience accessors

      # @return [HtmlPart] The main HTML part
      def html
        @html_part
      end

      # Raw HTML string of the main HTML part
      def raw_html
        html_part&.decoded_content
      end

      def raw_html=(value)
        self.html_part ||= HtmlPart.new
        html_part.content_type = 'text/html'
        html_part.content_transfer_encoding = 'quoted-printable'
        html_part.raw_content = value
      end

      # Body inner HTML
      def body_html
        html_part&.body_html
      end

      # CSS styles from HTML head
      def css_styles
        html_part&.css_styles
      end

      # Text content (stripped of HTML tags)
      def text
        return '' unless raw_html

        raw_html
          .gsub(/<[^>]+>/, ' ')
          .gsub('&lt;', '<')
          .gsub('&gt;', '>')
          .gsub('&amp;', '&')
          .gsub('&quot;', '"')
          .gsub('&#39;', "'")
          .gsub('&nbsp;', ' ')
          .gsub(/\s+/, ' ')
          .strip
      end

      # File parts by type

      # @return [Array<XmlPart>] All XML parts
      def xml_parts
        parts.grep(XmlPart)
      end

      # @return [Array<ImagePart>] All image parts
      def image_parts
        parts.grep(ImagePart)
      end

      # @return [ThemePart, nil] Theme data part
      def theme_part
        parts.find { |p| p.is_a?(ThemePart) }
      end

      # @return [XmlPart, nil] Filelist XML part
      def filelist_part
        parts.find { |p| p.is_a?(XmlPart) && p.filename == 'filelist.xml' }
      end

      # @return [String, nil] Filelist XML content
      def filelist_xml
        filelist_part&.decoded_content
      end

      # @return [XmlPart, nil] Color scheme mapping part
      def color_scheme_mapping_part
        parts.find do |p|
          p.is_a?(XmlPart) && p.filename&.include?('colorschememapping')
        end
      end

      # @return [String, nil] Color scheme mapping XML
      def color_scheme_mapping_xml
        color_scheme_mapping_part&.decoded_content
      end

      # @return [Array<HeaderFooterPart>] Header/footer HTML parts
      def header_footer_parts
        parts.grep(HeaderFooterPart)
      end

      # @return [String, nil] Header HTML
      def header_html
        header_footer_parts.find { |p| p.filename&.include?('header') }&.decoded_content
      end

      # @return [String, nil] Footer HTML (placeholder)
      def footer_html
        header_footer_parts.find { |p| p.filename&.include?('footer') }&.decoded_content
      end

      # @return [String, nil] Placeholder header HTML
      def placeholder_html
        header_footer_parts.find { |p| p.filename&.include?('plchdr') }&.decoded_content
      end

      # @return [Hash] Images as filename => decoded data
      def images
        image_parts.each_with_object({}) do |part, hash|
          hash[part.filename] = part.decoded_content if part.filename
        end
      end

      # Add a MIME part
      def add_part(part)
        parts << part
        self
      end

      # Build a summary of the document structure
      def inspect
        "#<#{self.class} parts=#{parts.length} images=#{image_parts.length} " \
          "xml=#{xml_parts.length} theme=#{theme_part ? 'yes' : 'no'}>"
      end
    end
  end
end
