# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Object extent dimensions
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:extent>
      class Extent < Lutaml::Model::Serializable
          attribute :cx, :integer
          attribute :cy, :integer

          xml do
            root 'extent'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :cx
            map_attribute 'true', to: :cy
          end
      end
    end
  end
end
