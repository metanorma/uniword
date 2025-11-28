# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Cell alignment properties
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:alignment>
      class Alignment < Lutaml::Model::Serializable
          attribute :horizontal, String
          attribute :vertical, String
          attribute :text_rotation, Integer
          attribute :wrap_text, String
          attribute :indent, Integer
          attribute :shrink_to_fit, String

          xml do
            root 'alignment'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :horizontal
            map_attribute 'true', to: :vertical
            map_attribute 'true', to: :text_rotation
            map_attribute 'true', to: :wrap_text
            map_attribute 'true', to: :indent
            map_attribute 'true', to: :shrink_to_fit
          end
      end
    end
  end
end
