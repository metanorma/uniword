# frozen_string_literal: true

require "spec_helper"
require "json"
require "uniword/diff"

RSpec.describe Uniword::Diff::DocumentDiffer do
  let(:old_doc) { Uniword::Wordprocessingml::DocumentRoot.new }
  let(:new_doc) { Uniword::Wordprocessingml::DocumentRoot.new }

  describe "#diff" do
    context "with identical documents" do
      before do
        add_paragraph(old_doc, "Hello World")
        add_paragraph(new_doc, "Hello World")
      end

      it "returns no text changes" do
        result = described_class.new(old_doc, new_doc).diff
        expect(result.text_changes).to be_empty
      end
    end

    context "with empty documents" do
      it "returns no text changes" do
        result = described_class.new(old_doc, new_doc).diff
        expect(result.text_changes).to be_empty
      end
    end

    context "with text additions" do
      before do
        add_paragraph(old_doc, "First paragraph")
        add_paragraph(new_doc, "First paragraph")
        add_paragraph(new_doc, "Second paragraph")
      end

      it "detects added paragraphs" do
        result = described_class.new(old_doc, new_doc).diff
        expect(result.text_changes.size).to eq(1)
        expect(result.text_changes.first[:change]).to eq(:added)
        expect(result.text_changes.first[:new]).to eq("Second paragraph")
      end
    end

    context "with text removals" do
      before do
        add_paragraph(old_doc, "First paragraph")
        add_paragraph(old_doc, "Second paragraph")
        add_paragraph(new_doc, "First paragraph")
      end

      it "detects removed paragraphs" do
        result = described_class.new(old_doc, new_doc).diff
        expect(result.text_changes.size).to eq(1)
        expect(result.text_changes.first[:change]).to eq(:removed)
        expect(result.text_changes.first[:old]).to eq("Second paragraph")
      end
    end

    context "with text modifications" do
      before do
        add_paragraph(old_doc, "Hello World")
        add_paragraph(new_doc, "Hello Universe")
      end

      it "detects text differences" do
        result = described_class.new(old_doc, new_doc).diff
        expect(result.text_changes.size).to be >= 1
        changes = result.text_changes
        old_texts = changes.filter_map { |c| c[:old] }
        new_texts = changes.filter_map { |c| c[:new] }
        expect(old_texts).to include("Hello World")
        expect(new_texts).to include("Hello Universe")
      end
    end

    context "with mixed changes" do
      before do
        add_paragraph(old_doc, "Unchanged")
        add_paragraph(old_doc, "Old second")
        add_paragraph(old_doc, "Removed paragraph")
        add_paragraph(new_doc, "Unchanged")
        add_paragraph(new_doc, "New second")
        add_paragraph(new_doc, "New third")
      end

      it "detects changes between documents" do
        result = described_class.new(old_doc, new_doc).diff
        changes = result.text_changes
        expect(changes.size).to be >= 2
        changes_types = changes.map { |c| c[:change] }
        expect(changes_types).to include(:modified)
      end
    end

    context "with text_only option" do
      it "skips formatting comparison when text_only is true" do
        result = described_class.new(
          old_doc, new_doc, options: { text_only: true }
        ).diff
        expect(result.format_changes).to be_empty
      end
    end
  end

  describe "DiffResult" do
    it "returns a DiffResult instance" do
      result = described_class.new(old_doc, new_doc).diff
      expect(result).to be_a(Uniword::Diff::DiffResult)
    end

    context "with changes" do
      before do
        add_paragraph(old_doc, "Old text")
        add_paragraph(new_doc, "New text")
      end

      it "provides a summary" do
        result = described_class.new(old_doc, new_doc).diff
        expect(result.summary).to include("text change")
      end

      it "serializes to JSON" do
        result = described_class.new(old_doc, new_doc).diff
        json = result.to_json
        parsed = JSON.parse(json)
        expect(parsed).to have_key("text_changes")
        expect(parsed).to have_key("summary")
      end

      it "converts to a hash" do
        result = described_class.new(old_doc, new_doc).diff
        hash = result.to_h
        expect(hash).to be_a(Hash)
        expect(hash).to have_key(:text_changes)
        expect(hash).to have_key(:format_changes)
        expect(hash).to have_key(:structure_changes)
        expect(hash).to have_key(:metadata_changes)
        expect(hash).to have_key(:style_changes)
      end
    end

    it "counts total changes correctly" do
      add_paragraph(old_doc, "Old")
      add_paragraph(new_doc, "New")
      add_paragraph(new_doc, "Added")
      result = described_class.new(old_doc, new_doc).diff
      expect(result.total_changes).to be > 0
    end
  end

  describe "structure changes" do
    it "detects paragraph count changes" do
      add_paragraph(old_doc, "One")
      add_paragraph(old_doc, "Two")
      add_paragraph(new_doc, "One")

      result = described_class.new(old_doc, new_doc).diff
      struct = result.structure_changes
      para_change = struct.find { |c| c[:change] == :paragraph_count }
      expect(para_change).not_to be_nil
      expect(para_change[:old_count]).to eq(2)
      expect(para_change[:new_count]).to eq(1)
    end

    it "detects table count changes" do
      add_paragraph(old_doc, "Text")
      add_paragraph(new_doc, "Text")
      old_doc.body.tables << Uniword::Wordprocessingml::Table.new

      result = described_class.new(old_doc, new_doc).diff
      struct = result.structure_changes
      table_change = struct.find { |c| c[:change] == :table_count }
      expect(table_change).not_to be_nil
      expect(table_change[:old_count]).to eq(1)
      expect(table_change[:new_count]).to eq(0)
    end
  end

  describe "LCS alignment" do
    it "correctly aligns common paragraphs" do
      add_paragraph(old_doc, "Keep this")
      add_paragraph(old_doc, "Remove this")
      add_paragraph(old_doc, "Also keep this")
      add_paragraph(new_doc, "Keep this")
      add_paragraph(new_doc, "Also keep this")
      add_paragraph(new_doc, "Brand new")

      result = described_class.new(old_doc, new_doc).diff
      texts = result.text_changes
      changes = texts.map { |c| c[:change] }

      expect(changes).to include(:removed, :added)
    end

    it "handles completely different documents" do
      add_paragraph(old_doc, "Alpha")
      add_paragraph(new_doc, "Beta")

      result = described_class.new(old_doc, new_doc).diff
      expect(result.text_changes.size).to be >= 1
    end
  end

  private

  # Helper to add a paragraph with plain text to a document.
  def add_paragraph(doc, text)
    para = Uniword::Wordprocessingml::Paragraph.new
    run = Uniword::Wordprocessingml::Run.new(text: text)
    para.runs << run
    doc.body.paragraphs << para
  end
end
