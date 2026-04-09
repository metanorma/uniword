# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Line break within text
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:br>
    class Break < Lutaml::Model::Serializable
      attribute :type, :string

      xml do
        element 'br'
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute 'type', to: :type
      end
    end
  end
end
