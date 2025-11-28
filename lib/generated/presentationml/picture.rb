# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Picture element on a slide
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:pic>
      class Picture < Lutaml::Model::Serializable
          attribute :nv_pic_pr, :string
          attribute :blip_fill, :string
          attribute :sp_pr, ShapeProperties

          xml do
            root 'pic'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'nvPicPr', to: :nv_pic_pr
            map_element 'blipFill', to: :blip_fill
            map_element 'spPr', to: :sp_pr
          end
      end
    end
  end
end
