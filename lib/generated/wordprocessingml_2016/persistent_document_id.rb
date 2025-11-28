# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2016
      # Persistent document identifier for tracking across sessions
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:persistentDocumentId>
      class PersistentDocumentId < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'persistentDocumentId'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
