# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # ID mapping for shapes
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:idmap>
    class VmlIdMap < Lutaml::Model::Serializable
      attribute :ext, String
      attribute :data, String

      xml do
        element 'idmap'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'ext', to: :ext
        map_attribute 'data', to: :data
      end
    end
  end
end
