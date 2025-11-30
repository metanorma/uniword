# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Document settings
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:settings>
      class Settings < Lutaml::Model::Serializable
          attribute :zoom, Zoom
          attribute :compat, Compat

          xml do
            element 'settings'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'zoom', to: :zoom, render_nil: false
            map_element 'compat', to: :compat, render_nil: false
          end
      end
    end
end
