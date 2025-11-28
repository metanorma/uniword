# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Text character properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:rPr>
      class TextCharacterProperties < Lutaml::Model::Serializable
          attribute :sz, Integer
          attribute :b, String
          attribute :i, String
          attribute :latin, TextFont
          attribute :ea, TextFont
          attribute :cs, TextFont

          xml do
            root 'rPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_attribute 'true', to: :sz
            map_attribute 'true', to: :b
            map_attribute 'true', to: :i
            map_element 'latin', to: :latin, render_nil: false
            map_element 'ea', to: :ea, render_nil: false
            map_element 'cs', to: :cs, render_nil: false
          end
      end
    end
  end
end
