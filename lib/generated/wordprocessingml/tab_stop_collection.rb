# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Tab stops collection
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tabs>
      class TabStopCollection < Lutaml::Model::Serializable
          attribute :tab_entries, TabStop, collection: true, default: -> { [] }

          xml do
            root 'tabs'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'tab', to: :tab_entries, render_nil: false
          end
      end
    end
  end
end
