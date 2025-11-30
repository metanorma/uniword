# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Ending delimiter character
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:endChr>
    class EndChar < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'endChr'
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute 'val', to: :val
      end
    end
  end
end
