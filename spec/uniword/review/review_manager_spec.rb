# frozen_string_literal: true

require "spec_helper"
require "uniword/review"

RSpec.describe Uniword::Review::ReviewManager do
  let(:doc) do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.comments = Uniword::CommentsPart.new
    doc.revisions = Uniword::TrackedChanges.new
    doc
  end

  let(:manager) { described_class.new(doc) }

  describe "#list_comments" do
    it "returns empty array when no comments" do
      expect(manager.list_comments).to eq([])
    end

    it "returns all comments" do
      c1 = Uniword::Comment.new(author: "Alice", text: "First")
      c2 = Uniword::Comment.new(author: "Bob", text: "Second")
      doc.comments.add_comment(c1)
      doc.comments.add_comment(c2)

      result = manager.list_comments
      expect(result.count).to eq(2)
      expect(result.map(&:author)).to eq(["Alice", "Bob"])
    end
  end

  describe "#add_comment" do
    it "adds a comment and returns it" do
      comment = manager.add_comment(
        text: "Please review",
        author: "Alice"
      )

      expect(comment).to be_a(Uniword::Comment)
      expect(comment.author).to eq("Alice")
      expect(comment.text).to eq("Please review")
      expect(manager.list_comments.count).to eq(1)
    end

    it "sets initials when provided" do
      comment = manager.add_comment(
        text: "Note",
        author: "Alice",
        initials: "A"
      )
      expect(comment.initials).to eq("A")
    end
  end

  describe "#reply_to_comment" do
    it "replies to an existing comment" do
      parent = manager.add_comment(
        text: "Original",
        author: "Alice"
      )

      reply = manager.reply_to_comment(
        parent.comment_id,
        text: "Reply text",
        author: "Bob"
      )

      expect(reply).to be_a(Uniword::Comment)
      expect(reply.author).to eq("Bob")
      expect(reply.text).to eq("Reply text")
      expect(manager.list_comments.count).to eq(2)
    end

    it "raises error if parent not found" do
      expect do
        manager.reply_to_comment("nonexistent", text: "X", author: "A")
      end.to raise_error(ArgumentError, /not found/)
    end
  end

  describe "#resolve_comment" do
    it "marks a comment as resolved" do
      comment = manager.add_comment(
        text: "Review this",
        author: "Alice"
      )

      result = manager.resolve_comment(comment.comment_id)
      expect(result).not_to be_nil
      expect(result.initials).to include("[resolved]")
    end

    it "returns nil if comment not found" do
      result = manager.resolve_comment("nonexistent")
      expect(result).to be_nil
    end
  end

  describe "#remove_comment" do
    it "removes a comment" do
      comment = manager.add_comment(
        text: "Remove me",
        author: "Alice"
      )

      expect(manager.list_comments.count).to eq(1)
      removed = manager.remove_comment(comment.comment_id)
      expect(removed).to eq(comment)
      expect(manager.list_comments.count).to eq(0)
    end

    it "returns nil if comment not found" do
      result = manager.remove_comment("nonexistent")
      expect(result).to be_nil
    end
  end

  describe "#clear_comments" do
    it "removes all comments" do
      manager.add_comment(text: "A", author: "Alice")
      manager.add_comment(text: "B", author: "Bob")

      expect(manager.list_comments.count).to eq(2)
      manager.clear_comments
      expect(manager.list_comments.count).to eq(0)
    end
  end

  describe "#list_revisions" do
    it "returns empty array when no revisions" do
      expect(manager.list_revisions).to eq([])
    end

    it "returns all revisions" do
      doc.revisions.add_insertion("Added text", author: "Alice")
      doc.revisions.add_deletion("Removed text", author: "Bob")

      result = manager.list_revisions
      expect(result.count).to eq(2)
    end
  end

  describe "#revisions_by_author" do
    it "filters revisions by author" do
      doc.revisions.add_insertion("A", author: "Alice")
      doc.revisions.add_insertion("B", author: "Bob")
      doc.revisions.add_deletion("C", author: "Alice")

      result = manager.revisions_by_author("Alice")
      expect(result.count).to eq(2)
      expect(result.all? { |r| r.author == "Alice" }).to be(true)
    end
  end

  describe "#revisions_by_type" do
    it "filters revisions by type" do
      doc.revisions.add_insertion("A", author: "Alice")
      doc.revisions.add_deletion("B", author: "Bob")
      doc.revisions.add_insertion("C", author: "Carol")

      result = manager.revisions_by_type(:insert)
      expect(result.count).to eq(2)
      expect(result.all?(&:insert?)).to be(true)
    end
  end

  describe "#accept" do
    it "accepts a revision by ID" do
      rev = doc.revisions.add_insertion("Added", author: "Alice")

      result = manager.accept(rev.revision_id)
      expect(result).to be(true)
      expect(manager.list_revisions.count).to eq(0)
    end

    it "returns false for unknown revision ID" do
      result = manager.accept("nonexistent")
      expect(result).to be(false)
    end
  end

  describe "#reject" do
    it "rejects a revision by ID" do
      rev = doc.revisions.add_deletion("Removed", author: "Alice")

      result = manager.reject(rev.revision_id)
      expect(result).to be(true)
      expect(manager.list_revisions.count).to eq(0)
    end

    it "returns false for unknown revision ID" do
      result = manager.reject("nonexistent")
      expect(result).to be(false)
    end
  end

  describe "#accept_all" do
    it "accepts all revisions" do
      doc.revisions.add_insertion("A", author: "Alice")
      doc.revisions.add_deletion("B", author: "Bob")
      doc.revisions.add_format_change("Bold", author: "Carol")

      count = manager.accept_all
      expect(count).to eq(3)
      expect(manager.list_revisions).to be_empty
    end

    it "returns 0 when no revisions" do
      count = manager.accept_all
      expect(count).to eq(0)
    end
  end

  describe "#reject_all" do
    it "rejects all revisions" do
      doc.revisions.add_insertion("A", author: "Alice")
      doc.revisions.add_deletion("B", author: "Bob")

      count = manager.reject_all
      expect(count).to eq(2)
      expect(manager.list_revisions).to be_empty
    end

    it "returns 0 when no revisions" do
      count = manager.reject_all
      expect(count).to eq(0)
    end
  end

  describe "#all_authors" do
    it "combines comment and revision authors" do
      manager.add_comment(text: "Note", author: "Alice")
      doc.revisions.add_insertion("Added", author: "Bob")
      doc.revisions.add_insertion("More", author: "Alice")

      authors = manager.all_authors
      expect(authors).to eq(["Alice", "Bob"])
    end

    it "returns empty array with no comments or revisions" do
      expect(manager.all_authors).to eq([])
    end
  end

  describe "#review_queue" do
    it "returns empty queue when no items" do
      expect(manager.review_queue).to eq([])
    end

    it "combines comments and revisions into sorted queue" do
      c1 = Uniword::Comment.new(
        author: "Alice",
        text: "Comment",
        date: "2024-01-01T10:00:00Z"
      )
      doc.comments.add_comment(c1)

      r1 = Uniword::Revision.new(
        type: :insert,
        author: "Bob",
        text: "Insert",
        date: "2024-01-01T09:00:00Z"
      )
      doc.revisions.add_revision(r1)

      queue = manager.review_queue
      expect(queue.size).to eq(2)

      # Sorted by date: revision first, then comment
      expect(queue[0][:type]).to eq(:revision)
      expect(queue[0][:item]).to eq(r1)
      expect(queue[1][:type]).to eq(:comment)
      expect(queue[1][:item]).to eq(c1)
    end

    it "includes correct entry structure" do
      manager.add_comment(text: "Test", author: "Alice")

      entry = manager.review_queue.first
      expect(entry).to have_key(:type)
      expect(entry).to have_key(:item)
      expect(entry).to have_key(:position)
      expect(entry[:type]).to eq(:comment)
    end
  end
end
