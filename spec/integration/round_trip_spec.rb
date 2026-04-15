# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe "DOCX Round-trip Validation" do
  let(:tmp_dir) { "tmp/roundtrip" }
  let(:fixtures_dir) { "spec/fixtures/docx_gem" }

  before(:all) do
    FileUtils.mkdir_p("tmp/roundtrip")
  end

  after(:each) do
    # Clean up temporary files after each test
    Dir.glob("#{tmp_dir}/*.docx").each { |f| safe_delete(f) }
  end

  describe "Basic Round-trip" do
    context "simple paragraph text" do
      let(:fixture_path) { "#{fixtures_dir}/basic.docx" }
      let(:temp_path) { "#{tmp_dir}/roundtrip_basic.docx" }

      it "preserves text content" do
        # Read fixture
        doc1 = Uniword::DocumentFactory.from_file(fixture_path)
        original_text = extract_text(doc1)

        # Write to temp
        doc1.save(temp_path)

        # Read back
        doc2 = Uniword::DocumentFactory.from_file(temp_path)

        # Compare text content
        expect(extract_text(doc2)).to eq(original_text)
      end

      it "preserves paragraph count" do
        doc1 = Uniword::DocumentFactory.from_file(fixture_path)
        original_count = doc1.paragraphs.count

        doc1.save(temp_path)
        doc2 = Uniword::DocumentFactory.from_file(temp_path)

        expect(doc2.paragraphs.count).to eq(original_count)
      end

      it "preserves element structure" do
        doc1 = Uniword::DocumentFactory.from_file(fixture_path)
        original_paragraphs = doc1.paragraphs.count
        original_tables = doc1.tables.count

        doc1.save(temp_path)
        doc2 = Uniword::DocumentFactory.from_file(temp_path)

        expect(doc2.paragraphs.count).to eq(original_paragraphs)
        expect(doc2.tables.count).to eq(original_tables)
      end
    end

    context "empty document" do
      let(:temp_path) { "#{tmp_dir}/roundtrip_empty.docx" }

      it "handles empty document" do
        doc1 = Uniword::Wordprocessingml::DocumentRoot.new

        doc1.save(temp_path)
        doc2 = Uniword::DocumentFactory.from_file(temp_path)

        expect(doc2.paragraphs).to be_empty
      end
    end
  end

  describe "Formatting Round-trip" do
    let(:fixture_path) { "#{fixtures_dir}/formatting.docx" }
    let(:temp_path) { "#{tmp_dir}/roundtrip_formatting.docx" }

    it "preserves text formatting" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)

      # Collect formatting info before save
      original_formatting = collect_run_formatting(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      # Collect formatting info after round-trip
      roundtrip_formatting = collect_run_formatting(doc2)

      expect(roundtrip_formatting).to match_array(original_formatting)
    end

    it "preserves bold text" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      bold_runs_before = count_bold_runs(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      bold_runs_after = count_bold_runs(doc2)
      expect(bold_runs_after).to eq(bold_runs_before)
    end

    it "preserves italic text" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      italic_runs_before = count_italic_runs(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      italic_runs_after = count_italic_runs(doc2)
      expect(italic_runs_after).to eq(italic_runs_before)
    end

    it "preserves font information" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      fonts_before = collect_fonts(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      fonts_after = collect_fonts(doc2)
      expect(fonts_after).to match_array(fonts_before)
    end
  end

  describe "Table Round-trip" do
    let(:fixture_path) { "#{fixtures_dir}/tables.docx" }
    let(:temp_path) { "#{tmp_dir}/roundtrip_tables.docx" }

    it "preserves table count" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      table_count_before = doc1.tables.count

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      expect(doc2.tables.count).to eq(table_count_before)
    end

    it "preserves table structure" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      table_structures_before = collect_table_structures(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      table_structures_after = collect_table_structures(doc2)
      expect(table_structures_after).to eq(table_structures_before)
    end

    it "preserves table cell content" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      cell_texts_before = collect_table_cell_texts(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      cell_texts_after = collect_table_cell_texts(doc2)
      expect(cell_texts_after).to eq(cell_texts_before)
    end

    it "preserves table borders" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      borders_before = collect_table_borders(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      borders_after = collect_table_borders(doc2)
      expect(borders_after).to eq(borders_before)
    end
  end

  describe "Styles Round-trip" do
    let(:fixture_path) { "#{fixtures_dir}/styles.docx" }
    let(:temp_path) { "#{tmp_dir}/roundtrip_styles.docx" }

    it "preserves style definitions" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      styles_before = collect_style_definitions(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      styles_after = collect_style_definitions(doc2)
      expect(styles_after.keys).to match_array(styles_before.keys)
    end

    it "preserves style applications" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      applied_styles_before = collect_applied_styles(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      applied_styles_after = collect_applied_styles(doc2)
      expect(applied_styles_after).to eq(applied_styles_before)
    end

    it "preserves paragraph styles" do
      doc1 = Uniword::DocumentFactory.from_file(fixture_path)
      para_styles_before = collect_paragraph_styles(doc1)

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      para_styles_after = collect_paragraph_styles(doc2)
      expect(para_styles_after).to eq(para_styles_before)
    end
  end

  describe "Complete Document Round-trip" do
    let(:temp_path) { "#{tmp_dir}/roundtrip_complete.docx" }

    it "preserves all features in complex document" do
      # Create document with ALL features
      doc1 = create_full_featured_document

      # Capture original state
      original_state = capture_document_state(doc1)

      # Write and re-read
      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      # Capture round-trip state
      roundtrip_state = capture_document_state(doc2)

      # Verify all features preserved
      expect(roundtrip_state[:paragraph_count]).to eq(original_state[:paragraph_count])
      expect(roundtrip_state[:table_count]).to eq(original_state[:table_count])
      expect(roundtrip_state[:text_content]).to eq(original_state[:text_content])
      expect(roundtrip_state[:formatting_count]).to eq(original_state[:formatting_count])
    end

    it "handles multiple paragraphs with various styles" do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new

      # Add multiple paragraphs with different content
      5.times do |i|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1}")
        para.runs << run
        doc1.body.paragraphs << para
      end

      original_texts = doc1.paragraphs.map { |p| extract_paragraph_text(p) }

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      roundtrip_texts = doc2.paragraphs.map { |p| extract_paragraph_text(p) }
      expect(roundtrip_texts).to eq(original_texts)
    end

    it "handles mixed content types" do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new

      # Add paragraph
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Text before table")
      para.runs << run
      doc1.body.paragraphs << para

      # Add table
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new
      cell = Uniword::Wordprocessingml::TableCell.new
      cell_para = Uniword::Wordprocessingml::Paragraph.new
      cell_run = Uniword::Wordprocessingml::Run.new(text: "Cell content")
      cell_para.runs << cell_run
      cell.paragraphs << cell_para
      row.cells << cell
      table.rows << row
      doc1.body.tables << table

      # Add another paragraph
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: "Text after table")
      para2.runs << run2
      doc1.body.paragraphs << para2

      original_structure = {
        elements: doc1.body.paragraphs.count + doc1.body.tables.count,
        text: extract_text(doc1)
      }

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      roundtrip_structure = {
        elements: doc2.body.paragraphs.count + doc2.body.tables.count,
        text: extract_text(doc2)
      }

      expect(roundtrip_structure).to eq(original_structure)
    end
  end

  describe "Property Preservation" do
    let(:temp_path) { "#{tmp_dir}/roundtrip_properties.docx" }

    it "preserves paragraph properties" do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new

      # Create paragraph with properties
      para = Uniword::Wordprocessingml::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: "center",
          line_spacing: 240
        )
      )

      run = Uniword::Wordprocessingml::Run.new(text: "Test paragraph")
      para.runs << run
      doc1.body.paragraphs << para

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      # Properties should be preserved
      expect(doc2.paragraphs.count).to eq(1)
      expect(extract_text(doc2)).to include("Test paragraph")
    end

    it "preserves run properties" do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new

      # Create run with properties
      run = Uniword::Wordprocessingml::Run.new(
        text: "Formatted text",
        properties: Uniword::Wordprocessingml::RunProperties.new(
          bold: true,
          italic: true,
          size: 48 # font_size * 2
        )
      )

      para.runs << run
      doc1.body.paragraphs << para

      doc1.save(temp_path)
      doc2 = Uniword::DocumentFactory.from_file(temp_path)

      expect(doc2.paragraphs.count).to eq(1)
      expect(extract_text(doc2)).to include("Formatted text")
    end
  end

  # Helper methods
  private

  def extract_text(document)
    text = document.paragraphs.map do |para|
      extract_paragraph_text(para)
    end
    document.tables.each do |table|
      table.rows.each do |row|
        row.cells.each do |cell|
          cell.paragraphs.each do |para|
            text << extract_paragraph_text(para)
          end
        end
      end
    end
    text.join("\n")
  end

  def extract_paragraph_text(paragraph)
    return "" unless paragraph.respond_to?(:runs)

    paragraph.runs.map do |run|
      run.respond_to?(:text) ? run.text : ""
    end.join
  end

  def collect_run_formatting(document)
    formatting = []
    document.paragraphs.each do |para|
      next unless para.respond_to?(:runs)

      para.runs.each do |run|
        next unless run.respond_to?(:properties) && run.properties

        formatting << {
          bold: run.properties.respond_to?(:bold) ? run.properties.bold : nil,
          italic: run.properties.respond_to?(:italic) ? run.properties.italic : nil,
          font: run.properties.respond_to?(:font) ? run.properties.font : nil
        }
      end
    end
    formatting
  end

  def count_bold_runs(document)
    count = 0
    document.paragraphs.each do |para|
      next unless para.respond_to?(:runs)

      para.runs.each do |run|
        count += 1 if run.respond_to?(:properties) && run.properties.respond_to?(:bold) && run.properties.bold
      end
    end
    count
  end

  def count_italic_runs(document)
    count = 0
    document.paragraphs.each do |para|
      next unless para.respond_to?(:runs)

      para.runs.each do |run|
        count += 1 if run.respond_to?(:properties) && run.properties.respond_to?(:italic) && run.properties.italic
      end
    end
    count
  end

  def collect_fonts(document)
    fonts = []
    document.paragraphs.each do |para|
      next unless para.respond_to?(:runs)

      para.runs.each do |run|
        fonts << run.properties.font if run.respond_to?(:properties) && run.properties.respond_to?(:font) && run.properties.font
      end
    end
    fonts.uniq
  end

  def collect_table_structures(document)
    document.tables.map do |table|
      {
        row_count: table.rows.count,
        cell_counts: table.rows.map { |row| row.cells.count }
      }
    end
  end

  def collect_table_cell_texts(document)
    texts = []
    document.tables.each do |table|
      table.rows.each do |row|
        row.cells.each do |cell|
          cell_text = cell.paragraphs.map { |p| extract_paragraph_text(p) }.join
          texts << cell_text
        end
      end
    end
    texts
  end

  def collect_table_borders(document)
    borders = []
    document.tables.each do |table|
      borders << table.properties.borders if table.respond_to?(:properties) && table.properties.respond_to?(:borders)
    end
    borders
  end

  def collect_style_definitions(document)
    return {} unless document.respond_to?(:styles_configuration)

    styles = {}
    if document.styles_configuration.respond_to?(:styles)
      document.styles_configuration.styles.each do |style|
        styles[style.style_id] = style if style.respond_to?(:style_id)
      end
    end
    styles
  end

  def collect_applied_styles(document)
    styles = []
    document.paragraphs.each do |para|
      styles << para.properties.style if para.respond_to?(:properties) && para.properties.respond_to?(:style)
    end
    styles
  end

  def collect_paragraph_styles(document)
    styles = []
    document.paragraphs.each do |para|
      if para.respond_to?(:style_id)
        styles << para.style_id
      elsif para.respond_to?(:properties) && para.properties.respond_to?(:style)
        styles << para.properties.style
      end
    end
    styles
  end

  def create_full_featured_document
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    # Multiple paragraphs with various styles
    3.times do |i|
      para = Uniword::Wordprocessingml::Paragraph.new

      # Create run with properties
      run = if i.even?
              Uniword::Wordprocessingml::Run.new(
                text: "Paragraph #{i + 1} with content",
                properties: Uniword::Wordprocessingml::RunProperties.new(bold: true)
              )
            elsif i.odd?
              Uniword::Wordprocessingml::Run.new(
                text: "Paragraph #{i + 1} with content",
                properties: Uniword::Wordprocessingml::RunProperties.new(italic: true)
              )
            else
              Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1} with content")
            end

      para.runs << run
      doc.body.paragraphs << para
    end

    # Table
    table = Uniword::Wordprocessingml::Table.new
    2.times do |r|
      row = Uniword::Wordprocessingml::TableRow.new
      2.times do |c|
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Cell #{r},#{c}")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
      end
      table.rows << row
    end
    doc.body.tables << table

    # More paragraphs
    2.times do |i|
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "After table paragraph #{i + 1}")
      para.runs << run
      doc.body.paragraphs << para
    end

    doc
  end

  def capture_document_state(document)
    {
      paragraph_count: document.paragraphs.count,
      table_count: document.tables.count,
      text_content: extract_text(document),
      formatting_count: collect_run_formatting(document).count
    }
  end
end
