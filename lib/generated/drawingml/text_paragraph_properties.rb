# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Text paragraph properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:pPr>
      class TextParagraphProperties < Lutaml::Model::Serializable
          attribute :algn, String
          attribute :marL, Integer
          attribute :marR, Integer

          xml do
            root 'pPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :algn
            map_attribute 'true', to: :marL
            map_attribute 'true', to: :marR
          end
      end
    end
  end
end
