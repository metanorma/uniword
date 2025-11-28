# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Document settings
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:settings>
      class Settings < Lutaml::Model::Serializable
          attribute :zoom, Zoom
          attribute :compat, Compat

          xml do
            root 'settings'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'zoom', to: :zoom, render_nil: false
            map_element 'compat', to: :compat, render_nil: false
          end
      end
    end
  end
end
