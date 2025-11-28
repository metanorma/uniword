# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Default paragraph properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:defPPr>
      class DefaultParagraphProperties < Lutaml::Model::Serializable
          attribute :algn, String
          attribute :lvl, Integer

          xml do
            root 'defPPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :algn
            map_attribute 'true', to: :lvl
          end
      end
    end
  end
end
