# frozen_string_literal: true

require "spec_helper"
require "open3"
require "tmpdir"

# Tracked changes end-to-end (TODO.fix/12): real w:ins/w:del nodes
# must round-trip, be listed by the review CLI, and accept/reject
# decisions must persist to the saved file.
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:dir) { Dir.mktmpdir }

  let(:tracked_doc) do
    path = File.join(dir, "tracked.docx")
    insertion = Uniword::Wordprocessingml::Insertion.new(
      id: "7", author: "Alice", date: "2026-01-01T00:00:00Z",
      runs: [Uniword::Wordprocessingml::Run.new(
        text: [Uniword::Wordprocessingml::Text.new(content: " INSERTED")],
      )]
    )
    deletion = Uniword::Wordprocessingml::Deletion.new(
      id: "8", author: "Bob", date: "2026-01-02T00:00:00Z",
      runs: [Uniword::Wordprocessingml::Run.new(
        del_text: Uniword::Wordprocessingml::DeletedText.new(
          content: " GONE",
        ),
      )]
    )
    Uniword::Builder::DocumentBuilder.new.tap do |builder|
      para = builder.paragraph("Hello")
      para.model.insertions << insertion
      para.model.deletions << deletion
    end.save(path)
    path
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  def paragraph_text(path)
    reloaded = Uniword::DocumentFactory.from_file(path)
    reloaded.body.paragraphs.first.text
  end

  it "lists tracked changes parsed from the document" do
    out, _err, status = run_cli("review", "changes", tracked_doc)
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Tracked changes (2)")
    expect(out).to include("Insertion").and include("Deletion")
  end

  it "accept-all keeps insertions and drops deletions" do
    out, _err, status = run_cli("review", "accept-all", tracked_doc)
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Accepted 2 revision(s)")
    expect(paragraph_text(tracked_doc)).to eq("Hello INSERTED")
  end

  it "reject-all drops insertions and restores deletions" do
    out, _err, status = run_cli("review", "reject-all", tracked_doc)
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Rejected 2 revision(s)")
    expect(paragraph_text(tracked_doc)).to eq("Hello GONE")
  end

  it "preserves tracked-change nodes through a conversion round-trip" do
    converted = File.join(dir, "converted.docx")
    _out, _err, status = run_cli("convert", tracked_doc, converted)
    expect(status.exitstatus).to eq(0)
    para = Uniword::DocumentFactory.from_file(converted)
      .body.paragraphs.first
    expect(para.insertions.size).to eq(1)
    expect(para.deletions.size).to eq(1)
  end
end
