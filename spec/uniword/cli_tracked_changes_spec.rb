# frozen_string_literal: true

require "spec_helper"
require "open3"
require "json"
require "tmpdir"

# Tracked changes end-to-end (TODO.fix/12): real w:ins/w:del nodes
# must round-trip, be listed by the review CLI, and accept/reject
# decisions must persist to the saved file. Filter flags (--author,
# --since/--until, --json) select the revision set for listing and for
# filtered accept/reject.
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

  it "lists tracked changes as JSON with id, author, date, type, text" do
    out, _err, status = run_cli("review", "changes", tracked_doc, "--json")
    expect(status.exitstatus).to eq(0)

    entries = JSON.parse(out)
    expect(entries.map { |e| e["id"] }).to eq(%w[7 8])
    expect(entries.map { |e| e["author"] }).to eq(%w[Alice Bob])
    expect(entries.map { |e| e["type"] }).to eq(%w[insert delete])
    expect(entries.map { |e| e["date"] })
      .to all(match(/2026-01-0\d/))
    expect(entries.first["text"]).to include("INSERTED")
  end

  it "filters tracked changes by author" do
    out, _err, status =
      run_cli("review", "changes", tracked_doc, "--author", "Alice")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Tracked changes (1)")
    expect(out).to include("Alice")
    expect(out).not_to include("Bob")
  end

  it "filters tracked changes by --since" do
    out, _err, status = run_cli("review", "changes", tracked_doc,
                                "--since", "2026-01-02")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Tracked changes (1)")
    expect(out).to include("Bob")
  end

  it "filters tracked changes by --until" do
    out, _err, status = run_cli("review", "changes", tracked_doc,
                                "--until", "2026-01-01")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Tracked changes (1)")
    expect(out).to include("Alice")
  end

  it "fails with exit 1 on an invalid date filter" do
    out, _err, status = run_cli("review", "changes", tracked_doc,
                                "--since", "not-a-date")
    expect(status.exitstatus).to eq(1)
    expect(out).to include("Invalid date")
  end

  it "accepts a missing revision ID with exit 1" do
    out, _err, status = run_cli("review", "accept", tracked_doc, "999")
    expect(status.exitstatus).to eq(1)
    expect(out).to include("Revision '999' not found")
  end

  it "accepts only the revisions matching the filters" do
    out, _err, status = run_cli("review", "accept", tracked_doc,
                                "--author", "Bob")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Accepted 1 revision(s)")
    expect(paragraph_text(tracked_doc)).to eq("Hello INSERTED")
  end

  it "rejects only the revisions matching the filters" do
    out, _err, status = run_cli("review", "reject", tracked_doc,
                                "--since", "2026-01-01",
                                "--until", "2026-01-01")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Rejected 1 revision(s)")
    # Alice's insertion is dropped; Bob's deletion stays pending, so
    # the paragraph keeps only its original text.
    expect(paragraph_text(tracked_doc)).to eq("Hello")
  end

  it "reports no matching revisions without any decision" do
    out, _err, status = run_cli("review", "accept", tracked_doc,
                                "--author", "Nobody")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("No matching revisions found")
    expect(paragraph_text(tracked_doc)).to eq("Hello INSERTED")
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
