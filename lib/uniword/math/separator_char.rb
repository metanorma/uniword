# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Separator delimiter character
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:sepChr>
    class SeparatorChar < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'sepChr'
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute 'val', to: :val
      end
    end
  end
end
