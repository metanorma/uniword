# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Paragraph borders
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:pBdr>
      class ParagraphBorders < Lutaml::Model::Serializable
          attribute :top, Border
          attribute :bottom, Border
          attribute :left, Border
          attribute :right, Border
          attribute :between, Border
          attribute :bar, Border

          xml do
            root 'pBdr'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'top', to: :top, render_nil: false
            map_element 'bottom', to: :bottom, render_nil: false
            map_element 'left', to: :left, render_nil: false
            map_element 'right', to: :right, render_nil: false
            map_element 'between', to: :between, render_nil: false
            map_element 'bar', to: :bar, render_nil: false
          end
      end
    end
  end
end
