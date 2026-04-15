# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Shape defaults
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:shapedefaults>
    class ShapeDefaults < Lutaml::Model::Serializable
      attribute :ext, :string
      attribute :spidmax, :string
      attribute :fill, :string
      attribute :stroke, :string

      xml do
        element "shapedefaults"
        namespace Uniword::Ooxml::Namespaces::Office
        mixed_content

        map_attribute "ext", to: :ext
        map_attribute "spidmax", to: :spidmax
        map_element "fill", to: :fill, render_nil: false
        map_element "stroke", to: :stroke, render_nil: false
      end
    end
  end
end
