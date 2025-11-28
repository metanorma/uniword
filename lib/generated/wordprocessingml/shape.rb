# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # VML shape object
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:shape>
      class Shape < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :type, :string
          attribute :style, :string

          xml do
            root 'shape'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :type
            map_attribute 'true', to: :style
          end
      end
    end
  end
end
