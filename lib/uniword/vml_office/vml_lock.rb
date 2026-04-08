# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Shape lock for VML
    #
    # Element: <o:lock>
    class VmlLock < Lutaml::Model::Serializable
      attribute :v_ext, :string
      attribute :rotation, :string
      attribute :cropping, :string
      attribute :text, :string
      attribute :groupstatus, :string
      attribute :ungrouping, :string
      attribute :selection, :string
      attribute :changeaspect, :string
      attribute :shapesize, :string

      xml do
        element 'lock'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'v:ext', to: :v_ext
        map_attribute 'rotation', to: :rotation
        map_attribute 'cropping', to: :cropping
        map_attribute 'text', to: :text
        map_attribute 'groupstatus', to: :groupstatus
        map_attribute 'ungrouping', to: :ungrouping
        map_attribute 'selection', to: :selection
        map_attribute 'changeaspect', to: :changeaspect
        map_attribute 'shapesize', to: :shapesize
      end
    end
  end
end
