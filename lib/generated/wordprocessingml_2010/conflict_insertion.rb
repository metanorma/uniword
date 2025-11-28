# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Conflict insertion marker
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:conflictIns>
      class ConflictInsertion < Lutaml::Model::Serializable
          attribute :id, String
          attribute :author, String
          attribute :date, String

          xml do
            root 'conflictIns'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :author
            map_attribute 'true', to: :date
          end
      end
    end
  end
end
