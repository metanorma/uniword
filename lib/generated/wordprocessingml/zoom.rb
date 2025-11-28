# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Document zoom level
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:zoom>
      class Zoom < Lutaml::Model::Serializable
          attribute :percent, :integer

          xml do
            root 'zoom'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :percent
          end
      end
    end
  end
end
