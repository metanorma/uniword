# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::ImagePart do
  let(:part) do
    described_class.new(
      r_id: "rId5", target: "media/image1.png",
      data: "PNG-BYTES", content_type: "image/png",
      source_path: "spec/fixtures/sample.png"
    )
  end

  describe "#initialize" do
    it "carries the binary data as content" do
      expect(part.content).to eq("PNG-BYTES")
    end

    it "carries the relationship id" do
      expect(part.r_id).to eq("rId5")
    end

    it "carries the relationship target" do
      expect(part.target).to eq("media/image1.png")
    end

    it "carries the content type" do
      expect(part.content_type).to eq("image/png")
    end

    it "carries the source path" do
      expect(part.source_path).to eq("spec/fixtures/sample.png")
    end

    it "derives the relationship type from the registry" do
      image = Uniword::Ooxml::PartRegistry.find_by_key(:image)
      expect(part.rel_type).to eq(image.rel_type)
    end
  end

  describe "#data" do
    it "aliases the binary content" do
      expect(part.data).to eq(part.content)
    end
  end

  describe "#data=" do
    it "replaces the binary content" do
      part.data = "NEW-BYTES"
      expect(part.content).to eq("NEW-BYTES")
    end
  end

  describe "#path" do
    it "is the package-relative emission path" do
      expect(part.path).to eq("word/media/image1.png")
    end
  end

  describe "#[]" do
    it "reads the legacy :data key" do
      expect(part[:data]).to eq("PNG-BYTES")
    end

    it "reads the legacy :path key as the source path" do
      expect(part[:path]).to eq("spec/fixtures/sample.png")
    end

    it "reads the Part :target key" do
      expect(part[:target]).to eq("media/image1.png")
    end

    it "reads the Part :content_type key" do
      expect(part[:content_type]).to eq("image/png")
    end
  end

  describe ".from_hash" do
    let(:wrapped) do
      described_class.from_hash(
        data: "PNG-BYTES", target: "media/image1.png",
        content_type: "image/png", path: "spec/fixtures/sample.png"
      )
    end

    it "normalizes a legacy hash entry into an ImagePart" do
      expect(wrapped).to be_a(described_class)
    end

    it "maps the legacy :data key" do
      expect(wrapped.data).to eq("PNG-BYTES")
    end

    it "maps the legacy :target key" do
      expect(wrapped.target).to eq("media/image1.png")
    end

    it "maps the legacy :content_type key" do
      expect(wrapped.content_type).to eq("image/png")
    end

    it "maps the legacy :path key to the source path" do
      expect(wrapped.source_path).to eq("spec/fixtures/sample.png")
    end
  end

  describe "DocumentRoot#image_parts integration" do
    let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }

    it "normalizes legacy hash assignments into ImagePart objects" do
      document.image_parts = { "rIdImg1" => { target: "media/a.png" } }
      expect(document.image_parts["rIdImg1"]).to be_a(described_class)
    end

    it "keys hash-assigned parts by the collection key" do
      document.image_parts["rIdImg1"] = { target: "media/a.png" }
      expect(document.image_parts["rIdImg1"].r_id).to eq("rIdImg1")
    end

    it "keeps hash-read compatibility on stored parts" do
      document.image_parts["rIdImg1"] = { data: "D", target: "a.png" }
      expect(document.image_parts.values.first[:data]).to eq("D")
    end

    it "clears the collection when assigned nil" do
      document.image_parts["rIdImg1"] = described_class.new(data: "D")
      document.image_parts = nil
      expect(document.image_parts).to be_empty
    end
  end
end
