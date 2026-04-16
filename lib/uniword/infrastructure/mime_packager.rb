# frozen_string_literal: true

require "securerandom"
require "base64"

module Uniword
  module Infrastructure
    # Serializes Mhtml::Document to MHTML MIME format.
    #
    # Rebuilds the MIME multipart structure from the document model,
    # encoding content appropriately (QP for text, base64 for binary).
    #
    # @example Serialize to file
    #   packager = MimePackager.from_document(document)
    #   packager.package("output.doc")
    class MimePackager
      attr_reader :document, :boundary

      # Create packager from an Mhtml::Document.
      #
      # @param document [Mhtml::Document] The document to serialize
      def initialize(document)
        @document = document
        @boundary = document.boundary || generate_boundary
      end

      # Create packager from document (class method for compatibility).
      def self.from_document(document)
        new(document)
      end

      # Package document to MHTML file.
      #
      # @param output_path [String] The output file path
      def package(output_path)
        raise ArgumentError, "Output path cannot be nil" if output_path.nil?
        raise ArgumentError, "Output path cannot be empty" if output_path.empty?

        File.binwrite(output_path, build_mime_content.encode("UTF-8"))
      end

      # Build complete MIME content as string.
      #
      # @return [String] The complete MHTML content
      def build_mime_content
        parts = []

        # MIME global header
        parts << "MIME-Version: 1.0"
        parts << "Content-Type: multipart/related; boundary=\"#{boundary}\""
        parts << ""

        # HTML part (main document)
        parts << build_part(document.html_part) if document.html_part

        # All other parts (XML, images, theme, etc.)
        document.parts.each do |part|
          next if part == document.html_part

          parts << build_part(part)
        end

        # Final boundary
        parts << "--#{boundary}--"
        parts << ""

        parts.join("\r\n")
      end

      private

      # Build a single MIME part.
      def build_part(part)
        lines = []

        # Boundary
        lines << "--#{boundary}"

        # Headers
        lines << "Content-Location: #{part.content_location}" if part.content_location
        lines << "Content-Transfer-Encoding: #{part.content_transfer_encoding}" if part.content_transfer_encoding

        if part.content_type
          ct = part.content_type
          # Add charset for text types
          ct += '; charset="utf-8"' if ct.start_with?("text/") && !ct.include?("charset")
          lines << "Content-Type: #{ct}"
        end

        lines << "Content-ID: <#{part.content_id}>" if part.content_id

        # Empty line separating headers from body
        lines << ""

        # Body — encode if needed
        encoding = part.content_transfer_encoding
        if encoding == "quoted-printable"
          # Use decoded_content to avoid double-encoding on round-trip
          body = quoted_printable_encode(part.decoded_content)
        elsif encoding == "base64"
          begin
            # Decoded content (round-trip: raw_content is already base64)
            body = Base64.strict_encode64(part.decoded_content)
          rescue ArgumentError
            # New part: raw_content is raw binary data
            body = Base64.strict_encode64(part.raw_content)
          end
          body = body.gsub(/.{1,76}/, "\\0\r\n").rstrip
        else
          body = part.raw_content
        end
        lines << body

        lines.join("\r\n")
      end

      # Generate unique MIME boundary.
      def generate_boundary
        salt = SecureRandom.uuid.tr("-", ".")[0..17]
        "----=_NextPart_#{salt}"
      end

      # Quoted-printable encode content
      # Encodes special characters and uses soft line breaks
      # RFC 2045: only '=' (61) and control chars (0-31, 127) must be encoded
      def quoted_printable_encode(content)
        result = []
        line_length = 0
        max_line_length = 76

        content.bytes.each do |byte|
          char = byte.chr
          # Encode only '=' and control characters per RFC 2045
          if byte == 61 || byte < 33 || byte > 126
            result << ("=%02X" % byte)
            line_length += 3
          else
            result << char
            line_length += 1
          end

          # Soft line break if line gets too long
          if line_length >= max_line_length - 1
            result << "=\r\n"
            line_length = 0
          end
        end

        result.join
      end
    end
  end
end
