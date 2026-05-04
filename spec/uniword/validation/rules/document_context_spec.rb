# frozen_string_literal: true

require "spec_helper"
require "uniword/validation/rules"

RSpec.describe Uniword::Validation::Rules::DocumentContext do
  subject(:context) { described_class.new(docx_path) }

  let(:docx_path) { File.join(FIXTURES_DIR, "01_single_word.docx") }

  after { context.close }

  describe "#initialize" do
    it "stores the path" do
      expect(context.path).to eq(docx_path)
    end
  end

  describe "#zip" do
    it "returns a Zip::File" do
      expect(context.zip).to be_a(Zip::File)
    end

    it "caches the zip handle" do
      first = context.zip
      second = context.zip
      expect(first).to equal(second)
    end
  end

  describe "#close" do
    it "clears cached parts" do
      context.document_xml
      context.close
      expect(context.instance_variable_get(:@parsed_parts)).to be_empty
    end
  end

  describe "#zip_entries" do
    it "returns entry names from the package" do
      entries = context.zip_entries
      expect(entries).to be_a(Array)
      expect(entries).to include("[Content_Types].xml")
    end
  end

  describe "#part_exists?" do
    it "returns true for existing parts" do
      expect(context.part_exists?("[Content_Types].xml")).to be true
    end

    it "returns false for missing parts" do
      expect(context.part_exists?("nonexistent.xml")).to be false
    end
  end

  describe "#part" do
    it "returns a parsed document for existing parts" do
      doc = context.part("word/document.xml")
      expect(doc).not_to be_nil
    end

    it "returns nil for missing parts" do
      doc = context.part("word/nonexistent.xml")
      expect(doc).to be_nil
    end

    it "caches parsed results" do
      first = context.part("word/document.xml")
      second = context.part("word/document.xml")
      expect(first).to equal(second)
    end
  end

  describe "#document_xml" do
    it "returns parsed document.xml" do
      doc = context.document_xml
      expect(doc).not_to be_nil
    end
  end

  describe "#styles_xml" do
    it "returns parsed styles.xml or nil" do
      result = context.styles_xml
      expect(result).to be_nil.or(be_a(Moxml::Document))
    end
  end

  describe "#model" do
    it "returns a Package object" do
      pkg = context.model
      expect(pkg).to be_a(Uniword::Docx::Package)
    end

    it "caches the model" do
      first = context.model
      second = context.model
      expect(first).to equal(second)
    end
  end

  describe "#relationships" do
    it "returns an array of relationship hashes" do
      rels = context.relationships("_rels/.rels")
      expect(rels).to be_a(Array)
      expect(rels.first).to include(:id, :type, :target) if rels.any?
    end
  end

  describe "#content_types" do
    it "returns a hash of content types" do
      types = context.content_types
      expect(types).to be_a(Hash)
      expect(types).not_to be_empty
    end

    it "includes rels content type" do
      types = context.content_types
      expect(types).to have_key("rels")
    end
  end

  describe "#style_ids" do
    it "returns a Set of style IDs" do
      ids = context.style_ids
      expect(ids).to be_a(Set)
    end
  end

  describe "#numbering_ids" do
    it "returns a Set of numbering IDs" do
      ids = context.numbering_ids
      expect(ids).to be_a(Set)
    end
  end
end
