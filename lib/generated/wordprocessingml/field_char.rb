# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Field character marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:fldChar>
      class FieldChar < Lutaml::Model::Serializable
          attribute :fldCharType, :string
          attribute :dirty, :boolean

          xml do
            root 'fldChar'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :fldCharType
            map_attribute 'true', to: :dirty
          end
      end
    end
  end
end
