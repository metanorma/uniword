# frozen_string_literal: true

module Uniword
  module Styles
    # Base class for all style definitions
    #
    # Responsibility: Hold common style definition properties
    # Single Responsibility: Base definition structure only
    #
    # This is the base class for all style types (paragraph, character, list, table).
    # It provides common functionality for style inheritance and property management.
    class StyleDefinition
      attr_reader :name, :base_style

      def initialize(config)
        @name = config[:name]
        @base_style = config[:base_style]
        @config = config
      end

      # Resolve inherited properties from base style
      #
      # @param library [StyleLibrary] The style library to resolve base styles from
      # @return [Hash] Merged properties including base style properties
      def resolve_inheritance(library = nil)
        return properties unless @base_style && library

        base_def = library.send(style_type, @base_style)
        base_props = base_def.resolve_inheritance(library)

        merge_properties(base_props, properties)
      end

      # Get properties for this style
      #
      # @return [Hash] Style properties
      def properties
        @config[:properties] || {}
      end

      protected

      # Merge base properties with override properties
      #
      # @param base [Hash] Base properties
      # @param override [Hash] Override properties
      # @return [Hash] Merged properties
      def merge_properties(base, override)
        base.merge(override || {})
      end

      # Get the style type for this definition
      # Must be implemented by subclasses
      #
      # @return [Symbol] Style type (:paragraph_style, :character_style, etc.)
      def style_type
        raise NotImplementedError, 'Subclasses must implement style_type'
      end
    end
  end
end
