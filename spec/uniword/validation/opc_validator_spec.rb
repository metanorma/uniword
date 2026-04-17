# frozen_string_literal: true

require "spec_helper"
require "zip"
require "uniword/validation/opc_validator"

RSpec.describe Uniword::Validation::OpcValidator do
  let(:validator) { described_class.new }

  def create_test_zip(entries)
    dir = Dir.mktmpdir
    zip_path = File.join(dir, "test.docx")

    Zip::File.open(zip_path, Zip::File::CREATE) do |zip|
      entries.each do |name, content|
        zip.get_output_stream(name) { |f| f.write(content) }
      end
    end

    zip_path
  end

  describe "valid DOCX" do
    let(:path) { "spec/fixtures/blank/blank.docx" }

    it "returns no errors" do
      issues = validator.validate(path)
      errors = issues.select { |i| i.severity == "error" }
      expect(errors).to be_empty
    end
  end

  describe "invalid ZIP" do
    it "reports OPC-001 for non-ZIP files" do
      tmp = Tempfile.new(["test", ".docx"])
      tmp.write("this is not a zip file")
      tmp.close

      issues = validator.validate(tmp.path)
      opc001 = issues.select { |i| i.code == "OPC-001" }

      expect(opc001.size).to eq(1)
      expect(opc001.first.severity).to eq("error")

      tmp.unlink
    end
  end

  describe "missing required parts" do
    it "reports OPC-002 for missing Content_Types.xml" do
      zip_path = create_test_zip(
        "word/document.xml" => "<w:document/>"
      )

      issues = validator.validate(zip_path)
      opc002 = issues.select { |i| i.code == "OPC-002" }
      expect(opc002).not_to be_empty

      FileUtils.rm_rf(File.dirname(zip_path))
    end

    it "reports OPC-004 for missing word/document.xml" do
      zip_path = create_test_zip(
        "[Content_Types].xml" => '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"/>',
        "_rels/.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>'
      )

      issues = validator.validate(zip_path)
      opc004 = issues.select { |i| i.code == "OPC-004" }
      expect(opc004).not_to be_empty

      FileUtils.rm_rf(File.dirname(zip_path))
    end
  end

  describe "broken relationships" do
    it "reports OPC-006 for missing targets" do
      zip_path = create_test_zip(
        "[Content_Types].xml" => '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/xml"/></Types>',
        "_rels/.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/core-properties" Target="docProps/core.xml"/></Relationships>',
        "word/document.xml" => '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'
      )

      issues = validator.validate(zip_path)
      opc006 = issues.select { |i| i.code == "OPC-006" }
      expect(opc006.size).to eq(1)
      expect(opc006.first.message).to include("docProps/core.xml")

      FileUtils.rm_rf(File.dirname(zip_path))
    end
  end

  describe "content types" do
    it "reports OPC-005 for undeclared extensions" do
      zip_path = create_test_zip(
        "[Content_Types].xml" => '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/xml"/></Types>',
        "_rels/.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>',
        "word/document.xml" => "<w:document/>",
        "word/media/image1.png" => "PNG data"
      )

      issues = validator.validate(zip_path)
      opc005 = issues.select { |i| i.code == "OPC-005" }
      expect(opc005).not_to be_empty
      expect(opc005.first.message).to include("image1.png")

      FileUtils.rm_rf(File.dirname(zip_path))
    end

    it "does not flag .rels files as missing content types" do
      zip_path = create_test_zip(
        "[Content_Types].xml" => '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/xml"/></Types>',
        "_rels/.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="test" Target="word/document.xml"/></Relationships>',
        "word/_rels/document.xml.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>',
        "word/document.xml" => "<w:document/>"
      )

      issues = validator.validate(zip_path)
      rels_issues = issues.select { |i| i.message.include?(".rels") }
      expect(rels_issues).to be_empty

      FileUtils.rm_rf(File.dirname(zip_path))
    end
  end

  describe "XML well-formedness" do
    it "reports OPC-008 for malformed XML" do
      zip_path = create_test_zip(
        "[Content_Types].xml" => '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/xml"/></Types>',
        "_rels/.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>',
        "word/document.xml" => "<w:document><unclosed>"
      )

      issues = validator.validate(zip_path)
      opc008 = issues.select { |i| i.code == "OPC-008" }
      expect(opc008).not_to be_empty

      FileUtils.rm_rf(File.dirname(zip_path))
    end
  end
end
