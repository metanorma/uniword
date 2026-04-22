# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "zip"
require "canon"

RSpec.describe "DOCX Round-Trip Fidelity" do
  let(:fixtures_dir) { File.expand_path("../fixtures", __dir__) }
  let(:temp_dir) { "tmp/roundtrip_spec" }

  before(:all) do
    FileUtils.mkdir_p("tmp/roundtrip_spec")
  end

  after(:all) do
    FileUtils.rm_rf("tmp/roundtrip_spec")
  end

  # Helper to extract all files from a DOCX ZIP
  def extract_docx_files(docx_path)
    files = {}
    Zip::File.open(docx_path) do |zip_file|
      zip_file.each do |entry|
        next if entry.directory?

        content = entry.get_input_stream.read
        content = content.force_encoding("UTF-8") if content.encoding == Encoding::ASCII_8BIT
        files[entry.name] = content
      end
    end
    files
  end

  # Perform a round-trip: load original, save to target path
  def roundtrip(original_path, saved_path)
    doc = Uniword.load(original_path)
    doc.save(saved_path)
    doc
  end

  # Assert all XML files are preserved (no additions, no removals, all equivalent)
  def expect_all_xml_preserved(original_path, saved_path)
    original_files = extract_docx_files(original_path)
    saved_files = extract_docx_files(saved_path)

    added = saved_files.keys - original_files.keys
    expect(added).to be_empty, "Unexpected files added: #{added.join(", ")}"

    removed = original_files.keys - saved_files.keys
    expect(removed).to be_empty, "Files removed: #{removed.join(", ")}"

    xml_files = original_files.keys.select { |f| f.end_with?(".xml", ".rels") }
    xml_files.each do |filename|
      orig = original_files[filename]
      saved = saved_files[filename]
      # Normalize content types and relationships (reconciled by Reconciler)
      if filename == "[Content_Types].xml" || filename.end_with?(".rels")
        orig = XmlNormalizers.normalize_for_roundtrip(orig)
        saved = XmlNormalizers.normalize_for_roundtrip(saved)
      end
      expect(saved).to be_xml_equivalent_to(orig),
                       "#{filename} was modified during round-trip"
    end
  end

  describe "blank/blank.docx round-trip" do
    let(:original_path) { File.join(fixtures_dir, "blank/blank.docx") }
    let(:roundtrip_path) { File.join(temp_dir, "blank_roundtrip.docx") }

    it "preserves all XML files through load/save cycle" do
      original_files = extract_docx_files(original_path)
      xml_files = original_files.keys.select { |f| f.end_with?(".xml", ".rels") }
      puts "\n  Checking #{xml_files.length} XML files for fidelity..."

      roundtrip(original_path, roundtrip_path)
      expect_all_xml_preserved(original_path, roundtrip_path)
    end

    it "preserves document structure and content" do
      doc1 = roundtrip(original_path, roundtrip_path)
      doc2 = Uniword.load(roundtrip_path)

      expect(doc2.paragraphs.length).to eq(doc1.paragraphs.length)
      expect(doc2.text).to eq(doc1.text)
    end

    it "produces valid DOCX that Word can open" do
      roundtrip(original_path, roundtrip_path)

      expect { Zip::File.open(roundtrip_path, &:entries) }.not_to raise_error

      saved_files = extract_docx_files(roundtrip_path)
      expect(saved_files["word/document.xml"]).not_to be_nil
      expect(saved_files["[Content_Types].xml"]).not_to be_nil
      expect(saved_files["_rels/.rels"]).not_to be_nil
    end
  end

  describe "word-template-apa-style-paper round-trip" do
    let(:original_path) { File.join(fixtures_dir, "word-template-apa-style-paper/word-template-apa-style-paper.docx") }
    let(:roundtrip_path) { File.join(temp_dir, "apa_roundtrip.docx") }

    it "loads and preserves content through round-trip" do
      doc1 = Uniword.load(original_path)
      expect(doc1).to be_a(Uniword::Wordprocessingml::DocumentRoot)

      doc1.save(roundtrip_path)
      doc2 = Uniword.load(roundtrip_path)

      expect(doc2.text).to eq(doc1.text)
      expect(doc2.paragraphs.length).to eq(doc1.paragraphs.length)
    end

    it "maintains XML file structure" do
      original_files = extract_docx_files(original_path)
      roundtrip(original_path, roundtrip_path)
      saved_files = extract_docx_files(roundtrip_path)

      %w[word/document.xml [Content_Types].xml _rels/.rels].each do |filename|
        expect(saved_files[filename]).not_to be_nil, "#{filename} must exist"
      end

      expect(saved_files["word/document.xml"]).to be_xml_equivalent_to(original_files["word/document.xml"])
    end
  end

  describe "word-template-paper-with-cover-and-toc round-trip" do
    let(:original_path) do
      File.join(fixtures_dir, "word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx")
    end
    let(:roundtrip_path) { File.join(temp_dir, "cover_toc_roundtrip.docx") }

    it "handles document with complex structure" do
      expect { roundtrip(original_path, roundtrip_path) }.not_to raise_error
    end

    it "preserves text content" do
      doc1 = roundtrip(original_path, roundtrip_path)
      doc2 = Uniword.load(roundtrip_path)

      expect(doc2.text.length).to be > 0
      expect(doc2.text).to eq(doc1.text)
    end
  end

  describe "Multiple round-trips" do
    let(:original_path) { File.join(fixtures_dir, "blank/blank.docx") }

    it "maintains fidelity through 3 round-trips" do
      doc1 = Uniword.load(original_path)
      original_text = doc1.text

      path1 = File.join(temp_dir, "multi_rt1.docx")
      path2 = File.join(temp_dir, "multi_rt2.docx")
      path3 = File.join(temp_dir, "multi_rt3.docx")

      doc1.save(path1)
      doc2 = Uniword.load(path1)
      doc2.save(path2)
      doc3 = Uniword.load(path2)
      doc3.save(path3)
      doc4 = Uniword.load(path3)

      expect(doc2.text).to eq(original_text)
      expect(doc3.text).to eq(original_text)
      expect(doc4.text).to eq(original_text)

      files1 = extract_docx_files(path1)
      files3 = extract_docx_files(path3)
      expect(files3["word/document.xml"]).to be_xml_equivalent_to(files1["word/document.xml"])
    end
  end

  describe "File-level comparison report" do
    let(:original_path) { File.join(fixtures_dir, "blank/blank.docx") }
    let(:roundtrip_path) { File.join(temp_dir, "report_test.docx") }

    it "generates detailed comparison of all files" do
      original_files = extract_docx_files(original_path)
      roundtrip(original_path, roundtrip_path)
      saved_files = extract_docx_files(roundtrip_path)

      puts "\n#{"=" * 60}"
      puts "DOCX Round-Trip Fidelity Report"
      puts "=" * 60
      puts "Original: #{File.basename(original_path)}"
      puts "Saved: #{File.basename(roundtrip_path)}"
      puts

      all_files = (original_files.keys + saved_files.keys).uniq.sort
      xml_files = all_files.select { |f| f.end_with?(".xml", ".rels") }
      other_files = all_files - xml_files

      puts "XML Files (#{xml_files.length}):"
      xml_files.each do |filename|
        orig = original_files[filename]
        saved = saved_files[filename]
        status = if orig && !saved
                   "REMOVED"
                 elsif !orig && saved
                   "ADDED"
                 else
                   o = orig
                   s = saved
                   if filename == "[Content_Types].xml" || filename.end_with?(".rels")
                     o = XmlNormalizers.normalize_for_roundtrip(orig)
                     s = XmlNormalizers.normalize_for_roundtrip(saved)
                   end
                   Canon::Comparison.equivalent?(o, s) ? "PRESERVED" : "MODIFIED"
                 end
        puts "  #{status}: #{filename}"
      end

      if other_files.any?
        puts "\nOther Files (#{other_files.length}):"
        other_files.each do |filename|
          orig = original_files[filename]
          saved = saved_files[filename]
          status = if orig && !saved
                     "REMOVED"
                   elsif !orig && saved
                     "ADDED"
                   elsif orig == saved
                     "PRESERVED"
                   else
                     "MODIFIED"
                   end
          puts "  #{status}: #{filename}"
        end
      end

      puts "=" * 60
      puts

      expect_all_xml_preserved(original_path, roundtrip_path)
    end
  end

  ISO_FIXTURES_DIR = File.join(__dir__, "../../spec/fixtures/uniword-private/fixtures/iso")

  ISO_FIXTURES = {
    "ISO 8601-1:2019/Amd1" => "ISO 8601-1;2019_Amd 1 ed.1 - id.81801 Publication Word (en).docx",
    "ISO 690:2021" => "ISO_690_2021-Word_document(en).docx"
  }.freeze

  ISO_FIXTURES.each do |name, filename|
    describe "#{name} round-trip" do
      let(:original_path) { File.join(ISO_FIXTURES_DIR, filename) }
      let(:roundtrip_path) { File.join(temp_dir, "#{name.downcase.tr(" :/", "_")}_roundtrip.docx") }

      before { skip "ISO fixtures not available" unless File.exist?(original_path) }

      it "loads and saves without error" do
        expect { roundtrip(original_path, roundtrip_path) }.not_to raise_error
      end

      it "preserves text content" do
        doc = roundtrip(original_path, roundtrip_path)
        expect(doc.text.length).to be > 0

        original_files = extract_docx_files(original_path)
        saved_files = extract_docx_files(roundtrip_path)
        expect(saved_files["word/document.xml"]).to be_xml_equivalent_to(original_files["word/document.xml"])
      end

      it "maintains XML structure" do
        original_files = extract_docx_files(original_path)
        roundtrip(original_path, roundtrip_path)
        saved_files = extract_docx_files(roundtrip_path)
        expect(saved_files["word/document.xml"]).to be_xml_equivalent_to(original_files["word/document.xml"])
      end
    end
  end
end
