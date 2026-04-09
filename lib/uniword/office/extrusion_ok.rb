# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Allow extrusion flag
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:extrusionok>
    class ExtrusionOk < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'extrusionok'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'value', to: :value
      end
    end
  end
end
