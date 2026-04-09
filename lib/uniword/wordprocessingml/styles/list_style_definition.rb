# frozen_string_literal: true


module Uniword
  module Styles
    # List style definition
    #
    # Responsibility: Hold list-specific style properties
    # Single Responsibility: List style configuration only
    #
    # Defines formatting properties for lists including numbering
    # format, bullet characters, and level-specific formatting.
    class ListStyleDefinition < StyleDefinition
      attr_reader :numbering_definition, :levels

      def initialize(config)
        super
        @numbering_definition = config[:numbering_definition]
        @levels = config[:levels] || []
      end

      # Get level definition by level number
      #
      # @param level_num [Integer] The level number (0-based)
      # @return [Hash] Level definition
      def level(level_num)
        @levels[level_num] || @levels.first || {}
      end

      # Resolve inherited properties for lists
      #
      # @param library [StyleLibrary] The style library to resolve base styles from
      # @return [Hash] Merged properties including base style properties
      def resolve_inheritance(library = nil)
        return full_properties unless @base_style && library

        base_def = library.list_style(@base_style)
        base_props = base_def.resolve_inheritance(library)

        {
          numbering_definition: @numbering_definition || base_props[:numbering_definition],
          levels: merge_levels(base_props[:levels], @levels)
        }
      end

      # Get all properties
      #
      # @return [Hash] All style properties
      def full_properties
        {
          numbering_definition: @numbering_definition,
          levels: @levels
        }
      end

      protected

      def style_type
        :list_style
      end

      # Merge base levels with override levels
      #
      # @param base [Array] Base level definitions
      # @param override [Array] Override level definitions
      # @return [Array] Merged level definitions
      def merge_levels(base, override)
        return override if override && !override.empty?
        return base if base

        []
      end
    end
  end
end
