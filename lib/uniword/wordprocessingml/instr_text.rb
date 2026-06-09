# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Field instruction text
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:instrText>
    class InstrText < Lutaml::Model::Serializable
      attribute :content, :string, collection: true, initialize_empty: true
      attribute :xml_space, :string

      xml do
        element "instrText"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_content to: :content
        map_attribute "xml:space", to: :xml_space
      end

      def initialize(attrs = {})
        if attrs.is_a?(Hash)
          text_val = attrs.delete(:text) || attrs[:content]
          if text_val.is_a?(String)
            attrs[:xml_space] = "preserve" if Text.preserve_whitespace?(text_val)
            attrs[:content] = [text_val] unless attrs.key?(:content)
          end
        end
        super
      end

      def text
        content&.join
      end

      def text=(value)
        self.content = value.is_a?(Array) ? value : [value.to_s]
      end

      def to_s
        text.to_s
      end
    end
  end
end
