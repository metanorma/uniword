# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # WordprocessingGroup namespace for shape groups in DrawingML
  # Namespace: http://schemas.microsoft.com/office/word/2010/wordprocessingGroup
  # Prefix: wpg
  module WordprocessingGroup
    # Group shape container
    # Contains wps:wsp (WordprocessingShape) elements
    class Group < Lutaml::Model::Serializable
      attribute :c_nv_grp_sp_pr, Lutaml::Model::Serializable
      attribute :grp_sp_pr, Lutaml::Model::Serializable
      attribute :shapes, Uniword::WordprocessingShape::WordprocessingShape, collection: true,
                                                                            initialize_empty: true

      xml do
        root 'wgp'
        namespace Uniword::Ooxml::Namespaces::WordprocessingGroup
        mixed_content

        map_element 'cNvGrpSpPr', to: :c_nv_grp_sp_pr, render_nil: false
        map_element 'grpSpPr', to: :grp_sp_pr, render_nil: false
        map_element 'wsp', to: :shapes, render_nil: false
      end
    end
  end
end
