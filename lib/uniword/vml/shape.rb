# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML shape element
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:shape>
      class Shape < Lutaml::Model::Serializable
        attribute :id, String
        attribute :type, String
        attribute :style, String
        attribute :fillcolor, String
        attribute :strokecolor, String
        attribute :strokeweight, String
        attribute :coordsize, String
        attribute :coordorigin, String
        attribute :path, String
        attribute :fill, String
        attribute :stroke, String
        attribute :textbox, String
        attribute :imagedata, String

        xml do
          element 'shape'
          namespace Uniword::Ooxml::Namespaces::Vml

          map_attribute 'id', to: :id
          map_attribute 'type', to: :type
          map_attribute 'style', to: :style
          map_attribute 'fillcolor', to: :fillcolor
          map_attribute 'strokecolor', to: :strokecolor
          map_attribute 'strokeweight', to: :strokeweight
          map_attribute 'coordsize', to: :coordsize
          map_attribute 'coordorigin', to: :coordorigin
          map_attribute 'path', to: :path
          map_element '', to: :fill, render_nil: false
          map_element '', to: :stroke, render_nil: false
          map_element '', to: :textbox, render_nil: false
          map_element '', to: :imagedata, render_nil: false
        end
      end
    end
  end
end
