# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Graphic data holder
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:graphicData>
      class GraphicData < Lutaml::Model::Serializable
          attribute :uri, :string

          xml do
            root 'graphicData'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :uri
          end
      end
    end
  end
end
