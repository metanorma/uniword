# frozen_string_literal: true

module Uniword
  module Drawingml
      # Represents object defaults in a theme (DrawingML)
      #
      # This element is typically empty in most themes.
      class ObjectDefaults < Lutaml::Model::Serializable
        attribute :ln_def, Drawingml::LineDefaults
        attribute :sp_def, Drawingml::ShapeDefaults
        attribute :tx_def, Drawingml::TextDefaults

        xml do
          element 'objectDefaults'
          namespace Ooxml::Namespaces::DrawingML

          map_element 'lnDef', to: :ln_def, render_nil: false
          map_element 'spDef', to: :sp_def, render_nil: false
          map_element 'txDef', to: :tx_def, render_nil: false
        end
      end
  end
end
