# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Picture Locking
    #
    # Complex type for picture locking properties.
    class PictureLocking < Lutaml::Model::Serializable
      attribute :no_grp, :string
      attribute :no_select, :string
      attribute :no_rot, :string
      attribute :no_change_aspect, :string
      attribute :no_move, :string
      attribute :no_resize, :string
      attribute :no_crop, :string
      attribute :ext_lst, OfficeArtExtensionList

      xml do
        element 'picLocks'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'noGrp', to: :no_grp, render_nil: false
        map_attribute 'noSelect', to: :no_select, render_nil: false
        map_attribute 'noRot', to: :no_rot, render_nil: false
        map_attribute 'noChangeAspect', to: :no_change_aspect, render_nil: false
        map_attribute 'noMove', to: :no_move, render_nil: false
        map_attribute 'noResize', to: :no_resize, render_nil: false
        map_attribute 'noCrop', to: :no_crop, render_nil: false
        map_element 'extLst', to: :ext_lst, render_nil: false
      end
    end
  end
end
