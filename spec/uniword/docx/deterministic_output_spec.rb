# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::DeterministicOutput do
  describe ".reorder_entries" do
    it "puts [Content_Types].xml first" do
      result = described_class.reorder_entries(%w[word/document.xml
                                                  [Content_Types].xml])
      expect(result.first).to eq("[Content_Types].xml")
    end

    it "puts _rels/.rels second" do
      result = described_class.reorder_entries(%w[word/document.xml
                                                  [Content_Types].xml
                                                  _rels/.rels])
      expect(result[1]).to eq("_rels/.rels")
    end

    it "sorts the rest alphabetically" do
      result = described_class.reorder_entries(%w[word/z.xml word/a.xml
                                                  [Content_Types].xml])
      expect(result.last(2)).to eq(%w[word/a.xml word/z.xml])
    end

    it "preserves priority order when both priority entries present" do
      result = described_class.reorder_entries(%w[_rels/.rels
                                                  [Content_Types].xml])
      expect(result).to eq(%w[[Content_Types].xml _rels/.rels])
    end
  end

  describe "FIXED_TIMESTAMP" do
    it "is 1980-01-01 (DOS epoch)" do
      expect(described_class::FIXED_TIMESTAMP.year).to eq(1980)
      expect(described_class::FIXED_TIMESTAMP.month).to eq(1)
      expect(described_class::FIXED_TIMESTAMP.day).to eq(1)
    end
  end
end
