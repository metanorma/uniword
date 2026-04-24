# frozen_string_literal: true

require "base64"

module Uniword
  module Infrastructure
    # Parses MHTML (MIME HTML) files into Mhtml::Document model.
    #
    # Parses MIME multipart structure, decodes content transfer encodings,
    # creates typed MimePart objects, and populates Mhtml::Document.
    #
    # @example Parse an MHTML file
    #   parser = Uniword::Infrastructure::MimeParser.new
    #   document = parser.parse("document.mhtml")
    class MimeParser
      # Parse MHTML file and return a populated Mhtml::Document.
      #
      # @param path [String] The file path to parse
      # @return [Mhtml::Document] The parsed document
      # @raise [ArgumentError] if path is nil or file not found
      def parse(path)
        raise ArgumentError, "Path cannot be nil" if path.nil?
        raise ArgumentError, "File not found: #{path}" unless File.exist?(path)

        content = File.binread(path).force_encoding("UTF-8")
        parse_content(content)
      end

      # Parse MHTML content string.
      #
      # @param content [String] The MHTML content to parse
      # @return [Mhtml::Document] The parsed document
      def parse_content(content)
        @content = content
        @boundary = extract_boundary
        @raw_parts = split_parts

        document = Mhtml::Document.new
        document.boundary = @boundary

        @raw_parts.each do |part|
          mime_part = parse_mime_part(part)
          next unless mime_part

          document.html_part = mime_part if mime_part.is_a?(Mhtml::HtmlPart) && !document.html_part

          document.add_part(mime_part)
        end

        extract_metadata(document)
        document
      end

      private

      # Extract MIME boundary from content.
      def extract_boundary
        if (match = @content.match(/boundary="([^"]+)"/))
          match[1]
        elsif (match = @content.match(/boundary=([^\s;]+)/))
          match[1]
        else
          raise "No MIME boundary found in content"
        end
      end

      # Split content into raw MIME part strings.
      def split_parts
        parts = @content.split(/--#{Regexp.escape(@boundary)}/)
        parts.reject! { |p| p.strip.empty? || p.strip == "--" }
        # Skip the global MIME header (Content-Type: multipart/related)
        # Strip leading CRLF first since boundary lines end with \r\n
        parts.reject! do |p|
          p.gsub(/^\r?\n/, "").match?(/^Content-Type:\s*multipart/i)
        end
        parts
      end

      # Parse a single raw MIME part into a typed MimePart.
      def parse_mime_part(raw_part)
        headers, body = raw_part.split(/\r?\n\r?\n/, 2)
        return nil unless body

        # Strip leading CRLF from headers (boundary lines end with \r\n)
        headers = headers.gsub(/^\r?\n/, "")

        content_type = extract_header(headers, "Content-Type")
        content_location = extract_header(headers, "Content-Location")
        encoding = extract_header(headers, "Content-Transfer-Encoding")
        content_id = extract_header(headers, "Content-ID")

        mime_part = create_typed_part(content_type)
        return nil unless mime_part

        mime_part.content_type = content_type
        mime_part.content_location = content_location
        mime_part.content_transfer_encoding = encoding
        mime_part.content_id = content_id&.gsub(/[<>]/, "")
        mime_part.raw_content = body.rstrip

        mime_part
      end

      # Create a typed MimePart based on content type.
      def create_typed_part(content_type)
        return nil unless content_type

        case content_type
        when %r{text/html}i
          Mhtml::HtmlPart.new
        when %r{image/}i
          Mhtml::ImagePart.new
        when %r{application/vnd.ms-officetheme}i
          Mhtml::ThemePart.new
        when %r{text/xml|application/xml}i
          Mhtml::XmlPart.new
        else
          Mhtml::MimePart.new
        end
      end

      # Extract header value from headers string.
      def extract_header(headers, header_name)
        if (match = headers.match(/^#{header_name}:\s*(.+?)$/i))
          match[1].strip
        end
      end

      # Extract metadata from HTML part into document model.
      def extract_metadata(document)
        html = document.html_part
        return unless html

        # Parse DocumentProperties
        props_xml = html.document_properties_xml
        if props_xml
          begin
            document.document_properties =
              Mhtml::Metadata::DocumentProperties.from_xml(props_xml)
          rescue StandardError
            # Store raw if parsing fails
            document.document_properties =
              Mhtml::Metadata::DocumentProperties.new
          end
        end

        # Parse OfficeDocumentSettings
        ods_xml = html.office_document_settings_xml
        if ods_xml
          begin
            document.office_document_settings =
              Mhtml::Metadata::OfficeDocumentSettings.from_xml(ods_xml)
          rescue StandardError
            document.office_document_settings =
              Mhtml::Metadata::OfficeDocumentSettings.new
          end
        end

        # Parse WordDocument settings
        wd_xml = html.word_document_xml
        if wd_xml
          begin
            document.word_document_settings =
              Mhtml::Metadata::WordDocumentSettings.from_xml(wd_xml)
          rescue StandardError
            document.word_document_settings =
              Mhtml::Metadata::WordDocumentSettings.new
          end
        end

        # Store LatentStyles as raw XML (too many entries to model individually)
        ls_xml = html.latent_styles_xml
        document.latent_styles_raw = ls_xml if ls_xml

        # Classify header/footer HTML parts
        document.parts.each do |part|
          next unless part.is_a?(Mhtml::HtmlPart)
          next if part == document.html_part

          fname = part.filename
          next unless fname&.include?("header") || fname&.include?("footer") ||
            fname&.include?("plchdr")

          # Convert to HeaderFooterPart
          idx = document.parts.index(part)
          hf = Mhtml::HeaderFooterPart.new
          hf.content_type = part.content_type
          hf.content_location = part.content_location
          hf.content_transfer_encoding = part.content_transfer_encoding
          hf.content_id = part.content_id
          hf.raw_content = part.raw_content
          document.parts[idx] = hf
        end
      end
    end
  end
end
