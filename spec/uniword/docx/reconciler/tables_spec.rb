# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler do
  let(:table_class) { Uniword::Wordprocessingml::Table }
  let(:row_class) { Uniword::Wordprocessingml::TableRow }
  let(:cell_class) { Uniword::Wordprocessingml::TableCell }

  def build_package_with_table(table)
    package = Uniword::Docx::Package.new
    package.document = Uniword::Wordprocessingml::DocumentRoot.new
    package.document.body.tables << table
    package
  end

  describe "table reconciliation" do
    let(:table_props_class) { Uniword::Wordprocessingml::TableProperties }
    let(:grid_class) { Uniword::Wordprocessingml::TableGrid }
    let(:grid_col_class) { Uniword::Wordprocessingml::GridCol }
    let(:table_width_class) { Uniword::Properties::TableWidth }
    let(:table_look_class) { Uniword::Properties::TableLook }

    def build_table_with_cells(col_count, row_count)
      rows = row_count.times.map do
        cells = col_count.times.map { cell_class.new }
        row_class.new(cells: cells)
      end
      table_class.new(rows: rows)
    end

    it "adds tblPr when missing" do
      table = build_table_with_cells(2, 1)
      table.properties = nil
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(table.properties).to be_a(table_props_class)
    end

    it "adds tblW with defaults when missing" do
      table = build_table_with_cells(2, 1)
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      tw = table.properties.table_width
      expect(tw).not_to be_nil
      expect(tw.w).to eq(0)
      expect(tw.type).to eq("auto")
    end

    it "adds tblLook with defaults when missing" do
      table = build_table_with_cells(2, 1)
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      look = table.properties.table_look
      expect(look).not_to be_nil
      expect(look.val).to eq("04A0")
      expect(look.first_row).to eq(1)
      expect(look.no_v_band).to eq(1)
    end

    it "creates tblGrid with correct column count" do
      table = build_table_with_cells(3, 2)
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(table.grid).not_to be_nil
      expect(table.grid.columns.size).to eq(3)
    end

    it "adjusts tblGrid when column count mismatches" do
      table = build_table_with_cells(3, 1)
      table.grid = grid_class.new(columns: [grid_col_class.new])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(table.grid.columns.size).to eq(3)
    end

    it "defaults gridCol widths to equal content-width shares" do
      table = build_table_with_cells(2, 1)
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      widths = table.grid.columns.map(&:width)
      # US Letter defaults: (12240 - 1440 - 1440) / 2 = 4680
      expect(widths).to eq([4680, 4680])
    end

    it "keeps explicit widths and shares the remainder" do
      table = build_table_with_cells(2, 1)
      table.grid = grid_class.new(
        columns: [grid_col_class.new(width: 2500), grid_col_class.new],
      )
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      widths = table.grid.columns.map(&:width)
      expect(widths).to eq([2500, 6860])
    end

    it "records the width defaulting as a fix" do
      table = build_table_with_cells(2, 1)
      package = build_package_with_table(table)

      reconciler = described_class.new(package)
      reconciler.reconcile

      fix = reconciler.applied_fixes.find { |f| f.code == "R33" }
      expect(fix).not_to be_nil
      expect(fix.part).to eq("word/document.xml")
    end

    it "defaults widths on the builder-managed path too" do
      table = build_table_with_cells(3, 1)
      # Mirrors TableBuilder output: grid present, columns width-less.
      table.grid = grid_class.new(
        columns: [grid_col_class.new, grid_col_class.new,
                  grid_col_class.new],
      )
      package = build_package_with_table(table)

      described_class.new(package, builder_managed: true).reconcile

      widths = table.grid.columns.map(&:width)
      expect(widths).to eq([3120, 3120, 3120])
    end

    it "fills missing tblLook attributes on existing table" do
      table = build_table_with_cells(2, 1)
      table.properties = table_props_class.new(
        table_look: table_look_class.new,
      )
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      look = table.properties.table_look
      expect(look.val).to eq("04A0")
      expect(look.first_row).to eq(1)
    end

    it "does not overwrite existing valid table structure" do
      table = build_table_with_cells(2, 1)
      table.properties = table_props_class.new(
        table_width: table_width_class.new(w: 5000, type: "dxa"),
        table_look: table_look_class.new(
          val: "01A0", first_row: 0, last_row: 0,
          first_column: 0, last_column: 0,
          no_h_band: 0, no_v_band: 0,
        ),
      )
      table.grid = grid_class.new(
        columns: [grid_col_class.new(width: 2500),
                  grid_col_class.new(width: 2500)],
      )
      package = build_package_with_table(table)

      reconciler = described_class.new(package)
      reconciler.reconcile

      look = table.properties.table_look
      expect(look.val).to eq("01A0")
      expect(look.first_row).to eq(0)
      expect(table.properties.table_width.w).to eq(5000)
      expect(table.properties.table_width.type).to eq("dxa")
    end
  end

  describe "table gridAfter reconciliation" do
    it "adds gridAfter when row covers fewer columns than grid" do
      row_full = row_class.new(cells: [cell_class.new, cell_class.new, cell_class.new])
      row_short = row_class.new(cells: [cell_class.new, cell_class.new])
      table = table_class.new(rows: [row_full, row_short])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      # row_full covers 3 cols (no gridAfter); row_short covers 2 cols (gridAfter=1)
      expect(row_full.properties&.grid_after).to be_nil
      expect(row_short.properties).not_to be_nil
      expect(row_short.properties.grid_after).not_to be_nil
      expect(row_short.properties.grid_after.value).to eq(1)
    end

    it "does not add gridAfter when row covers all grid columns" do
      row = row_class.new(cells: [cell_class.new, cell_class.new, cell_class.new])
      table = table_class.new(rows: [row])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(row.properties&.grid_after).to be_nil
    end

    it "accounts for gridSpan when calculating gridAfter" do
      # Row 1: 3 cells, covers 3 cols
      row_full = row_class.new(cells: [cell_class.new, cell_class.new, cell_class.new])
      # Row 2: 1 cell with gridSpan=2, covers 2 out of 3 → gridAfter=1
      tc_pr = Uniword::Wordprocessingml::TableCellProperties.new(
        grid_span: Uniword::Wordprocessingml::ValInt.new(value: 2),
      )
      span_cell = cell_class.new
      span_cell.properties = tc_pr
      row_span = row_class.new(cells: [span_cell])
      table = table_class.new(rows: [row_full, row_span])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(row_span.properties.grid_after.value).to eq(1)
    end
  end
end
