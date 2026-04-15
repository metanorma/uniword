# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Mhtml
    # MHTML-specific Styles Configuration class
    #
    # This is SEPARATE from OOXML WordprocessingML StylesConfiguration.
    # MHTML uses HTML/CSS for styling, not OOXML style parts.
    #
    # This class manages style definitions for MHTML documents
    # and provides CSS output for MHTML serialization.
    class StylesConfiguration < Lutaml::Model::Serializable
      attribute :styles, :hash, default: -> { {} }
      attribute :css_classes, :hash, default: -> { {} }

      # MHTML-specific: Convert styles to CSS
      #
      # @return [String] CSS stylesheet content
      def to_css
        css = +""
        styles.each do |name, properties|
          css << ".#{name} {\n"
          properties.each do |prop, value|
            css << "  #{prop_to_css(prop)}: #{value};\n"
          end
          css << "}\n\n"
        end
        css
      end

      # MHTML-specific: Get style by name
      #
      # @param name [String] Style name
      # @return [Hash, nil] Style properties
      def style(name)
        styles[name.to_s]
      end

      # MHTML-specific: Add a style
      #
      # @param name [String] Style name
      # @param properties [Hash] CSS properties
      def add_style(name, properties)
        styles[name.to_s] = properties
      end

      private

      # Convert Ruby-style property to CSS property
      def prop_to_css(prop)
        prop.to_s.gsub("_", "-")
      end
    end
  end
end
