# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Transformation::HtmlElementBuilder do
  def parse_fragment(html)
    Nokogiri::HTML.fragment(html)
  end

  def first_element(html)
    parse_fragment(html).first_element_child
  end

  describe ".build_table" do
    it "builds a simple table" do
      html = first_element("<table><tr><td>Hello</td><td>World</td></tr></table>")
      table = described_class.build_table(html)
      expect(table).not_to be_nil
      expect(table.rows.size).to eq(1)
      expect(table.rows.first.cells.size).to eq(2)
    end

    it "handles colspan → gridSpan" do
      html = first_element("<table><tr><td colspan='3'>Wide</td></tr></table>")
      table = described_class.build_table(html)
      cell = table.rows.first.cells.first
      expect(cell.properties.grid_span.value).to eq(3)
    end

    it "detects <th> as header cell" do
      html = first_element("<table><tr><th>Header</th><td>Data</td></tr></table>")
      table = described_class.build_table(html)
      cells = table.rows.first.cells
      expect(cells[0].header).to be(true)
      expect(cells[1].header).to be(false)
    end

    it "handles rowspan → vMerge restart with continuation cells" do
      html = first_element(<<~HTML)
        <table>
          <tr><td rowspan='2'>Merged</td><td>B1</td></tr>
          <tr><td>B2</td></tr>
        </table>
      HTML
      table = described_class.build_table(html)
      expect(table.rows.size).to eq(2)

      # Row 0: start cell with vMerge restart + normal cell
      row0 = table.rows[0]
      expect(row0.cells.size).to eq(2)
      expect(row0.cells[0].properties.v_merge.value).to eq(1) # restart
      expect(row0.cells[1].properties&.v_merge).to be_nil

      # Row 1: continuation cell + normal cell
      row1 = table.rows[1]
      expect(row1.cells.size).to eq(2)
      cont_cell = row1.cells[0]
      expect(cont_cell.properties.v_merge.value).to be_nil # continuation (no val)
      expect(row1.cells[1].properties&.v_merge).to be_nil
    end

    it "handles both colspan and rowspan on same cell" do
      html = first_element(<<~HTML)
        <table>
          <tr><td colspan='2' rowspan='2'>Big</td><td>A</td></tr>
          <tr><td>B</td></tr>
        </table>
      HTML
      table = described_class.build_table(html)
      cell = table.rows[0].cells[0]
      expect(cell.properties.grid_span.value).to eq(2)
      expect(cell.properties.v_merge.value).to eq(1) # restart

      # Row 1 should have 2 continuation cells + 1 normal
      row1 = table.rows[1]
      expect(row1.cells[0].properties.v_merge.value).to be_nil
      expect(row1.cells[1].properties.v_merge.value).to be_nil
      expect(row1.cells[2].properties&.v_merge).to be_nil
    end

    it "returns nil for empty table" do
      html = first_element("<table></table>")
      expect(described_class.build_table(html)).to be_nil
    end
  end

  describe ".build_cell" do
    it "sets header flag for <th>" do
      html = first_element("<th>Header</th>")
      cell = described_class.build_cell(html)
      expect(cell.header).to be(true)
    end

    it "sets grid_span for colspan" do
      html = first_element("<td colspan='4'>Wide</td>")
      cell = described_class.build_cell(html)
      expect(cell.properties.grid_span.value).to eq(4)
    end

    it "sets vMerge restart for rowspan" do
      html = first_element("<td rowspan='3'>Tall</td>")
      cell = described_class.build_cell(html)
      expect(cell.properties.v_merge.value).to eq(1)
    end

    it "creates paragraph from cell text content" do
      html = first_element("<td>Hello</td>")
      cell = described_class.build_cell(html)
      expect(cell.paragraphs.size).to eq(1)
      expect(cell.paragraphs.first.runs.first.text.to_s).to eq("Hello")
    end
  end

  describe ".build_children" do
    it "handles <br> elements as break runs" do
      html = first_element("<p>Line 1<br>Line 2</p>")
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      texts = para.runs.reject { |r| r.text.to_s.empty? }
      breaks = para.runs.select(&:break)
      expect(texts.size).to eq(2)
      expect(breaks.size).to eq(1)
    end

    it "detects page-break style on <br>" do
      html = first_element("<p>Text<br style='page-break-before:always'>More</p>")
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      break_run = para.runs.find(&:break)
      expect(break_run).not_to be_nil
      expect(break_run.break.type).to eq("page")
    end

    it "handles footnote reference spans" do
      html = first_element(<<~HTML)
        <p>Text<span class="MsoFootnoteReference"><a href="#_ftn1">1</a></span></p>
      HTML
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      fn_runs = para.runs.select(&:footnote_reference)
      expect(fn_runs.size).to eq(1)
      expect(fn_runs.first.footnote_reference.id).to eq("1")
    end

    it "handles endnote reference spans" do
      html = first_element(<<~HTML)
        <p>Text<span class="MsoEndnoteReference"><a href="#_edn2">2</a></span></p>
      HTML
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      en_runs = para.runs.select(&:endnote_reference)
      expect(en_runs.size).to eq(1)
      expect(en_runs.first.endnote_reference.id).to eq("2")
    end

    it "handles hyperlink elements" do
      html = first_element('<p>Click <a href="https://example.com">here</a></p>')
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      expect(para.hyperlinks.size).to eq(1)
      expect(para.hyperlinks.first.id).to eq("https://example.com")
      expect(para.hyperlinks.first.runs.first.text.to_s).to eq("here")
    end

    it "handles internal bookmark hyperlinks" do
      html = first_element('<p>See <a href="#section1">Section 1</a></p>')
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      expect(para.hyperlinks.size).to eq(1)
      expect(para.hyperlinks.first.anchor).to eq("section1")
    end

    it "skips hyperlinks without href" do
      html = first_element("<p><a>No link</a></p>")
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      expect(para.hyperlinks).to be_empty
    end

    it "handles regular spans as runs" do
      html = first_element("<p><span>styled text</span></p>")
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      expect(para.runs.size).to eq(1)
      expect(para.runs.first.text.to_s).to eq("styled text")
    end

    it "preserves text nodes alongside special elements" do
      html = first_element("<p>Before<br>After</p>")
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html)

      texts = para.runs.map { |r| r.text.to_s }.reject(&:empty?)
      expect(texts).to eq(%w[Before After])
    end
  end

  describe ".extract_note_id" do
    it "extracts from nested anchor href" do
      html = first_element('<span class="MsoFootnoteReference"><a href="#_ftn5">5</a></span>')
      expect(described_class.extract_note_id(html)).to eq("5")
    end

    it "extracts from text content as fallback" do
      html = first_element('<span class="MsoFootnoteReference">3</span>')
      expect(described_class.extract_note_id(html)).to eq("3")
    end

    it "returns nil when no ID found" do
      html = first_element('<span class="MsoFootnoteReference"></span>')
      expect(described_class.extract_note_id(html)).to be_nil
    end
  end

  describe ".footnote_reference_span?" do
    it "returns true for MsoFootnoteReference class" do
      html = first_element('<span class="MsoFootnoteReference">1</span>')
      expect(described_class.footnote_reference_span?(html)).to be(true)
    end

    it "returns false for regular spans" do
      html = first_element("<span>text</span>")
      expect(described_class.footnote_reference_span?(html)).to be(false)
    end

    it "returns false for non-span elements" do
      html = first_element("<b>bold</b>")
      expect(described_class.footnote_reference_span?(html)).to be(false)
    end
  end

  describe ".build_paragraph content retention" do
    it "preserves paragraphs containing only a hyperlink" do
      html = first_element('<p><a href="https://example.com">click here</a></p>')
      para = described_class.build_paragraph(html)
      expect(para).not_to be_nil
      expect(para.hyperlinks.size).to eq(1)
    end

    it "preserves paragraphs containing text and a hyperlink" do
      html = first_element('<p>Click <a href="https://example.com">here</a> for info</p>')
      para = described_class.build_paragraph(html)
      expect(para).not_to be_nil
      expect(para.runs.size).to eq(2) # "Click" and "for info"
      expect(para.hyperlinks.size).to eq(1)
    end

    it "preserves paragraphs containing only footnote reference" do
      html = first_element('<p><span class="MsoFootnoteReference"><a href="#_ftn1">1</a></span></p>')
      para = described_class.build_paragraph(html)
      expect(para).not_to be_nil
      fn_runs = para.runs.select(&:footnote_reference)
      expect(fn_runs.size).to eq(1)
    end

    it "preserves paragraphs with mixed content: text, footnote ref, and hyperlink" do
      html = first_element(<<~HTML)
        <p>Some text<span class="MsoFootnoteReference"><a href="#_ftn2">2</a></span> and <a href="#_ref1">link</a></p>
      HTML
      para = described_class.build_paragraph(html)
      expect(para).not_to be_nil
      expect( # "Some text" and "and"
        para.runs.reject do |r|
          r.text.to_s.empty?
        end.size,
      ).to eq(2)
      expect(para.runs.select(&:footnote_reference).size).to eq(1)
      expect(para.hyperlinks.size).to eq(1)
    end

    it "returns nil for completely empty paragraphs" do
      html = first_element("<p></p>")
      para = described_class.build_paragraph(html)
      expect(para).to be_nil
    end

    it "returns nil for whitespace-only paragraphs" do
      html = first_element("<p>   </p>")
      para = described_class.build_paragraph(html)
      expect(para).to be_nil
    end

    it "preserves paragraphs containing only a break" do
      html = first_element("<p><br></p>")
      para = described_class.build_paragraph(html)
      expect(para).not_to be_nil
      expect(para.runs.select(&:break).size).to eq(1)
    end
  end

  describe ".create_break_run edge cases" do
    it "treats clear=all as page break" do
      html = first_element('<br clear="all">')
      para = Uniword::Wordprocessingml::Paragraph.new
      described_class.build_children(para, html.parent || html)

      # The <br> is inside a fragment; we test via create_break_run directly
      run = described_class.create_break_run(html)
      expect(run.break.type).to eq("page")
    end

    it "treats plain <br> as line break (no type)" do
      html = first_element("<br>")
      run = described_class.create_break_run(html)
      expect(run.break.type).to be_nil
    end
  end

  describe "integration: HTML table with complex merges" do
    it "handles table matching rice.doc structure" do
      # Simulates rice.doc Table 0: th rowspan=2, th colspan=4, etc.
      html = first_element(<<~HTML)
        <table>
          <tr>
            <th rowspan='2'>Defect</th>
            <th colspan='4'>Maximum permissible</th>
          </tr>
          <tr>
            <td>husked rice</td>
            <td>milled rice</td>
            <td>husked parboiled</td>
            <td>milled parboiled</td>
          </tr>
        </table>
      HTML
      table = described_class.build_table(html)

      # Row 0: 2 cells (th with rowspan=2 + th with colspan=4)
      row0 = table.rows[0]
      expect(row0.cells.size).to eq(2)
      expect(row0.cells[0].header).to be(true)
      expect(row0.cells[0].properties.v_merge.value).to eq(1) # restart
      expect(row0.cells[1].header).to be(true)
      expect(row0.cells[1].properties.grid_span.value).to eq(4)

      # Row 1: continuation cell + 4 data cells
      row1 = table.rows[1]
      expect(row1.cells.size).to eq(5)
      expect(row1.cells[0].properties.v_merge.value).to be_nil # continuation
      expect(row1.cells[0].header).not_to be(true) # continuation cells are not <th>
    end

    it "handles table with colspan=5 rows (rice.doc rows 18-19)" do
      html = first_element(<<~HTML)
        <table>
          <tr><td colspan='5'>Live insects...</td></tr>
          <tr><td colspan='5'>NOTE 1...</td></tr>
        </table>
      HTML
      table = described_class.build_table(html)

      row0 = table.rows[0]
      expect(row0.cells.size).to eq(1)
      expect(row0.cells[0].properties.grid_span.value).to eq(5)

      row1 = table.rows[1]
      expect(row1.cells.size).to eq(1)
      expect(row1.cells[0].properties.grid_span.value).to eq(5)
    end
  end
end
