# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Frame containing graphic objects like tables and charts
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:graphic_frame>
      class GraphicFrame < Lutaml::Model::Serializable
          attribute :nv_graphic_frame_pr, :string
          attribute :xfrm, :string
          attribute :graphic, :string

          xml do
            root 'graphic_frame'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'nvGraphicFramePr', to: :nv_graphic_frame_pr
            map_element 'xfrm', to: :xfrm
            map_element 'graphic', to: :graphic
          end
      end
    end
  end
end
