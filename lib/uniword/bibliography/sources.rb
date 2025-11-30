# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Bibliography
      # Container for all bibliography sources in the document
      #
      # Generated from OOXML schema: bibliography.yml
      # Element: <b:sources>
      class Sources < Lutaml::Model::Serializable
          attribute :selected_style, :string
          attribute :style_name, :string
          attribute :source, Source, collection: true, default: -> { [] }

          xml do
            element 'sources'
            namespace Uniword::Ooxml::Namespaces::Bibliography
            mixed_content

            map_attribute 'SelectedStyle', to: :selected_style
            map_attribute 'StyleName', to: :style_name
            map_element 'Source', to: :source, render_nil: false
          end
      end
    end
end
