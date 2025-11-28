# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Shape layout
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:shapelayout>
      class ShapeLayout < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :idmap, String

          xml do
            root 'shapelayout'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'
            mixed_content

            map_attribute 'true', to: :ext
            map_element 'idmap', to: :idmap, render_nil: false
          end
      end
    end
  end
end
