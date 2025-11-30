# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Paragraph formatting properties
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:pPr>
    class ParagraphProperties < Lutaml::Model::Serializable
      attribute :style, :string
      attribute :num_id, :integer
      attribute :ilvl, :integer
      attribute :alignment, :string
      attribute :spacing_before, :integer
      attribute :spacing_after, :integer
      attribute :line_spacing, :float
      attribute :line_rule, :string
      attribute :indent_left, :integer
      attribute :indent_right, :integer
      attribute :indent_first_line, :integer
      attribute :borders, ParagraphBorders
      attribute :shading, Shading
      attribute :tab_stops, TabStopCollection

      xml do
        element 'pPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'val', to: :style
        map_attribute 'val', to: :num_id
        map_attribute 'val', to: :ilvl
        map_attribute 'val', to: :alignment
        map_attribute 'before', to: :spacing_before
        map_attribute 'after', to: :spacing_after
        map_attribute 'line', to: :line_spacing
        map_attribute 'lineRule', to: :line_rule
        map_attribute 'left', to: :indent_left
        map_attribute 'right', to: :indent_right
        map_attribute 'firstLine', to: :indent_first_line
        map_element 'pBdr', to: :borders, render_nil: false
        map_element 'shd', to: :shading, render_nil: false
        map_element 'tabs', to: :tab_stops, render_nil: false
      end
    end
  end
end
