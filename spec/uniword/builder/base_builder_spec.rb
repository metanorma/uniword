# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::BaseBuilder do
  describe ".default_model_class" do
    it "raises NotImplementedError on the base class" do
      expect { described_class.default_model_class }
        .to raise_error(NotImplementedError, /must implement/)
    end
  end

  describe "subclass integration" do
    let(:builder) { Uniword::Builder::ParagraphBuilder.new }

    it "provides attr_reader :model" do
      expect(builder.model).to be_a(Uniword::Wordprocessingml::Paragraph)
    end

    it "creates a new model when none is provided" do
      builder = Uniword::Builder::RunBuilder.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::Run)
    end

    it "wraps an existing model when provided" do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      expect(builder.model).to eq(para)
    end

    describe ".from_model" do
      it "creates a builder wrapping the given model" do
        table = Uniword::Wordprocessingml::Table.new
        builder = Uniword::Builder::TableBuilder.from_model(table)
        expect(builder.model).to eq(table)
      end
    end

    describe "#build" do
      it "returns the underlying model" do
        builder = Uniword::Builder::SectionBuilder.new
        model = builder.build
        expect(model).to be_a(Uniword::Wordprocessingml::SectionProperties)
        expect(model).to equal(builder.model)
      end
    end

    it "works with builders that have extra initialization" do
      builder = Uniword::Builder::DocumentBuilder.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end

    it "works with builders that override initialize" do
      builder = Uniword::Builder::SdtBuilder.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::StructuredDocumentTag)
    end

    it "works with NumberingBuilder" do
      builder = Uniword::Builder::NumberingBuilder.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::NumberingConfiguration)
    end

    it "works with TableRowBuilder" do
      builder = Uniword::Builder::TableRowBuilder.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::TableRow)
    end

    it "works with TableCellBuilder" do
      builder = Uniword::Builder::TableCellBuilder.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::TableCell)
    end
  end
end
