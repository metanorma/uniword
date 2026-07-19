# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "zip"
require "canon"
require "nokogiri"

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
    expect(added).to be_empty, "Unexpected files added: #{added.join(', ')}"

    removed = original_files.keys - saved_files.keys
    expect(removed).to be_empty, "Files removed: #{removed.join(', ')}"

    xml_files = original_files.keys.select { |f| f.end_with?(".xml", ".rels") }
    xml_files.each do |filename|
      orig = original_files[filename]
      saved = saved_files[filename]
      # Normalize document.xml: Reconciler adds namespace declarations,
      # mc:Ignorable, and paragraph tracking attributes (rsid, paraId)
      if filename == "word/document.xml"
        orig = XmlNormalizers.normalize_document_xml(orig)
        saved = XmlNormalizers.normalize_document_xml(saved)
      else
        # All other XML files: normalize mc:Ignorable and reconciled ordering
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
      original_files.keys.select do |f|
        f.end_with?(".xml", ".rels")
      end

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
    let(:original_path) do
      File.join(fixtures_dir,
                "word-template-apa-style-paper/word-template-apa-style-paper.docx")
    end
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

      expect(XmlNormalizers.normalize_document_xml(saved_files["word/document.xml"]))
        .to be_xml_equivalent_to(XmlNormalizers.normalize_document_xml(original_files["word/document.xml"]))
    end
  end

  describe "word-template-paper-with-cover-and-toc round-trip" do
    let(:original_path) do
      File.join(fixtures_dir,
                "word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx")
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
      expect(XmlNormalizers.normalize_document_xml(files3["word/document.xml"]))
        .to be_xml_equivalent_to(XmlNormalizers.normalize_document_xml(files1["word/document.xml"]))
    end
  end

  describe "File-level comparison report" do
    let(:original_path) { File.join(fixtures_dir, "blank/blank.docx") }
    let(:roundtrip_path) { File.join(temp_dir, "report_test.docx") }

    it "generates detailed comparison of all files" do
      original_files = extract_docx_files(original_path)
      roundtrip(original_path, roundtrip_path)
      saved_files = extract_docx_files(roundtrip_path)

      all_files = (original_files.keys + saved_files.keys).uniq.sort
      xml_files = all_files.select { |f| f.end_with?(".xml", ".rels") }
      other_files = all_files - xml_files

      xml_files.each do |filename|
        orig = original_files[filename]
        saved = saved_files[filename]
        if orig && !saved
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
          if Canon::Comparison.equivalent?(o,
                                           s)
            "PRESERVED"
          else
            "MODIFIED"
          end
        end
      end

      if other_files.any?

        other_files.each do |filename|
          orig = original_files[filename]
          saved = saved_files[filename]
          if orig && !saved
            "REMOVED"
          elsif !orig && saved
            "ADDED"
          elsif orig == saved
            "PRESERVED"
          else
            "MODIFIED"
          end
        end
      end

      expect_all_xml_preserved(original_path, roundtrip_path)
    end
  end

  describe "rId stability through round-trip" do
    let(:demo_path) do
      File.join(fixtures_dir, "uniword-demo/demo_formal_integral_proper.docx")
    end
    # Relationship-rich fixture: styles, settings, webSettings, fontTable,
    # theme, numbering, footnotes, endnotes, headers, image, glossary,
    # customXml (12+ relationships in document.xml.rels alone).
    let(:apa_path) do
      File.join(fixtures_dir,
                "word-template-apa-style-paper/word-template-apa-style-paper.docx")
    end
    let(:roundtrip_path) { File.join(temp_dir, "rid_stable_roundtrip.docx") }

    # Ordered (Id, Type, Target, TargetMode) signature of one .rels part.
    def rels_signature(files, name)
      Nokogiri::XML(files[name]).xpath(
        "//xmlns:Relationship",
        "xmlns" => "http://schemas.openxmlformats.org/package/2006/relationships",
      ).map { |n| [n["Id"], n["Type"], n["Target"], n["TargetMode"]] }
    end

    it "preserves every relationship rId verbatim (byte-identical rIds)" do
      roundtrip(demo_path, roundtrip_path)
      original_files = extract_docx_files(demo_path)
      saved_files = extract_docx_files(roundtrip_path)

      rels_parts = original_files.keys.select { |f| f.end_with?(".rels") }
      expect(rels_parts.size).to be >= 2

      rels_parts.each do |name|
        expect(saved_files).to have_key(name)
        expect(rels_signature(saved_files, name))
          .to eq(rels_signature(original_files, name)),
              "rIds changed in #{name}"
      end
    end

    it "keeps every carried part's rId stable in a relationship-rich template" do
      roundtrip(apa_path, roundtrip_path)
      original_files = extract_docx_files(apa_path)
      saved_files = extract_docx_files(roundtrip_path)

      original_files.keys.select { |f| f.end_with?(".rels") }.each do |name|
        base = name.sub(%r{(^|/)_rels/[^/]+\.rels$}, '\1')
        orig = rels_signature(original_files, name)
        saved = saved_files[name] ? rels_signature(saved_files, name) : []

        # Every rel in the output must exist verbatim in the input
        # (no renumbering, no reassignment to a different target).
        expect(saved - orig).to be_empty,
                                "rels reassigned in #{name}: #{saved - orig}"

        # Every input rel whose target part survived (external rels and
        # parts uniword emits; the unmodeled glossary sub-document is a
        # known coverage gap, unrelated to rId stability) must survive.
        carried = orig.reject do |_, _, target, mode|
          next false if mode == "External"

          resolved = File.expand_path(File.join("/", base, target))[1..]
          !saved_files.key?(resolved)
        end
        expect(carried - saved).to be_empty,
                                   "carried rels lost in #{name}: " \
                                   "#{carried - saved}"
      end
    end

    it "keeps body r:id references pointing at their original rIds" do
      doc = roundtrip(apa_path, roundtrip_path)
      original_files = extract_docx_files(apa_path)
      saved_files = extract_docx_files(roundtrip_path)

      rid_refs = lambda do |xml|
        Nokogiri::XML(xml).xpath(
          "//@r:id | //@r:embed",
          "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
        ).map(&:value).sort
      end
      expect(rid_refs.call(saved_files["word/document.xml"]))
        .to eq(rid_refs.call(original_files["word/document.xml"]))
      expect(doc.text.length).to be > 0
    end
  end

  ISO_FIXTURES_DIR = File.join(__dir__,
                               "../../spec/fixtures/uniword-private/fixtures/iso")
  ISO_FIXTURES = {
    "ISO 8601-1:2019/Amd1" => "ISO 8601-1;2019_Amd 1 ed.1 - id.81801 Publication Word (en).docx",
    "ISO 690:2021" => "ISO_690_2021-Word_document(en).docx",
  }.freeze

  ISO_FIXTURES.each do |name, filename|
    describe "#{name} round-trip" do
      let(:original_path) { File.join(ISO_FIXTURES_DIR, filename) }
      let(:roundtrip_path) do
        File.join(temp_dir, "#{name.downcase.tr(' :/', '_')}_roundtrip.docx")
      end

      before do
        skip "ISO fixtures not available" unless File.exist?(original_path)
      end

      it "loads and saves without error" do
        expect { roundtrip(original_path, roundtrip_path) }.not_to raise_error
      end

      it "preserves text content" do
        doc = roundtrip(original_path, roundtrip_path)
        expect(doc.text.length).to be > 0

        original_files = extract_docx_files(original_path)
        saved_files = extract_docx_files(roundtrip_path)
        expect(XmlNormalizers.normalize_document_xml(saved_files["word/document.xml"]))
          .to be_xml_equivalent_to(XmlNormalizers.normalize_document_xml(original_files["word/document.xml"]))
      end

      it "maintains XML structure" do
        original_files = extract_docx_files(original_path)
        roundtrip(original_path, roundtrip_path)
        saved_files = extract_docx_files(roundtrip_path)
        expect(XmlNormalizers.normalize_document_xml(saved_files["word/document.xml"]))
          .to be_xml_equivalent_to(XmlNormalizers.normalize_document_xml(original_files["word/document.xml"]))
      end
    end
  end
end
