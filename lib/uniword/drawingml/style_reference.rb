# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Style reference with index and color
    #
    # Elements: <a:lnRef>, <a:fillRef>, <a:effectRef>
    class StyleReference < Lutaml::Model::Serializable
      attribute :idx, :integer
      attribute :scheme_clr, SchemeColor

      xml do
        element 'styleRef'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_attribute 'idx', to: :idx
        map_element 'schemeClr', to: :scheme_clr, render_nil: false
      end
    end
  end
end