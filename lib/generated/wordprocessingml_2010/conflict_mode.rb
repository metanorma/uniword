# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Conflict resolution mode
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:conflictMode>
      class ConflictMode < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'conflictMode'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
