# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Font reference
    #
    # Element: <a:fontRef>
    class FontReference < Lutaml::Model::Serializable
      attribute :idx, :string
      attribute :scheme_clr, SchemeColor

      xml do
        element "fontRef"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "idx", to: :idx
        map_element "schemeClr", to: :scheme_clr, render_nil: false
      end
    end
  end
end
