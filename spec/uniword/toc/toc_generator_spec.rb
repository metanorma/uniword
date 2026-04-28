# frozen_string_literal: true

require "spec_helper"
require "uniword/toc"

RSpec.describe Uniword::Toc::TocGenerator do
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }

  def build_heading(text, level, index: nil)
    para = Uniword::Wordprocessingml::Paragraph.new
    para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
    para.properties.style = Uniword::Properties::StyleReference.new(
      value: "Heading#{level}",
    )
    para.runs << Uniword::Wordprocessingml::Run.new(text: text)
    para
  end

  def build_normal_paragraph(text)
    para = Uniword::Wordprocessingml::Paragraph.new
    para.runs << Uniword::Wordprocessingml::Run.new(text: text)
    para
  end

  describe "#generate" do
    it "returns empty array when document has no paragraphs" do
      generator = described_class.new(document)
      entries = generator.generate

      expect(entries).to eq([])
    end

    it "extracts heading paragraphs with correct levels" do
      document.body.paragraphs << build_heading("Chapter 1", 1)
      document.body.paragraphs << build_normal_paragraph("Some body text")
      document.body.paragraphs << build_heading("Section 1.1", 2)
      document.body.paragraphs << build_heading("Section 1.2", 2)
      document.body.paragraphs << build_heading("Subsection 1.2.1", 3)

      generator = described_class.new(document)
      entries = generator.generate

      expect(entries.size).to eq(4)
      expect(entries[0].level).to eq(1)
      expect(entries[0].text).to eq("Chapter 1")
      expect(entries[1].level).to eq(2)
      expect(entries[1].text).to eq("Section 1.1")
      expect(entries[2].level).to eq(2)
      expect(entries[2].text).to eq("Section 1.2")
      expect(entries[3].level).to eq(3)
      expect(entries[3].text).to eq("Subsection 1.2.1")
    end

    it "sets paragraph_index for each entry" do
      document.body.paragraphs << build_heading("First", 1)
      document.body.paragraphs << build_normal_paragraph("Body")
      document.body.paragraphs << build_heading("Second", 1)

      generator = described_class.new(document)
      entries = generator.generate

      expect(entries[0].paragraph_index).to eq(0)
      expect(entries[1].paragraph_index).to eq(2)
    end

    it "sets style_name from the paragraph style" do
      document.body.paragraphs << build_heading("Intro", 1)

      generator = described_class.new(document)
      entries = generator.generate

      expect(entries[0].style_name).to eq("Heading1")
    end

    it "skips paragraphs without heading styles" do
      document.body.paragraphs << build_normal_paragraph("Just text")
      document.body.paragraphs << build_heading("Real Heading", 1)
      document.body.paragraphs << build_normal_paragraph("More text")

      generator = described_class.new(document)
      entries = generator.generate

      expect(entries.size).to eq(1)
      expect(entries[0].text).to eq("Real Heading")
    end

    it "respects max_level option" do
      document.body.paragraphs << build_heading("Level 1", 1)
      document.body.paragraphs << build_heading("Level 2", 2)
      document.body.paragraphs << build_heading("Level 3", 3)
      document.body.paragraphs << build_heading("Level 4", 4)

      generator = described_class.new(document)
      entries = generator.generate(max_level: 2)

      expect(entries.size).to eq(2)
      expect(entries[0].text).to eq("Level 1")
      expect(entries[1].text).to eq("Level 2")
    end

    it "skips headings with empty text" do
      document.body.paragraphs << build_heading("", 1)
      document.body.paragraphs << build_heading("  ", 2)
      document.body.paragraphs << build_heading("Valid", 1)

      generator = described_class.new(document)
      entries = generator.generate

      expect(entries.size).to eq(1)
      expect(entries[0].text).to eq("Valid")
    end

    it "recognizes heading styles case-insensitively" do
      para = Uniword::Wordprocessingml::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = Uniword::Properties::StyleReference.new(
        value: "heading 2",
      )
      para.runs << Uniword::Wordprocessingml::Run.new(text: "Lowercase heading")
      document.body.paragraphs << para

      generator = described_class.new(document)
      entries = generator.generate

      expect(entries.size).to eq(1)
      expect(entries[0].level).to eq(2)
    end

    it "ignores heading levels above 6" do
      document.body.paragraphs << build_heading("Deep", 9)

      generator = described_class.new(document)
      entries = generator.generate

      expect(entries).to eq([])
    end
  end

  describe "#insert" do
    it "adds a TOC SDT to the document body" do
      document.body.paragraphs << build_heading("Chapter", 1)

      generator = described_class.new(document)
      entries = generator.generate
      generator.insert(entries, position: 0)

      sdts = document.body.structured_document_tags
      expect(sdts.size).to eq(1)
    end

    it "creates SDT with paragraphs including title and field" do
      document.body.paragraphs << build_heading("One", 1)
      document.body.paragraphs << build_heading("Two", 2)

      generator = described_class.new(document)
      entries = generator.generate
      generator.insert(entries, position: 0, max_level: 3)

      sdt = document.body.structured_document_tags.first
      paragraphs = sdt.content.paragraphs

      # Title paragraph + field paragraph + 2 entry paragraphs
      expect(paragraphs.size).to eq(4)

      # First paragraph is the title
      title_text = paragraphs[0].runs.map { |r| r.text.to_s }.join
      expect(title_text).to eq("Table of Contents")
    end

    it "includes TOC field instruction in the SDT" do
      document.body.paragraphs << build_heading("One", 1)

      generator = described_class.new(document)
      entries = generator.generate
      generator.insert(entries, position: 0, max_level: 3)

      sdt = document.body.structured_document_tags.first
      field_para = sdt.content.paragraphs[1]

      instr = field_para.instr_text.first
      expect(instr.text).to include("TOC")
      expect(instr.text).to include('"1-3"')
    end

    it "uses max_level in the field instruction" do
      document.body.paragraphs << build_heading("One", 1)

      generator = described_class.new(document)
      entries = generator.generate
      generator.insert(entries, position: 0, max_level: 2)

      sdt = document.body.structured_document_tags.first
      field_para = sdt.content.paragraphs[1]

      instr = field_para.instr_text.first
      expect(instr.text).to include('"1-2"')
    end
  end

  describe "#update" do
    it "returns empty when no existing TOC is present" do
      document.body.paragraphs << build_heading("One", 1)

      generator = described_class.new(document)
      result = generator.update

      expect(result).to eq([])
    end

    it "rebuilds an existing TOC SDT" do
      document.body.paragraphs << build_heading("First", 1)
      document.body.paragraphs << build_heading("Second", 2)

      generator = described_class.new(document)

      # Insert initial TOC
      entries = generator.generate
      generator.insert(entries, position: 0)

      # Add more headings
      document.body.paragraphs << build_heading("Third", 1)

      # Update should find the existing TOC and rebuild it
      updated = generator.update

      expect(updated.size).to eq(3)
      expect(updated[0].text).to eq("First")
      expect(updated[1].text).to eq("Second")
      expect(updated[2].text).to eq("Third")
    end
  end
end

RSpec.describe Uniword::Toc::TocEntry do
  describe "#initialize" do
    it "stores all attributes" do
      entry = described_class.new(
        level: 2,
        text: "Section 1",
        page: 5,
        style_name: "Heading2",
        paragraph_index: 10,
      )

      expect(entry.level).to eq(2)
      expect(entry.text).to eq("Section 1")
      expect(entry.page).to eq(5)
      expect(entry.style_name).to eq("Heading2")
      expect(entry.paragraph_index).to eq(10)
    end

    it "defaults optional attributes to nil" do
      entry = described_class.new(level: 1, text: "Title")

      expect(entry.page).to be_nil
      expect(entry.style_name).to be_nil
      expect(entry.paragraph_index).to be_nil
    end
  end

  describe "#to_s" do
    it "indents based on level" do
      entry = described_class.new(level: 2, text: "Section")
      expect(entry.to_s).to eq("  Section")
    end

    it "includes page number when present" do
      entry = described_class.new(level: 1, text: "Chapter", page: 3)
      expect(entry.to_s).to eq("Chapter (p.3)")
    end

    it "does not show page when nil" do
      entry = described_class.new(level: 1, text: "Chapter")
      expect(entry.to_s).to eq("Chapter")
    end
  end

  describe "#to_h" do
    it "returns a hash with all attributes" do
      entry = described_class.new(
        level: 1,
        text: "Intro",
        page: 2,
        style_name: "Heading1",
        paragraph_index: 0,
      )

      h = entry.to_h
      expect(h[:level]).to eq(1)
      expect(h[:text]).to eq("Intro")
      expect(h[:page]).to eq(2)
      expect(h[:style_name]).to eq("Heading1")
      expect(h[:paragraph_index]).to eq(0)
    end
  end
end
