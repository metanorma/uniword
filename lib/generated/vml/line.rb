# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML line shape
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:line>
      class Line < Lutaml::Model::Serializable
          attribute :id, String
          attribute :style, String
          attribute :from, String
          attribute :to, String
          attribute :strokecolor, String
          attribute :strokeweight, String
          attribute :stroke, String

          xml do
            root 'line'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :style
            map_attribute 'true', to: :from
            map_attribute 'true', to: :to
            map_attribute 'true', to: :strokecolor
            map_attribute 'true', to: :strokeweight
            map_element '', to: :stroke, render_nil: false
          end
      end
    end
  end
end
