# frozen_string_literal: true

require 'base64'

module Uniword
  module Infrastructure
    # Parses MHTML (MIME HTML) files.
    #
    # Responsibility: Extract HTML and resources from MHTML MIME format.
    # MHTML files are MIME multipart documents containing HTML and embedded
    # resources (images, styles, etc.).
    #
    # @example Parse an MHTML file
    #   parser = Uniword::Infrastructure::MimeParser.new
    #   parts = parser.parse("document.mhtml")
    #   # => { "html" => "<html>...</html>", "filelist" => "...", "images" => {...} }
    class MimeParser
      # Parse MHTML file and extract MIME parts.
      #
      # @param path [String] The file path to parse
      # @return [Hash] Hash containing parsed MIME parts
      #   - 'html': The main HTML content
      #   - 'filelist': The filelist.xml content (if present)
      #   - 'images': Hash of filename => binary data
      # @raise [ArgumentError] if file cannot be read
      #
      # @example Parse a file
      #   parser = MimeParser.new
      #   parts = parser.parse("document.mhtml")
      def parse(path)
        raise ArgumentError, 'Path cannot be nil' if path.nil?
        raise ArgumentError, "File not found: #{path}" unless File.exist?(path)

        content = File.read(path, encoding: 'UTF-8')
        parse_content(content)
      end

      # Parse MHTML content string.
      #
      # @param content [String] The MHTML content to parse
      # @return [Hash] Hash containing parsed MIME parts
      def parse_content(content)
        @content = content
        @boundary = extract_boundary
        @parts = {}

        split_parts
        extract_parts

        {
          'html' => @parts[:html],
          'filelist' => @parts[:filelist],
          'images' => @parts[:images] || {}
        }
      end

      private

      # Extract MIME boundary from content.
      #
      # @return [String] The boundary string
      # @raise [RuntimeError] if no boundary found
      def extract_boundary
        if (match = @content.match(/boundary="([^"]+)"/))
          match[1]
        elsif (match = @content.match(/boundary=([^\s;]+)/))
          match[1]
        else
          raise 'No MIME boundary found in content'
        end
      end

      # Split content into MIME parts.
      #
      # @return [Array<String>] Array of MIME part strings
      def split_parts
        @raw_parts = @content.split(/--#{Regexp.escape(@boundary)}/)
        @raw_parts.reject! { |part| part.strip.empty? || part.strip == '--' }
      end

      # Extract and parse all MIME parts.
      #
      # @return [void]
      def extract_parts
        @raw_parts.each do |part|
          parse_part(part)
        end
      end

      # Parse a single MIME part.
      #
      # @param part [String] The MIME part content
      # @return [void]
      def parse_part(part)
        # Split headers from content
        headers, content = part.split(/\r?\n\r?\n/, 2)
        return unless content

        content_type = extract_header(headers, 'Content-Type')
        content_location = extract_header(headers, 'Content-Location')
        encoding = extract_header(headers, 'Content-Transfer-Encoding')

        # Decode content if needed
        decoded_content = decode_content(content, encoding)

        # Store by type
        store_part(content_type, content_location, decoded_content)
      end

      # Extract header value from headers string.
      #
      # @param headers [String] The headers string
      # @param header_name [String] The header name to extract
      # @return [String, nil] The header value or nil
      def extract_header(headers, header_name)
        if (match = headers.match(/^#{header_name}:\s*(.+?)$/i))
          match[1].strip
        end
      end

      # Decode content based on encoding.
      #
      # @param content [String] The content to decode
      # @param encoding [String, nil] The encoding type
      # @return [String] The decoded content
      def decode_content(content, encoding)
        return content unless encoding

        case encoding.downcase
        when 'base64'
          Base64.decode64(content.gsub(/\s+/, ''))
        when 'quoted-printable'
          decode_quoted_printable(content)
        else
          content
        end
      end

      # Decode quoted-printable encoded content.
      #
      # @param content [String] The quoted-printable content
      # @return [String] The decoded content
      def decode_quoted_printable(content)
        content
          .gsub(/=\r?\n/, '')
          .gsub(/=([0-9A-F]{2})/i) { ::Regexp.last_match(1).hex.chr }
      end

      # Store parsed part in appropriate location.
      #
      # @param content_type [String] The content type
      # @param content_location [String, nil] The content location
      # @param content [String] The decoded content
      # @return [void]
      def store_part(content_type, content_location, content)
        return unless content_type

        case content_type
        when %r{text/html}i
          # Keep the largest HTML part (main document content)
          # MHTML files may have multiple HTML parts, we want the biggest one
          @parts[:html] = content if @parts[:html].nil? || content.length > @parts[:html].length
        when %r{text/xml}i
          @parts[:filelist] = content if content_location&.include?('filelist')
        when %r{image/}i
          @parts[:images] ||= {}
          filename = extract_filename(content_location)
          @parts[:images][filename] = content if filename
        end
      end

      # Extract filename from content location.
      #
      # @param content_location [String, nil] The content location
      # @return [String, nil] The extracted filename
      def extract_filename(content_location)
        return nil unless content_location

        # Remove cid: prefix if present
        location = content_location.sub(/^cid:/i, '')

        # Handle various formats:
        # - file:///C:/path/to/file.png
        # - filename.png
        if (match = location.match(%r{([^/\\]+\.[a-z0-9]+)$}i))
          match[1]
        end
      end
    end
  end
end
