# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Shape layout settings
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:shapelayout>
    class VmlShapeLayout < Lutaml::Model::Serializable
      attribute :ext, String
      attribute :idmap, String

      xml do
        element 'shapelayout'
        namespace Uniword::Ooxml::Namespaces::Vml
        mixed_content

        map_attribute 'ext', to: :ext
        map_element 'idmap', to: :idmap, render_nil: false
      end
    end
  end
end
