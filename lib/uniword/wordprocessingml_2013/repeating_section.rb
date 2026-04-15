# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2013
    # Repeating section content control
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:repeatingSection>
    class RepeatingSection < Lutaml::Model::Serializable
      attribute :section_title, :string
      attribute :do_not_allow_insert_delete_section, :string

      xml do
        element "repeatingSection"
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute "section-title", to: :section_title
        map_attribute "do-not-allow-insert-delete-section",
                      to: :do_not_allow_insert_delete_section
      end
    end
  end
end
