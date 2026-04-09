# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Right position
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:right>
    class Right < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'right'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'value', to: :value
      end
    end
  end
end
