# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Pattern fill
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:pattFill>
    class PatternFill < Lutaml::Model::Serializable
      attribute :prst, :string
      attribute :fg_clr, :string
      attribute :bg_clr, :string

      xml do
        element 'pattFill'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_attribute 'prst', to: :prst
        map_element 'fgClr', to: :fg_clr, render_nil: false
        map_element 'bgClr', to: :bg_clr, render_nil: false
      end
    end
  end
end
