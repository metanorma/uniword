# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Conditional format style wrapper
    # XML: <w:cnfStyle w:val="00101010101010101010"/>
    # 6-bit binary bit flags for row/column conditional formatting
    class CnfStyle < Lutaml::Model::Serializable
      attribute :value, :string
      attribute :first_row, :string
      attribute :last_row, :string
      attribute :first_column, :string
      attribute :last_column, :string
      attribute :even_horizontal_band, :string
      attribute :odd_horizontal_band, :string
      attribute :even_vertical_band, :string
      attribute :odd_vertical_band, :string
      attribute :first_row_first_column, :string
      attribute :first_row_last_column, :string
      attribute :last_row_first_column, :string
      attribute :last_row_last_column, :string

      xml do
        element 'cnfStyle'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
        map_attribute 'firstRow', to: :first_row, render_nil: false
        map_attribute 'lastRow', to: :last_row, render_nil: false
        map_attribute 'firstColumn', to: :first_column, render_nil: false
        map_attribute 'lastColumn', to: :last_column, render_nil: false
        map_attribute 'evenHBand', to: :even_horizontal_band,
                  render_nil: false
        map_attribute 'oddHBand', to: :odd_horizontal_band,
                  render_nil: false
        map_attribute 'evenVBand', to: :even_vertical_band,
                  render_nil: false
        map_attribute 'oddVBand', to: :odd_vertical_band,
                  render_nil: false
        map_attribute 'firstRowFirstColumn',
                  to: :first_row_first_column, render_nil: false
        map_attribute 'firstRowLastColumn',
                  to: :first_row_last_column, render_nil: false
        map_attribute 'lastRowFirstColumn',
                  to: :last_row_first_column, render_nil: false
        map_attribute 'lastRowLastColumn',
                  to: :last_row_last_column, render_nil: false
      end
    end
  end
end
