# frozen_string_literal: true

require "moxml"
require "nokogiri"

module Uniword
  module Validation
    # Maps XML namespace URIs to XSD schema files and loads schemas for validation.
    #
    # Uses Moxml for namespace detection (parsing XML to find declared namespaces)
    # and Nokogiri::XML::Schema for actual XSD validation.
    #
    # The registry knows which OOXML namespace URIs correspond to which XSD files
    # bundled in data/schemas/.
    #
    # @example Detect namespaces and load schema for a part
    #   registry = SchemaRegistry.new
    #   ns_uris = registry.detect_namespaces(xml_string)
    #   schema = registry.schema_for_namespaces(ns_uris)
    #   errors = schema.validate(Nokogiri::XML(xml_string))
    class SchemaRegistry
      # Map of namespace URI => XSD file (relative to data/schemas/)
      NAMESPACE_XSD_MAP = {
        # Base WordprocessingML (ISO 29500)
        "http://schemas.openxmlformats.org/wordprocessingml/2006/main" =>
          "microsoft/wml-2010.xsd",

        # Microsoft versioned extensions
        "http://schemas.microsoft.com/office/word/2010/wordml" =>
          "microsoft/wml-2010.xsd",
        "http://schemas.microsoft.com/office/word/2012/wordml" =>
          "microsoft/wml-2012.xsd",
        "http://schemas.microsoft.com/office/word/2015/wordml/symex" =>
          "microsoft/wml-symex-2015.xsd",
        "http://schemas.microsoft.com/office/word/2016/wordml/cid" =>
          "microsoft/wml-cid-2016.xsd",
        "http://schemas.microsoft.com/office/word/2018/wordml" =>
          "microsoft/wml-2018.xsd",
        "http://schemas.microsoft.com/office/word/2018/wordml/cex" =>
          "microsoft/wml-cex-2018.xsd",
        "http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash" =>
          "microsoft/wml-sdtdatahash-2020.xsd",

        # Markup Compatibility
        "http://schemas.openxmlformats.org/markup-compatibility/2006" =>
          "mce/mc.xsd",

        # OPC schemas
        "http://schemas.openxmlformats.org/package/2006/content-types" =>
          "ecma/opc-contentTypes.xsd",
        "http://schemas.openxmlformats.org/package/2006/relationships" =>
          "ecma/opc-relationships.xsd",
      }.freeze

      # Parts that use WordprocessingML schemas
      WORDML_PARTS = %w[
        word/document.xml
        word/styles.xml
        word/settings.xml
        word/fontTable.xml
        word/numbering.xml
        word/footnotes.xml
        word/endnotes.xml
        word/comments.xml
      ].freeze

      # Pattern for header/footer parts
      HEADER_FOOTER_PATTERN = %r{\Aword/(header|footer)\d*\.xml\z}

      # Pattern for theme parts
      THEME_PATTERN = %r{\Aword/theme/theme\d+\.xml\z}

      # Pattern for relationship parts
      RELS_PATTERN = %r{_rels/.*\.rels\z}

      attr_reader :schemas_dir

      def initialize(schemas_dir: nil)
        @schemas_dir = schemas_dir || default_schemas_dir
        @moxml = Moxml.new(:nokogiri)
        @schema_cache = {}
      end

      # Detect namespace URIs from XML content.
      #
      # @param xml_content [String] Raw XML
      # @return [Array<String>] Namespace URIs declared on root element
      def detect_namespaces(xml_content)
        doc = @moxml.parse(xml_content)
        doc.root.namespaces.map(&:uri)
      rescue StandardError => e
        Uniword.logger&.debug { "Namespace detection failed: #{e.message}" }
        []
      end

      # Detect mc:Ignorable prefixes from XML content.
      #
      # @param xml_content [String] Raw XML
      # @return [Array<String>] Namespace prefixes listed in mc:Ignorable
      def detect_ignorable(xml_content)
        doc = @moxml.parse(xml_content)
        root = doc.root
        ignorable = root["Ignorable"] ||
          root["mc:Ignorable"]
        return [] unless ignorable

        ignorable.split(/\s+/).reject(&:empty?)
      rescue StandardError => e
        Uniword.logger&.debug { "Ignorable detection failed: #{e.message}" }
        []
      end

      # Determine the primary XSD schema for a given XML part.
      #
      # For Word parts (document.xml, styles.xml, etc.), returns wml-2010.xsd
      # which imports the base wml.xsd and all extension schemas.
      # For relationship and content type parts, returns the appropriate schema.
      #
      # @param part_name [String] Path within ZIP (e.g., "word/document.xml")
      # @return [String, nil] XSD path relative to schemas_dir
      def primary_schema_for_part(part_name)
        case part_name
        when "[Content_Types].xml"
          "ecma/opc-contentTypes.xsd"
        when "_rels/.rels", ->(n) { n.match?(RELS_PATTERN) }
          "ecma/opc-relationships.xsd"
        when *WORDML_PARTS, ->(n) { n.match?(HEADER_FOOTER_PATTERN) }
          "microsoft/wml-2010.xsd"
        when ->(n) { n.match?(THEME_PATTERN) }
          "iso/dml-main.xsd"
        end
      end

      # Load and cache an XSD schema for validation.
      #
      # @param xsd_relative_path [String] Path relative to schemas_dir
      # @return [Nokogiri::XML::Schema] Compiled schema
      def load_schema(xsd_relative_path)
        return @schema_cache[xsd_relative_path] if @schema_cache.key?(xsd_relative_path)

        xsd_path = File.join(schemas_dir, xsd_relative_path)
        unless File.exist?(xsd_path)
          raise ArgumentError,
                "XSD schema not found: #{xsd_path}"
        end

        # Nokogiri::XML::Schema resolves relative imports from CWD.
        # We chdir to the schema file's own directory so imports like
        # "word12.xsd" (from microsoft/wml-2010.xsd) resolve correctly.
        schema = nil
        original_dir = Dir.pwd
        schema_dir = File.dirname(xsd_path)
        begin
          Dir.chdir(schema_dir)
          schema = Nokogiri::XML::Schema(File.read(File.basename(xsd_path)))
        ensure
          Dir.chdir(original_dir)
        end

        @schema_cache[xsd_relative_path] = schema
        schema
      end

      # Map namespace URIs to their corresponding XSD files.
      #
      # @param ns_uris [Array<String>] Namespace URIs to look up
      # @return [Hash<String, String>] { uri => xsd_relative_path }
      def xsd_map_for_namespaces(ns_uris)
        result = {}
        ns_uris.each do |uri|
          xsd = NAMESPACE_XSD_MAP[uri]
          result[uri] = xsd if xsd
        end
        result
      end

      # Check if a namespace URI has a known XSD schema.
      #
      # @param uri [String] Namespace URI
      # @return [Boolean]
      def known_namespace?(uri)
        NAMESPACE_XSD_MAP.key?(uri)
      end

      # Return unknown namespace URIs from a set.
      #
      # @param ns_uris [Array<String>] Namespace URIs to check
      # @return [Array<String>] URIs with no bundled XSD
      def unknown_namespaces(ns_uris)
        ns_uris.reject { |uri| known_namespace?(uri) }
      end

      private

      def default_schemas_dir
        File.join(File.dirname(__FILE__), "..", "..", "..", "data", "schemas")
      end
    end
  end
end
