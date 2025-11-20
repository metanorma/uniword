# frozen_string_literal: true

require 'securerandom'
require 'base64'

module Uniword
  module Infrastructure
    # Packages HTML and resources into MHTML format.
    #
    # Responsibility: Create MHTML MIME multipart documents from HTML and resources.
    # MHTML files contain HTML and embedded resources in MIME format.
    #
    # @example Package HTML into MHTML
    #   packager = Uniword::Infrastructure::MimePackager.new(html, images)
    #   packager.package("output.doc")
    class MimePackager
      # @return [String] The HTML content
      attr_reader :html_content

      # @return [Hash] The resources (images, etc.)
      attr_reader :resources

      # @return [String] The MIME boundary
      attr_reader :boundary

      # Initialize packager with HTML and resources.
      #
      # @param html_content [String] The main HTML content
      # @param resources [Hash] Hash of resources (filename => data)
      # @param options [Hash] Optional configuration
      # @option options [String] :filelist_xml Custom filelist.xml content
      #
      # @example Create a packager
      #   packager = MimePackager.new(html, { 'image1.png' => image_data })
      def initialize(html_content, resources = {}, options = {})
        @html_content = html_content
        @resources = resources || {}
        @options = options
        @boundary = generate_boundary
      end

      # Package content into MHTML file.
      #
      # @param output_path [String] The output file path
      # @return [void]
      # @raise [ArgumentError] if output_path is invalid
      #
      # @example Package to file
      #   packager.package("output.doc")
      def package(output_path)
        raise ArgumentError, 'Output path cannot be nil' if output_path.nil?
        raise ArgumentError, 'Output path cannot be empty' if output_path.empty?

        mime_content = build_mime_structure
        write_file(output_path, mime_content)
      end

      private

      # Build complete MIME multipart structure.
      #
      # @return [String] The complete MIME content
      def build_mime_structure
        parts = []

        # MIME header
        parts << build_mime_header

        # HTML content part
        parts << build_html_part

        # Filelist part
        parts << build_filelist_part

        # Resource parts (images, etc.)
        resources.each do |filename, data|
          parts << build_resource_part(filename, data)
        end

        # Terminator - end with single newline for compatibility
        parts << "--#{boundary}--\n"

        # Replace image src with cid: references
        contentid(parts.join("\r\n"))
      end

      # Build MIME header section.
      #
      # @return [String] The MIME header
      def build_mime_header
        <<~HEADER.chomp
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="#{boundary}"
        HEADER
      end

      # Build HTML content part.
      #
      # @return [String] The HTML MIME part
      def build_html_part
        <<~PART.chomp
          --#{boundary}
          Content-Type: text/html; charset="utf-8"
          Content-Transfer-Encoding: quoted-printable
          Content-Location: document.html

          #{html_content}
        PART
      end

      # Build filelist.xml part.
      #
      # @return [String] The filelist MIME part
      def build_filelist_part
        filelist_xml = @options[:filelist_xml] || generate_filelist_xml

        <<~PART.chomp
          --#{boundary}
          Content-Type: text/xml; charset="utf-8"
          Content-Location: filelist.xml

          #{filelist_xml}
        PART
      end

      # Generate filelist.xml content.
      #
      # @return [String] The filelist XML
      def generate_filelist_xml
        entries = resources.keys.map do |filename|
          %(<o:File HRef="#{filename}"/>)
        end

        <<~XML.chomp
          <xml xmlns:o="urn:schemas-microsoft-com:office:office">
            <o:MainFile HRef="document.html"/>
          #{entries.join("\n  ")}
          </xml>
        XML
      end

      # Build resource MIME part.
      #
      # @param filename [String] The resource filename
      # @param data [String] The resource binary data
      # @return [String] The resource MIME part
      def build_resource_part(filename, data)
        content_type = detect_mime_type(filename)
        encoded = Base64.strict_encode64(data).scan(/.{1,76}/).join("\r\n")

        <<~PART.chomp
          --#{boundary}
          Content-Type: #{content_type}
          Content-Transfer-Encoding: base64
          Content-Location: #{filename}

          #{encoded}
        PART
      end

      # Detect MIME type from filename extension.
      #
      # @param filename [String] The filename
      # @return [String] The MIME type
      def detect_mime_type(filename)
        ext = File.extname(filename).downcase

        case ext
        when '.png' then 'image/png'
        when '.jpg', '.jpeg' then 'image/jpeg'
        when '.gif' then 'image/gif'
        when '.svg' then 'image/svg+xml'
        when '.bmp' then 'image/bmp'
        when '.tif', '.tiff' then 'image/tiff'
        when '.webp' then 'image/webp'
        when '.css' then 'text/css; charset="utf-8"'
        when '.xml' then 'text/xml; charset="utf-8"'
        when '.html', '.htm' then 'text/html; charset="utf-8"'
        else 'application/octet-stream'
        end
      end

      # Generate unique MIME boundary.
      #
      # @return [String] The boundary string
      def generate_boundary
        salt = SecureRandom.uuid.tr('-', '.')[0..17]
        "----=_NextPart_#{salt}"
      end

      # Replace image src attributes with cid: references.
      #
      # @param mhtml [String] The MHTML content
      # @return [String] The modified MHTML content
      def contentid(mhtml)
        # Replace img src attributes
        result = mhtml.gsub(%r{(<img[^<>]*?src=")([^"'<]+)(['"])}m) do |match|
          # Keep data: and http: URLs as-is
          if /^data:|^https?:/.match?(Regexp.last_match(2))
            match
          else
            "#{Regexp.last_match(1)}cid:#{File.basename(Regexp.last_match(2))}#{Regexp.last_match(3)}"
          end
        end

        # Replace v:imagedata src attributes (VML images)
        result.gsub(%r{(<v:imagedata[^<>]*?src=")([^"'<]+)(['"])}m) do |match|
          if /^data:|^https?:/.match?(Regexp.last_match(2))
            match
          else
            "#{Regexp.last_match(1)}cid:#{File.basename(Regexp.last_match(2))}#{Regexp.last_match(3)}"
          end
        end
      end

      # Write content to file.
      #
      # @param path [String] The file path
      # @param content [String] The content to write
      # @return [void]
      def write_file(path, content)
        File.write(path, content, encoding: 'UTF-8')
      end
    end
  end
end
