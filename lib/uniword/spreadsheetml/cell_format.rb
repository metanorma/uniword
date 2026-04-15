# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Cell format record
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:xf>
    class CellFormat < Lutaml::Model::Serializable
      attribute :num_fmt_id, :integer
      attribute :font_id, :integer
      attribute :fill_id, :integer
      attribute :border_id, :integer
      attribute :apply_number_format, :string
      attribute :apply_font, :string
      attribute :apply_fill, :string
      attribute :apply_border, :string
      attribute :apply_alignment, :string
      attribute :alignment, Alignment

      xml do
        element "xf"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "num-fmt-id", to: :num_fmt_id
        map_attribute "font-id", to: :font_id
        map_attribute "fill-id", to: :fill_id
        map_attribute "border-id", to: :border_id
        map_attribute "apply-number-format", to: :apply_number_format
        map_attribute "apply-font", to: :apply_font
        map_attribute "apply-fill", to: :apply_fill
        map_attribute "apply-border", to: :apply_border
        map_attribute "apply-alignment", to: :apply_alignment
        map_element "alignment", to: :alignment, render_nil: false
      end
    end
  end
end
