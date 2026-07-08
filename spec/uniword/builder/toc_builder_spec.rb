# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::TocBuilder do
  describe ".build" do
    it "returns an array of paragraphs" do
      result = described_class.build
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result[0]).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(result[1]).to be_a(Uniword::Wordprocessingml::Paragraph)
    end

    it "creates a title paragraph with the given title" do
      result = described_class.build(title: "Contents")
      title_run = result[0].runs.first
      expect(title_run.text_string).to eq("Contents")
    end

    it "creates a TOC field paragraph with field chars" do
      result = described_class.build
      toc_para = result[1]
      expect(toc_para.field_chars.size).to eq(3)
      expect(toc_para.instr_text.size).to eq(1)
      expect(toc_para.instr_text.first.text).to include("TOC")
    end
  end
end
