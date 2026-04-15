# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Style matrix containing style references
    #
    # Element: <a:style>
    class StyleMatrix < Lutaml::Model::Serializable
      attribute :ln_ref, StyleReference
      attribute :fill_ref, StyleReference
      attribute :effect_ref, StyleReference
      attribute :font_ref, FontReference

      xml do
        element "style"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element "lnRef", to: :ln_ref, render_nil: false
        map_element "fillRef", to: :fill_ref, render_nil: false
        map_element "effectRef", to: :effect_ref, render_nil: false
        map_element "fontRef", to: :font_ref, render_nil: false
      end
    end
  end
end
