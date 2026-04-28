# frozen_string_literal: true

require "securerandom"

# Shared test helpers for Uniword specs.
#
# Automatically loaded by spec_helper.rb via Dir[...support/**/*.rb].
# Included in all specs via RSpec.configure.
module DocumentHelpers
  # Extract plain text from a document (paragraphs + tables)
  def extract_text(document)
    text = document.paragraphs.map { |para| extract_paragraph_text(para) }
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

  # Extract text from a single paragraph
  def extract_paragraph_text(paragraph)
    return "" unless paragraph.respond_to?(:runs)

    paragraph.runs.map do |run|
      run.respond_to?(:text) ? run.text : ""
    end.join
  end

  # Create a DocumentRoot with the specified number of paragraphs and runs
  def create_large_document(paragraphs: 100, runs_per_para: 5)
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    paragraphs.times do |i|
      para = Uniword::Wordprocessingml::Paragraph.new
      runs_per_para.times do |j|
        run = Uniword::Wordprocessingml::Run.new(
          text: "Paragraph #{i + 1}, Run #{j + 1}: Some test content here.",
        )
        para.runs << run
      end
      doc.body.paragraphs << para
    end

    doc
  end

  # Create a DocumentRoot with tables
  def create_document_with_tables(table_count: 10, rows: 5, cols: 4)
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    table_count.times do |t|
      table = Uniword::Wordprocessingml::Table.new

      rows.times do |r|
        row = Uniword::Wordprocessingml::TableRow.new
        cols.times do |c|
          cell = Uniword::Wordprocessingml::TableCell.new
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(
            text: "Table #{t + 1}, Row #{r + 1}, Col #{c + 1}",
          )
          para.runs << run
          cell.paragraphs << para
          row.cells << cell
        end
        table.rows << row
      end
      doc.body.tables << table
    end

    doc
  end

  # Normalize XML for comparison by parsing and re-serializing
  def normalize_xml(xml)
    Nokogiri::XML(xml).to_xml
  end

  # Generate a temp file path for tests
  def temp_docx_path(prefix: "uniword_test")
    File.join(Dir.tmpdir, "#{prefix}_#{SecureRandom.uuid}.docx")
  end
end

RSpec.configure do |config|
  config.include DocumentHelpers
end
