# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Cell format record
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:xf>
      class CellFormat < Lutaml::Model::Serializable
          attribute :num_fmt_id, Integer
          attribute :font_id, Integer
          attribute :fill_id, Integer
          attribute :border_id, Integer
          attribute :apply_number_format, String
          attribute :apply_font, String
          attribute :apply_fill, String
          attribute :apply_border, String
          attribute :apply_alignment, String
          attribute :alignment, Alignment

          xml do
            root 'xf'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :num_fmt_id
            map_attribute 'true', to: :font_id
            map_attribute 'true', to: :fill_id
            map_attribute 'true', to: :border_id
            map_attribute 'true', to: :apply_number_format
            map_attribute 'true', to: :apply_font
            map_attribute 'true', to: :apply_fill
            map_attribute 'true', to: :apply_border
            map_attribute 'true', to: :apply_alignment
            map_element 'alignment', to: :alignment, render_nil: false
          end
      end
    end
  end
end
