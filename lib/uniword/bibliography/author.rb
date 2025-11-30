# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Author information container for bibliography sources
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:author>
      class Author < Lutaml::Model::Serializable
          attribute :name_list, NameList
          attribute :corporate, :string

          xml do
            element 'author'
            namespace Uniword::Ooxml::Namespaces::Bibliography
            mixed_content

            map_element 'NameList', to: :name_list, render_nil: false
            map_element 'Corporate', to: :corporate, render_nil: false
          end
      end
    end
end
