# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::SdtBuilder do
  describe "BaseBuilder integration" do
    it "creates a new StructuredDocumentTag by default" do
      sdt = described_class.new
      expect(sdt.model).to be_a(Uniword::Wordprocessingml::StructuredDocumentTag)
    end

    it "wraps an existing model via from_model" do
      model = Uniword::Wordprocessingml::StructuredDocumentTag.new
      sdt = described_class.from_model(model)
      expect(sdt.model).to eq(model)
    end

    it "returns the model from build" do
      sdt = described_class.new
      expect(sdt.build).to eq(sdt.model)
    end
  end

  describe "#id" do
    it "sets a custom ID" do
      sdt = described_class.new
      sdt.id(42)
      expect(sdt.properties.id.value).to eq(42)
    end

    it "auto-assigns an ID in build when none set" do
      sdt = described_class.new
      model = sdt.build
      expect(model.properties.id.value).to be_a(Integer)
    end
  end

  describe "#tag" do
    it "sets the developer tag" do
      sdt = described_class.new
      sdt.tag("myTag")
      expect(sdt.properties.tag.value).to eq("myTag")
    end
  end

  describe "#alias" do
    it "sets the display alias" do
      sdt = described_class.new
      sdt.alias("Display Name")
      expect(sdt.properties.alias_name.value).to eq("Display Name")
    end
  end

  describe ".text" do
    it "creates a text content control" do
      sdt = described_class.text(tag: "field1", alias_name: "Name")
      expect(sdt.properties.text).to be_a(Uniword::Wordprocessingml::StructuredDocumentTag::Text)
      expect(sdt.properties.tag.value).to eq("field1")
      expect(sdt.properties.alias_name.value).to eq("Name")
    end

    it "sets showing_placeholder when placeholder_text provided" do
      sdt = described_class.text(placeholder_text: "Enter name")
      expect(sdt.properties.showing_placeholder_header).to be_a(
        Uniword::Wordprocessingml::StructuredDocumentTag::ShowingPlaceholderHeader,
      )
    end
  end

  describe ".date" do
    it "creates a date picker content control" do
      sdt = described_class.date(tag: "date1", format: "yyyy-MM-dd")
      expect(sdt.properties.date).to be_a(Uniword::Wordprocessingml::StructuredDocumentTag::Date)
      expect(sdt.properties.date.date_format.value).to eq("yyyy-MM-dd")
    end
  end

  describe ".bibliography" do
    it "creates a bibliography placeholder" do
      sdt = described_class.bibliography
      expect(sdt.properties.bibliography).to be_a(
        Uniword::Wordprocessingml::StructuredDocumentTag::Bibliography,
      )
      expect(sdt.properties.doc_part_obj).not_to be_nil
    end
  end

  describe ".doc_part" do
    it "creates a document part content control" do
      sdt = described_class.doc_part(gallery: "Table of Contents")
      expect(sdt.properties.doc_part_obj.doc_part_gallery.value).to eq("Table of Contents")
    end
  end
end
