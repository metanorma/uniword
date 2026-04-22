# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Field instruction text
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:instrText>
    class InstrText < Lutaml::Model::Serializable
      attribute :text, :string
      attribute :xml_space, :string

      xml do
        element "instrText"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "xml:space", to: :xml_space
        map_element "text", to: :text, render_nil: false
      end

      def initialize(attrs = {})
        if attrs[:text].is_a?(String) && (attrs[:text].start_with?(" ") || attrs[:text].end_with?(" ") || attrs[:text].include?("\t"))
          attrs[:xml_space] =
            "preserve"
        end
        super
      end
    end
  end
end
