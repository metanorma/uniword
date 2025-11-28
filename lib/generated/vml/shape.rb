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
            root 'shape'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :type
            map_attribute 'true', to: :style
            map_attribute 'true', to: :fillcolor
            map_attribute 'true', to: :strokecolor
            map_attribute 'true', to: :strokeweight
            map_attribute 'true', to: :coordsize
            map_attribute 'true', to: :coordorigin
            map_attribute 'true', to: :path
            map_element '', to: :fill, render_nil: false
            map_element '', to: :stroke, render_nil: false
            map_element '', to: :textbox, render_nil: false
            map_element '', to: :imagedata, render_nil: false
          end
      end
    end
  end
end
