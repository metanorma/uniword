# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Top position
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:top>
    class Top < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'top'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'value', to: :value
      end
    end
  end
end
