# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Table structure reconciliation.
      #
      # Ensures tables have required properties, grid, and cell widths.
      # Adds gridAfter for rows that don't cover all grid columns.
      module Tables
        DEFAULT_TABLE_LOOK = Properties::TableLook.new(
          val: "04A0",
          first_row: 1,
          last_row: 0,
          first_column: 1,
          last_column: 0,
          no_h_band: 0,
          no_v_band: 1,
        ).freeze

        def reconcile_tables
          return unless package.document&.body

          tables = package.document.body.tables
          return unless tables

          tables.each_with_index do |tbl, idx|
            reconcile_single_table(tbl, idx)
          end
        end

        private

        def reconcile_single_table(tbl, idx)
          fixed = false

          unless tbl.properties
            tbl.properties = Wordprocessingml::TableProperties.new
            fixed = true
          end

          tw = tbl.properties.table_width
          if tw.nil?
            tbl.properties.table_width = Properties::TableWidth.new(w: 0, type: "auto")
            fixed = true
          elsif tw.w.nil? || tw.type.nil?
            tw.w ||= 0
            tw.type ||= "auto"
            fixed = true
          end

          if tbl.properties.table_look.nil?
            tbl.properties.table_look = Properties::TableLook.new(
              val: DEFAULT_TABLE_LOOK.val,
              first_row: DEFAULT_TABLE_LOOK.first_row,
              last_row: DEFAULT_TABLE_LOOK.last_row,
              first_column: DEFAULT_TABLE_LOOK.first_column,
              last_column: DEFAULT_TABLE_LOOK.last_column,
              no_h_band: DEFAULT_TABLE_LOOK.no_h_band,
              no_v_band: DEFAULT_TABLE_LOOK.no_v_band,
            )
            fixed = true
          elsif tbl.properties.table_look.val.nil?
            look = tbl.properties.table_look
            look.val = DEFAULT_TABLE_LOOK.val
            look.first_row ||= DEFAULT_TABLE_LOOK.first_row
            look.last_row ||= DEFAULT_TABLE_LOOK.last_row
            look.first_column ||= DEFAULT_TABLE_LOOK.first_column
            look.last_column ||= DEFAULT_TABLE_LOOK.last_column
            look.no_h_band ||= DEFAULT_TABLE_LOOK.no_h_band
            look.no_v_band ||= DEFAULT_TABLE_LOOK.no_v_band
            fixed = true
          end

          col_count = tbl.column_count
          if tbl.grid.nil?
            grid_cols = Array.new(col_count) { Wordprocessingml::GridCol.new }
            tbl.grid = Wordprocessingml::TableGrid.new(columns: grid_cols)
            fixed = true
          elsif tbl.grid.columns.size != col_count
            current = tbl.grid.columns.size
            if current < col_count
              (col_count - current).times do
                tbl.grid.columns << Wordprocessingml::GridCol.new
              end
            else
              tbl.grid.columns = tbl.grid.columns.first(col_count)
            end
            fixed = true
          end

          tbl.grid&.columns&.each_with_index do |col, ci|
            next if col.width

            Uniword.logger&.warn do
              "Table #{idx}: gridCol[#{ci}] has no w:w — " \
              "table may render with incorrect column widths"
            end
          end

          record_fix("R10", "Reconciled table structure for table #{idx}") if fixed

          tbl.rows&.each do |row|
            row.cells&.each do |cell|
              tc_pr = cell.properties
              if tc_pr.nil?
                cell.properties = Wordprocessingml::TableCellProperties.new(
                  cell_width: Uniword::Properties::CellWidth.new(w: 0, type: "auto"),
                )
                insert_element_order(cell, "tcPr", 0)
                record_fix("R12", "Added missing tcPr with tcW to table cell")
              elsif tc_pr.cell_width.nil?
                tc_pr.cell_width = Uniword::Properties::CellWidth.new(w: 0, type: "auto")
                record_fix("R12", "Added missing tcW to table cell")
              end

              reconcile_table_cell_order(cell)
            end
          end

          reconcile_grid_after(tbl)
        end

        def reconcile_table_cell_order(cell)
          order = cell.element_order
          return unless order && !order.empty?

          tcPr_idx = order.index { |e| e.name == "tcPr" }
          first_p_idx = order.index { |e| e.name == "p" }

          return if tcPr_idx.nil? || first_p_idx.nil?
          return if tcPr_idx < first_p_idx

          tcPr_entry = order.delete_at(tcPr_idx)
          order.insert(first_p_idx, tcPr_entry)

          record_fix("R10", "Moved tcPr before p in table cell")
        end

        def reconcile_grid_after(tbl)
          grid_col_count = tbl.grid&.columns&.size || 0
          return unless grid_col_count.positive?

          tbl.rows&.each do |row|
            cells = row.cells
            next unless cells && !cells.empty?

            covered = cells.sum do |cell|
              span = cell.properties&.grid_span&.value
              span && span > 0 ? span : 1
            end

            missing = grid_col_count - covered
            next if missing <= 0

            row_props = row.properties
            if row_props.nil?
              row.properties = Wordprocessingml::TableRowProperties.new(
                grid_after: Wordprocessingml::GridAfter.new(value: missing),
              )
              insert_element_order(row, "trPr", 0)
            elsif row_props.grid_after.nil? || row_props.grid_after.value != missing
              row_props.grid_after ||= Wordprocessingml::GridAfter.new
              row_props.grid_after.value = missing
            end
            record_fix("R13", "Added gridAfter=#{missing} to table row (grid has #{grid_col_count} cols, row covers #{covered})")
          end
        end
      end
    end
  end
end
