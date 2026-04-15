# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Symbol character
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:sym>
    class Symbol < Lutaml::Model::Serializable
      attribute :font, :string
      attribute :char, :string

      xml do
        element "sym"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "font", to: :font
        map_attribute "char", to: :char
      end
    end
  end
end
