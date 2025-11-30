# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Group of shapes treated as a single unit
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:grp_sp>
    class GroupShape < Lutaml::Model::Serializable
      attribute :nv_grp_sp_pr, :string
      attribute :grp_sp_pr, :string
      attribute :sp, Shape, collection: true, default: -> { [] }
      attribute :grp_sp, GroupShape, collection: true, default: -> { [] }

      xml do
        element 'grp_sp'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'nvGrpSpPr', to: :nv_grp_sp_pr
        map_element 'grpSpPr', to: :grp_sp_pr
        map_element 'sp', to: :sp, render_nil: false
        map_element 'grpSp', to: :grp_sp, render_nil: false
      end
    end
  end
end
