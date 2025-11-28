# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Repeating section content control
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:repeatingSection>
      class RepeatingSection < Lutaml::Model::Serializable
          attribute :section_title, String
          attribute :do_not_allow_insert_delete_section, String

          xml do
            root 'repeatingSection'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :section_title
            map_attribute 'true', to: :do_not_allow_insert_delete_section
          end
      end
    end
  end
end
