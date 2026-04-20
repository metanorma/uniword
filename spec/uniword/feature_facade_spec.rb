# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::DocumentRoot,
               "FeatureFacade" do
  let(:doc) { described_class.new }

  # --- Review ---

  describe "#list_comments" do
    it "delegates to ReviewManager" do
      expect(doc.list_comments).to be_an(Array)
    end
  end

  describe "#add_comment" do
    it "returns self for chaining" do
      result = doc.add_comment(text: "Note", author: "Alice")
      expect(result).to be(doc)
    end
  end

  describe "#accept_all_changes" do
    it "returns self for chaining" do
      result = doc.accept_all_changes
      expect(result).to be(doc)
    end
  end

  describe "#reject_all_changes" do
    it "returns self for chaining" do
      result = doc.reject_all_changes
      expect(result).to be(doc)
    end
  end

  describe "#clear_comments" do
    it "returns self for chaining" do
      result = doc.clear_comments
      expect(result).to be(doc)
    end
  end

  # --- Diff ---

  describe "#diff" do
    let(:other_doc) { described_class.new }

    it "returns a DiffResult" do
      result = doc.diff(other_doc)
      expect(result).to be_a(Uniword::Diff::DiffResult)
    end

    it "passes text_only option" do
      result = doc.diff(other_doc, text_only: true)
      expect(result).to be_a(Uniword::Diff::DiffResult)
    end
  end

  # --- Spellcheck ---

  describe "#spellcheck" do
    it "returns a SpellcheckResult" do
      result = doc.spellcheck
      expect(result).to be_a(Uniword::Spellcheck::SpellcheckResult)
    end
  end

  # --- Images ---

  describe "#list_images" do
    it "returns an array" do
      expect(doc.list_images).to be_an(Array)
    end
  end

  describe "#extract_images" do
    it "returns 0 for empty document" do
      expect(doc.extract_images("/tmp/nonexistent")).to eq(0)
    end
  end

  describe "#insert_image" do
    it "raises for missing file" do
      expect { doc.insert_image("/nonexistent.png") }
        .to raise_error(ArgumentError)
    end
  end

  describe "#remove_image" do
    it "returns self for chaining" do
      result = doc.remove_image("image1.png")
      expect(result).to be(doc)
    end
  end

  # --- Watermark ---

  describe "#add_watermark" do
    it "returns self for chaining" do
      result = doc.add_watermark("DRAFT")
      expect(result).to be(doc)
    end
  end

  describe "#remove_watermark" do
    it "returns self for chaining" do
      result = doc.remove_watermark
      expect(result).to be(doc)
    end
  end

  describe "#watermark?" do
    it "returns false for document without watermarks" do
      expect(doc.watermark?).to be(false)
    end
  end

  describe "#list_watermarks" do
    it "returns an array" do
      expect(doc.list_watermarks).to be_an(Array)
    end
  end

  # --- TOC ---

  describe "#generate_toc" do
    it "returns an array of entries" do
      expect(doc.generate_toc).to be_an(Array)
    end
  end

  describe "#insert_toc" do
    it "returns self for chaining" do
      result = doc.insert_toc
      expect(result).to be(doc)
    end
  end

  describe "#update_toc" do
    it "returns self for chaining" do
      result = doc.update_toc
      expect(result).to be(doc)
    end
  end

  # --- Headers & Footers ---

  describe "#list_headers" do
    it "returns an array" do
      expect(doc.list_headers).to be_an(Array)
    end
  end

  describe "#list_footers" do
    it "returns an array" do
      expect(doc.list_footers).to be_an(Array)
    end
  end

  describe "#add_header" do
    it "returns self for chaining" do
      result = doc.add_header("Title", type: "default")
      expect(result).to be(doc)
    end

    it "raises for invalid type" do
      expect { doc.add_header("X", type: "bogus") }
        .to raise_error(ArgumentError)
    end
  end

  describe "#add_footer" do
    it "returns self for chaining" do
      result = doc.add_footer("Page 1")
      expect(result).to be(doc)
    end
  end

  describe "#remove_headers" do
    it "returns self for chaining" do
      result = doc.remove_headers(type: "default")
      expect(result).to be(doc)
    end
  end

  describe "#remove_footers" do
    it "returns self for chaining" do
      result = doc.remove_footers(type: "default")
      expect(result).to be(doc)
    end
  end

  # --- Protection ---

  describe "#protect" do
    it "returns self for chaining" do
      result = doc.protect(:read_only)
      expect(result).to be(doc)
    end

    it "raises for invalid type" do
      expect { doc.protect(:bogus) }.to raise_error(ArgumentError)
    end
  end

  describe "#unprotect" do
    it "returns self for chaining" do
      result = doc.unprotect
      expect(result).to be(doc)
    end
  end

  describe "#protection_active?" do
    it "returns false when not protected" do
      expect(doc.protection_active?).to be(false)
    end

    it "returns true after applying protection" do
      doc.protect(:read_only)
      expect(doc.protection_active?).to be(true)
    end
  end

  describe "#protection_info" do
    it "returns nil when not protected" do
      expect(doc.protection_info).to be_nil
    end

    it "returns hash after applying protection" do
      doc.protect(:read_only)
      expect(doc.protection_info).to include(:type, :password_protected)
    end
  end

  # --- Chaining ---

  describe "method chaining" do
    it "supports chaining mutators" do
      result = doc.add_comment(text: "Fix", author: "Alice")
                 .add_watermark("DRAFT")
                 .protect(:read_only)
                 .add_header("Confidential")
                 .add_footer("Page 1")
                 .insert_toc
      expect(result).to be(doc)
    end
  end
end
