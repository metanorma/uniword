# frozen_string_literal: true

require "spec_helper"
require "uniword/generation"

RSpec.describe Uniword::Generation::DocumentGenerator do
  let(:mapper) do
    Uniword::Generation::StyleMapper.new(nil)
  end

  describe "#generate" do
    context "with structured content" do
      let(:content) do
        [
          { element: "heading_1", text: "Introduction" },
          { element: "body", text: "This is body text." },
          { element: "heading_2", text: "Scope" },
          { element: "note", text: "This is a note." },
        ]
      end

      let(:output_path) do
        File.join(Dir.tmpdir,
                  "generator_test_#{Process.pid}_#{rand(1000)}.docx")
      end

      after do
        safe_delete(output_path)
      end

      it "generates a valid DOCX file" do
        generator = described_class.new(
          style_source: "nonexistent.docx",
        )
        generator.generate(content, output_path)

        expect(File.exist?(output_path)).to be true
        expect(File.size(output_path)).to be > 0
      end

      it "produces a document with correct paragraph count" do
        generator = described_class.new(
          style_source: "nonexistent.docx",
        )
        generator.generate(content, output_path)

        doc = Uniword::DocumentFactory.from_file(output_path)
        expect(doc.paragraphs.count).to eq(4)
      end

      it "preserves text content in paragraphs" do
        generator = described_class.new(
          style_source: "nonexistent.docx",
        )
        generator.generate(content, output_path)

        doc = Uniword::DocumentFactory.from_file(output_path)
        texts = doc.paragraphs.map(&:text)
        expect(texts).to include("Introduction")
        expect(texts).to include("This is body text.")
        expect(texts).to include("Scope")
        expect(texts).to include("This is a note.")
      end
    end

    context "with table content" do
      let(:content) do
        [
          { element: "heading_1", text: "Data" },
          {
            element: "table",
            text: "",
            children: [
              ["Header 1", "Header 2"],
              ["Cell 1", "Cell 2"],
            ],
          },
        ]
      end

      let(:output_path) do
        File.join(Dir.tmpdir,
                  "generator_table_#{Process.pid}_#{rand(1000)}.docx")
      end

      after do
        safe_delete(output_path)
      end

      it "generates a document with a table" do
        generator = described_class.new(
          style_source: "nonexistent.docx",
        )
        generator.generate(content, output_path)

        doc = Uniword::DocumentFactory.from_file(output_path)
        expect(doc.paragraphs.count).to eq(1)
        expect(doc.tables.count).to eq(1)
      end
    end

    context "with empty content" do
      let(:output_path) do
        File.join(Dir.tmpdir,
                  "generator_empty_#{Process.pid}_#{rand(1000)}.docx")
      end

      after do
        safe_delete(output_path)
      end

      it "generates an empty document" do
        generator = described_class.new(
          style_source: "nonexistent.docx",
        )
        generator.generate([], output_path)

        expect(File.exist?(output_path)).to be true
        doc = Uniword::DocumentFactory.from_file(output_path)
        expect(doc.paragraphs.count).to eq(0)
      end
    end
  end
end
