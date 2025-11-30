# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Text run - inline text with formatting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:r>
      class Run < Lutaml::Model::Serializable
          attribute :properties, RunProperties
          attribute :text, :string
          attribute :tab, Tab
          attribute :break, Break

          xml do
            element 'r'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'rPr', to: :properties, render_nil: false
            map_element 't', to: :text, render_nil: false
            map_element 'tab', to: :tab, render_nil: false
            map_element 'br', to: :break, render_nil: false
          end
      end
    end
end
