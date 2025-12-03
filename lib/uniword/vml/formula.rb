# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML formula for shape geometry calculations
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:f>
      class Formula < Lutaml::Model::Serializable
        # Pattern 0: Attributes BEFORE xml mappings
        attribute :eqn, :string

        xml do
          element 'f'
          namespace Uniword::Ooxml::Namespaces::Vml

          map_attribute 'eqn', to: :eqn, render_nil: false
        end
      end
    end
  end
end