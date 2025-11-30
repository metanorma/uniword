# frozen_string_literal: true

require_relative 'comment'

module Uniword
  # Represents the comments part of a Word document (word/comments.xml).
  #
  # This class manages the collection of all comments in a document.
  # In OOXML packages, comments are stored separately from the main
  # document in word/comments.xml.
  #
  # The CommentsPart maintains a collection of Comment objects and
  # handles serialization/deserialization to/from the comments.xml file.
  #
  # @example Create comments part
  #   comments_part = Uniword::CommentsPart.new
  #   comment = Uniword::Comment.new(
  #     author: "John Doe",
  #     text: "Please review"
  #   )
  #   comments_part.add_comment(comment)
  #
  # @attr [Array<Comment>] comments Collection of all comments
  #
  # @see Comment For individual comment structure
  class CommentsPart < Lutaml::Model::Serializable
    # OOXML namespace configuration for comments
    xml do
      element 'comments'
      namespace Ooxml::Namespaces::WordProcessingML

      map_element 'comment', to: :comments
    end

    # Collection of all comments
    attribute :comments, Comment, collection: true, default: -> { [] }

    # Initialize a new comments part
    #
    # @param attributes [Hash] Comments part attributes
    def initialize(attributes = {})
      super
      @comment_counter = 0
    end

    # Add a comment to the collection
    #
    # @param comment [Comment] The comment to add
    # @return [Comment] The added comment with assigned ID
    def add_comment(comment)
      raise ArgumentError, 'comment must be a Comment instance' unless comment.is_a?(Comment)

      # Assign sequential ID if not already set
      unless comment.comment_id && !comment.comment_id.empty?
        comment.comment_id = next_comment_id
      end

      comments << comment
      comment
    end

    # Find a comment by ID
    #
    # @param comment_id [String] The comment ID to find
    # @return [Comment, nil] The comment if found, nil otherwise
    def find_comment(comment_id)
      comments.find { |c| c.comment_id == comment_id.to_s }
    end

    # Remove a comment by ID
    #
    # @param comment_id [String] The comment ID to remove
    # @return [Comment, nil] The removed comment if found, nil otherwise
    def remove_comment(comment_id)
      comment = find_comment(comment_id)
      comments.delete(comment) if comment
      comment
    end

    # Get all comments by a specific author
    #
    # @param author [String] The author name
    # @return [Array<Comment>] Comments by the author
    def comments_by_author(author)
      comments.select { |c| c.author == author }
    end

    # Get the number of comments
    #
    # @return [Integer] The count of comments
    def count
      comments.size
    end

    # Check if there are any comments
    #
    # @return [Boolean] true if empty
    def empty?
      comments.empty?
    end

    # Get all unique authors
    #
    # @return [Array<String>] List of unique author names
    def authors
      comments.map(&:author).uniq.compact
    end

    # Clear all comments
    #
    # @return [void]
    def clear
      comments.clear
      @comment_counter = 0
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the comments part
    def inspect
      "#<Uniword::CommentsPart count=#{count} authors=#{authors.count}>"
    end

    private

    # Generate next sequential comment ID
    #
    # @return [String] The next comment ID
    def next_comment_id
      @comment_counter += 1
      @comment_counter.to_s
    end
  end
end