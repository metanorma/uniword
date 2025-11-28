# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Text run
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:r>
      class TextRun < Lutaml::Model::Serializable
          attribute :t, String

          xml do
            root 'r'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 't', to: :t
          end
      end
    end
  end
end
