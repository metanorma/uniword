# frozen_string_literal: true

require "spec_helper"
require "fileutils"

# TODO.validate/07 — CI XSD validation of generated output.
#
# First end-to-end XSD validation of real library output: a corpus of
# Builder-generated documents (paragraphs, runs, tables, styles, numbering,
# headers/footers, images, footnotes, bookmarks, hyperlinks) plus a
# selection of spec/fixtures DOCX round-trips (load -> save). Every corpus
# document is saved to test_output/xsd_corpus/ and verified via
# VerifyOrchestrator with xsd_validation: true; each XSD-coverable part
# (per SchemaRegistry.primary_schema_for_part) is checked.
#
# Assertion policy (per the item):
# - OPC parts ([Content_Types].xml, all .rels, docProps/core.xml,
#   docProps/app.xml): HARD FAIL on any XSD error. core.xml is validated
#   offline: ecma/opc-coreProperties.xsd's Dublin Core imports were
#   localized (bundled dc.xsd/dcterms.xsd/dcmitype.xsd/xml.xsd with
#   relative schemaLocations) and SchemaRegistry maps all three docProps
#   parts.
# - WordprocessingML (and other non-OPC) parts: hard-fail on non-MCE
#   errors. XmlSchemaValidator preprocesses each part per its own
#   mc:Ignorable declaration (stripping ignorable-marked attributes,
#   extension elements, and the mc:Ignorable attribute itself —
#   TODO.refactor/06), so w14/w15 extension content no longer produces
#   false errors; full validity after preprocessing is asserted for the
#   whole corpus. Fixtures whose OWN content is schema-invalid
#   independent of MCE remain `pending` with root causes below.
RSpec.describe "XSD validation of generated output" do
  OUTPUT_DIR = File.join("test_output", "xsd_corpus").freeze

  # Package parts that carry OPC-level structure. Errors here always fail.
  OPC_PART_PATTERN = %r{\A(?:\[Content_Types\]\.xml|.+\.rels|docProps/(?:core|app)\.xml)\z}

  # Namespace URIs treated as MCE extension content (see header comment).
  MCE_NAMESPACE_PREFIXES = [
    "http://schemas.microsoft.com/",
    "http://schemas.openxmlformats.org/markup-compatibility/2006",
  ].freeze

  # -------------------------------------------------------------------
  # Corpus definition
  # -------------------------------------------------------------------

  # Builder-generated documents, one per exercised feature area.
  BUILDER_DOCS = {
    "paragraphs_runs" => lambda do |doc|
      doc.heading("Heading One", level: 1)
      doc.heading("Heading Two", level: 2)
      doc.paragraph do |p|
        p << "Plain "
        p << Uniword::Builder.text("bold", bold: true)
        p << " "
        p << Uniword::Builder.text("italic", italic: true)
        p << " "
        p << Uniword::Builder.text("underlined", underline: true)
        p << " "
        p << Uniword::Builder.text("colored", color: "FF0000")
        p << " "
        p << Uniword::Builder.text("sized", size: 14)
        p << " "
        p << Uniword::Builder.text("highlighted", highlight: "yellow")
        p << " "
        p << Uniword::Builder.text("struck", strike: true)
      end
      doc.paragraph { |p| p << "Second paragraph" }
    end,
    "tables" => lambda do |doc|
      doc.paragraph { |p| p << "Table below" }
      doc.table do |t|
        t.row do |r|
          r.cell { |c| c << "H1" }
          r.cell { |c| c << "H2" }
        end
        t.row do |r|
          r.cell { |c| c << "A1" }
          r.cell { |c| c << "A2" }
        end
      end
      doc.paragraph { |p| p << "After table" }
    end,
    "styles" => lambda do |doc|
      doc.define_style("Emphasis Plus", base_on: "Normal") do |s|
        s.italic(true)
        s.color("0000FF")
      end
      doc.heading("Styled", level: 1)
      doc.paragraph { |p| p << "Body text" }
    end,
    "numbering" => lambda do |doc|
      doc.bullet_list do |l|
        l.item("Bullet one")
        l.item("Bullet two")
      end
      doc.numbered_list do |l|
        l.item("Step one")
        l.item("Step two")
      end
    end,
    "headers_footers" => lambda do |doc|
      doc.header { |h| h << Uniword::Builder.text("Header text", bold: true) }
      doc.footer do |f|
        f << "Page "
        f << Uniword::Builder.page_number_field
      end
      doc.paragraph { |p| p << "Body with header and footer" }
    end,
    "images" => lambda do |doc|
      doc.paragraph { |p| p << "Image below" }
      doc.image(File.join(FIXTURES_DIR, "sample.png"),
                width: 200_000, height: 200_000, alt_text: "sample image")
    end,
    "footnotes" => lambda do |doc|
      doc.paragraph do |p|
        p << "Text with a footnote"
        p << doc.footnote("Footnote content")
      end
    end,
    "bookmarks_hyperlinks" => lambda do |doc|
      doc.bookmark("target1") { |p| p << "Bookmarked paragraph" }
      doc.paragraph do |p|
        p << "See "
        p << Uniword::Builder.hyperlink("https://example.com", "Example Site")
      end
    end,
  }.freeze

  # Round-trip fixtures whose own content is schema-valid (modulo MCE):
  # hard assertions apply to their WordprocessingML parts too.
  CLEAN_ROUNDTRIP_FIXTURES = {
    "01_single_word-repaired" => "01_single_word-repaired.docx",
    "02_two_words-repaired" => "02_two_words-repaired.docx",
    "03_two_paragraphs-repaired" => "03_two_paragraphs-repaired.docx",
    "04_with_empty_para-repaired" => "04_with_empty_para-repaired.docx",
    "05_longer_text-repaired" => "05_longer_text-repaired.docx",
    "06_cjk_text-repaired" => "06_cjk_text-repaired.docx",
    "docx_gem_basic" => "docx_gem/basic.docx",
    "docx_gem_formatting" => "docx_gem/formatting.docx",
    "docx_gem_saving" => "docx_gem/saving.docx",
    "docx_gem_test_with_style" => "docx_gem/test_with_style.docx",
    "docx_gem_weird" => "docx_gem/weird_docx.docx",
    "docx_gem_editing" => "docx_gem/editing.docx",
    "docx_gem_office365" => "docx_gem/office365.docx",
    "docx_gem_internal_links" => "docx_gem/internal-links.docx",
  }.freeze

  # Round-trip fixtures whose OWN content is schema-invalid independent of
  # MCE (verified: the errors are present in the fixture before round-trip).
  # Round-trip preserves input content and element order by design
  # (fidelity), so the invalid content survives the save. The non-MCE
  # assertion for these is `pending` with the fixture-specific root cause.
  # Save-time content normalization is validation-engine scope:
  # TODO.validate/11 (validation engine consolidation).
  INHERITED_ERROR_FIXTURES = {
    "01_single_word" => {
      file: "01_single_word.docx",
      reason: "fixture styles.xml has w:sz/w:szCs/w:kern without the " \
              "required w:val and w:tblInd out of order, settings.xml has " \
              "w:proofState out of order, fontTable.xml has w:sig without " \
              "required usb/csb attributes — all pre-existing in the " \
              "fixture and preserved by round-trip fidelity",
    },
    "02_two_words" => {
      file: "02_two_words.docx",
      reason: "fixture styles.xml has w:sz/w:szCs/w:kern without the " \
              "required w:val and w:tblInd out of order, settings.xml has " \
              "w:proofState out of order, fontTable.xml has w:sig without " \
              "required usb/csb attributes — all pre-existing in the " \
              "fixture and preserved by round-trip fidelity",
    },
    "03_two_paragraphs" => {
      file: "03_two_paragraphs.docx",
      reason: "fixture styles.xml has w:sz/w:szCs/w:kern without the " \
              "required w:val and w:tblInd out of order, settings.xml has " \
              "w:proofState out of order, fontTable.xml has w:sig without " \
              "required usb/csb attributes — all pre-existing in the " \
              "fixture and preserved by round-trip fidelity",
    },
    "04_with_empty_para" => {
      file: "04_with_empty_para.docx",
      reason: "fixture styles.xml has w:sz/w:szCs/w:kern without the " \
              "required w:val and w:tblInd out of order, settings.xml has " \
              "w:proofState out of order, fontTable.xml has w:sig without " \
              "required usb/csb attributes — all pre-existing in the " \
              "fixture and preserved by round-trip fidelity",
    },
    "05_longer_text" => {
      file: "05_longer_text.docx",
      reason: "fixture styles.xml has w:sz/w:szCs/w:kern without the " \
              "required w:val and w:tblInd out of order, settings.xml has " \
              "w:proofState out of order, fontTable.xml has w:sig without " \
              "required usb/csb attributes — all pre-existing in the " \
              "fixture and preserved by round-trip fidelity",
    },
    "06_cjk_text" => {
      file: "06_cjk_text.docx",
      reason: "fixture styles.xml has w:sz/w:szCs/w:kern without the " \
              "required w:val and w:tblInd out of order, settings.xml has " \
              "w:proofState out of order, fontTable.xml has w:sig without " \
              "required usb/csb attributes — all pre-existing in the " \
              "fixture and preserved by round-trip fidelity",
    },
    "docx_gem_tables" => {
      file: "docx_gem/tables.docx",
      reason: "fixture w:tblBorders declares w:right after w:insideH " \
              "(CT_TblBorders requires right before insideH/insideV) — " \
              "pre-existing in the fixture, preserved by round-trip fidelity",
    },
    "docx_gem_no_styles" => {
      file: "docx_gem/no_styles.docx",
      reason: "fixture w:pgMar lacks the required w:header/w:footer/" \
              "w:gutter attributes (docx gem writes minimal pgMar) — " \
              "pre-existing in the fixture, preserved by round-trip fidelity",
    },
    "docx_gem_substitution" => {
      file: "docx_gem/substitution.docx",
      reason: "fixture w:pgMar lacks the required w:gutter attribute " \
              "(docx gem writes minimal pgMar) — pre-existing in the " \
              "fixture, preserved by round-trip fidelity",
    },
  }.freeze

  # -------------------------------------------------------------------
  # Corpus generation + verification (once per document, cached)
  # -------------------------------------------------------------------

  before(:all) do
    FileUtils.mkdir_p(OUTPUT_DIR)

    BUILDER_DOCS.each do |name, build|
      doc = Uniword::Builder::DocumentBuilder.new
      build.call(doc)
      # Save runs the write-time package integrity gate
      # (Uniword.configuration.validate_on_save == true) and raises
      # Uniword::ValidationError on invalid packages.
      doc.save(File.join(OUTPUT_DIR, "builder_#{name}.docx"))
    end

    (CLEAN_ROUNDTRIP_FIXTURES.values + INHERITED_ERROR_FIXTURES.values.map do |v|
      v[:file]
    end).each do |fixture|
      src = File.join(FIXTURES_DIR, fixture)
      dst = File.join(OUTPUT_DIR, "rt_#{File.basename(fixture)}")
      Uniword::DocumentFactory.from_file(src).save(dst)
    end
  end

  # Verify once per file; reports are plain data and safe to memoize.
  # Kept in a module — an example-group constant is frozen by RSpec (and
  # a frozen Hash cannot be mutated anyway).
  module ReportCache
    @reports = {}

    class << self
      def fetch(path)
        @reports[path] ||=
          Uniword::Validation::VerifyOrchestrator.new(xsd_validation: true)
            .verify(path)
      end
    end
  end

  def verify_once(path)
    ReportCache.fetch(path)
  end

  def layer(report, name)
    report.layers.find { |l| l.name == name }
  end

  def xsd_issues(report)
    layer(report, "XSD Schema").issues
  end

  # XSD error-severity issues, plus XSD-003 "schema unavailable / cannot
  # validate" warnings: an unavailable schema on a part we expect to
  # validate must not silently pass. (XSD-003 "unknown namespace" infos are
  # informational and excluded.)
  def xsd_findings(report)
    xsd_issues(report).select do |issue|
      issue.severity == "error" ||
        (issue.severity == "warning" && issue.code == "XSD-003")
    end
  end

  # Issue messages carry a "part: message" prefix (XmlSchemaValidator).
  def issue_part(issue)
    issue.message.split(": ", 2).first
  end

  def opc_findings(report)
    xsd_findings(report).select do |issue|
      issue_part(issue).match?(OPC_PART_PATTERN)
    end
  end

  def non_opc_findings(report)
    xsd_findings(report).reject do |issue|
      issue_part(issue).match?(OPC_PART_PATTERN)
    end
  end

  # True when the offending element or attribute lives in an MCE extension
  # namespace (see header comment). libxml reports the offending attribute
  # as "attribute '{uri}name'" and the offending element as the first
  # "{uri}name" in the message.
  def mce_attributable?(issue)
    ns = issue.message[/attribute '\{([^}]*)\}/, 1] ||
      issue.message[/\{([^}]*)\}/, 1]
    return false unless ns

    MCE_NAMESPACE_PREFIXES.any? { |prefix| ns.start_with?(prefix) }
  end

  def non_mce_findings(report)
    non_opc_findings(report).reject { |issue| mce_attributable?(issue) }
  end

  def format_issues(issues)
    issues.map { |i| "  [#{i.code}] #{i.message}" }.join("\n")
  end

  # -------------------------------------------------------------------
  # Shared examples
  # -------------------------------------------------------------------

  # Hard assertions applied to every corpus document.
  RSpec.shared_examples "an XSD-validated package" do |path|
    it "passes OPC package validation" do
      opc = layer(verify_once(path), "OPC Package")
      expect(opc.status).to eq("pass"),
                            "OPC layer errors:\n" \
                            "#{format_issues(opc.issues.select(&:error?))}"
    end

    it "has no XSD errors in OPC parts " \
       "([Content_Types].xml, .rels, docProps)" do
      findings = opc_findings(verify_once(path))
      expect(findings).to be_empty,
                          "XSD errors in OPC parts of #{File.basename(path)}:" \
                          "\n#{format_issues(findings)}"
    end
  end

  # Hard assertion for documents whose non-OPC parts must be schema-clean
  # modulo MCE extension content.
  RSpec.shared_examples "XSD-clean WordprocessingML output" do |path|
    it "has no non-MCE XSD errors in WordprocessingML parts" do
      findings = non_mce_findings(verify_once(path))
      expect(findings).to be_empty,
                          "Non-MCE XSD errors in #{File.basename(path)}:\n" \
                          "#{format_issues(findings)}"
    end
  end

  # -------------------------------------------------------------------
  # Schema coverage sanity (locks in the part -> schema mapping the
  # corpus assertions rely on)
  # -------------------------------------------------------------------

  describe "schema coverage of generated parts" do
    let(:registry) { Uniword::Validation::SchemaRegistry.new }

    it "maps WordprocessingML parts to the wml schema" do
      %w[
        word/document.xml word/styles.xml word/settings.xml
        word/fontTable.xml word/numbering.xml word/footnotes.xml
        word/webSettings.xml word/header1.xml word/footer1.xml
      ].each do |part|
        expect(registry.primary_schema_for_part(part))
          .to eq("microsoft/wml-2010.xsd"), "no primary schema for #{part}"
      end
    end

    it "maps OPC parts to their schemas" do
      expect(registry.primary_schema_for_part("[Content_Types].xml"))
        .to eq("ecma/opc-contentTypes.xsd")
      expect(registry.primary_schema_for_part("_rels/.rels"))
        .to eq("ecma/opc-relationships.xsd")
      expect(registry.primary_schema_for_part("word/_rels/document.xml.rels"))
        .to eq("ecma/opc-relationships.xsd")
      expect(registry.primary_schema_for_part("docProps/core.xml"))
        .to eq("ecma/opc-coreProperties.xsd")
      expect(registry.primary_schema_for_part("docProps/app.xml"))
        .to eq("iso/shared-documentPropertiesExtended.xsd")
      expect(registry.primary_schema_for_part("docProps/custom.xml"))
        .to eq("iso/shared-documentPropertiesCustom.xsd")
    end

    it "maps theme parts to the DrawingML schema" do
      expect(registry.primary_schema_for_part("word/theme/theme1.xml"))
        .to eq("iso/dml-main.xsd")
    end
  end

  # -------------------------------------------------------------------
  # Builder-generated corpus
  # -------------------------------------------------------------------

  BUILDER_DOCS.each_key do |name|
    describe "builder document: #{name}" do
      path = File.join(OUTPUT_DIR, "builder_#{name}.docx")
      it_behaves_like "an XSD-validated package", path
      it_behaves_like "XSD-clean WordprocessingML output", path
    end
  end

  # -------------------------------------------------------------------
  # Fixture round-trips with schema-valid source content
  # -------------------------------------------------------------------

  CLEAN_ROUNDTRIP_FIXTURES.each do |name, fixture|
    describe "round-trip fixture: #{name}" do
      path = File.join(OUTPUT_DIR, "rt_#{File.basename(fixture)}")
      it_behaves_like "an XSD-validated package", path
      it_behaves_like "XSD-clean WordprocessingML output", path
    end
  end

  # -------------------------------------------------------------------
  # Fixture round-trips with schema-invalid source content (inherited
  # errors; see INHERITED_ERROR_FIXTURES for root causes)
  # -------------------------------------------------------------------

  INHERITED_ERROR_FIXTURES.each do |name, info|
    describe "round-trip fixture: #{name}" do
      path = File.join(OUTPUT_DIR, "rt_#{File.basename(info[:file])}")
      it_behaves_like "an XSD-validated package", path

      it "has no non-MCE XSD errors in WordprocessingML parts" do
        pending "#{info[:reason]} — save-time content normalization is " \
                "validation-engine scope: TODO.validate/11"
        findings = non_mce_findings(verify_once(path))
        expect(findings).to be_empty,
                            "Non-MCE XSD errors in #{info[:file]}:\n" \
                            "#{format_issues(findings)}"
      end
    end
  end

  # -------------------------------------------------------------------
  # Full validity after MCE preprocessing (TODO.refactor/06)
  # -------------------------------------------------------------------

  describe "full XSD validity after MCE preprocessing" do
    it "produces zero non-MCE XSD errors for the whole corpus" do
      offenders = (BUILDER_DOCS.keys.map do |n|
                     File.join(OUTPUT_DIR, "builder_#{n}.docx")
                   end +
                   CLEAN_ROUNDTRIP_FIXTURES.values.map do |f|
                     File.join(OUTPUT_DIR, "rt_#{File.basename(f)}")
                   end).select do |path|
        non_mce_findings(verify_once(path)).any?
      end
      expect(offenders).to be_empty,
                           "Documents with non-MCE XSD findings:\n  " \
                           "#{offenders.join("\n  ")}"
    end
  end
end
