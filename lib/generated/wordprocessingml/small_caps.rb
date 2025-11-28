# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Small caps formatting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:smallCaps>
      class SmallCaps < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'smallCaps'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
