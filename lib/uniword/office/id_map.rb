# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # ID mapping
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:idmap>
    class IdMap < Lutaml::Model::Serializable
      attribute :ext, String
      attribute :data, String

      xml do
        element 'idmap'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'ext', to: :ext
        map_attribute 'data', to: :data
      end
    end
  end
end
