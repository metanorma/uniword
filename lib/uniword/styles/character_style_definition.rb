# frozen_string_literal: true

require_relative 'style_definition'

module Uniword
  module Styles
    # Character (run) style definition
    #
    # Responsibility: Hold character-specific style properties
    # Single Responsibility: Character style configuration only
    #
    # Defines formatting properties for text runs including font,
    # size, color, bold, italic, underline, etc.
    class CharacterStyleDefinition < StyleDefinition
      attr_reader :run_properties

      def initialize(config)
        super
        @run_properties = config[:run_properties] || {}
      end

      # Resolve inherited run properties
      #
      # @param library [StyleLibrary] The style library to resolve base styles from
      # @return [Hash] Merged run properties including base style properties
      def resolve_inheritance(library = nil)
        return @run_properties unless @base_style && library

        base_def = library.character_style(@base_style)
        base_props = base_def.resolve_inheritance(library)

        merge_properties(base_props, @run_properties)
      end

      # Character styles don't have paragraph properties
      def properties
        {}
      end

      protected

      def style_type
        :character_style
      end
    end
  end
end
