# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Mhtml
    # MHTML-specific Theme class
    #
    # This is SEPARATE from OOXML DrawingML Theme.
    # MHTML uses HTML/CSS for styling, not OOXML theme parts.
    #
    # This class represents theme information extracted from MHTML documents
    # and provides HTML/CSS output for MHTML serialization.
    class Theme < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :colors, :hash, default: -> { {} }
      attribute :fonts, :hash, default: -> { {} }

      # MHTML-specific: Convert theme to CSS variables
      #
      # @return [String] CSS with theme variables
      def to_css
        css = +""
        colors.each do |name, value|
          css << "--#{name}: #{value};\n"
        end
        fonts.each do |name, value|
          css << "--font-#{name}: #{value};\n"
        end
        css
      end

      # MHTML-specific: Get theme color for CSS
      #
      # @param name [String] Color name
      # @return [String, nil] Color value
      def color(name)
        colors[name.to_s]
      end

      # MHTML-specific: Get theme font for CSS
      #
      # @param name [String] Font name
      # @return [String, nil] Font family
      def font(name)
        fonts[name.to_s]
      end
    end
  end
end
