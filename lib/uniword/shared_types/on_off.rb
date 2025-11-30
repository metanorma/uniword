# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module SharedTypes
    # Boolean on/off type used throughout OOXML
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:on_off>
    class OnOff < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'on_off'
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute 'val', to: :val
      end
    end
  end
end
