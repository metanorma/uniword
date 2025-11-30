# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Specularity value
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:specularity>
    class Specularity < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'specularity'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'value', to: :value
      end
    end
  end
end
