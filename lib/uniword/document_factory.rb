# frozen_string_literal: true

# All classes autoloaded via lib/uniword.rb
# No require_relative needed - autoload handles lazy loading

module Uniword
  # Factory for creating Document instances.
  #
  # Responsibility: Handle document creation from various sources.
  # Follows Single Responsibility Principle - creation logic separated from
  # Document class itself.
  #
  # @example Create document from file
  #   document = Uniword::DocumentFactory.from_file("document.docx")
  #
  # @example Create empty document
  #   document = Uniword::DocumentFactory.create
  #
  # @example Create with specific format
  #   document = Uniword::DocumentFactory.from_file("doc.mhtml", format: :mhtml)
  class DocumentFactory
    class << self
      # Create a new empty document.
      #
      # @return [Wordprocessingml::DocumentRoot] A new empty document
      #
      # @example Create empty document
      #   document = DocumentFactory.create
      def create
        Wordprocessingml::DocumentRoot.new
      end

      # Create a document from a file.
      #
      # @param path [String] The file path
      # @param format [Symbol] The format (:auto, :docx, :mhtml)
      # @return [Document] The loaded document
      # @raise [ArgumentError] if path is invalid
      # @raise [ArgumentError] if format is not supported
      #
      # @example Load DOCX file
      #   document = DocumentFactory.from_file("document.docx")
      #
      # @example Load with explicit format
      #   document = DocumentFactory.from_file("doc.mht", format: :mhtml)
      def from_file(path, format: :auto)
        # Handle binary strings (for docx gem compatibility)
        # Convert to StringIO if it's a binary string (contains null bytes or has binary encoding)
        path = StringIO.new(path) if path.is_a?(String) && (path.encoding == Encoding::ASCII_8BIT || path.include?("\x00"))

        validate_path(path)

        format = detect_format(path) if format == :auto

        case format
        when :docx, :docm
          package = Docx::Package.from_file(path)
          doc = package.document
          copy_package_parts_to_document(package, doc)
          doc
        when :dotx, :dotm
          Ooxml::DotxPackage.from_file(path)
        when :mhtml
          mhtml_doc = Mhtml::MhtmlPackage.from_file(path)
          # Convert Mhtml::Document to DocumentRoot for uniform API
          if mhtml_doc.is_a?(Mhtml::Document)
            Transformation::Transformer.new.mhtml_to_docx(mhtml_doc)
          else
            mhtml_doc
          end
        when :html
          html_content = read_file_content(path)
          Uniword.from_html(html_content)
        else
          raise ArgumentError, "Unsupported format: #{format}"
        end
      rescue ArgumentError
        # Re-raise validation errors as-is
        raise
      rescue Zip::Error => e
        raise CorruptedFileError.new(path.to_s,
                                     "Invalid ZIP structure: #{e.message}")
      rescue Nokogiri::XML::SyntaxError => e
        raise CorruptedFileError.new(path.to_s, "Invalid XML: #{e.message}")
      rescue StandardError => e
        # Re-raise our custom errors
        raise if e.is_a?(Uniword::Error)

        # Wrap other errors
        raise CorruptedFileError.new(path.to_s, e.message)
      end

      # Create a document from binary data (IO/StringIO stream or binary string).
      # Compatible with docx gem API
      #
      # @param stream [IO, StringIO, String] The binary stream or data
      # @param format [Symbol] The format (:auto, :docx, :mhtml)
      # @return [Document] The loaded document (Generated::Wordprocessingml::DocumentRoot)
      #
      # @example Load from stream
      #   stream = StringIO.new(File.binread("doc.docx"))
      #   document = DocumentFactory.from_file_data(stream)
      #
      # @example Load from binary string
      #   data = File.binread("doc.docx")
      #   document = DocumentFactory.from_file_data(data)
      def from_file_data(stream, format: :auto)
        # Convert binary string to StringIO if needed
        stream = StringIO.new(stream) if stream.is_a?(String)

        # Use from_file which already supports IO/StringIO
        from_file(stream, format: format)
      end

      # Create a Theme from a theme file (.thmx).
      #
      # IMPORTANT: This returns a Theme object, NOT a Document!
      # Theme files (.thmx) are standalone packages containing only theme data.
      #
      # @param path [String] The file path to .thmx file
      # @param format [Symbol] The format (:auto, :thmx)
      # @return [Theme] The loaded theme
      # @raise [ArgumentError] if path is invalid or not a theme format
      #
      # @example Load theme file
      #   theme = DocumentFactory.from_theme_file("celestial.thmx")
      #   theme.name # => "Celestial"
      def from_theme_file(path, format: :auto)
        validate_path(path)

        format = detect_format(path) if format == :auto

        case format
        when :thmx
          Ooxml::ThmxPackage.from_file(path)
        else
          raise ArgumentError,
                "Not a theme format: #{format}. Use from_file() for documents."
        end
      rescue ArgumentError
        # Re-raise validation errors as-is
        raise
      rescue Zip::Error => e
        raise CorruptedFileError.new(path.to_s,
                                     "Invalid ZIP structure: #{e.message}")
      rescue Nokogiri::XML::SyntaxError => e
        raise CorruptedFileError.new(path.to_s, "Invalid XML: #{e.message}")
      rescue StandardError => e
        # Re-raise our custom errors
        raise if e.is_a?(Uniword::Error)

        # Wrap other errors
        raise CorruptedFileError.new(path.to_s, e.message)
      end

      # Detect the format of a file.
      #
      # Uses FormatDetector for signature-based detection with extension fallback.
      #
      # @param path [String] The file path
      # @return [Symbol] The detected format (:docx, :mhtml)
      # @raise [ArgumentError] if format cannot be detected
      #
      # @example Detect format
      #   format = DocumentFactory.detect_format("document.docx")
      #   # => :docx
      def detect_format(path)
        detector = FormatDetector.new
        detector.detect(path)
      end

      # Mapping from Docx::Package attribute names to DocumentRoot
      # attribute names. Keys where names differ use explicit mapping.
      PACKAGE_PART_MAPPINGS = {
        styles: :styles_configuration,
        numbering: :numbering_configuration,
        settings: :settings,
        font_table: :font_table,
        web_settings: :web_settings,
        theme: :theme,
        core_properties: :core_properties,
        app_properties: :app_properties,
        document_rels: :document_rels,
        theme_rels: :theme_rels,
        package_rels: :package_rels,
        content_types: :content_types,
        custom_properties: :custom_properties,
        custom_xml_items: :custom_xml_items,
        footnotes: :footnotes,
        endnotes: :endnotes,
      }.freeze

      # Copy package parts to document for round-trip preservation
      #
      # @param package [Docx::Package] The source package
      # @param document [Wordprocessingml::DocumentRoot] The target document
      # @return [void]
      def copy_package_parts_to_document(package, document)
        return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

        PACKAGE_PART_MAPPINGS.each do |pkg_attr, doc_attr|
          value = package.send(pkg_attr)
          document.send(:"#{doc_attr}=", value) if value
        end
      end

      private

      # Read file content as UTF-8 string.
      #
      # @param path [String, IO, StringIO] File path or stream
      # @return [String] File content
      def read_file_content(path)
        case path
        when IO, StringIO
          path.read
        else
          File.read(path, encoding: "UTF-8")
        end
      end

      # Validate file path or stream.
      #
      # @param path [String, IO, StringIO] The path or stream to validate
      # @return [void]
      # @raise [FileNotFoundError] if file doesn't exist
      # @raise [ArgumentError] if path is nil or empty
      def validate_path(path)
        raise ArgumentError, "Path cannot be nil" if path.nil?

        # Allow IO and StringIO objects (for docx gem compatibility)
        return if path.is_a?(IO) || path.is_a?(StringIO)

        # For strings, validate
        if path.respond_to?(:empty?) && path.empty?
          raise ArgumentError,
                "Path cannot be empty"
        end
        raise FileNotFoundError, path unless File.exist?(path)
      end
    end
  end
end
