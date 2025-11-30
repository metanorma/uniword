# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # Shape layout
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:shapelayout>
      class ShapeLayout < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :idmap, String

          xml do
            element 'shapelayout'
            namespace Uniword::Ooxml::Namespaces::Office
            mixed_content

            map_attribute 'ext', to: :ext
            map_element 'idmap', to: :idmap, render_nil: false
          end
      end
    end
end
