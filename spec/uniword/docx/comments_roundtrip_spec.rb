# frozen_string_literal: true

require "spec_helper"
require "zip"

# word/comments.xml must survive a load -> save round-trip with its
# content-type override, its document relationship, and the body
# anchors (commentRangeStart/commentRangeEnd/commentReference) intact —
# through BOTH save paths (Package#to_file and DocumentRoot#save) —
# and the write-time package integrity gate must pass throughout.
RSpec.describe "Comments part round-trip preservation" do
  let(:tmp_dir) { "tmp/comments_roundtrip" }

  let(:document_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:commentRangeStart w:id="0"/><w:r><w:t>Reviewed text</w:t></w:r><w:commentRangeEnd w:id="0"/><w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r></w:p><w:p><w:r><w:t>Plain</w:t></w:r></w:p></w:body></w:document>
    XML
  end

  let(:comments_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:comments xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:comment w:id="0" w:author="Jane Doe" w:date="2024-01-15T10:30:00Z" w:initials="JD"><w:p><w:r><w:t>Please rephrase.</w:t></w:r></w:p></w:comment></w:comments>
    XML
  end

  let(:document_rels_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments" Target="comments.xml"/></Relationships>
    XML
  end

  let(:zip_content) do
    {
      "word/document.xml" => document_xml,
      "word/comments.xml" => comments_xml,
      "word/_rels/document.xml.rels" => document_rels_xml,
    }
  end

  before { FileUtils.mkdir_p(tmp_dir) }

  after do
    Dir.glob("#{tmp_dir}/*.docx").each { |f| safe_delete(f) }
  end

  def entry_paths(docx_path)
    Zip::File.open(docx_path) { |z| z.entries.map(&:name) }
  end

  describe "loading" do
    it "parses word/comments.xml into the package comments collection" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)

      expect(package.comments).to be_a(Uniword::CommentsPart)
      expect(package.comments.size).to eq(1)
      comment = package.comments.first
      expect(comment.comment_id).to eq("0")
      expect(comment.author).to eq("Jane Doe")
      expect(comment.initials).to eq("JD")
      expect(comment.text).to include("Please rephrase")
    end

    it "parses the body anchors" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)
      para = package.document.body.paragraphs.first

      expect(para.comment_range_starts.map(&:id)).to eq(%w[0])
      expect(para.comment_range_ends.map(&:id)).to eq(%w[0])
      expect(para.runs.last.comment_reference.id).to eq("0")
    end
  end

  describe "package-level save (Package#to_file)" do
    it "re-emits comments.xml with anchors, rel, and content type" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)
      path = File.join(tmp_dir, "package_level.docx")
      package.to_file(path) # raises ValidationError if the gate trips

      expect(entry_paths(path)).to include("word/comments.xml")
      Zip::File.open(path) do |z|
        part = Uniword::CommentsPart.from_xml(z.read("word/comments.xml"))
        expect(part.comments.map(&:comment_id)).to eq(%w[0])
        expect(part.comments.first.author).to eq("Jane Doe")

        body = z.read("word/document.xml")
        expect(body).to include('<w:commentRangeStart w:id="0"/>')
        expect(body).to include('<w:commentRangeEnd w:id="0"/>')
        expect(body).to include('<w:commentReference w:id="0"/>')

        rels = z.read("word/_rels/document.xml.rels")
        expect(rels).to include("relationships/comments")
        expect(rels).to include('Target="comments.xml"')

        content_types = z.read("[Content_Types].xml")
        expect(content_types).to include('PartName="/word/comments.xml"')
      end
    end
  end

  describe "document-level save (DocumentRoot#save)" do
    it "preserves comments and anchors through the copy flows" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)
      intermediate = File.join(tmp_dir, "intermediate.docx")
      package.to_file(intermediate)

      path = File.join(tmp_dir, "document_level.docx")
      doc = Uniword::DocumentFactory.from_file(intermediate)
      expect(doc.comments.size).to eq(1)
      doc.save(path)

      expect(entry_paths(path)).to include("word/comments.xml")
      reloaded = Uniword::DocumentFactory.from_file(path)
      expect(reloaded.comments.size).to eq(1)
      expect(reloaded.comments.first.author).to eq("Jane Doe")
      para = reloaded.paragraphs.first
      expect(para.comment_range_starts.map(&:id)).to eq(%w[0])
      expect(para.runs.last.comment_reference.id).to eq("0")
    end
  end

  describe "empty comments part (styles.docx shape)" do
    let(:comments_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:comments xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>
      XML
    end

    it "preserves the empty part and its relationship" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)
      path = File.join(tmp_dir, "empty_comments.docx")
      package.to_file(path)

      expect(entry_paths(path)).to include("word/comments.xml")
      Zip::File.open(path) do |z|
        rels = z.read("word/_rels/document.xml.rels")
        expect(rels).to include("relationships/comments")
      end
    end
  end

  describe "ReviewManager add_comment flow" do
    it "serializes added comments through the same package path" do
      package = Uniword::Docx::Package.from_zip_content(zip_content)
      intermediate = File.join(tmp_dir, "review_intermediate.docx")
      package.to_file(intermediate)

      doc = Uniword::DocumentFactory.from_file(intermediate)
      manager = Uniword::Review::ReviewManager.new(doc)
      added = manager.add_comment(text: "Second look", author: "Bob")
      expect(added.comment_id).to eq("1")

      path = File.join(tmp_dir, "review_added.docx")
      doc.save(path)

      reloaded = Uniword::DocumentFactory.from_file(path)
      expect(reloaded.comments.size).to eq(2)
      expect(reloaded.comments.map(&:author)).to eq(["Jane Doe", "Bob"])
      expect(reloaded.comments.map(&:comment_id)).to eq(%w[0 1])
    end
  end
end
