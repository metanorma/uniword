# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Character specification
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:chr>
    class Char < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "chr"
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute "val", to: :val
      end
    end
  end
end
