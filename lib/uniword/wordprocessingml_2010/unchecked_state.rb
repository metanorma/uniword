# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Unchecked state symbol definition
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:uncheckedState>
    class UncheckedState < Lutaml::Model::Serializable
      attribute :font, :string
      attribute :val, :string

      xml do
        element "uncheckedState"
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute "font", to: :font
        map_attribute "val", to: :val
      end
    end
  end
end
