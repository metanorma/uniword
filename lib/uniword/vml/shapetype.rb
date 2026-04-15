# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML shape type definition (template)
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:shapetype>
    class Shapetype < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :coordsize, :string
      attribute :coordorigin, :string
      attribute :path, :string
      attribute :stroke, :string
      attribute :fill, :string

      xml do
        element "shapetype"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
        map_attribute "coordsize", to: :coordsize
        map_attribute "coordorigin", to: :coordorigin
        map_attribute "path", to: :path
        map_element "", to: :stroke, render_nil: false
        map_element "", to: :fill, render_nil: false
      end
    end
  end
end
