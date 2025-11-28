# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Shape defaults
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:shapedefaults>
      class ShapeDefaults < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :spidmax, String
          attribute :fill, String
          attribute :stroke, String

          xml do
            root 'shapedefaults'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'
            mixed_content

            map_attribute 'true', to: :ext
            map_attribute 'true', to: :spidmax
            map_element 'fill', to: :fill, render_nil: false
            map_element 'stroke', to: :stroke, render_nil: false
          end
      end
    end
  end
end
