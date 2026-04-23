# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::CommentsPart do
  let(:comments_part) { described_class.new }

  describe "#initialize" do
    it "creates an empty comments collection" do
      expect(comments_part.comments).to be_empty
      expect(comments_part.count).to eq(0)
    end
  end

  describe "#add_comment" do
    it "adds a comment to the collection" do
      comment = Uniword::Comment.new(author: "John", text: "Review")
      comments_part.add_comment(comment)

      expect(comments_part.count).to eq(1)
      expect(comments_part.comments).to include(comment)
    end

    it "assigns sequential ID if not set" do
      comment1 = Uniword::Comment.new(author: "John")
      comment1.instance_variable_set(:@comment_id, nil)
      comment2 = Uniword::Comment.new(author: "Jane")
      comment2.instance_variable_set(:@comment_id, nil)

      comments_part.add_comment(comment1)
      comments_part.add_comment(comment2)

      expect(comment1.comment_id).to eq("1")
      expect(comment2.comment_id).to eq("2")
    end

    it "preserves existing comment ID" do
      comment = Uniword::Comment.new(author: "John", comment_id: "custom_123")
      comments_part.add_comment(comment)

      expect(comment.comment_id).to eq("custom_123")
    end

    it "raises error if not a Comment instance" do
      expect do
        comments_part.add_comment("not a comment")
      end.to raise_error(ArgumentError, /must be a Comment instance/)
    end

    it "returns the added comment" do
      comment = Uniword::Comment.new(author: "John")
      result = comments_part.add_comment(comment)
      expect(result).to eq(comment)
    end
  end

  describe "#find_comment" do
    it "finds comment by ID" do
      comment = Uniword::Comment.new(
        author: "John",
        comment_id: "123",
      )
      comments_part.add_comment(comment)

      found = comments_part.find_comment("123")
      expect(found).to eq(comment)
    end

    it "returns nil for non-existent ID" do
      found = comments_part.find_comment("999")
      expect(found).to be_nil
    end

    it "handles numeric IDs" do
      comment = Uniword::Comment.new(
        author: "John",
        comment_id: "5",
      )
      comments_part.add_comment(comment)

      found = comments_part.find_comment(5)
      expect(found).to eq(comment)
    end
  end

  describe "#remove_comment" do
    it "removes comment by ID" do
      comment = Uniword::Comment.new(
        author: "John",
        comment_id: "1",
      )
      comments_part.add_comment(comment)

      removed = comments_part.remove_comment("1")
      expect(removed).to eq(comment)
      expect(comments_part.count).to eq(0)
    end

    it "returns nil for non-existent comment" do
      removed = comments_part.remove_comment("999")
      expect(removed).to be_nil
    end
  end

  describe "#comments_by_author" do
    before do
      comments_part.add_comment(
        Uniword::Comment.new(author: "John", text: "Comment 1"),
      )
      comments_part.add_comment(
        Uniword::Comment.new(author: "Jane", text: "Comment 2"),
      )
      comments_part.add_comment(
        Uniword::Comment.new(author: "John", text: "Comment 3"),
      )
    end

    it "returns comments by specific author" do
      john_comments = comments_part.comments_by_author("John")
      expect(john_comments.count).to eq(2)
      expect(john_comments.all? { |c| c.author == "John" }).to be true
    end

    it "returns empty array for unknown author" do
      bob_comments = comments_part.comments_by_author("Bob")
      expect(bob_comments).to be_empty
    end
  end

  describe "#count" do
    it "returns zero for empty collection" do
      expect(comments_part.count).to eq(0)
    end

    it "returns correct count with comments" do
      3.times { |i| comments_part.add_comment(Uniword::Comment.new(author: "Author#{i}")) }
      expect(comments_part.count).to eq(3)
    end
  end

  describe "#empty?" do
    it "returns true for new comments part" do
      expect(comments_part).to be_empty
    end

    it "returns false with comments" do
      comments_part.add_comment(Uniword::Comment.new(author: "John"))
      expect(comments_part).not_to be_empty
    end
  end

  describe "#authors" do
    it "returns empty array for no comments" do
      expect(comments_part.authors).to be_empty
    end

    it "returns unique author names" do
      comments_part.add_comment(Uniword::Comment.new(author: "John"))
      comments_part.add_comment(Uniword::Comment.new(author: "Jane"))
      comments_part.add_comment(Uniword::Comment.new(author: "John"))

      authors = comments_part.authors
      expect(authors).to contain_exactly("John", "Jane")
    end

    it "excludes nil authors" do
      comment = Uniword::Comment.new(comment_id: "1")
      comment.instance_variable_set(:@author, nil)
      comments_part.add_comment(comment)

      expect(comments_part.authors).to be_empty
    end
  end

  describe "#clear" do
    it "removes all comments" do
      3.times { |i| comments_part.add_comment(Uniword::Comment.new(author: "Author#{i}")) }
      expect(comments_part.count).to eq(3)

      comments_part.clear
      expect(comments_part).to be_empty
    end

    it "resets comment counter" do
      comments_part.add_comment(Uniword::Comment.new(author: "John"))
      comments_part.clear

      comment = Uniword::Comment.new(author: "Jane")
      comment.instance_variable_set(:@comment_id, nil)
      comments_part.add_comment(comment)

      expect(comment.comment_id).to eq("1")
    end
  end
end
