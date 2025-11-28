# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Binary Large Image or Picture reference
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:blip>
      class Blip < Lutaml::Model::Serializable
          attribute :embed, String
          attribute :link, String

          xml do
            root 'blip'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :embed
            map_attribute 'true', to: :link
          end
      end
    end
  end
end
