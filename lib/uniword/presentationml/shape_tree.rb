# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Container for all shapes and content on a slide
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:sp_tree>
    class ShapeTree < Lutaml::Model::Serializable
      attribute :nv_grp_sp_pr, :string
      attribute :grp_sp_pr, :string
      attribute :sp, Shape, collection: true, initialize_empty: true
      attribute :grp_sp, GroupShape, collection: true, initialize_empty: true
      attribute :graphic_frame, GraphicFrame, collection: true, initialize_empty: true
      attribute :cxn_sp, ConnectionShape, collection: true, initialize_empty: true
      attribute :pic, Picture, collection: true, initialize_empty: true

      xml do
        element 'sp_tree'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'nvGrpSpPr', to: :nv_grp_sp_pr, render_nil: false
        map_element 'grpSpPr', to: :grp_sp_pr, render_nil: false
        map_element 'sp', to: :sp, render_nil: false
        map_element 'grpSp', to: :grp_sp, render_nil: false
        map_element 'graphicFrame', to: :graphic_frame, render_nil: false
        map_element 'cxnSp', to: :cxn_sp, render_nil: false
        map_element 'pic', to: :pic, render_nil: false
      end
    end
  end
end
