# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML group shape
    #
    # Element: <grpSp>
    class GvmlGroupShape < Lutaml::Model::Serializable
      attribute :nv_grp_sp_pr, GvmlGroupShapeNonVisual
      attribute :grp_sp_pr, GroupShapeProperties
      attribute :tx_sp, GvmlTextShape, collection: true
      attribute :sp, GvmlShape, collection: true
      attribute :cxn_sp, GvmlConnector, collection: true
      attribute :pic, GvmlPicture, collection: true
      attribute :graphic_frame, GvmlGraphicalObjectFrame, collection: true
      attribute :grp_sp, :self, collection: true

      xml do
        element 'grpSp'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'nvGrpSpPr', to: :nv_grp_sp_pr, render_nil: false
        map_element 'grpSpPr', to: :grp_sp_pr, render_nil: false
        map_element 'txSp', to: :tx_sp, render_nil: false
        map_element 'sp', to: :sp, render_nil: false
        map_element 'cxnSp', to: :cxn_sp, render_nil: false
        map_element 'pic', to: :pic, render_nil: false
        map_element 'graphicFrame', to: :graphic_frame, render_nil: false
        map_element 'grpSp', to: :grp_sp, render_nil: false
      end
    end
  end
end
