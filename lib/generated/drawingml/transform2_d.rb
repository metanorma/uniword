# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # 2D transformation
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:xfrm>
      class Transform2D < Lutaml::Model::Serializable
          attribute :false, Offset
          attribute :ext, Extents

          xml do
            root 'xfrm'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'false', to: :false, render_nil: false
            map_element 'ext', to: :ext, render_nil: false
          end
      end
    end
  end
end
