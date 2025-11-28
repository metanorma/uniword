# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Text body properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:bodyPr>
      class BodyProperties < Lutaml::Model::Serializable
          attribute :wrap, String

          xml do
            root 'bodyPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :wrap
          end
      end
    end
  end
end
