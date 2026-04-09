# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module SharedTypes
    # Vertical alignment enumeration
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:vertical_alignment>
    class VerticalAlignment < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'vertical_alignment'
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute 'val', to: :val
      end
    end
  end
end
