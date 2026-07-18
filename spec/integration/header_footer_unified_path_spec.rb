# frozen_string_literal: true

require "spec_helper"
require "zip"
require "nokogiri"

# Acceptance regression spec for TODO.validate/09 (absorbs TODO/06):
# loading a DOCX that already has headers/footers and adding a header
# through the Builder must produce exactly one relationship set — no
# duplicate rels, no duplicate content-type overrides, no dangling
# sectPr references. The write-time package integrity gate runs on
# every save (validate_on_save defaults to true), so a successful save
# is itself gate approval.
RSpec.describe "Unified header/footer path (TODO.validate/09)" do
  let(:fixture) { "spec/fixtures/docx_gem/basic.docx" }
  let(:tmp_dir) { "tmp/header_footer_unified" }
  let(:output) { File.join(tmp_dir, "builder_added.docx") }
  let(:marker) { "BUILDER ADDED FIRST HEADER" }

  before { FileUtils.mkdir_p(tmp_dir) }

  def zip_entries(path)
    Zip::File.open(path).entries.map(&:name)
  end

  def part_names(path, pattern)
    zip_entries(path).grep(pattern)
  end

  def rels(path)
    Zip::File.open(path) do |zip|
      Nokogiri::XML(zip.read("word/_rels/document.xml.rels"))
    end
  end

  def header_footer_rels(path)
    rels(path).xpath("//*[local-name()='Relationship']").select do |rel|
      rel["Type"].match?(%r{/(header|footer)\z})
    end
  end

  def content_type_overrides(path)
    Zip::File.open(path) do |zip|
      Nokogiri::XML(zip.read("[Content_Types].xml"))
        .xpath("//*[local-name()='Override']")
        .map { |o| o["PartName"] }
        .grep(%r{\A/word/(header|footer)\d+\.xml\z})
    end
  end

  def sect_pr_references(path)
    Zip::File.open(path) do |zip|
      Nokogiri::XML(zip.read("word/document.xml"))
        .xpath("//*[local-name()='headerReference' or " \
               "local-name()='footerReference']")
    end
  end

  # Namespaced attributes (r:id, w:type) are looked up by local name.
  def ref_attr(ref, name)
    ref.attribute(name)&.value
  end

  context "when adding a new header type to a loaded document" do
    before do
      doc = Uniword.load(fixture)
      builder = Uniword::Builder::DocumentBuilder.new(doc)
      builder.header(type: "first") { |h| h << marker }
      doc.save(output)
    end

    after { safe_delete(output) }

    it "emits one part file per header/footer part" do
      parts = part_names(output, %r{\Aword/(header|footer)\d+\.xml\z})
      expect(parts.sort).to eq(
        %w[word/footer1.xml word/footer2.xml word/header1.xml
           word/header2.xml word/header3.xml],
      )
    end

    it "emits exactly one relationship per part (unique ids and targets)" do
      hf_rels = header_footer_rels(output)
      expect(hf_rels.size).to eq(5)
      expect(hf_rels.map { |r| r["Id"] }.uniq.size).to eq(5)
      expect(hf_rels.map { |r| r["Target"] }.uniq.size).to eq(5)
    end

    it "emits no duplicate content-type overrides" do
      overrides = content_type_overrides(output)
      expect(overrides.size).to eq(5)
      expect(overrides.uniq.size).to eq(5)
    end

    it "resolves every sectPr reference to a rel of the matching kind" do
      hf_rels = header_footer_rels(output)
      by_id = hf_rels.to_h { |r| [r["Id"], r] }

      refs = sect_pr_references(output)
      expect(refs.size).to eq(5)
      refs.each do |ref|
        rel = by_id[ref_attr(ref, "id")]
        expect(rel).not_to be_nil,
                           "dangling sectPr reference r:id=#{ref_attr(ref, 'id')}"
        expected_kind = ref.name == "headerReference" ? "header" : "footer"
        expect(rel["Type"]).to end_with("/#{expected_kind}")
      end
    end

    it "wires the builder-added header to its own part" do
      first_ref = sect_pr_references(output).find do |ref|
        ref.name == "headerReference" && ref_attr(ref, "type") == "first"
      end
      expect(first_ref).not_to be_nil

      rel = header_footer_rels(output).find do |r|
        r["Id"] == ref_attr(first_ref, "id")
      end
      expect(rel).not_to be_nil

      xml = Zip::File.open(output) do |zip|
        zip.read("word/#{rel['Target']}")
      end
      expect(xml).to include(marker)
    end

    it "keeps the loaded parts stable on a second round-trip" do
      doc = Uniword.load(output)
      second = File.join(tmp_dir, "second_roundtrip.docx")
      doc.save(second)

      hf_rels = header_footer_rels(second)
      expect(hf_rels.size).to eq(5)
      expect(hf_rels.map { |r| r["Target"] }.uniq.size).to eq(5)
      expect(content_type_overrides(second).uniq.size).to eq(5)
    ensure
      safe_delete(second)
    end
  end

  context "when replacing an existing header type on a loaded document" do
    let(:replacement) { "REPLACED DEFAULT HEADER" }

    before do
      doc = Uniword.load(fixture)
      builder = Uniword::Builder::DocumentBuilder.new(doc)
      builder.header(type: "default") { |h| h << replacement }
      doc.save(output)
    end

    after { safe_delete(output) }

    it "reuses the existing part slot instead of duplicating" do
      parts = part_names(output, %r{\Aword/header\d+\.xml\z})
      expect(parts.sort).to eq(%w[word/header1.xml word/header2.xml])

      hf_rels = header_footer_rels(output)
      expect(hf_rels.size).to eq(4)
      expect(hf_rels.map { |r| r["Target"] }.uniq.size).to eq(4)
      expect(content_type_overrides(output).uniq.size).to eq(4)
    end

    it "serves the replacement content from the original part" do
      default_ref = sect_pr_references(output).find do |ref|
        ref.name == "headerReference" && ref_attr(ref, "type") == "default"
      end
      rel = header_footer_rels(output).find do |r|
        r["Id"] == ref_attr(default_ref, "id")
      end

      xml = Zip::File.open(output) do |zip|
        zip.read("word/#{rel['Target']}")
      end
      expect(xml).to include(replacement)
    end
  end

  describe "the public view API on a loaded document" do
    let(:doc) { Uniword.load(fixture) }

    it "exposes loaded headers by sectPr type" do
      expect(doc.headers["default"]).to be_a(Uniword::Wordprocessingml::Header)
      expect(doc.headers["even"]).to be_a(Uniword::Wordprocessingml::Header)
    end

    it "exposes loaded footers by sectPr type" do
      expect(doc.footers["default"]).to be_a(Uniword::Wordprocessingml::Footer)
      expect(doc.footers["even"]).to be_a(Uniword::Wordprocessingml::Footer)
    end

    it "shares one store between the views and header_footer_parts" do
      expect(doc.header_footer_parts.size).to eq(4)
      expect(doc.headers.size).to eq(2)
      expect(doc.footers.size).to eq(2)
    end
  end
end
