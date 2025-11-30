# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Table cell properties
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tcPr>
    class TableCellProperties < Lutaml::Model::Serializable
      attribute :width, :integer
      attribute :width_type, :string
      attribute :borders, TableCellBorders
      attribute :shading, Shading
      attribute :v_align, :string
      attribute :gridSpan, :integer
      attribute :v_merge, :string

      xml do
        element 'tcPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'w', to: :width
        map_attribute 'type', to: :width_type
        map_element 'tcBorders', to: :borders, render_nil: false
        map_element 'shd', to: :shading, render_nil: false
        map_attribute 'val', to: :v_align
        map_attribute 'val', to: :gridSpan
        map_attribute 'val', to: :v_merge
      end
    end
  end
end
