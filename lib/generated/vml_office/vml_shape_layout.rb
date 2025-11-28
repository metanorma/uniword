# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Shape layout settings
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:shapelayout>
      class VmlShapeLayout < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :idmap, String

          xml do
            root 'shapelayout'
            namespace 'urn:schemas-microsoft-com:vml', 'o'
            mixed_content

            map_attribute 'true', to: :ext
            map_element 'idmap', to: :idmap, render_nil: false
          end
      end
    end
  end
end
