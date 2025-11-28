# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Text position (raised/lowered)
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:position>
      class Position < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'position'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
