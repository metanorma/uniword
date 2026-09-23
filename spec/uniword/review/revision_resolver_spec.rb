# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Review::RevisionResolver do
  subject(:resolver) { described_class.new(document) }

  let(:document) do
    Uniword::Wordprocessingml::DocumentRoot.new.tap do |doc|
      doc.body.paragraphs << paragraph
    end
  end
  let(:paragraph) do
    Uniword::Wordprocessingml::Paragraph.new(
      runs: [run("Hello")],
      insertions: [insertion],
      deletions: [deletion],
    )
  end
  let(:insertion) do
    Uniword::Wordprocessingml::Insertion.new(
      id: "7", author: "Alice",
      runs: [run(" INSERTED")]
    )
  end
  let(:deletion) do
    Uniword::Wordprocessingml::Deletion.new(
      id: "8", author: "Bob",
      runs: [deleted_run(" GONE")]
    )
  end

  def run(text)
    Uniword::Wordprocessingml::Run.new(
      text: [Uniword::Wordprocessingml::Text.new(content: text)],
    )
  end

  def deleted_run(text)
    Uniword::Wordprocessingml::Run.new(
      del_text: Uniword::Wordprocessingml::DeletedText.new(content: text),
    )
  end

  def facade
    Uniword::TrackedChanges.new
  end

  describe "#hydrate" do
    it "registers one facade revision per tracked node" do
      tracked_changes = resolver.hydrate(facade)

      expect(tracked_changes.revisions.map(&:revision_id)).to eq(%w[7 8])
    end

    it "registers insertions with type and text" do
      revision = resolver.hydrate(facade).find_revision("7")

      expect(revision).to be_insert
      expect(revision.author).to eq("Alice")
      expect(revision.text).to eq(" INSERTED")
    end

    it "registers deletions with type and text" do
      revision = resolver.hydrate(facade).find_revision("8")

      expect(revision).to be_delete
      expect(revision.text).to eq(" GONE")
    end
  end

  describe "#accept" do
    it "splices an insertion's runs into the paragraph" do
      resolver.hydrate(facade)

      expect(resolver.accept("7")).to be(true)
      expect(paragraph.insertions).to be_empty
      expect(paragraph.text).to eq("Hello INSERTED")
    end

    it "removes a deletion node" do
      resolver.hydrate(facade)

      expect(resolver.accept("8")).to be(true)
      expect(paragraph.deletions).to be_empty
      expect(paragraph.text).to eq("Hello INSERTED")
    end

    it "returns false for unknown ids" do
      expect(resolver.accept("999")).to be(false)
    end
  end

  describe "#reject" do
    it "removes an insertion node" do
      resolver.hydrate(facade)

      expect(resolver.reject("7")).to be(true)
      expect(paragraph.insertions).to be_empty
      expect(paragraph.text).to eq("Hello")
    end

    it "restores a deletion's text as live content" do
      resolver.hydrate(facade)

      expect(resolver.reject("8")).to be(true)
      expect(paragraph.deletions).to be_empty
      expect(paragraph.runs.map(&:text_string)).to include(" GONE")
    end

    it "returns false for unknown ids" do
      expect(resolver.reject("999")).to be(false)
    end
  end
end
