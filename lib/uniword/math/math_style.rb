# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math style wrapper
    #
    # Element: <m:sty>
    class MathStyle < Lutaml::Model::Serializable
      # Pattern 0: Attribute BEFORE xml mapping
      attribute :value, :string

      xml do
        element 'sty'
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute 'val', to: :value
      end
    end
  end
end