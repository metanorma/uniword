# frozen_string_literal: true

require "spec_helper"

# Regression specs for TODO.fix/10: the walker must only follow the
# block-level accessors each container class actually maps.
RSpec.describe Uniword::FindReplace::ParagraphWalker do
  def paragraph(text)
    run = Uniword::Wordprocessingml::Run.new(
      text: [Uniword::Wordprocessingml::Text.new(content: text)],
    )
    Uniword::Wordprocessingml::Paragraph.new(runs: [run])
  end

  def table_with_cell_text(text)
    cell = Uniword::Wordprocessingml::TableCell.new(
      paragraphs: [paragraph(text)],
    )
    row = Uniword::Wordprocessingml::TableRow.new(cells: [cell])
    Uniword::Wordprocessingml::Table.new(rows: [row])
  end

  def texts_of(*containers)
    texts = []
    described_class.each_paragraph(containers) { |p| texts << p.text }
    texts
  end

  describe "Body containers" do
    it "yields paragraphs from the body and from nested table cells" do
      body = Uniword::Wordprocessingml::Body.new
      body.paragraphs << paragraph("body text")
      body.tables << table_with_cell_text("cell text")

      expect(texts_of(body)).to eq(["body text", "cell text"])
    end
  end

  describe "table-bearing part containers" do
    it "yields paragraphs from Header content and its tables" do
      header = Uniword::Wordprocessingml::Header.new
      header.paragraphs << paragraph("header text")
      header.tables << table_with_cell_text("header cell text")

      expect(texts_of(header)).to eq(["header text", "header cell text"])
    end

    it "yields paragraphs from Footer content and its tables" do
      footer = Uniword::Wordprocessingml::Footer.new
      footer.paragraphs << paragraph("footer text")
      footer.tables << table_with_cell_text("footer cell text")

      expect(texts_of(footer)).to eq(["footer text", "footer cell text"])
    end
  end

  describe "paragraph-only containers" do
    it "yields Footnote paragraphs without probing unmapped accessors" do
      footnote = Uniword::Wordprocessingml::Footnote.new(
        paragraphs: [paragraph("footnote text")],
      )

      expect(texts_of(footnote)).to eq(["footnote text"])
    end

    it "yields Endnote paragraphs without probing unmapped accessors" do
      endnote = Uniword::Wordprocessingml::Endnote.new(
        paragraphs: [paragraph("endnote text")],
      )

      expect(texts_of(endnote)).to eq(["endnote text"])
    end

    it "yields Comment paragraphs without probing unmapped accessors" do
      comment = Uniword::Comment.new(paragraphs: [paragraph("comment text")])

      expect(texts_of(comment)).to eq(["comment text"])
    end
  end

  describe "structured document tags" do
    def sdt_wrapping(content)
      Uniword::Wordprocessingml::StructuredDocumentTag.new(content: content)
    end

    def sdt_with_paragraph(text)
      content = Uniword::Wordprocessingml::StructuredDocumentTag::Content.new(
        paragraphs: [paragraph(text)],
      )
      sdt_wrapping(content)
    end

    it "yields paragraphs and table text from sdt content" do
      sdt = sdt_with_paragraph("sdt text")
      sdt.content.tables << table_with_cell_text("sdt cell text")
      body = Uniword::Wordprocessingml::Body.new
      body.structured_document_tags << sdt

      expect(texts_of(body)).to eq(["sdt text", "sdt cell text"])
    end

    it "recurses into nested sdts" do
      content = Uniword::Wordprocessingml::StructuredDocumentTag::Content.new
      content.sdts << sdt_with_paragraph("nested sdt text")
      body = Uniword::Wordprocessingml::Body.new
      body.structured_document_tags << sdt_wrapping(content)

      expect(texts_of(body)).to eq(["nested sdt text"])
    end
  end
end
