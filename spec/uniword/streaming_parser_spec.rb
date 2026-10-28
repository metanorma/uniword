# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::StreamingParser do
  let(:parser) { described_class.new }

  let(:zip_content) do
    {
      "word/document.xml" => <<~XML,
        <?xml version="1.0"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:r><w:t>Hello</w:t></w:r></w:p>
            <w:tbl><w:tr><w:tc><w:p><w:r><w:t>Cell</w:t></w:r></w:p></w:tc></w:tr></w:tbl>
          </w:body>
        </w:document>
      XML
    }
  end

  describe "#parse_streaming" do
    it "parses top-level paragraphs" do
      document = parser.parse_streaming(zip_content)

      expect(document.body.paragraphs.length).to eq(1)
      expect(document.body.paragraphs.first.runs.first.text.first.content)
        .to eq("Hello")
    end

    it "parses tables with rows and cells" do
      document = parser.parse_streaming(zip_content)

      expect(document.body.tables.length).to eq(1)
      row = document.body.tables.first.rows.first
      expect(row.cells.length).to eq(1)
      expect(row.cells.first.paragraphs.first.runs.first.text.first.content)
        .to eq("Cell")
    end

    it "returns an empty document when document.xml is absent" do
      document = parser.parse_streaming({})

      expect(document.body.paragraphs).to be_empty
      expect(document.body.tables).to be_empty
    end

    it "respects the paragraph limit" do
      parser.set_limits(paragraphs: 1)
      document = parser.parse_streaming(zip_content)

      expect(document.body.paragraphs.length).to eq(1)
    end
  end

  describe "#parse_metadata_only" do
    it "counts paragraphs and tables without full parsing" do
      metadata = parser.parse_metadata_only(zip_content)

      expect(metadata[:paragraph_count]).to eq(2)
      expect(metadata[:table_count]).to eq(1)
      expect(metadata[:has_images]).to be false
    end

    it "returns empty metadata when document.xml is absent" do
      expect(parser.parse_metadata_only({})).to eq({})
    end
  end

  describe ".should_stream?" do
    it "returns false for missing files" do
      expect(described_class.should_stream?("/nonexistent/file.docx"))
        .to be false
    end
  end
end
