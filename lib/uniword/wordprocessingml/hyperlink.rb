# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Hyperlink element
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:hyperlink>
      class Hyperlink < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :anchor, :string
          attribute :tooltip, :string
          attribute :runs, Run, collection: true, default: -> { [] }

          xml do
            element 'hyperlink'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_attribute 'id', to: :id
            map_attribute 'anchor', to: :anchor
            map_attribute 'tooltip', to: :tooltip
            map_element 'r', to: :runs, render_nil: false
          end
      end
    end
end
