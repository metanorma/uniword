# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Table structure reconciliation.
      #
      # Ensures tables have required properties, grid, and cell widths.
      # Adds gridAfter for rows that don't cover all grid columns.
      module Tables
        def reconcile_tables
          return unless package.document&.body

          tables = package.document.body.tables
          return unless tables

          tables.each_with_index do |tbl, idx|
            if allocator
              reconcile_table_cell_order_only(tbl, idx)
            else
              reconcile_single_table(tbl, idx)
            end
          end
        end

        private

        # Allocator path: builders create complete tables.
        # Only fix element order issues and calculate gridAfter.
        def reconcile_table_cell_order_only(tbl, idx)
          tbl.rows&.each do |row|
            row.cells&.each do |cell|
              reconcile_table_cell_order(cell)
            end
          end
          reconcile_grid_after(tbl)
        end

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
            tbl.properties.table_look = Wordprocessingml::TableDefaults.default_table_look
            fixed = true
          elsif tbl.properties.table_look.val.nil?
            Wordprocessingml::TableDefaults.fill_missing_table_look(tbl.properties.table_look)
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

          record_fix(FixCodes::TABLE_STRUCTURE_RECONCILED, "Reconciled table structure for table #{idx}") if fixed

          tbl.rows&.each do |row|
            row.cells&.each do |cell|
              tc_pr = cell.properties
              if tc_pr.nil?
                cell.properties = Wordprocessingml::TableCellProperties.new(
                  cell_width: Uniword::Properties::CellWidth.new(w: 0, type: "auto"),
                )
                insert_element_order(cell, "tcPr", 0)
                record_fix(FixCodes::TABLE_CELL_DEFAULTS, "Added missing tcPr with tcW to table cell")
              elsif tc_pr.cell_width.nil?
                tc_pr.cell_width = Uniword::Properties::CellWidth.new(w: 0, type: "auto")
                record_fix(FixCodes::TABLE_CELL_DEFAULTS, "Added missing tcW to table cell")
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

          record_fix(FixCodes::TABLE_CELL_PR_REORDERED, "Moved tcPr before p in table cell")
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
            record_fix(FixCodes::TABLE_ROW_GRID_AFTER, "Added gridAfter=#{missing} to table row (grid has #{grid_col_count} cols, row covers #{covered})")
          end
        end
      end
    end
  end
end
