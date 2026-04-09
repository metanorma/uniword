# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML path definition
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:path>
    class Path < Lutaml::Model::Serializable
      attribute :v, :string
      attribute :textpathok, :string
      attribute :fillok, :string
      attribute :strokeok, :string

      xml do
        element 'path'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'v', to: :v
        map_attribute 'textpathok', to: :textpathok
        map_attribute 'fillok', to: :fillok
        map_attribute 'strokeok', to: :strokeok
      end
    end
  end
end
