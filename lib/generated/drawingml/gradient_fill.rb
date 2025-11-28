# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Gradient fill container
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:gradFill>
      class GradientFill < Lutaml::Model::Serializable
          attribute :gs_lst, GradientStopList
          attribute :lin, LinearGradient
          attribute :path, PathGradient

          xml do
            root 'gradFill'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'gsLst', to: :gs_lst
            map_element 'lin', to: :lin, render_nil: false
            map_element 'path', to: :path, render_nil: false
          end
      end
    end
  end
end
