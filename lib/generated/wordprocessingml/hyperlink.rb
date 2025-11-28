# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'hyperlink'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_attribute 'true', to: :id
            map_attribute 'true', to: :anchor
            map_attribute 'true', to: :tooltip
            map_element 'r', to: :runs, render_nil: false
          end
      end
    end
  end
end
