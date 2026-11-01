# frozen_string_literal: true

require "spec_helper"

# Value object for plain-text conversion outcomes (issue #80).
RSpec.describe Uniword::Converter::PlainTextResult do
  let(:result) do
    described_class.new(
      format: :markdown,
      direction: :docx_to_markdown,
      block_counts: { headings: 2, paragraphs: 3, tables: 1 },
      dropped_features: ["comments"],
      text: "# Title\n",
    )
  end

  describe "#total_blocks" do
    it "sums the block counts" do
      expect(result.total_blocks).to eq(6)
    end
  end

  describe "#dropped?" do
    it "reports known and unknown features" do
      expect(result.dropped?("comments")).to be(true)
      expect(result.dropped?("headers/footers")).to be(false)
    end
  end

  describe "#clean?" do
    it "is false when features were dropped" do
      expect(result).not_to be_clean
    end

    it "is true when nothing was dropped" do
      clean = described_class.new(format: :asciidoc,
                                  direction: :asciidoc_to_docx)
      expect(clean).to be_clean
    end
  end

  describe "#summary" do
    it "summarizes counts and drops" do
      expect(result.summary)
        .to eq("docx_to_markdown: converted 2 headings, 3 paragraphs, " \
               "1 tables; dropped: comments")
    end

    it "omits the drop clause when clean" do
      clean = described_class.new(format: :markdown,
                                  direction: :markdown_to_docx,
                                  block_counts: { paragraphs: 1 })
      expect(clean.summary)
        .to eq("markdown_to_docx: converted 1 paragraphs")
    end
  end

  describe "#to_h" do
    it "exposes the full record" do
      hash = result.to_h
      expect(hash[:format]).to eq(:markdown)
      expect(hash[:direction]).to eq(:docx_to_markdown)
      expect(hash[:blocks]).to eq(headings: 2, paragraphs: 3, tables: 1)
      expect(hash[:total_blocks]).to eq(6)
      expect(hash[:dropped_features]).to eq(["comments"])
      expect(hash[:summary]).to include("dropped: comments")
    end
  end

  describe "#to_json" do
    it "produces parseable JSON" do
      parsed = JSON.parse(result.to_json)
      expect(parsed["total_blocks"]).to eq(6)
      expect(parsed["dropped_features"]).to eq(["comments"])
    end
  end

  describe "payload accessors" do
    it "exposes text for to_* conversions" do
      expect(result.text).to eq("# Title\n")
      expect(result.document).to be_nil
    end

    it "exposes the document for from_* conversions" do
      document = Uniword::Wordprocessingml::DocumentRoot.new
      from = described_class.new(format: :markdown,
                                 direction: :markdown_to_docx,
                                 document: document)
      expect(from.document).to be(document)
      expect(from.text).to be_nil
    end
  end
end
