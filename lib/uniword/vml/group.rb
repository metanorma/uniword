# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML shape group container
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:group>
    class Group < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :coordsize, :string
      attribute :coordorigin, :string
      attribute :shapes, Shape, collection: true, initialize_empty: true

      xml do
        element 'group'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'id', to: :id
        map_attribute 'style', to: :style
        map_attribute 'coordsize', to: :coordsize
        map_attribute 'coordorigin', to: :coordorigin
        map_element 'shape', to: :shapes, render_nil: false
      end
    end
  end
end
