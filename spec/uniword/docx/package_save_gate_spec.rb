# frozen_string_literal: true

require "spec_helper"
require "stringio"

# Write-time package integrity gate (through the save chain) and
# reconciliation transparency (Package#applied_fixes + fix logging).
RSpec.describe "Package save integrity gate" do
  let(:output_dir) { File.expand_path("../../tmp", __dir__) }
  let(:output_path) { File.join(output_dir, "gate_spec_output.docx") }

  let(:document) do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.body = Uniword::Wordprocessingml::Body.new
    doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
      runs: [Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(content: "Hello")
      )],
    )
    doc
  end

  before { FileUtils.mkdir_p(output_dir) }

  after do
    safe_delete(output_path)
    Uniword.configuration.reset!
  end

  describe "default save of a normal document" do
    it "passes the gate and writes the file" do
      document.save(output_path)
      expect(File.exist?(output_path)).to be(true)
    end

    it "produces no referential repair fixes for a valid document" do
      package = Uniword::Docx::Package.new
      package.document = document
      package.to_file(output_path)

      referential_codes = %w[R17 R18 R19 R20 R21 R22 R23 R32]
      codes = package.applied_fixes.map(&:code)
      expect(codes & referential_codes).to be_empty
    end
  end

  describe "invalid output" do
    let(:document) do
      doc = super()
      doc.custom_xml_items = [{ index: 1, xml_content: "<broken<xml" }]
      doc
    end

    # Order-independent clean state — Windows file-handle release can
    # lag past the previous test's `after` block (GC delay, AV scan),
    # leaving the output file on disk. Pre-clean here so the assertions
    # below do not depend on cross-test cleanup timing.
    before do
      safe_delete(output_path)
      Dir.glob("#{output_path}.*.tmp").each { |p| safe_delete(p) }
    end

    it "raises ValidationError listing structured issues" do
      expect { document.save(output_path) }
        .to raise_error(Uniword::ValidationError) do |error|
          expect(error.issues).not_to be_empty
          issue = error.issues.first
          expect(issue.code).to eq("OPC-008")
          expect(issue.part).to eq("customXml/item1.xml")
          expect(issue.message).to include("Malformed XML")
        end
    end

    it "does not write the file when the gate rejects the package" do
      begin
        document.save(output_path)
      rescue Uniword::ValidationError
        nil
      end
      expect(File.exist?(output_path)).to be(false)
    end

    it "writes the file with validate: false" do
      document.save(output_path, validate: false)
      expect(File.exist?(output_path)).to be(true)
    end

    it "writes the file when configuration disables validation" do
      Uniword.configuration.validate_on_save = false
      document.save(output_path)
      expect(File.exist?(output_path)).to be(true)
    end
  end

  describe "Package#to_zip_content validate: keyword" do
    it "raises for invalid content by default" do
      package = Uniword::Docx::Package.new
      package.document = document
      package.custom_xml_items = [{ index: 1, xml_content: "<oops" }]

      expect { package.to_zip_content }
        .to raise_error(Uniword::ValidationError)
    end

    it "returns content with validate: false" do
      package = Uniword::Docx::Package.new
      package.document = document
      package.custom_xml_items = [{ index: 1, xml_content: "<oops" }]

      content = package.to_zip_content(validate: false)
      expect(content).to have_key("customXml/item1.xml")
    end
  end

  describe "Package#applied_fixes" do
    let(:document_with_dangling_image) do
      Uniword::Wordprocessingml::DocumentRoot.from_xml(
        <<~XML,
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:body><w:p><w:r><w:drawing><wp:inline><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:blipFill><a:blip r:embed="rId99"/></pic:blipFill></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p></w:body></w:document>
        XML
      )
    end

    it "is empty before the first save" do
      expect(Uniword::Docx::Package.new.applied_fixes).to eq([])
    end

    it "exposes Fix value objects with code, message and part" do
      package = Uniword::Docx::Package.new
      package.document = document_with_dangling_image
      package.to_file(output_path)

      fix = package.applied_fixes.find { |f| f.code == "R23" }
      expect(fix).to be_a(Uniword::Docx::Reconciler::Fix)
      expect(fix.message).to include("dangling image")
      expect(fix.part).to eq("word/document.xml")
    end

    it "removes dangling image references from the saved output" do
      package = Uniword::Docx::Package.new
      package.document = document_with_dangling_image
      package.to_file(output_path)

      reloaded = Uniword::Docx::Package.from_file(output_path)
      expect(reloaded.document.to_xml).not_to include("rId99")
    end
  end

  describe "save-fix logging" do
    let(:log_output) { StringIO.new }

    around do |example|
      original = Uniword.logger
      Uniword.logger = Logger.new(log_output)
      example.run
    ensure
      Uniword.logger = original
    end

    it "logs applied fixes when log_save_fixes is enabled" do
      Uniword.configuration.log_save_fixes = true
      document.save(output_path)

      expect(log_output.string).to include("Reconciler fix")
    end

    it "stays silent when log_save_fixes is disabled" do
      Uniword.configuration.log_save_fixes = false
      document.save(output_path)

      expect(log_output.string).not_to include("Reconciler fix")
    end
  end

  describe "DocumentWriter#write_to_stream" do
    it "threads the validate flag through stream writes" do
      doc = document
      doc.custom_xml_items = [{ index: 1, xml_content: "<broken" }]
      writer = Uniword::DocumentWriter.new(doc)

      expect { writer.write_to_stream(StringIO.new) }
        .to raise_error(Uniword::ValidationError)
    end
  end
end
