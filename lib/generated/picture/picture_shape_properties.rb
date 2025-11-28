# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Picture shape properties
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:spPr>
      class PictureShapeProperties < Lutaml::Model::Serializable
          attribute :xfrm, String
          attribute :ln, String

          xml do
            root 'spPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'
            mixed_content

            map_element 'xfrm', to: :xfrm, render_nil: false
            map_element 'ln', to: :ln, render_nil: false
          end
      end
    end
  end
end
