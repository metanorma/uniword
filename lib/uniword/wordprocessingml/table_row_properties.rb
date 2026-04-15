# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table row properties
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:trPr>
    class TableRowProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML
      attribute :tr_height, TrHeight
      attribute :tbl_header, ValInt
      attribute :cant_split, ValInt
      attribute :grid_before, GridBefore
      attribute :grid_after, GridAfter
      attribute :w_before, WidthBefore
      attribute :w_after, WidthAfter
      attribute :cnf_style, CnfStyle
      attribute :div_id, ValInt

      xml do
        element "trPr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "trHeight", to: :tr_height, render_nil: false
        map_element "tblHeader", to: :tbl_header, render_nil: false
        map_element "cantSplit", to: :cant_split, render_nil: false
        map_element "gridBefore", to: :grid_before, render_nil: false
        map_element "gridAfter", to: :grid_after, render_nil: false
        map_element "wBefore", to: :w_before, render_nil: false
        map_element "wAfter", to: :w_after, render_nil: false
        map_element "cnfStyle", to: :cnf_style, render_nil: false
        map_element "divId", to: :div_id, render_nil: false
      end

      def initialize(attrs = {})
        # Handle table_header: keyword for docx-js API compatibility
        if attrs.key?(:table_header)
          val = attrs.delete(:table_header)
          attrs[:tbl_header] = coerce_to_val_int(val)
        end
        super
      end

      private

      def coerce_to_val_int(val)
        case val
        when ValInt then val
        when true, 1 then ValInt.new(value: 1)
        when false, 0 then nil
        when Integer then ValInt.new(value: val)
        when nil then nil
        else ValInt.new(value: val.to_i)
        end
      end
    end
  end
end
