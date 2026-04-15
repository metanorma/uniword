# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Builder::FootnoteBuilder do
  let(:doc) { Uniword::Builder::DocumentBuilder.new }

  describe "#footnote" do
    it "creates a footnote and returns a Run with footnoteReference" do
      fb = described_class.new(doc)
      run = fb.footnote("Footnote text")

      expect(run).to be_a(Uniword::Wordprocessingml::Run)
      expect(run.footnote_reference).not_to be_nil
      expect(run.footnote_reference.id).to eq("1")
    end

    it "stores footnote body in document footnotes" do
      fb = described_class.new(doc)
      fb.footnote("Footnote text")

      expect(doc.model.footnotes).not_to be_nil
      expect(doc.model.footnotes.footnote_entries.size).to eq(1)

      entry = doc.model.footnotes.footnote_entries.first
      expect(entry.id).to eq("1")
      expect(entry.type).to eq("normal")
      expect(entry.paragraphs.size).to be >= 1
      expect(entry.paragraphs.first.text).to include("Footnote text")
    end

    it "assigns unique IDs to multiple footnotes" do
      fb = described_class.new(doc)
      run1 = fb.footnote("First")
      run2 = fb.footnote("Second")
      run3 = fb.footnote("Third")

      expect(run1.footnote_reference.id).to eq("1")
      expect(run2.footnote_reference.id).to eq("2")
      expect(run3.footnote_reference.id).to eq("3")
    end

    it "accepts a block for rich content" do
      fb = described_class.new(doc)
      fb.footnote do |p|
        p << Uniword::Builder.text("Bold note", bold: true)
        p << " and normal text"
      end

      entry = doc.model.footnotes.footnote_entries.first
      expect(entry.paragraphs.first.runs.size).to be >= 2
    end
  end

  describe "#endnote" do
    it "creates an endnote and returns a Run with endnoteReference" do
      fb = described_class.new(doc)
      run = fb.endnote("Endnote text")

      expect(run).to be_a(Uniword::Wordprocessingml::Run)
      expect(run.endnote_reference).not_to be_nil
      expect(run.endnote_reference.id).to eq("1")
    end

    it "stores endnote body in document endnotes" do
      fb = described_class.new(doc)
      fb.endnote("Endnote text")

      expect(doc.model.endnotes).not_to be_nil
      expect(doc.model.endnotes.endnote_entries.size).to eq(1)

      entry = doc.model.endnotes.endnote_entries.first
      expect(entry.id).to eq("1")
      expect(entry.type).to eq("normal")
      expect(entry.paragraphs.first.text).to include("Endnote text")
    end

    it "assigns unique IDs independent of footnotes" do
      fb = described_class.new(doc)
      fb.footnote("Note 1")
      run_endnote = fb.endnote("Endnote 1")
      run_footnote2 = fb.footnote("Note 2")

      expect(run_endnote.endnote_reference.id).to eq("1")
      expect(run_footnote2.footnote_reference.id).to eq("2")
    end

    it "accepts a block for rich content" do
      fb = described_class.new(doc)
      fb.endnote do |p|
        p << Uniword::Builder.text("Italic note", italic: true)
      end

      entry = doc.model.endnotes.endnote_entries.first
      expect(entry.paragraphs.first.runs.size).to be >= 1
    end
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, "#footnote" do
  it "creates a footnote via document builder" do
    doc = described_class.new
    run = doc.footnote("A footnote")

    expect(run).to be_a(Uniword::Wordprocessingml::Run)
    expect(run.footnote_reference).not_to be_nil
    expect(doc.model.footnotes.footnote_entries.size).to eq(1)
  end

  it "can be used inline in a paragraph" do
    doc = described_class.new
    doc.paragraph do |p|
      p << "See note "
      p << doc.footnote("Important detail")
    end

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(1)

    runs = paragraphs.first.runs
    expect(runs.size).to eq(2)
    expect(runs.first.text.to_s).to eq("See note ")
    expect(runs.last.footnote_reference).not_to be_nil
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, "#endnote" do
  it "creates an endnote via document builder" do
    doc = described_class.new
    run = doc.endnote("An endnote")

    expect(run).to be_a(Uniword::Wordprocessingml::Run)
    expect(run.endnote_reference).not_to be_nil
    expect(doc.model.endnotes.endnote_entries.size).to eq(1)
  end

  it "can be used inline in a paragraph" do
    doc = described_class.new
    doc.paragraph do |p|
      p << "See "
      p << doc.endnote("Reference")
    end

    runs = doc.model.body.paragraphs.first.runs
    expect(runs.size).to eq(2)
    expect(runs.last.endnote_reference).not_to be_nil
  end
end

RSpec.describe Uniword::Builder, ".line_break" do
  it "creates a Run with a line break" do
    run = described_class.line_break

    expect(run).to be_a(Uniword::Wordprocessingml::Run)
    expect(run.break).not_to be_nil
    expect(run.break.type).to eq("line")
  end

  it "can be used in a paragraph" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph do |p|
      p << "Line 1"
      p << Uniword::Builder.line_break
      p << "Line 2"
    end

    runs = doc.model.body.paragraphs.first.runs
    expect(runs.size).to eq(3)
    expect(runs[0].text.to_s).to eq("Line 1")
    expect(runs[1].break.type).to eq("line")
    expect(runs[2].text.to_s).to eq("Line 2")
  end
end

RSpec.describe Uniword::Wordprocessingml::FootnoteRef do
  it "serializes to XML" do
    ref = described_class.new
    xml = ref.to_xml(prefix: true)

    expect(xml).to include("<w:footnoteRef")
  end
end

RSpec.describe Uniword::Wordprocessingml::EndnoteRef do
  it "serializes to XML" do
    ref = described_class.new
    xml = ref.to_xml(prefix: true)

    expect(xml).to include("<w:endnoteRef")
  end
end

RSpec.describe Uniword::Wordprocessingml::Run, "footnote/endnote references" do
  it "stores a footnoteReference" do
    run = described_class.new(
      footnote_reference: Uniword::Wordprocessingml::FootnoteReference.new(id: "1")
    )

    expect(run.footnote_reference).not_to be_nil
    expect(run.footnote_reference.id).to eq("1")
  end

  it "stores an endnoteReference" do
    run = described_class.new(
      endnote_reference: Uniword::Wordprocessingml::EndnoteReference.new(id: "1")
    )

    expect(run.endnote_reference).not_to be_nil
    expect(run.endnote_reference.id).to eq("1")
  end

  it "serializes footnoteReference in XML" do
    run = described_class.new(
      footnote_reference: Uniword::Wordprocessingml::FootnoteReference.new(id: "2")
    )
    xml = run.to_xml(prefix: true)

    expect(xml).to include("<w:footnoteReference")
    expect(xml).to include('w:id="2"')
  end

  it "serializes endnoteReference in XML" do
    run = described_class.new(
      endnote_reference: Uniword::Wordprocessingml::EndnoteReference.new(id: "3")
    )
    xml = run.to_xml(prefix: true)

    expect(xml).to include("<w:endnoteReference")
    expect(xml).to include('w:id="3"')
  end
end

RSpec.describe Uniword::Wordprocessingml::DocumentRoot, "footnotes/endnotes" do
  it "stores footnotes" do
    doc = described_class.new
    fn = Uniword::Wordprocessingml::Footnotes.new
    doc.footnotes = fn

    expect(doc.footnotes).to eq(fn)
  end

  it "stores endnotes" do
    doc = described_class.new
    en = Uniword::Wordprocessingml::Endnotes.new
    doc.endnotes = en

    expect(doc.endnotes).to eq(en)
  end
end

RSpec.describe "Document with footnotes round-trip" do
  it "creates a document with footnotes that saves and loads" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.title("Footnote Test")

    doc.paragraph do |p|
      p << "This has a footnote"
      p << doc.footnote("First footnote")
    end

    doc.paragraph do |p|
      p << "This has another"
      p << doc.footnote("Second footnote")
    end

    path = "/tmp/test_footnotes.docx"
    doc.save(path)

    expect(File.exist?(path)).to be(true)

    # Verify the footnotes part exists in the ZIP
    require "zip"
    Zip::File.open(path) do |zip|
      expect(zip.find_entry("word/footnotes.xml")).not_to be_nil

      # Verify content types include footnotes
      content_types = zip.read("[Content_Types].xml")
      expect(content_types).to include("footnotes+xml")

      # Verify document relationships include footnotes
      rels = zip.read("word/_rels/document.xml.rels")
      expect(rels).to include("footnotes")

      # Verify footnote content
      fn_xml = zip.read("word/footnotes.xml")
      expect(fn_xml).to include("First footnote")
      expect(fn_xml).to include("Second footnote")
    end

    File.delete(path)
  end

  it "creates a document with endnotes that saves correctly" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.title("Endnote Test")

    doc.paragraph do |p|
      p << "Text with endnote"
      p << doc.endnote("Endnote content")
    end

    path = "/tmp/test_endnotes.docx"
    doc.save(path)

    require "zip"
    Zip::File.open(path) do |zip|
      en_xml = zip.read("word/endnotes.xml")
      expect(en_xml).to include("Endnote content")
    end

    File.delete(path)
  end
end
