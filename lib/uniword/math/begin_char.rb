# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Beginning delimiter character
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:begChr>
    class BeginChar < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "begChr"
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute "val", to: :val
      end
    end
  end
end
