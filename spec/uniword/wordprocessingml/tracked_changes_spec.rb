# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::TrackedChanges do
  let(:tracked_changes) { described_class.new }

  describe "#initialize" do
    it "creates with track changes disabled by default" do
      expect(tracked_changes.enabled).to be false
      expect(tracked_changes.revisions).to be_empty
    end

    it "can be initialized with enabled flag" do
      tc = described_class.new(enabled: true)
      expect(tc.enabled).to be true
    end
  end

  describe "#add_revision" do
    it "adds a revision to the collection" do
      revision = Uniword::Revision.new(
        author: "John",
        text: "New text"
      )
      tracked_changes.add_revision(revision)

      expect(tracked_changes.count).to eq(1)
      expect(tracked_changes.revisions).to include(revision)
    end

    it "assigns sequential ID if not set" do
      rev1 = Uniword::Revision.new(author: "John")
      rev1.instance_variable_set(:@revision_id, nil)
      rev2 = Uniword::Revision.new(author: "Jane")
      rev2.instance_variable_set(:@revision_id, nil)

      tracked_changes.add_revision(rev1)
      tracked_changes.add_revision(rev2)

      expect(rev1.revision_id).to eq("1")
      expect(rev2.revision_id).to eq("2")
    end

    it "preserves existing revision ID" do
      revision = Uniword::Revision.new(
        author: "John",
        revision_id: "custom_123"
      )
      tracked_changes.add_revision(revision)

      expect(revision.revision_id).to eq("custom_123")
    end

    it "raises error if not a Revision instance" do
      expect do
        tracked_changes.add_revision("not a revision")
      end.to raise_error(ArgumentError, /must be a Revision instance/)
    end

    it "returns the added revision" do
      revision = Uniword::Revision.new(author: "John")
      result = tracked_changes.add_revision(revision)
      expect(result).to eq(revision)
    end
  end

  describe "#add_insertion" do
    it "creates and adds an insertion revision" do
      revision = tracked_changes.add_insertion("New text", author: "John")

      expect(revision).to be_insert
      expect(revision.text).to eq("New text")
      expect(revision.author).to eq("John")
      expect(tracked_changes.count).to eq(1)
    end

    it "supports custom date" do
      date_str = "2024-01-15T10:30:00Z"
      revision = tracked_changes.add_insertion(
        "Text",
        author: "John",
        date: date_str
      )
      expect(revision.date).to eq(date_str)
    end
  end

  describe "#add_deletion" do
    it "creates and adds a deletion revision" do
      revision = tracked_changes.add_deletion("Old text", author: "Jane")

      expect(revision).to be_delete
      expect(revision.text).to eq("Old text")
      expect(revision.author).to eq("Jane")
      expect(tracked_changes.count).to eq(1)
    end
  end

  describe "#add_format_change" do
    it "creates and adds a format change revision" do
      revision = tracked_changes.add_format_change(
        "Changed to bold",
        author: "Editor"
      )

      expect(revision).to be_format_change
      expect(revision.content).to eq("Changed to bold")
      expect(revision.author).to eq("Editor")
      expect(tracked_changes.count).to eq(1)
    end
  end

  describe "#find_revision" do
    it "finds revision by ID" do
      revision = Uniword::Revision.new(
        author: "John",
        revision_id: "123"
      )
      tracked_changes.add_revision(revision)

      found = tracked_changes.find_revision("123")
      expect(found).to eq(revision)
    end

    it "returns nil for non-existent ID" do
      found = tracked_changes.find_revision("999")
      expect(found).to be_nil
    end

    it "handles numeric IDs" do
      revision = Uniword::Revision.new(
        author: "John",
        revision_id: "5"
      )
      tracked_changes.add_revision(revision)

      found = tracked_changes.find_revision(5)
      expect(found).to eq(revision)
    end
  end

  describe "#remove_revision" do
    it "removes revision by ID" do
      revision = Uniword::Revision.new(
        author: "John",
        revision_id: "1"
      )
      tracked_changes.add_revision(revision)

      removed = tracked_changes.remove_revision("1")
      expect(removed).to eq(revision)
      expect(tracked_changes.count).to eq(0)
    end

    it "returns nil for non-existent revision" do
      removed = tracked_changes.remove_revision("999")
      expect(removed).to be_nil
    end
  end

  describe "#revisions_by_author" do
    before do
      tracked_changes.add_insertion("Text 1", author: "John")
      tracked_changes.add_deletion("Text 2", author: "Jane")
      tracked_changes.add_insertion("Text 3", author: "John")
    end

    it "returns revisions by specific author" do
      john_revisions = tracked_changes.revisions_by_author("John")
      expect(john_revisions.count).to eq(2)
      expect(john_revisions.all? { |r| r.author == "John" }).to be true
    end

    it "returns empty array for unknown author" do
      bob_revisions = tracked_changes.revisions_by_author("Bob")
      expect(bob_revisions).to be_empty
    end
  end

  describe "#revisions_by_type" do
    before do
      tracked_changes.add_insertion("Text 1", author: "John")
      tracked_changes.add_deletion("Text 2", author: "Jane")
      tracked_changes.add_insertion("Text 3", author: "John")
      tracked_changes.add_format_change("Bold", author: "Editor")
    end

    it "returns insertions" do
      insertions = tracked_changes.revisions_by_type(:insert)
      expect(insertions.count).to eq(2)
      expect(insertions.all?(&:insert?)).to be true
    end

    it "returns deletions" do
      deletions = tracked_changes.revisions_by_type(:delete)
      expect(deletions.count).to eq(1)
      expect(deletions.all?(&:delete?)).to be true
    end

    it "returns format changes" do
      format_changes = tracked_changes.revisions_by_type(:format_change)
      expect(format_changes.count).to eq(1)
      expect(format_changes.all?(&:format_change?)).to be true
    end
  end

  describe "#insertions" do
    it "returns all insertion revisions" do
      tracked_changes.add_insertion("Text 1", author: "John")
      tracked_changes.add_deletion("Text 2", author: "Jane")
      tracked_changes.add_insertion("Text 3", author: "John")

      expect(tracked_changes.insertions.count).to eq(2)
    end
  end

  describe "#deletions" do
    it "returns all deletion revisions" do
      tracked_changes.add_insertion("Text 1", author: "John")
      tracked_changes.add_deletion("Text 2", author: "Jane")
      tracked_changes.add_deletion("Text 3", author: "Jane")

      expect(tracked_changes.deletions.count).to eq(2)
    end
  end

  describe "#format_changes" do
    it "returns all format change revisions" do
      tracked_changes.add_format_change("Bold", author: "Editor")
      tracked_changes.add_insertion("Text", author: "John")
      tracked_changes.add_format_change("Italic", author: "Editor")

      expect(tracked_changes.format_changes.count).to eq(2)
    end
  end

  describe "#count" do
    it "returns zero for empty collection" do
      expect(tracked_changes.count).to eq(0)
    end

    it "returns correct count with revisions" do
      3.times { |i| tracked_changes.add_insertion("Text #{i}", author: "John") }
      expect(tracked_changes.count).to eq(3)
    end
  end

  describe "#empty?" do
    it "returns true for new tracked changes" do
      expect(tracked_changes).to be_empty
    end

    it "returns false with revisions" do
      tracked_changes.add_insertion("Text", author: "John")
      expect(tracked_changes).not_to be_empty
    end
  end

  describe "#authors" do
    it "returns empty array for no revisions" do
      expect(tracked_changes.authors).to be_empty
    end

    it "returns unique author names" do
      tracked_changes.add_insertion("Text 1", author: "John")
      tracked_changes.add_deletion("Text 2", author: "Jane")
      tracked_changes.add_insertion("Text 3", author: "John")

      authors = tracked_changes.authors
      expect(authors).to contain_exactly("John", "Jane")
    end

    it "excludes nil authors" do
      revision = Uniword::Revision.new(revision_id: "1")
      revision.instance_variable_set(:@author, nil)
      tracked_changes.add_revision(revision)

      expect(tracked_changes.authors).to be_empty
    end
  end

  describe "#clear" do
    it "removes all revisions" do
      3.times { |i| tracked_changes.add_insertion("Text #{i}", author: "John") }
      expect(tracked_changes.count).to eq(3)

      tracked_changes.clear
      expect(tracked_changes).to be_empty
    end

    it "resets revision counter" do
      tracked_changes.add_insertion("Text 1", author: "John")
      tracked_changes.clear

      revision = Uniword::Revision.new(author: "Jane")
      revision.instance_variable_set(:@revision_id, nil)
      tracked_changes.add_revision(revision)

      expect(revision.revision_id).to eq("1")
    end
  end

  describe "#accept_all" do
    it "clears all revisions" do
      3.times { |i| tracked_changes.add_insertion("Text #{i}", author: "John") }
      tracked_changes.accept_all

      expect(tracked_changes).to be_empty
    end

    it "returns count of accepted changes" do
      3.times { |i| tracked_changes.add_insertion("Text #{i}", author: "John") }
      count = tracked_changes.accept_all

      expect(count).to eq(3)
    end
  end

  describe "#reject_all" do
    it "clears all revisions" do
      3.times { |i| tracked_changes.add_insertion("Text #{i}", author: "John") }
      tracked_changes.reject_all

      expect(tracked_changes).to be_empty
    end

    it "returns count of rejected changes" do
      3.times { |i| tracked_changes.add_insertion("Text #{i}", author: "John") }
      count = tracked_changes.reject_all

      expect(count).to eq(3)
    end
  end

  describe "#enabled" do
    it "can enable track changes" do
      tracked_changes.enabled = true
      expect(tracked_changes.enabled).to be true
    end

    it "can disable track changes" do
      tracked_changes.enabled = true
      tracked_changes.enabled = false
      expect(tracked_changes.enabled).to be false
    end
  end
end
