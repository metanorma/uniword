# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module SharedTypes
    # Text alignment enumeration
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:text_alignment>
    class TextAlignment < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'text_alignment'
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute 'val', to: :val
      end
    end
  end
end
