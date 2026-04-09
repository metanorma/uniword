# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math font specification
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:mathFont>
    class MathFont < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'mathFont'
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute 'val', to: :val
      end
    end
  end
end
