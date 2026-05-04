# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Builder::ImageBuilder do
  let(:png_path) { File.join(FIXTURES_DIR, "sample.png") }

  describe ".read_dimensions" do
    context "with a valid PNG file" do
      it "returns [width, height] array" do
        w, h = described_class.read_dimensions(png_path)
        expect(w).to be_a(Integer)
        expect(h).to be_a(Integer)
        expect(w).to be > 0
        expect(h).to be > 0
      end
    end

    context "with a non-existent file" do
      it "returns [100, 100] fallback" do
        result = described_class.read_dimensions("/nonexistent/image.png")
        expect(result).to eq([100, 100])
      end
    end

    context "with a non-image file" do
      let(:temp_path) do
        f = Tempfile.new(%w[test .txt])
        f.write("not an image")
        f.close
        f.path
      end

      after { FileUtils.rm_f(temp_path) }

      it "returns [100, 100] fallback" do
        result = described_class.read_dimensions(temp_path)
        expect(result).to eq([100, 100])
      end
    end
  end

  describe ".register_image" do
    context "with a document model" do
      let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }

      it "returns a relationship ID" do
        r_id = described_class.register_image(doc, png_path)
        expect(r_id).to match(/^rIdImg\d+$/)
      end

      it "registers image in document image_parts" do
        described_class.register_image(doc, png_path)
        expect(doc.image_parts).not_to be_empty
      end

      it "stores correct content type for PNG" do
        described_class.register_image(doc, png_path)
        entry = doc.image_parts.values.first
        expect(entry[:content_type]).to eq("image/png")
      end

      it "stores image data" do
        described_class.register_image(doc, png_path)
        entry = doc.image_parts.values.first
        expect(entry[:data]).not_to be_nil
      end

      it "stores correct target path" do
        described_class.register_image(doc, png_path)
        entry = doc.image_parts.values.first
        expect(entry[:target]).to eq("media/sample.png")
      end
    end

    context "without a document context" do
      it "returns a generated relationship ID" do
        r_id = described_class.register_image(nil, png_path)
        expect(r_id).to match(/^rIdImg\d+$/)
      end
    end
  end

  describe ".create_drawing" do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }

    it "returns a Drawing object" do
      drawing = described_class.create_drawing(doc, png_path)
      expect(drawing).to be_a(Uniword::Wordprocessingml::Drawing)
    end

    it "creates inline drawing with extent" do
      drawing = described_class.create_drawing(doc, png_path)
      expect(drawing.inline).not_to be_nil
      expect(drawing.inline.extent).not_to be_nil
    end

    it "uses custom dimensions when provided" do
      drawing = described_class.create_drawing(doc, png_path,
                                               width: 500_000, height: 300_000)
      expect(drawing.inline.extent.cx).to eq(500_000)
      expect(drawing.inline.extent.cy).to eq(300_000)
    end

    it "auto-detects dimensions when not provided" do
      drawing = described_class.create_drawing(doc, png_path)
      expect(drawing.inline.extent.cx).to be > 0
      expect(drawing.inline.extent.cy).to be > 0
    end
  end

  describe ".create_run" do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }

    it "returns a Run with a Drawing" do
      run = described_class.create_run(doc, png_path)
      expect(run).to be_a(Uniword::Wordprocessingml::Run)
      expect(run.drawings).not_to be_empty
    end
  end
end
