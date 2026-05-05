# frozen_string_literal: true

require "spec_helper"
require "uniword/diff/package_differ"
require "tmpdir"

RSpec.describe Uniword::Diff::PackageDiffer do
  let(:bad_path) { "spec/fixtures/hello-world-bad.docx" }
  let(:repaired_path) { "spec/fixtures/hello-world-repaired.docx" }

  describe "ZIP metadata comparison" do
    subject(:result) do
      described_class.new(bad_path, repaired_path).diff
    end

    it "returns zip_metadata_changes" do
      expect(result.zip_metadata_changes).to be_an(Array)
    end

    it "returns ZipMetadataChange instances" do
      expect(result.zip_metadata_changes).to all(be_a(Uniword::Diff::ZipMetadataChange))
    end

    it "serializes ZipMetadataChange to hash" do
      result.zip_metadata_changes.each do |mc|
        h = mc.to_h
        expect(h).to include(:part, :differences)
      end
    end
  end

  describe "OPC validation" do
    subject(:result) do
      described_class.new(bad_path, repaired_path).diff
    end

    it "returns opc_issues" do
      expect(result.opc_issues).to be_an(Array)
    end

    it "has no OPC issues for valid fixture files" do
      expect(result.opc_issues).to be_empty
    end

    it "detects missing required parts" do
      Dir.mktmpdir do |dir|
        broken_path = create_minimal_docx(dir, "broken.docx",
                                          parts: { "[Content_Types].xml" => '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"></Types>',
                                                   "_rels/.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"></Relationships>' })

        result = described_class.new(broken_path, broken_path).diff
        missing = result.opc_issues.select { |i| i.category == :missing_part }
        expect(missing).not_to be_empty
        expect(missing.map(&:part)).to include("word/document.xml")
      end
    end

    it "serializes OpcIssue to hash" do
      Dir.mktmpdir do |dir|
        broken_path = create_minimal_docx(dir, "broken.docx",
                                          parts: { "[Content_Types].xml" => '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"></Types>' })

        result = described_class.new(broken_path, broken_path).diff
        result.opc_issues.each do |issue|
          h = issue.to_h
          expect(h).to include(:part, :severity, :category, :description)
        end
      end
    end
  end

  describe "Canon integration" do
    context "when canon: false (default)" do
      subject(:result) do
        described_class.new(bad_path, repaired_path).diff
      end

      it "does not set canon_equivalent on parts" do
        result.modified_parts.each do |p|
          expect(p.canon_equivalent).to be_nil
        end
      end
    end

    context "when canon: true" do
      subject(:result) do
        described_class.new(bad_path, repaired_path, canon: true).diff
      end

      it "sets canon_equivalent on XML parts" do
        xml_parts = result.modified_parts.select do |p|
          p.name.end_with?(".xml")
        end
        xml_parts.each do |p|
          expect(p.canon_equivalent).not_to be_nil
        end
      end

      it "sets canon_summary for non-equivalent parts" do
        non_equiv = result.modified_parts.select do |p|
          p.name.end_with?(".xml") && p.canon_equivalent == false
        end
        non_equiv.each do |p|
          expect(p.canon_summary).to be_a(String)
        end
      end

      it "includes canon info in to_h output" do
        h = result.to_h
        parts_with_canon = h[:modified_parts].select do |p|
          p.key?(:canon_equivalent)
        end
        expect(parts_with_canon).not_to be_empty
      end
    end

    context "when comparing identical content with different formatting" do
      it "reports canon_equivalent: true for semantically identical XML" do
        Dir.mktmpdir do |dir|
          xml_a = '<?xml version="1.0"?><root><child  attr="val" >text</child></root>'
          xml_b = '<?xml version="1.0"?><root><child attr="val">text</child></root>'

          path_a = create_minimal_docx(dir, "a.docx",
                                       parts: { "word/document.xml" => xml_a })
          path_b = create_minimal_docx(dir, "b.docx",
                                       parts: { "word/document.xml" => xml_b })

          result = described_class.new(path_a, path_b, canon: true).diff
          doc_part = result.modified_parts.find do |p|
            p.name == "word/document.xml"
          end
          expect(doc_part).not_to be_nil
          expect(doc_part.canon_equivalent).to be(true)
        end
      end
    end
  end

  describe "backward compatibility" do
    it "maintains existing API for diff without canon" do
      result = described_class.new(bad_path, repaired_path).diff

      expect(result).to be_a(Uniword::Diff::PackageDiffResult)
      expect(result).to respond_to(:added_parts)
      expect(result).to respond_to(:removed_parts)
      expect(result).to respond_to(:modified_parts)
      expect(result).to respond_to(:unchanged_parts)
      expect(result).to respond_to(:xml_changes)
      expect(result).to respond_to(:summary)
      expect(result).to respond_to(:to_json)
      expect(result).to respond_to(:to_h)
    end

    it "preserves existing test expectations" do
      result = described_class.new(bad_path, repaired_path).diff

      expect(result).not_to be_empty
      expect(result.added_parts).to include("word/theme/theme1.xml")
      expect(result.modified_parts.map(&:name)).to include("word/document.xml")
    end
  end

  private

  # Helper to create a minimal DOCX file with specified parts.
  def create_minimal_docx(dir, filename, parts:)
    path = File.join(dir, filename)
    require "zip"
    Zip::OutputStream.open(path) do |zos|
      parts.each do |name, content|
        zos.put_next_entry(name)
        zos.write(content)
      end
    end
    path
  end
end
