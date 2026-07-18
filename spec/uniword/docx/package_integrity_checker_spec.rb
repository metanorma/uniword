# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::PackageIntegrityChecker do
  subject(:checker) { described_class.new }

  let(:content_types_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
        <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
        <Default Extension="xml" ContentType="application/xml"/>
        <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
      </Types>
    XML
  end

  let(:package_rels_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
      </Relationships>
    XML
  end

  let(:document_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p/></w:body></w:document>
    XML
  end

  let(:document_rels_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>
    XML
  end

  let(:valid_content) do
    {
      "[Content_Types].xml" => content_types_xml,
      "_rels/.rels" => package_rels_xml,
      "word/document.xml" => document_xml,
      "word/_rels/document.xml.rels" => document_rels_xml,
    }
  end

  describe "#check with a valid package" do
    it "returns no issues" do
      expect(checker.check(valid_content)).to be_empty
    end

    it "does not mutate the content hash" do
      snapshot = Marshal.load(Marshal.dump(valid_content))
      checker.check(valid_content)
      expect(valid_content).to eq(snapshot)
    end
  end

  describe "OPC-005 content-type coverage" do
    it "flags an entry with no Default or Override content type" do
      content = valid_content.merge("word/media/image1.png" => "PNGDATA")
      issues = checker.check(content)

      expect(issues.map(&:code)).to include("OPC-005")
      expect(issues.first.part).to eq("word/media/image1.png")
    end

    it "accepts entries covered by a Default extension" do
      content = valid_content.merge("customXml/item1.xml" => "<item/>")
      expect(checker.check(content)).to be_empty
    end

    it "flags a missing [Content_Types].xml part" do
      content = valid_content.reject { |k, _| k == "[Content_Types].xml" }
      issues = checker.check(content)

      expect(issues.map(&:code)).to include("OPC-005")
    end
  end

  describe "OPC-006 relationship target existence" do
    it "flags a package relationship targeting a missing entry" do
      content = valid_content.dup
      content["_rels/.rels"] = package_rels_xml.sub(
        'Target="word/document.xml"', 'Target="word/missing.xml"'
      )
      issues = checker.check(content)

      expect(issues.map(&:code)).to include("OPC-006")
      expect(issues.first.message).to include("word/missing.xml")
    end

    it "resolves part-relative targets against the owning directory" do
      content = valid_content.merge("word/styles.xml" => "<w:styles xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"/>")
      content["word/_rels/document.xml.rels"] = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
        </Relationships>
      XML

      expect(checker.check(content)).to be_empty
    end

    it "skips external relationships" do
      content = valid_content.dup
      content["_rels/.rels"] = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
          <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="http://example.com" TargetMode="External"/>
        </Relationships>
      XML

      expect(checker.check(content)).to be_empty
    end
  end

  describe "OPC-009 relationship reference resolution" do
    let(:drawing_document_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:body><w:p><w:r><w:drawing><wp:inline><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:blipFill><a:blip r:embed="rId42"/></pic:blipFill></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p></w:body></w:document>
      XML
    end

    it "flags an r:embed with no matching Relationship" do
      content = valid_content.merge("word/document.xml" => drawing_document_xml)
      issues = checker.check(content)

      expect(issues.map(&:code)).to include("OPC-009")
      issue = issues.find { |i| i.code == "OPC-009" }
      expect(issue.part).to eq("word/document.xml")
      expect(issue.message).to include("rId42")
    end

    it "accepts an r:embed declared in the part's .rels" do
      content = valid_content.merge(
        "word/document.xml" => drawing_document_xml,
        "word/media/image1.png" => "PNGDATA",
      )
      content["[Content_Types].xml"] = content_types_xml.sub(
        '<Default Extension="xml"',
        '<Default Extension="png" ContentType="image/png"/><Default Extension="xml"'
      )
      content["word/_rels/document.xml.rels"] = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId42" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.png"/>
        </Relationships>
      XML

      expect(checker.check(content)).to be_empty
    end
  end

  describe "OPC-010 relationship ID uniqueness" do
    it "flags duplicate relationship IDs in a .rels part" do
      content = valid_content.dup
      content["word/_rels/document.xml.rels"] = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
        </Relationships>
      XML
      issues = checker.check(content)

      expect(issues.map(&:code)).to include("OPC-010")
      issue = issues.find { |i| i.code == "OPC-010" }
      expect(issue.part).to eq("word/_rels/document.xml.rels")
    end
  end

  describe "OPC-008 XML well-formedness" do
    it "flags a malformed XML part" do
      content = valid_content.merge("word/document.xml" => "<w:document>")
      issues = checker.check(content)

      expect(issues.map(&:code)).to include("OPC-008")
      issue = issues.find { |i| i.code == "OPC-008" }
      expect(issue.part).to eq("word/document.xml")
    end

    it "flags a malformed .rels part" do
      content = valid_content.merge("_rels/.rels" => "<<<not xml")
      issues = checker.check(content)

      expect(issues.map(&:code)).to include("OPC-008")
    end

    it "does not parse binary entries" do
      content = valid_content.merge("word/media/image1.png" => "\x89PNG\x00\xFF".dup)
      content["[Content_Types].xml"] = content_types_xml.sub(
        '<Default Extension="xml"',
        '<Default Extension="png" ContentType="image/png"/><Default Extension="xml"'
      )

      expect(checker.check(content).map(&:code)).not_to include("OPC-008")
    end
  end

  describe "issue shape" do
    it "returns structured issues with code, part and message" do
      content = valid_content.merge("word/document.xml" => "<broken")
      issue = checker.check(content).first

      expect(issue).to be_a(Uniword::Validation::Report::ValidationIssue)
      expect(issue.severity).to eq("error")
      expect(issue.code).not_to be_nil
      expect(issue.part).not_to be_nil
      expect(issue.message).not_to be_nil
    end
  end
end
