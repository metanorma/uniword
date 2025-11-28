# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Custom XML conflict insertion
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:customXmlConflictIns>
      class CustomXmlConflictInsertion < Lutaml::Model::Serializable
          attribute :id, String
          attribute :uri, String

          xml do
            root 'customXmlConflictIns'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :uri
          end
      end
    end
  end
end
