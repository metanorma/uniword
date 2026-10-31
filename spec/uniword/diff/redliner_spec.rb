# frozen_string_literal: true

require "spec_helper"
require "zip"

RSpec.describe Uniword::Diff::Redliner do
  let(:work_dir) { "tmp/redliner_spec" }

  before { FileUtils.mkdir_p(work_dir) }

  after do
    Dir.glob("#{work_dir}/*.docx").each { |f| safe_delete(f) }
  end

  def build_document(texts)
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.body = Uniword::Wordprocessingml::Body.new
    texts.each do |text|
      runs = text.empty? ? [] : [Uniword::Wordprocessingml::Run.new(text: text)]
      doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: runs,
      )
    end
    doc
  end

  # The packaged document.xml is the shipped artifact; the bare
  # model to_xml renders default-namespace element names for
  # constructed documents, so assertions read the saved bytes.
  def saved_document_xml(result)
    path = File.join(work_dir, "redline-#{result.object_id}.docx")
    result.document.save(path)
    Zip::File.open(path) { |zip| zip.read("word/document.xml") }
  end

  def redline(old_texts, new_texts)
    result = described_class.new(
      build_document(old_texts), build_document(new_texts),
      author: "Alice", date: "2026-10-31T09:00:00Z"
    ).redline
    [result, saved_document_xml(result)]
  end

  describe "identical documents" do
    it "produces no tracked changes" do
      result, xml = redline(["Same text."], ["Same text."])

      expect(result).to be_empty
      expect(xml).not_to include("<w:ins")
      expect(xml).not_to include("<w:del")
      expect(result.document.body.paragraphs.first.text).to eq("Same text.")
    end
  end

  describe "modified paragraphs" do
    it "wraps inserted words in w:ins" do
      result, = redline(["Hello world"], ["Hello brave world"])

      expect(result.insertions).to eq(1)
      expect(result.deletions).to eq(0)
      ins = result.document.body.paragraphs.first.insertions.first
      expect(ins.text).to eq(" brave")
      expect(ins.author).to eq("Alice")
      expect(ins.date).to eq("2026-10-31T09:00:00Z")
    end

    it "keeps the base text around the insertion" do
      result, = redline(["Hello world"], ["Hello brave world"])

      para = result.document.body.paragraphs.first
      expect(para.text).to eq("Hello brave world")
      expect(para.runs.map(&:text_string)).to eq(["Hello", " world"])
    end

    it "wraps deleted words in w:del with w:delText only" do
      result, xml = redline(["Hello brave world"], ["Hello world"])

      expect(result.deletions).to eq(1)
      del = result.document.body.paragraphs.first.deletions.first
      expect(del.text).to eq(" brave")
      # Deleted content is w:delText, never a live w:t.
      expect(xml).to include("<w:delText")
      expect(xml).not_to include("> brave </w:t>")
    end

    it "emits one revision element per contiguous change" do
      result, = redline(["one two three"], ["one 2 three"])

      para = result.document.body.paragraphs.first
      expect(para.deletions.size).to eq(1)
      expect(para.insertions.size).to eq(1)
      expect(para.deletions.first.text).to eq("two")
      expect(para.insertions.first.text).to eq("2")
    end

    it "serializes the interleaved children in emission order" do
      _, xml = redline(["one two three"], ["one 2 three"])

      keep = xml.index("one")
      del = xml.index("<w:del ")
      insertion = xml.index("<w:ins ")
      tail = xml.index("three")
      expect(keep).to be < del
      expect(del).to be < insertion
      expect(insertion).to be < tail
    end

    it "carries the author and date on every revision element" do
      _, xml = redline(["one two three"], ["one 2 three"])

      expect(xml.scan('w:author="Alice"').size).to eq(2)
      expect(xml.scan('w:date="2026-10-31T09:00:00Z"').size).to eq(2)
    end
  end

  describe "removed paragraphs" do
    it "wraps the runs in w:del and marks the paragraph mark deleted" do
      result, xml = redline(["AAA", "KILL ME", "CCC"], ["AAA", "CCC"])

      expect(result.stats[:removed]).to eq(1)
      para = result.document.body.paragraphs[1]
      expect(para.deletions.first.text).to eq("KILL ME")
      expect(para.properties.run_properties.del).to be_a(
        Uniword::Wordprocessingml::DeletedParagraphMark,
      )
      expect(xml).to include("<w:delText>KILL ME</w:delText>")
    end

    it "hides deleted content from paragraph text" do
      result, = redline(["AAA", "KILL ME", "CCC"], ["AAA", "CCC"])

      expect(result.document.body.paragraphs.map(&:text))
        .to eq(["AAA", "", "CCC"])
    end

    it "marks a removed empty paragraph's mark deleted" do
      result, xml = redline(["AAA", "", "CCC"], ["AAA", "CCC"])

      expect(result.stats[:removed]).to eq(1)
      para = result.document.body.paragraphs[1]
      expect(para.deletions).to be_empty
      expect(para.properties.run_properties.del).to be_a(
        Uniword::Wordprocessingml::DeletedParagraphMark,
      )
      expect(xml).to include("<w:rPr><w:del ")
    end
  end

  describe "added paragraphs" do
    it "inserts the paragraph with runs wrapped in w:ins" do
      result, = redline(["AAA", "BBB"], ["AAA", "NEW MIDDLE", "BBB"])

      expect(result.stats[:added]).to eq(1)
      expect(result.insertions).to eq(1)
      para = result.document.body.paragraphs[1]
      expect(para.insertions.first.text).to eq("NEW MIDDLE")
      expect(para.properties.run_properties.ins).to be_a(
        Uniword::Wordprocessingml::InsertedParagraphMark,
      )
      expect(para.runs).to be_empty
    end

    it "places the added paragraph at its document position" do
      _, xml = redline(["AAA", "BBB"], ["AAA", "NEW MIDDLE", "BBB"])

      a_pos = xml.index("AAA")
      new_pos = xml.index("NEW MIDDLE")
      b_pos = xml.index("BBB")
      expect(a_pos).to be < new_pos
      expect(new_pos).to be < b_pos
    end

    it "marks an added empty paragraph's mark inserted" do
      result, xml = redline(["AAA", "BBB"], ["AAA", "", "BBB"])

      expect(result.stats[:added]).to eq(1)
      para = result.document.body.paragraphs[1]
      expect(para.insertions).to be_empty
      expect(para.properties.run_properties.ins).to be_a(
        Uniword::Wordprocessingml::InsertedParagraphMark,
      )
      expect(xml).to include("<w:rPr><w:ins ")
    end
  end

  describe "determinism" do
    it "produces identical output for the same pair" do
      _, first = redline(["Alpha beta.", "Gamma."], ["Alpha beta!", "Gamma."])
      _, second = redline(["Alpha beta.", "Gamma."], ["Alpha beta!", "Gamma."])

      expect(first).to eq(second)
    end
  end

  describe "file round trip" do
    it "preserves the tracked changes through save and reload" do
      old_path = File.join(work_dir, "old.docx")
      new_path = File.join(work_dir, "new.docx")
      out_path = File.join(work_dir, "redline.docx")
      build_document(["Alpha line.", "Beta line.",
                      "Gamma line."]).save(old_path)
      build_document(["Alpha line.", "Beta!", "Gamma line."]).save(new_path)

      base = Uniword::DocumentFactory.from_file(old_path)
      revised = Uniword::DocumentFactory.from_file(new_path)
      result = described_class.new(base, revised).redline
      result.document.save(out_path)

      reloaded = Uniword::DocumentFactory.from_file(out_path)
      ins = reloaded.body.paragraphs.sum { |p| p.insertions.size }
      dels = reloaded.body.paragraphs.sum { |p| p.deletions.size }
      expect(ins).to eq(result.insertions)
      expect(dels).to eq(result.deletions)
      expect(ins).to be_positive
      expect(dels).to be_positive
    end
  end

  describe "XSD validity" do
    it "produces an XSD-clean document" do
      out_path = File.join(work_dir, "redline.docx")
      base = Uniword::DocumentFactory.from_file(
        "spec/fixtures/03_two_paragraphs.docx",
      )
      revised = Uniword::DocumentFactory.from_file(
        "spec/fixtures/05_longer_text.docx",
      )
      result = described_class.new(base, revised).redline
      result.document.save(out_path)

      report = Uniword::Validation::VerifyOrchestrator
        .new(xsd_validation: true).verify(out_path)
      xsd = report.layers.find { |l| l.name == "XSD Schema" }
      # Some fixtures carry known inherited theme-part errors; the
      # redline only rewrites document.xml, so assert on that part.
      doc_errors = xsd.errors.select do |error|
        error.part.to_s.end_with?("document.xml")
      end
      expect(doc_errors).to be_empty
    end
  end
end
