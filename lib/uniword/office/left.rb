# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Left position
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:left>
    class Left < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'left'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'value', to: :value
      end
    end
  end
end
