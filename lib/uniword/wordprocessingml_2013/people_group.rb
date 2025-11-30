# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2013
      # Group of people for collaborative editing
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:peopleGroup>
      class PeopleGroup < Lutaml::Model::Serializable
          attribute :group_id, String
          attribute :people, String

          xml do
            element 'peopleGroup'
            namespace Uniword::Ooxml::Namespaces::Word2012
            mixed_content

            map_attribute 'group-id', to: :group_id
            map_element 'people', to: :people, render_nil: false
          end
      end
    end
end
