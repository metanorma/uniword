# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Bibliography
      # List of individual author names
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:name_list>
      class NameList < Lutaml::Model::Serializable
          attribute :person, Person, collection: true, default: -> { [] }

          xml do
            root 'name_list'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography', 'b'
            mixed_content

            map_element 'Person', to: :person, render_nil: false
          end
      end
    end
  end
end
