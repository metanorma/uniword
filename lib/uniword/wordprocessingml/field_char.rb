# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Field character marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:fldChar>
      class FieldChar < Lutaml::Model::Serializable
          attribute :fldCharType, :string
          attribute :dirty, :boolean

          xml do
            element 'fldChar'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'fldCharType', to: :fldCharType
            map_attribute 'dirty', to: :dirty
          end
      end
    end
end
