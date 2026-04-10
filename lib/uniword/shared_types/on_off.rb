# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module SharedTypes
    # Boolean on/off type used throughout OOXML
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:on_off>
    class OnOff < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement

      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'on_off'
        namespace Uniword::Ooxml::Namespaces::SharedTypes
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
