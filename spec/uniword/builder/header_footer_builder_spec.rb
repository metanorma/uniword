# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::HeaderFooterBuilder do
  describe "header" do
    it "creates a Header model" do
      hf = described_class.new(:header)
      expect(hf.model).to be_a(Uniword::Wordprocessingml::Header)
    end
  end

  describe "footer" do
    it "creates a Footer model" do
      hf = described_class.new(:footer)
      expect(hf.model).to be_a(Uniword::Wordprocessingml::Footer)
    end
  end

  describe "#<<" do
    it "appends a string as a paragraph with run" do
      hf = described_class.new(:header)
      hf << "Header text"
      expect(hf.model.paragraphs.size).to eq(1)
      expect(hf.model.paragraphs.first.runs.first.text.to_s).to eq("Header text")
    end

    it "appends a Run to the last paragraph" do
      hf = described_class.new(:header)
      hf << "First"
      hf << Uniword::Wordprocessingml::Run.new(text: " Second")
      expect(hf.model.paragraphs.size).to eq(1)
      expect(hf.model.paragraphs.first.runs.size).to eq(2)
    end

    it "appends a Paragraph directly" do
      hf = described_class.new(:header)
      para = Uniword::Wordprocessingml::Paragraph.new
      hf << para
      expect(hf.model.paragraphs).to include(para)
    end

    it "appends a Table" do
      hf = described_class.new(:header)
      table = Uniword::Wordprocessingml::Table.new
      hf << table
      expect(hf.model.tables).to include(table)
    end

    it "appends a ParagraphBuilder" do
      hf = described_class.new(:header)
      pb = Uniword::Builder::ParagraphBuilder.new
      pb << "Built paragraph"
      hf << pb
      expect(hf.model.paragraphs.last.runs.first.text.to_s).to eq("Built paragraph")
    end

    it "raises for unsupported types" do
      hf = described_class.new(:header)
      expect { hf << 42 }.to raise_error(ArgumentError)
    end
  end

  describe "#paragraph" do
    it "creates and appends a paragraph with text" do
      hf = described_class.new(:header)
      hf.paragraph("Title")
      expect(hf.model.paragraphs.size).to eq(1)
    end
  end

  describe "#build" do
    it "returns the model" do
      hf = described_class.new(:header)
      expect(hf.build).to eq(hf.model)
    end
  end
end
