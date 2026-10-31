# frozen_string_literal: true

require "spec_helper"
require "open3"
require "json"
require "tmpdir"

# CLI coverage for the `uniword comments` group: list (text + JSON),
# add anchored by search text, and Word-semantics resolve that strips
# the comment entry and its anchor markers.
RSpec.describe Uniword::CommentsCLI do
  let(:cli) { described_class.new }
  let(:exe) { File.expand_path("../../../exe/uniword", __dir__) }
  let(:dir) { Dir.mktmpdir }

  let(:commented_doc) do
    path = File.join(dir, "commented.docx")
    Uniword::Builder::DocumentBuilder.new.tap do |builder|
      builder.paragraph("Intro paragraph")
      builder.paragraph("Conclusion paragraph")
      builder.comment(author: "Jane Doe", text: "Please verify")
    end.save(path)
    path
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  def reloaded(path)
    Uniword::DocumentFactory.from_file(path)
  end

  describe "#list" do
    it "lists comments with author, date, and anchored text" do
      out = captured_stdout { cli.invoke(:list, [commented_doc]) }

      expect(out).to include("Comments (1)")
      expect(out).to include("Jane Doe")
      expect(out).to include("Conclusion paragraph")
    end

    it "emits JSON with id, author, date, text, and anchored text" do
      entries = JSON.parse(captured_stdout do
        cli.invoke(:list, [commented_doc], json: true)
      end)

      expect(entries.size).to eq(1)
      entry = entries.first
      expect(entry["author"]).to eq("Jane Doe")
      expect(entry["text"]).to eq("Please verify")
      expect(entry["anchored_text"]).to eq("Conclusion paragraph")
      expect(entry["id"]).to be_a(String)
      expect(entry["date"]).to be_a(String)
    end

    it "reports an empty document without comments" do
      path = File.join(dir, "plain.docx")
      builder = Uniword::Builder::DocumentBuilder.new
      builder.paragraph("Plain")
      builder.save(path)

      expect do
        cli.invoke(:list, [path], json: false)
      end.to output(/No comments found/).to_stdout
    end
  end

  describe "#add" do
    it "anchors the comment to the first paragraph with the search text" do
      cli.invoke(:add, [commented_doc],
                 author: "Bob", text: "Rewrite this",
                 at: "Intro paragraph")

      doc = reloaded(commented_doc)
      expect(doc.comments.count).to eq(2)
      anchored = doc.body.paragraphs.first
      expect(anchored.comment_range_starts.size).to eq(1)
      expect(doc.body.paragraphs.first.text).to include("Intro paragraph")
    end

    it "anchors to the last paragraph without --at" do
      cli.invoke(:add, [commented_doc],
                 author: "Bob", text: "Looks good")

      doc = reloaded(commented_doc)
      last = doc.body.paragraphs.last
      new_id = doc.comments.find { |c| c.author == "Bob" }.comment_id
      expect(last.comment_range_starts.map(&:id)).to include(new_id)
    end

    it "fails when no paragraph matches the search text" do
      out, _err, status = run_cli("comments", "add", commented_doc,
                                  "--author", "Bob", "--text", "Note",
                                  "--at", "nonexistent phrase")
      expect(status.exitstatus).to eq(1)
      expect(out).to include("No paragraph containing")
    end

    it "keeps the document XSD-clean and round-trippable" do
      cli.invoke(:add, [commented_doc],
                 author: "Bob", text: "Rewrite this",
                 at: "Intro paragraph")

      doc = reloaded(commented_doc)
      expect(doc.comments.find { |c| c.author == "Bob" }.text)
        .to eq("Rewrite this")
      doc.body.paragraphs.each do |paragraph|
        expect(paragraph.text).to include("paragraph")
      end
    end
  end

  describe "#resolve" do
    it "removes the comment entry and its anchor markers" do
      comment_id = reloaded(commented_doc).comments.first.comment_id
      cli.invoke(:resolve, [commented_doc, comment_id])

      doc = reloaded(commented_doc)
      expect(doc.comments.count).to eq(0)
      doc.all_paragraphs.each do |paragraph|
        expect(paragraph.comment_range_starts).to be_empty
        expect(paragraph.comment_range_ends).to be_empty
        expect(paragraph.comment_references).to be_empty
      end
      expect(doc.body.paragraphs.first.text).to include("Intro paragraph")
    end

    it "writes to the --output path when given" do
      comment_id = reloaded(commented_doc).comments.first.comment_id
      output_path = File.join(dir, "resolved.docx")
      cli.invoke(:resolve, [commented_doc, comment_id],
                 output: output_path)

      expect(reloaded(output_path).comments.count).to eq(0)
      expect(reloaded(commented_doc).comments.count).to eq(1)
    end

    it "fails with exit 1 for an unknown comment ID" do
      out, _err, status = run_cli("comments", "resolve", commented_doc,
                                  "999")
      expect(status.exitstatus).to eq(1)
      expect(out).to include("Comment '999' not found")
    end
  end

  def captured_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original
  end
end
