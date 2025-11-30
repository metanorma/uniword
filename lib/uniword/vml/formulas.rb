# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML formula definitions for shape geometry
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:formulas>
      class Formulas < Lutaml::Model::Serializable
        attribute :formulas, String, collection: true, default: -> { [] }

        xml do
          element 'formulas'
          namespace Uniword::Ooxml::Namespaces::Vml
          mixed_content

          map_element 'f', to: :formulas, render_nil: false
        end
      end
    end
  end
end
