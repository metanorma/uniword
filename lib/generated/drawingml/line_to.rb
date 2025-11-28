# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Line to command
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:lnTo>
      class LineTo < Lutaml::Model::Serializable
          attribute :pt, String

          xml do
            root 'lnTo'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'pt', to: :pt
          end
      end
    end
  end
end
