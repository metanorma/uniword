# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Pattern fill
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:pattFill>
      class PatternFill < Lutaml::Model::Serializable
          attribute :prst, String
          attribute :fg_clr, String
          attribute :bg_clr, String

          xml do
            root 'pattFill'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_attribute 'true', to: :prst
            map_element 'fgClr', to: :fg_clr, render_nil: false
            map_element 'bgClr', to: :bg_clr, render_nil: false
          end
      end
    end
  end
end
