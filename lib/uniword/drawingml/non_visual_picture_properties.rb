# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Non-Visual Picture Properties
    #
    # Complex type for non-visual picture drawing properties.
    class NonVisualPictureProperties < Lutaml::Model::Serializable
      attribute :prefer_relative_resize, :string
      attribute :pic_locks, PictureLocking
      attribute :ext_lst, OfficeArtExtensionList

      xml do
        element 'cNvPicPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'preferRelativeResize', to: :prefer_relative_resize, render_nil: false
        map_element 'picLocks', to: :pic_locks, render_nil: false
        map_element 'extLst', to: :ext_lst, render_nil: false
      end
    end
  end
end
