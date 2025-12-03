# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math text content
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:t>
    class MathText < Lutaml::Model::Serializable
      # Pattern 0: Attribute BEFORE xml mapping
      attribute :value, :string

      xml do
        element 't'
        namespace Uniword::Ooxml::Namespaces::MathML

        map_content to: :value
      end
    end
  end
end
