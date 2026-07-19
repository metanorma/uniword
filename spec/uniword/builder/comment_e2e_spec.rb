# frozen_string_literal: true

require "spec_helper"
require "zip"

# End-to-end comment authoring: the builder registers comments in the
# document's CommentsPart and anchors them in the body, so saving emits
# a valid word/comments.xml (with content-type override and document
# relationship) and comments survive a load -> save round-trip.
RSpec.describe "Builder comment authoring (end-to-end)" do
  let(:output_dir) { "test_output" }
  let(:path) { File.join(output_dir, "builder_comments.docx") }

  after { safe_delete(path) }

  def build_document
    Uniword::Builder::DocumentBuilder.new.tap do |doc|
      doc.paragraph { |p| p << "First paragraph to review." }
      doc.comment(author: "Alice", initials: "AL",
                  text: "Check this wording.")
      doc.paragraph { |p| p << "Second paragraph." }
      doc.comment(author: "Bob", text: "Looks good.") do |c|
        c << "One more thing."
      end
    end
  end

  def zip_read(path, entry)
    Zip::File.open(path) { |z| z.read(entry) }
  end

  describe "model registration" do
    it "stores comments in a CommentsPart with sequential ids" do
      doc = build_document

      expect(doc.model.comments).to be_a(Uniword::CommentsPart)
      expect(doc.model.comments.size).to eq(2)
      expect(doc.model.comments.map(&:comment_id)).to eq(%w[1 2])
      expect(doc.model.comments[0].author).to eq("Alice")
      expect(doc.model.comments[1].paragraphs.size).to eq(2)
    end

    it "anchors each comment around the preceding paragraph" do
      doc = build_document

      first, second = doc.model.body.paragraphs
      expect(first.comment_range_starts.map(&:id)).to eq(%w[1])
      expect(first.comment_range_ends.map(&:id)).to eq(%w[1])
      expect(first.runs.last.comment_reference.id).to eq("1")
      expect(second.comment_range_starts.map(&:id)).to eq(%w[2])
      expect(second.runs.last.comment_reference.id).to eq("2")
    end

    it "registers the CommentReference character style" do
      doc = build_document

      style = doc.model.styles_configuration.style_by_id("CommentReference")
      expect(style).not_to be_nil
      expect(style.type).to eq("character")
    end
  end

  describe "package output" do
    before { build_document.save(path) }

    it "emits word/comments.xml with all comments" do
      xml = zip_read(path, "word/comments.xml")
      part = Uniword::CommentsPart.from_xml(xml)

      expect(part.comments.size).to eq(2)
      expect(part.comments.map(&:author)).to eq(%w[Alice Bob])
      expect(part.comments.map(&:comment_id)).to eq(%w[1 2])
      expect(part.comments[0].initials).to eq("AL")
      expect(part.comments[0].text).to include("Check this wording")
    end

    it "anchors comments in document.xml in canonical order" do
      xml = zip_read(path, "word/document.xml")

      %w[1 2].each do |id|
        start_pos = xml.index(%(<w:commentRangeStart w:id="#{id}"/>))
        end_pos = xml.index(%(<w:commentRangeEnd w:id="#{id}"/>))
        ref_pos = xml.index(%(<w:commentReference w:id="#{id}"/>))
        expect(start_pos).not_to be_nil
        expect(end_pos).not_to be_nil
        expect(ref_pos).not_to be_nil
        expect(start_pos).to be < end_pos
        expect(end_pos).to be < ref_pos
      end
      expect(xml).to include('<w:rStyle w:val="CommentReference"/>')
    end

    it "declares the comments content type and relationship" do
      content_types = zip_read(path, "[Content_Types].xml")
      rels = zip_read(path, "word/_rels/document.xml.rels")

      expect(content_types).to include('PartName="/word/comments.xml"')
      expect(content_types).to include("comments+xml")
      expect(rels).to include("relationships/comments")
      expect(rels).to include('Target="comments.xml"')
    end
  end

  describe "reopening the saved document" do
    before { build_document.save(path) }

    it "populates the comments collection" do
      doc = Uniword.load(path)

      expect(doc.comments).to be_a(Uniword::CommentsPart)
      expect(doc.comments.size).to eq(2)
      expect(doc.comments.map(&:author)).to eq(%w[Alice Bob])
      expect(doc.comments.map(&:comment_id)).to eq(%w[1 2])
    end

    it "parses the body anchors" do
      doc = Uniword.load(path)
      first = doc.paragraphs.first

      expect(first.comment_range_starts.map(&:id)).to eq(%w[1])
      expect(first.comment_range_ends.map(&:id)).to eq(%w[1])
      expect(first.runs.last.comment_reference.id).to eq("1")
    end

    it "survives a second save (round-trip)" do
      Uniword.load(path).save(path)
      doc = Uniword.load(path)

      expect(doc.comments.map(&:comment_id)).to eq(%w[1 2])
      expect(doc.comments.map(&:author)).to eq(%w[Alice Bob])
      xml = zip_read(path, "word/document.xml")
      expect(xml.scan("commentRangeStart").size).to eq(2)
      expect(xml.scan("commentReference").size).to eq(2)
    end
  end

  describe "comment without a preceding paragraph" do
    it "is saved unanchored but present in comments.xml" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.comment(author: "Solo", text: "Document-level remark")
      doc.save(path)

      part = Uniword::CommentsPart.from_xml(zip_read(path, "word/comments.xml"))
      expect(part.comments.size).to eq(1)
      expect(part.comments.first.author).to eq("Solo")
      xml = zip_read(path, "word/document.xml")
      expect(xml).not_to include("commentRangeStart")
    end
  end
end
