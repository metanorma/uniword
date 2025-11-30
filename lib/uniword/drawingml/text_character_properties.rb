# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'rPr'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_attribute 'sz', to: :sz
            map_attribute 'b', to: :b
            map_attribute 'i', to: :i
            map_element 'latin', to: :latin, render_nil: false
            map_element 'ea', to: :ea, render_nil: false
            map_element 'cs', to: :cs, render_nil: false
          end
      end
    end
end
