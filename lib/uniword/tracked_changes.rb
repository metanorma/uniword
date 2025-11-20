# frozen_string_literal: true

require_relative 'revision'

module Uniword
  # Manages track changes for a Word document.
  #
  # This class represents the collection of all revisions (tracked changes)
  # in a document, including insertions, deletions, and formatting changes.
  #
  # Track changes allow users to see what modifications have been made to
  # a document, who made them, and when.
  #
  # @example Enable track changes
  #   tracked_changes = Uniword::TrackedChanges.new
  #   tracked_changes.enabled = true
  #
  # @example Add an insertion
  #   revision = Uniword::Revision.new(
  #     type: :insert,
  #     author: "John Doe",
  #     text: "New content"
  #   )
  #   tracked_changes.add_revision(revision)
  #
  # @attr [Boolean] enabled Whether track changes is enabled
  # @attr [Array<Revision>] revisions Collection of all revisions
  #
  # @see Revision For individual revision structure
  class TrackedChanges
    # Whether track changes is enabled
    attr_accessor :enabled

    # Collection of all revisions
    attr_accessor :revisions

    # Initialize tracked changes
    #
    # @param attributes [Hash] Tracked changes attributes
    # @option attributes [Boolean] :enabled Whether track changes is enabled
    def initialize(attributes = {})
      @enabled = attributes[:enabled] || false
      @revisions = []
      @revision_counter = 0
    end

    # Add a revision to the collection
    #
    # @param revision [Revision] The revision to add
    # @return [Revision] The added revision with assigned ID
    def add_revision(revision)
      raise ArgumentError, 'revision must be a Revision instance' unless revision.is_a?(Revision)

      # Assign sequential ID if not already set
      unless revision.revision_id && !revision.revision_id.empty?
        revision.revision_id = next_revision_id
      end

      revisions << revision
      revision
    end

    # Add an insertion
    #
    # @param text [String] The inserted text
    # @param author [String] The author name
    # @param date [String, Time, nil] Optional date
    # @return [Revision] The created insertion revision
    def add_insertion(text, author:, date: nil)
      revision = Revision.new(
        type: :insert,
        text: text,
        author: author,
        date: date
      )
      add_revision(revision)
    end

    # Add a deletion
    #
    # @param text [String] The deleted text
    # @param author [String] The author name
    # @param date [String, Time, nil] Optional date
    # @return [Revision] The created deletion revision
    def add_deletion(text, author:, date: nil)
      revision = Revision.new(
        type: :delete,
        text: text,
        author: author,
        date: date
      )
      add_revision(revision)
    end

    # Add a format change
    #
    # @param content [String] Description of format change
    # @param author [String] The author name
    # @param date [String, Time, nil] Optional date
    # @return [Revision] The created format change revision
    def add_format_change(content, author:, date: nil)
      revision = Revision.new(
        type: :format_change,
        content: content,
        author: author,
        date: date
      )
      add_revision(revision)
    end

    # Find a revision by ID
    #
    # @param revision_id [String] The revision ID to find
    # @return [Revision, nil] The revision if found, nil otherwise
    def find_revision(revision_id)
      revisions.find { |r| r.revision_id == revision_id.to_s }
    end

    # Remove a revision by ID
    #
    # @param revision_id [String] The revision ID to remove
    # @return [Revision, nil] The removed revision if found, nil otherwise
    def remove_revision(revision_id)
      revision = find_revision(revision_id)
      revisions.delete(revision) if revision
      revision
    end

    # Get all revisions by a specific author
    #
    # @param author [String] The author name
    # @return [Array<Revision>] Revisions by the author
    def revisions_by_author(author)
      revisions.select { |r| r.author == author }
    end

    # Get all revisions of a specific type
    #
    # @param type [Symbol] The revision type (:insert, :delete, :format_change)
    # @return [Array<Revision>] Revisions of the specified type
    def revisions_by_type(type)
      revisions.select { |r| r.type == type }
    end

    # Get all insertions
    #
    # @return [Array<Revision>] All insertion revisions
    def insertions
      revisions_by_type(:insert)
    end

    # Get all deletions
    #
    # @return [Array<Revision>] All deletion revisions
    def deletions
      revisions_by_type(:delete)
    end

    # Get all format changes
    #
    # @return [Array<Revision>] All format change revisions
    def format_changes
      revisions_by_type(:format_change)
    end

    # Get the number of revisions
    #
    # @return [Integer] The count of revisions
    def count
      revisions.size
    end

    # Check if there are any revisions
    #
    # @return [Boolean] true if empty
    def empty?
      revisions.empty?
    end

    # Get all unique authors
    #
    # @return [Array<String>] List of unique author names
    def authors
      revisions.map(&:author).uniq.compact
    end

    # Clear all revisions
    #
    # @return [void]
    def clear
      revisions.clear
      @revision_counter = 0
    end

    # Accept all changes (remove all revisions)
    #
    # @return [Integer] The number of changes accepted
    def accept_all
      count_before = count
      clear
      count_before
    end

    # Reject all changes (remove all revisions)
    #
    # @return [Integer] The number of changes rejected
    def reject_all
      count_before = count
      clear
      count_before
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of tracked changes
    def inspect
      "#<Uniword::TrackedChanges enabled=#{enabled} " \
        "revisions=#{count} " \
        "insertions=#{insertions.count} " \
        "deletions=#{deletions.count}>"
    end

    private

    # Generate next sequential revision ID
    #
    # @return [String] The next revision ID
    def next_revision_id
      @revision_counter += 1
      @revision_counter.to_s
    end
  end
end