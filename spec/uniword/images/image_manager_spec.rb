# frozen_string_literal: true

require "spec_helper"
require "uniword/images"
require "fileutils"

RSpec.describe Uniword::Images::ImageManager do
  let(:fixture_with_image) do
    File.expand_path("../../fixtures/docx_gem/replacement.docx", __dir__)
  end

  let(:fixture_no_image) do
    File.expand_path("../../fixtures/docx_gem/basic.docx", __dir__)
  end

  let(:sample_png) do
    File.expand_path("../../fixtures/sample.png", __dir__)
  end

  describe "#list" do
    it "returns empty array for document without images" do
      doc = Uniword::DocumentFactory.from_file(fixture_no_image)
      manager = described_class.new(doc)

      expect(manager.list).to eq([])
    end

    it "returns ImageInfo objects for document with images" do
      doc = Uniword::DocumentFactory.from_file(fixture_with_image)
      manager = described_class.new(doc)

      images = manager.list
      expect(images).not_to be_empty
      expect(images).to all(be_a(Uniword::Images::ImageInfo))
    end

    it "populates image metadata correctly" do
      doc = Uniword::DocumentFactory.from_file(fixture_with_image)
      manager = described_class.new(doc)

      image = manager.list.first
      expect(image.name).to eq("image1.png")
      expect(image.path).to include("word/media/image1.png")
      expect(image.content_type).to eq("image/png")
      expect(image.size).to be_positive
    end

    it "detects pixel dimensions for PNG images" do
      doc = Uniword::DocumentFactory.from_file(fixture_with_image)
      manager = described_class.new(doc)

      image = manager.list.first
      expect(image.width).to be_a(Integer).and be_positive
      expect(image.height).to be_a(Integer).and be_positive
    end
  end

  describe "#extract" do
    let(:output_dir) { File.join(Dir.tmpdir, "uniword_images_test_#{Process.pid}") }

    after do
      FileUtils.rm_rf(output_dir) if File.exist?(output_dir)
    end

    it "returns 0 for document without images" do
      doc = Uniword::DocumentFactory.from_file(fixture_no_image)
      manager = described_class.new(doc)

      count = manager.extract(output_dir)
      expect(count).to eq(0)
    end

    it "extracts images and returns count" do
      doc = Uniword::DocumentFactory.from_file(fixture_with_image)
      manager = described_class.new(doc)

      count = manager.extract(output_dir)
      expect(count).to be_positive
    end

    it "creates files in the output directory" do
      doc = Uniword::DocumentFactory.from_file(fixture_with_image)
      manager = described_class.new(doc)

      manager.extract(output_dir)
      extracted = Dir.glob(File.join(output_dir, "*"))
      expect(extracted).not_to be_empty
      expect(extracted.first).to end_with("image1.png")
    end

    it "writes correct file sizes" do
      doc = Uniword::DocumentFactory.from_file(fixture_with_image)
      manager = described_class.new(doc)

      images = manager.list
      manager.extract(output_dir)

      images.each do |img|
        extracted_path = File.join(output_dir, img.name)
        expect(File.size(extracted_path)).to eq(img.size)
      end
    end

    it "creates the output directory if it does not exist" do
      nested_dir = File.join(output_dir, "nested", "deep")
      doc = Uniword::DocumentFactory.from_file(fixture_with_image)
      manager = described_class.new(doc)

      count = manager.extract(nested_dir)
      expect(count).to be_positive
      expect(File.directory?(nested_dir)).to be true
    end
  end

  describe "#insert" do
    let(:output_path) { File.join(Dir.tmpdir, "uniword_insert_test_#{Process.pid}.docx") }

    after do
      FileUtils.rm_f(output_path) if File.exist?(output_path)
    end

    it "inserts an image and returns relationship id" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      manager = described_class.new(doc)

      r_id = manager.insert(sample_png)
      expect(r_id).to start_with("rIdImg")
    end

    it "registers the image in image_parts" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      manager = described_class.new(doc)

      manager.insert(sample_png)
      expect(doc.image_parts).not_to be_empty
    end

    it "adds a paragraph with a drawing to the body" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      manager = described_class.new(doc)

      manager.insert(sample_png)
      expect(doc.body.paragraphs.size).to eq(1)
    end

    it "inserts at the specified position" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      body = doc.body
      body.paragraphs << Uniword::Wordprocessingml::Paragraph.new
      body.paragraphs << Uniword::Wordprocessingml::Paragraph.new
      manager = described_class.new(doc)

      manager.insert(sample_png, position: 1)
      expect(doc.body.paragraphs.size).to eq(3)
    end

    it "appends at the end when position is beyond paragraph count" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      body = doc.body
      body.paragraphs << Uniword::Wordprocessingml::Paragraph.new
      manager = described_class.new(doc)

      manager.insert(sample_png, position: 99)
      expect(doc.body.paragraphs.size).to eq(2)
    end

    it "accepts width and height dimension strings" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      manager = described_class.new(doc)

      r_id = manager.insert(sample_png, width: "6in", height: "4in")
      expect(r_id).to start_with("rIdImg")
    end

    it "accepts description as alt text" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      manager = described_class.new(doc)

      expect do
        manager.insert(sample_png, description: "A test image")
      end.not_to raise_error
    end

    it "raises ArgumentError for missing file" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      manager = described_class.new(doc)

      expect do
        manager.insert("/nonexistent/file.png")
      end.to raise_error(ArgumentError, /not found/)
    end
  end

  describe "#remove" do
    it "returns true when image is found and removed" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      doc.image_parts = {
        "rIdImg1" => {
          data: "binary",
          target: "media/image1.png",
          content_type: "image/png"
        }
      }
      manager = described_class.new(doc)

      result = manager.remove("image1.png")
      expect(result).to be true
      expect(doc.image_parts).not_to have_key("rIdImg1")
    end

    it "returns false when image is not found" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      doc.image_parts = {}
      manager = described_class.new(doc)

      result = manager.remove("nonexistent.png")
      expect(result).to be false
    end

    it "returns false when image_parts is nil" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      manager = described_class.new(doc)

      result = manager.remove("image1.png")
      expect(result).to be false
    end
  end
end

RSpec.describe Uniword::Images::ImageInfo do
  it "stores all attributes" do
    info = described_class.new(
      name: "photo.png",
      path: "word/media/photo.png",
      content_type: "image/png",
      size: 1024,
      width: 200,
      height: 150
    )

    expect(info.name).to eq("photo.png")
    expect(info.path).to eq("word/media/photo.png")
    expect(info.content_type).to eq("image/png")
    expect(info.size).to eq(1024)
    expect(info.width).to eq(200)
    expect(info.height).to eq(150)
  end

  it "allows nil dimensions" do
    info = described_class.new(
      name: "photo.png",
      path: "word/media/photo.png",
      content_type: "image/png",
      size: 512
    )

    expect(info.width).to be_nil
    expect(info.height).to be_nil
  end

  it "is frozen after creation" do
    info = described_class.new(
      name: "photo.png",
      path: "word/media/photo.png",
      content_type: "image/png",
      size: 100
    )

    expect(info).to be_frozen
  end

  it "produces a human-readable to_s" do
    info = described_class.new(
      name: "photo.png",
      path: "word/media/photo.png",
      content_type: "image/png",
      size: 2048,
      width: 200,
      height: 150
    )

    str = info.to_s
    expect(str).to include("photo.png")
    expect(str).to include("image/png")
    expect(str).to include("200x150")
  end
end
