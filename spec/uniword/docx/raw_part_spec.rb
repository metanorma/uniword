# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::RawPart do
  describe "#initialize" do
    it "carries the package path verbatim (no word/ prefix)" do
      expect(described_class.new(path: "docProps/meta.xml").path)
        .to eq("docProps/meta.xml")
    end

    it "exposes the path as its only package path" do
      part = described_class.new(path: "word/glossary/document.xml")

      expect(part.package_paths).to eq(["word/glossary/document.xml"])
    end

    it "carries the content bytes" do
      expect(described_class.new(content: "\x00\x01".b).content)
        .to eq("\x00\x01".b)
    end

    it "carries the content type" do
      part = described_class.new(content_type: "application/xml")

      expect(part.content_type).to eq("application/xml")
    end

    it "records the referencing relationship id" do
      expect(described_class.new(r_id: "rId1").r_id).to eq("rId1")
    end

    it "records the referencing relationship type" do
      expect(described_class.new(rel_type: "http://x/rel").rel_type)
        .to eq("http://x/rel")
    end
  end

  describe ".from_hash" do
    it "wraps a raw hash entry's path and content" do
      part = described_class.from_hash(path: "docProps/meta.xml",
                                       content: "<meta/>")

      expect(part.content).to eq("<meta/>")
    end

    it "carries the hash entry's content type" do
      part = described_class.from_hash(content_type: "application/xml")

      expect(part.content_type).to eq("application/xml")
    end
  end

  describe "#[]" do
    it "reads the path hash-style" do
      part = described_class.new(path: "docProps/meta.xml")

      expect(part[:path]).to eq("docProps/meta.xml")
    end
  end

  describe "PartCollection keyed by :path" do
    it "fills the part path from the collection key" do
      collection = Uniword::Docx::PartCollection.new(:path, described_class)
      collection["docProps/meta.xml"] = { content: "<meta/>" }

      expect(collection["docProps/meta.xml"].path).to eq("docProps/meta.xml")
    end
  end
end
