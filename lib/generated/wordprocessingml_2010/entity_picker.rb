# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Entity picker content control
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:entityPicker>
      class EntityPicker < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'entityPicker'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
