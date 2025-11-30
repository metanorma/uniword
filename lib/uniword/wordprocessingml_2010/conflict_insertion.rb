# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'conflictIns'
            namespace Uniword::Ooxml::Namespaces::Word2010

            map_attribute 'id', to: :id
            map_attribute 'author', to: :author
            map_attribute 'date', to: :date
          end
      end
    end
end
