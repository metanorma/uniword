# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Grid column definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:gridCol>
      class GridCol < Lutaml::Model::Serializable
          attribute :width, :integer

          xml do
            root 'gridCol'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :width
          end
      end
    end
  end
end
