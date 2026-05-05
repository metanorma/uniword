# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Transformation::MhtmlElementRenderer do
  let(:renderer) { described_class.new }

  # Helper to build minimal OOXML model objects for testing
  def make_run(text:, style: nil, bold: nil, italic: nil, footnote_ref: nil)
    run = Uniword::Wordprocessingml::Run.new(text: text)
    if style || bold || italic
      props = Uniword::Wordprocessingml::RunProperties.new
      props.style = Uniword::Properties::StyleReference.new(value: style) if style
      if bold
        b = Uniword::Properties::Bold.new
        b.val = true
        props.bold = b
      end
      if italic
        i = Uniword::Properties::Italic.new
        i.val = true
        props.italic = i
      end
      run.properties = props
    end
    if footnote_ref
      run.footnote_reference = Uniword::Wordprocessingml::FootnoteReference.new(id: "1")
    end
    run
  end

  def make_paragraph(runs:, style: nil)
    para = Uniword::Wordprocessingml::Paragraph.new
    para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
    if style
      para.properties.style = Uniword::Properties::StyleReference.new(value: style)
    end
    runs.each { |r| para.runs << r }
    para
  end

  def make_table_cell(paragraphs:, grid_span: nil, v_merge: false,
v_merge_val: nil, header: false)
    cell = Uniword::Wordprocessingml::TableCell.new
    cell.header = header
    has_merge = grid_span || v_merge
    cell.properties = Uniword::Wordprocessingml::TableCellProperties.new if has_merge
    if grid_span
      cell.properties.grid_span = Uniword::Wordprocessingml::ValInt.new(value: grid_span)
    end
    if v_merge
      cell.properties.v_merge = Uniword::Wordprocessingml::ValInt.new(value: v_merge_val)
    end
    paragraphs.each { |p| cell.paragraphs << p }
    cell
  end

  def make_table_row(cells:)
    row = Uniword::Wordprocessingml::TableRow.new
    cells.each { |c| row.cells << c }
    row
  end

  def make_table(rows:)
    table = Uniword::Wordprocessingml::Table.new
    rows.each { |r| table.rows << r }
    table
  end

  describe "#run_to_html" do
    it "renders plain text runs" do
      run = make_run(text: "Hello World")
      expect(renderer.run_to_html(run)).to eq("Hello World")
    end

    it "renders bold runs with <b> tag" do
      run = make_run(text: "bold", bold: true)
      expect(renderer.run_to_html(run)).to eq("<b>bold</b>")
    end

    it "renders italic runs with <i> tag" do
      run = make_run(text: "italic", italic: true)
      expect(renderer.run_to_html(run)).to eq("<i>italic</i>")
    end

    it "renders footnote reference as MsoFootnoteReference span" do
      run = make_run(text: "", footnote_ref: true)
      html = renderer.run_to_html(run)
      expect(html).to include("MsoFootnoteReference")
      expect(html).to include("mso-special-character:footnote")
    end

    it "renders footnote reference as empty span structure" do
      run = Uniword::Wordprocessingml::Run.new
      run.footnote_reference = Uniword::Wordprocessingml::FootnoteReference.new(id: "3")
      html = renderer.run_to_html(run)
      expect(html).to eq(
        '<span class="MsoFootnoteReference"><span style="mso-special-character:footnote"></span></span>',
      )
    end

    it "renders endnote reference as MsoEndnoteReference span" do
      run = Uniword::Wordprocessingml::Run.new
      run.endnote_reference = Uniword::Wordprocessingml::EndnoteReference.new(id: "2")
      html = renderer.run_to_html(run)
      expect(html).to include("MsoEndnoteReference")
      expect(html).to include("mso-special-character:endnote")
    end
  end

  describe "#paragraph_to_html" do
    it "renders normal paragraphs with MsoNormal class" do
      para = make_paragraph(runs: [make_run(text: "text")])
      html = renderer.paragraph_to_html(para)
      expect(html).to include("class=MsoNormal")
      expect(html).to include("text")
      expect(html).to start_with("<p")
    end

    it "renders Title style paragraphs as <h1> with MsoTitle class" do
      para = make_paragraph(runs: [make_run(text: "Title")], style: "Title")
      html = renderer.paragraph_to_html(para)
      expect(html).to start_with("<h1")
      expect(html).to include("class=MsoTitle")
      expect(html).to end_with("</h1>")
    end

    it "renders Heading2 style paragraphs as <h2>" do
      para = make_paragraph(runs: [make_run(text: "Section")],
                            style: "Heading2")
      html = renderer.paragraph_to_html(para)
      expect(html).to start_with("<h2")
      expect(html).to end_with("</h2>")
    end

    it "renders footnote reference in paragraph content" do
      fn_run = Uniword::Wordprocessingml::Run.new
      fn_run.footnote_reference = Uniword::Wordprocessingml::FootnoteReference.new(id: "1")
      para = make_paragraph(runs: [
                              make_run(text: "Some text"),
                              fn_run,
                            ])
      html = renderer.paragraph_to_html(para)
      expect(html).to include("Some text")
      expect(html).to include("MsoFootnoteReference")
      expect(html).to include("mso-special-character:footnote")
    end
  end

  describe "#table_to_html" do
    it "renders simple tables" do
      table = make_table(rows: [
                           make_table_row(cells: [
                                            make_table_cell(paragraphs: [make_paragraph(runs: [make_run(text: "A")])]),
                                            make_table_cell(paragraphs: [make_paragraph(runs: [make_run(text: "B")])]),
                                          ]),
                         ])
      html = renderer.table_to_html(table)
      expect(html).to include("<table>")
      expect(html).to include("<td>A</td>")
      expect(html).to include("<td>B</td>")
    end

    it "renders gridSpan as colspan attribute" do
      table = make_table(rows: [
                           make_table_row(cells: [
                                            make_table_cell(
                                              paragraphs: [make_paragraph(runs: [make_run(text: "Wide")])], grid_span: 3,
                                            ),
                                          ]),
                         ])
      html = renderer.table_to_html(table)
      expect(html).to include("colspan=3")
      expect(html).to include("Wide")
    end

    it "renders header cells with <th> tag" do
      table = make_table(rows: [
                           make_table_row(cells: [
                                            make_table_cell(
                                              paragraphs: [make_paragraph(runs: [make_run(text: "Header")])], header: true,
                                            ),
                                          ]),
                         ])
      html = renderer.table_to_html(table)
      expect(html).to include("<th>")
      expect(html).to include("Header")
    end

    it "renders vMerge as rowspan and skips continuation cells" do
      # Table with vertical merge: Row 0 has start cell, Row 1 has continuation
      table = make_table(rows: [
                           make_table_row(cells: [
                                            make_table_cell(
                                              paragraphs: [make_paragraph(runs: [make_run(text: "Merged")])], v_merge: true, v_merge_val: 1,
                                            ),
                                            make_table_cell(paragraphs: [make_paragraph(runs: [make_run(text: "B1")])]),
                                          ]),
                           make_table_row(cells: [
                                            make_table_cell(
                                              paragraphs: [make_paragraph(runs: [make_run(text: "")])], v_merge: true, v_merge_val: nil,
                                            ),
                                            make_table_cell(paragraphs: [make_paragraph(runs: [make_run(text: "B2")])]),
                                          ]),
                         ])
      html = renderer.table_to_html(table)

      # Row 0 should have rowspan=2 on the merged cell
      expect(html).to include("rowspan=2")
      expect(html).to include("Merged")

      # Row 1 should have only 1 cell (continuation cell skipped)
      doc = Nokogiri::HTML(html)
      rows = doc.css("tr")
      expect(rows[0].css("td").size).to eq(2)
      expect(rows[1].css("td").size).to eq(1)
      expect(rows[1].css("td").first.text).to eq("B2")
    end
  end
end
