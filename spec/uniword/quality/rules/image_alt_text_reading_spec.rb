# frozen_string_literal: true

require "spec_helper"

# The quality rule is the second consumer of the one alt-text reading, and it
# walks the same drawing list as the accessibility rule. Both halves of that
# claim are asserted here: the rule reads through Drawing#alt_text rather than
# the raw docPr/@descr, and DocumentRoot#images reaches a picture sitting in a
# table nested inside a table cell.
RSpec.describe Uniword::Quality::ImageAltTextRule do
  subject(:rule) { described_class.new(require_alt_text: true, min_length: 10) }

  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }

  before do
    document.body ||= Uniword::Wordprocessingml::Body.new
    document.body.paragraphs ||= []
    document.body.tables ||= []
  end

  def drawing_with(descr)
    drawing = Uniword::Wordprocessingml::Drawing.new
    inline = Uniword::WpDrawing::Inline.new
    inline.doc_properties = Uniword::WpDrawing::DocProperties.new(
      id: "1", name: "image1", descr: descr
    )
    drawing.inline = inline
    drawing
  end

  def paragraph_with(drawing)
    run = Uniword::Wordprocessingml::Run.new
    run.drawings << drawing
    paragraph = Uniword::Wordprocessingml::Paragraph.new
    paragraph.runs << run
    paragraph
  end

  def cell_with(paragraphs: [], tables: [])
    cell = Uniword::Wordprocessingml::TableCell.new
    cell.paragraphs ||= []
    cell.tables ||= []
    paragraphs.each { |para| cell.paragraphs << para }
    tables.each { |table| cell.tables << table }
    cell
  end

  def table_with(cell)
    row = Uniword::Wordprocessingml::TableRow.new
    row.cells ||= []
    row.cells << cell
    table = Uniword::Wordprocessingml::Table.new
    table.rows ||= []
    table.rows << row
    table
  end

  # A descr of nothing but spaces describes nothing. Drawing#alt_text strips
  # it and calls it absent; the raw attribute is a three-character string that
  # reads as present but too short.
  describe "reading alt text" do
    it "calls a whitespace-only descr missing, not short" do
      document.body.paragraphs << paragraph_with(drawing_with("   "))

      violations = rule.check(document)

      aggregate_failures do
        expect(violations.size).to eq(1)
        expect(violations.first.severity).to eq(:error)
        expect(violations.first.message).to include("missing alt text")
      end
    end

    it "strips surrounding whitespace before measuring the length" do
      document.body.paragraphs << paragraph_with(drawing_with("  #{'a' * 9}  "))

      violations = rule.check(document)

      aggregate_failures do
        expect(violations.size).to eq(1)
        expect(violations.first.severity).to eq(:warning)
        expect(violations.first.message).to include("9 characters")
      end
    end
  end

  describe "images inside tables" do
    it "checks a picture in a table cell" do
      cell = cell_with(paragraphs: [paragraph_with(drawing_with(nil))])
      document.body.tables << table_with(cell)

      expect(rule.check(document).size).to eq(1)
    end

    it "checks a picture in a table nested inside a table cell" do
      inner = table_with(cell_with(paragraphs: [paragraph_with(drawing_with(nil))]))
      document.body.tables << table_with(cell_with(tables: [inner]))

      aggregate_failures do
        expect(document.images.size).to eq(1)
        expect(rule.check(document).size).to eq(1)
      end
    end

    it "leaves a described picture in a nested table alone" do
      described = paragraph_with(drawing_with("A bar chart of yearly totals"))
      inner = table_with(cell_with(paragraphs: [described]))
      document.body.tables << table_with(cell_with(tables: [inner]))

      expect(rule.check(document)).to be_empty
    end
  end
end
