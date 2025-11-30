# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Entity picker content control
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:entityPicker>
    class EntityPicker < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'entityPicker'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'val', to: :val
      end
    end
  end
end
