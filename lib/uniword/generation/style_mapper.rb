# frozen_string_literal: true

require "yaml"

module Uniword
  module Generation
    # Maps semantic element types to OOXML style names.
    #
    # Loads mapping configuration from YAML files and provides lookup
    # for style names based on semantic element types (e.g., heading_1
    # maps to "Heading1" in ISO Publication style).
    #
    # @example Create mapper with ISO config
    #   mapper = StyleMapper.new("config/style_mappings/iso_publication.yml")
    #   mapper.style_for("heading_1")  # => "Heading1"
    #   mapper.style_for("body")       # => "Body Text"
    class StyleMapper
      DEFAULT_MAPPING = {
        "heading_1" => "Heading1",
        "heading_2" => "Heading2",
        "heading_3" => "Heading3",
        "heading_4" => "Heading4",
        "heading_5" => "Heading5",
        "heading_6" => "Heading6",
        "body" => "Normal",
        "note" => "Note",
        "example" => "Example",
        "table_title" => "TableTitle",
        "figure_title" => "FigureTitle",
      }.freeze

      # Initialize with a mapping config path.
      #
      # @param mapping_config [String, nil] Path to YAML mapping file.
      #   Falls back to DEFAULT_MAPPING when nil.
      def initialize(mapping_config = nil)
        @mapping = if mapping_config && File.exist?(mapping_config)
                     load_mapping(mapping_config)
                   else
                     DEFAULT_MAPPING.dup
                   end
      end

      # Look up the OOXML style name for a semantic element type.
      #
      # @param element_type [String] Semantic element type
      #   (e.g., "heading_1", "body", "note")
      # @param context [Hash] Optional context for disambiguation
      # @return [String] OOXML style name
      def style_for(element_type, context = {})
        @mapping[element_type.to_s] || default_for(element_type)
      end

      # Default paragraph style name.
      #
      # @return [String] The default body style name
      def default_paragraph_style
        @mapping["body"] || "Normal"
      end

      # All loaded mappings.
      #
      # @return [Hash] The full mapping hash
      def mappings
        @mapping.dup
      end

      private

      def load_mapping(path)
        data = YAML.safe_load(File.read(path))
        return DEFAULT_MAPPING.dup unless data.is_a?(Hash)
        return DEFAULT_MAPPING.dup unless data["mappings"]

        DEFAULT_MAPPING.merge(data["mappings"])
      end

      def default_for(element_type)
        key = element_type.to_s
        if key.start_with?("heading_")
          level = key.sub("heading_", "")
          "Heading#{level}"
        else
          default_paragraph_style
        end
      end
    end
  end
end
