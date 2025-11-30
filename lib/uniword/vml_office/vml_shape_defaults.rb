# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Default shape properties for VML
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:shapedefaults>
    class VmlShapeDefaults < Lutaml::Model::Serializable
      attribute :ext, String
      attribute :spidmax, String
      attribute :fill, String
      attribute :stroke, String
      attribute :textbox, String

      xml do
        element 'shapedefaults'
        namespace Uniword::Ooxml::Namespaces::Vml
        mixed_content

        map_attribute 'ext', to: :ext
        map_attribute 'spidmax', to: :spidmax
        map_element 'fill', to: :fill, render_nil: false
        map_element 'stroke', to: :stroke, render_nil: false
        map_element 'textbox', to: :textbox, render_nil: false
      end
    end
  end
end
