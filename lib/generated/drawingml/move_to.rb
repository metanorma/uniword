# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Move to command
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:moveTo>
      class MoveTo < Lutaml::Model::Serializable
          attribute :pt, String

          xml do
            root 'moveTo'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'pt', to: :pt
          end
      end
    end
  end
end
