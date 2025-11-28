# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Graphic object container
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:graphic>
      class Graphic < Lutaml::Model::Serializable
          attribute :graphicData, GraphicData

          xml do
            root 'graphic'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'graphicData', to: :graphicData, render_nil: false
          end
      end
    end
  end
end
