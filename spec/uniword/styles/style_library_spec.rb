# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Styles::StyleLibrary do
  describe ".load" do
    it "loads iso_standard style library" do
      library = described_class.load("iso_standard")

      expect(library.name).to eq("ISO Standard Styles")
      expect(library.version).to eq("1.0")
    end

    it "loads minimal style library" do
      library = described_class.load("minimal")

      expect(library.name).to eq("Minimal Styles")
      expect(library.version).to eq("1.0")
    end

    it "raises error for non-existent library" do
      expect do
        described_class.load("non_existent")
      end.to raise_error(Uniword::Configuration::ConfigurationError)
    end
  end

  describe "#paragraph_style" do
    let(:library) { described_class.load("iso_standard") }

    it "returns paragraph style definition" do
      style = library.paragraph_style(:title)

      expect(style).to be_a(Uniword::Styles::ParagraphStyleDefinition)
      expect(style.name).to eq("Title")
    end

    it "raises error for non-existent style" do
      expect do
        library.paragraph_style(:non_existent)
      end.to raise_error(ArgumentError, /Paragraph style not found/)
    end
  end

  describe "#character_style" do
    let(:library) { described_class.load("iso_standard") }

    it "returns character style definition" do
      style = library.character_style(:strong)

      expect(style).to be_a(Uniword::Styles::CharacterStyleDefinition)
      expect(style.name).to eq("Strong")
    end

    it "raises error for non-existent style" do
      expect do
        library.character_style(:non_existent)
      end.to raise_error(ArgumentError, /Character style not found/)
    end
  end

  describe "#list_style" do
    let(:library) { described_class.load("iso_standard") }

    it "returns list style definition" do
      style = library.list_style(:bullet_list)

      expect(style).to be_a(Uniword::Styles::ListStyleDefinition)
      expect(style.name).to eq("Bullet List")
    end

    it "has levels defined" do
      style = library.list_style(:bullet_list)

      expect(style.levels).not_to be_empty
      expect(style.levels.first[:text]).to eq("•")
    end
  end

  describe "#table_style" do
    let(:library) { described_class.load("iso_standard") }

    it "returns table style definition" do
      style = library.table_style(:standard_table)

      expect(style).to be_a(Uniword::Styles::TableStyleDefinition)
      expect(style.name).to eq("Standard Table")
    end
  end

  describe "#semantic_style" do
    let(:library) { described_class.load("iso_standard") }

    it "returns semantic style definition" do
      style = library.semantic_style(:term)

      expect(style).to be_a(Uniword::Styles::SemanticStyle)
      expect(style.name).to eq("Term")
      expect(style.semantic_type).to eq(:term)
    end
  end

  describe "style name accessors" do
    let(:library) { described_class.load("iso_standard") }

    it "returns paragraph style names" do
      names = library.paragraph_style_names

      expect(names).to include(:title, :heading_1, :body_text)
    end

    it "returns character style names" do
      names = library.character_style_names

      expect(names).to include(:emphasis, :strong, :code)
    end

    it "returns list style names" do
      names = library.list_style_names

      expect(names).to include(:bullet_list, :numbered_list)
    end
  end
end
