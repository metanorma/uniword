# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Font table
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:fonts>
      class Fonts < Lutaml::Model::Serializable
          attribute :font_entries, Font, collection: true, default: -> { [] }

          xml do
            root 'fonts'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'font', to: :font_entries, render_nil: false
          end
      end
    end
  end
end
