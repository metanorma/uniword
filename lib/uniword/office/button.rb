# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Button control
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:button>
    class Button < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :value, :string
      attribute :caption, :string

      xml do
        element 'button'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'type', to: :type
        map_attribute 'value', to: :value
        map_attribute 'caption', to: :caption
      end
    end
  end
end
