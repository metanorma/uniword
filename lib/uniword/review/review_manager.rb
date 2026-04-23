# frozen_string_literal: true

require_relative "accept_reject"

module Uniword
  module Review
    # Orchestrator for comments and tracked changes in a document.
    #
    # Provides a unified API for listing, adding, resolving, and removing
    # comments, as well as listing and accepting/rejecting tracked changes.
    #
    # Delegates individual revision operations to AcceptReject.
    #
    # @example List all comments
    #   manager = ReviewManager.new(doc)
    #   manager.list_comments
    #
    # @example Accept all tracked changes
    #   manager.accept_all
    #
    # @see AcceptReject For individual revision handling
    # @see InteractiveReview For the TUI review interface
    class ReviewManager
      attr_reader :document

      # Initialize a ReviewManager for the given document.
      #
      # @param document [Uniword::Wordprocessingml::DocumentRoot] The document
      def initialize(document)
        @document = document
        @accept_reject = AcceptReject.new
      end

      # --- Comments ---

      # List all comments in the document.
      #
      # @return [Array<Uniword::Comment>] All comments
      def list_comments
        comments_part.comments
      end

      # Add a new comment to the document.
      #
      # @param text [String] Comment text
      # @param author [String] Author name
      # @param initials [String, nil] Author initials
      # @return [Uniword::Comment] The added comment
      def add_comment(text:, author:, initials: nil)
        comment = Uniword::Comment.new(
          text: text,
          author: author,
          initials: initials,
        )
        comments_part.add_comment(comment)
      end

      # Reply to an existing comment.
      #
      # Creates a new comment linked to the parent by convention
      # (same author context).
      #
      # @param parent_id [String] The parent comment ID
      # @param text [String] Reply text
      # @param author [String] Author name
      # @return [Uniword::Comment] The reply comment
      # @raise [ArgumentError] If parent comment not found
      def reply_to_comment(parent_id, text:, author:)
        parent = comments_part.find_comment(parent_id)
        unless parent
          raise ArgumentError,
                "Comment #{parent_id} not found"
        end

        comment = Uniword::Comment.new(
          text: text,
          author: author,
        )
        comments_part.add_comment(comment)
      end

      # Resolve a comment (mark it as resolved).
      #
      # Resolved comments remain in the document but are hidden
      # from the active review interface.
      #
      # @param comment_id [String] The comment ID to resolve
      # @return [Uniword::Comment, nil] The resolved comment
      def resolve_comment(comment_id)
        comment = comments_part.find_comment(comment_id)
        return nil unless comment

        comment.initials = "#{comment.initials}[resolved]"
        comment
      end

      # Remove a comment from the document.
      #
      # @param comment_id [String] The comment ID to remove
      # @return [Uniword::Comment, nil] The removed comment
      def remove_comment(comment_id)
        comments_part.remove_comment(comment_id)
      end

      # Remove all comments from the document.
      #
      # @return [void]
      def clear_comments
        comments_part.clear
      end

      # --- Tracked Changes ---

      # List all revisions (tracked changes) in the document.
      #
      # @return [Array<Uniword::Revision>] All revisions
      def list_revisions
        tracked_changes.revisions
      end

      # Get revisions filtered by author.
      #
      # @param author [String] Author name
      # @return [Array<Uniword::Revision>] Revisions by the author
      def revisions_by_author(author)
        tracked_changes.revisions_by_author(author)
      end

      # Get revisions filtered by type.
      #
      # @param type [Symbol] Revision type (:insert, :delete,
      #   :format_change)
      # @return [Array<Uniword::Revision>] Revisions of the type
      def revisions_by_type(type)
        tracked_changes.revisions_by_type(type)
      end

      # Accept a single revision by ID.
      #
      # @param revision_id [String] The revision ID to accept
      # @return [Boolean] true if accepted, false if not found
      def accept(revision_id)
        revision = tracked_changes.find_revision(revision_id)
        return false unless revision

        @accept_reject.accept(revision)
        tracked_changes.remove_revision(revision_id)
        true
      end

      # Reject a single revision by ID.
      #
      # @param revision_id [String] The revision ID to reject
      # @return [Boolean] true if rejected, false if not found
      def reject(revision_id)
        revision = tracked_changes.find_revision(revision_id)
        return false unless revision

        @accept_reject.reject(revision)
        tracked_changes.remove_revision(revision_id)
        true
      end

      # Accept all tracked changes in the document.
      #
      # @return [Integer] Number of changes accepted
      def accept_all
        tracked_changes.accept_all
      end

      # Reject all tracked changes in the document.
      #
      # @return [Integer] Number of changes rejected
      def reject_all
        tracked_changes.reject_all
      end

      # Get all unique authors who have made changes.
      #
      # @return [Array<String>] Unique author names from both
      #   comments and revisions
      def all_authors
        comment_authors = comments_part.authors
        revision_authors = tracked_changes.authors
        (comment_authors + revision_authors).uniq.sort
      end

      # Build a combined review queue of comments and revisions,
      # sorted by position (date).
      #
      # Each item is a hash with :type (:comment or :revision),
      # :item, and :position keys.
      #
      # @return [Array<Hash>] Combined review queue
      def review_queue
        items = comments_part.comments.map do |comment|
          {
            type: :comment,
            item: comment,
            position: comment.date.to_s,
          }
        end

        tracked_changes.revisions.each do |revision|
          items << {
            type: :revision,
            item: revision,
            position: revision.date.to_s,
          }
        end

        items.sort_by { |e| e[:position] }
      end

      private

      # Get or initialize the CommentsPart for the document.
      #
      # @return [Uniword::CommentsPart] The comments collection
      def comments_part
        @comments_part ||= begin
          existing = document.comments
          if existing.is_a?(CommentsPart)
            existing
          else
            part = CommentsPart.new
            document.comments = part
            part
          end
        end
      end

      # Get or initialize TrackedChanges for the document.
      #
      # @return [Uniword::TrackedChanges] The tracked changes collection
      def tracked_changes
        @tracked_changes ||= begin
          existing = document.revisions
          if existing.is_a?(TrackedChanges)
            existing
          else
            tc = TrackedChanges.new
            document.revisions = tc
            tc
          end
        end
      end
    end
  end
end
