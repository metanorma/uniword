# frozen_string_literal: true

require "spec_helper"
require "zip"

# Relationship parts beyond document.xml.rels (settings.xml.rels,
# footnotes.xml.rels, endnotes.xml.rels) must survive a load -> save
# round-trip through BOTH save paths — package-level (Package#to_file)
# and document-level (DocumentRoot#save) — otherwise r:id references in
# those parts dangle in the saved package (OPC-009).
RSpec.describe "Note and settings .rels round-trip preservation" do
  let(:tmp_dir) { "tmp/rels_roundtrip" }

  let(:document_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>Body</w:t></w:r></w:p></w:body></w:document>
    XML
  end

  let(:settings_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:attachedTemplate r:id="rId1"/></w:settings>
    XML
  end

  let(:settings_rels_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/attachedTemplate" Target="file:///tmp/template.dotx" TargetMode="External"/></Relationships>
    XML
  end

  let(:footnotes_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:footnotes xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:footnote w:id="1"><w:p><w:r><w:footnoteRef/></w:r><w:hyperlink r:id="rId5"><w:r><w:t>link</w:t></w:r></w:hyperlink></w:p></w:footnote></w:footnotes>
    XML
  end

  let(:footnotes_rels_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="https://example.com" TargetMode="External"/></Relationships>
    XML
  end

  let(:zip_content) do
    {
      "word/document.xml" => document_xml,
      "word/settings.xml" => settings_xml,
      "word/_rels/settings.xml.rels" => settings_rels_xml,
      "word/footnotes.xml" => footnotes_xml,
      "word/_rels/footnotes.xml.rels" => footnotes_rels_xml,
    }
  end

  before { FileUtils.mkdir_p(tmp_dir) }

  after do
    Dir.glob("#{tmp_dir}/*.docx").each { |f| safe_delete(f) }
  end

  def entry_paths(docx_path)
    Zip::File.open(docx_path) { |z| z.entries.map(&:name) }
  end

  describe "package-level save (Package#to_file)" do
    it "preserves settings.xml.rels and footnotes.xml.rels" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)
      path = File.join(tmp_dir, "package_level.docx")
      package.to_file(path) # raises ValidationError if rels dangle

      entries = entry_paths(path)
      expect(entries).to include("word/_rels/settings.xml.rels")
      expect(entries).to include("word/_rels/footnotes.xml.rels")
    end
  end

  describe "document-level save (DocumentRoot#save)" do
    it "preserves settings.xml.rels and footnotes.xml.rels" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)
      intermediate = File.join(tmp_dir, "intermediate.docx")
      package.to_file(intermediate)

      path = File.join(tmp_dir, "document_level.docx")
      Uniword::DocumentFactory.from_file(intermediate).save(path)

      entries = entry_paths(path)
      expect(entries).to include("word/_rels/settings.xml.rels")
      expect(entries).to include("word/_rels/footnotes.xml.rels")
    end
  end

  describe "fixture with attachedTemplate (regression)" do
    let(:apa) do
      "spec/fixtures/word-template-apa-style-paper/" \
        "word-template-apa-style-paper.docx"
    end

    it "saves without tripping the write-time gate" do
      path = File.join(tmp_dir, "apa.docx")
      Uniword::DocumentFactory.from_file(apa).save(path)

      expect(entry_paths(path)).to include("word/_rels/settings.xml.rels")
    end
  end
end
