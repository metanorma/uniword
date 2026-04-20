# frozen_string_literal: true

require "thor"
require_relative "helpers"

module Uniword
  # Review subcommands for Uniword CLI.
  #
  # Provides commands for reviewing comments and tracked changes:
  # - comments: list comments in a document
  # - changes: list tracked changes (revisions) in a document
  # - accept: accept a single revision by ID
  # - reject: reject a single revision by ID
  # - accept-all: accept all tracked changes
  # - reject-all: reject all tracked changes
  # - interactive: step through changes one-by-one
  class ReviewCLI < Thor
    include CLIHelpers

    desc "comments FILE", "List all comments in a document"
    long_desc <<~DESC
      Display all comments in a document with author, date, and text.

      Examples:
        $ uniword review comments document.docx
        $ uniword review comments document.docx --verbose
    DESC
    option :verbose, aliases: "-v", desc: "Show detailed information",
                     type: :boolean, default: false
    def comments(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)
      comment_list = manager.list_comments

      if comment_list.empty?
        say "No comments found.", :yellow
        return
      end

      say "Comments (#{comment_list.count}):", :green
      comment_list.each_with_index do |comment, idx|
        say "  #{idx + 1}. ID: #{comment.comment_id}"
        say "     Author: #{comment.author || "(unknown)"}"
        say "     Date:   #{comment.date || "(unknown)"}"

        if options[:verbose]
          say "     Text:   #{comment.text}"
        else
          preview = comment.text&.[](0..60) || "(empty)"
          preview += "..." if comment.text.to_s.length > 60
          say "     Text:   #{preview}"
        end
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "changes FILE", "List all tracked changes in a document"
    long_desc <<~DESC
      Display all tracked changes (revisions) with type, author, and text.

      Examples:
        $ uniword review changes document.docx
        $ uniword review changes document.docx --author "John Doe"
        $ uniword review changes document.docx --type insert
    DESC
    option :author, desc: "Filter revisions by author", type: :string
    option :type, desc: "Filter by type (insert/delete/format_change)",
                  type: :string
    option :verbose, aliases: "-v", desc: "Show detailed information",
                     type: :boolean, default: false
    def changes(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      revisions = filtered_revisions(manager)

      if revisions.empty?
        say "No tracked changes found.", :yellow
        return
      end

      say "Tracked changes (#{revisions.count}):", :green
      revisions.each_with_index do |rev, idx|
        say "  #{idx + 1}. ID: #{rev.revision_id}"
        say "     Type:   #{format_type(rev.type)}"
        say "     Author: #{rev.author || "(unknown)"}"
        say "     Date:   #{rev.date || "(unknown)"}"

        if options[:verbose]
          say "     Text:   #{rev.text}"
        else
          preview = rev.text&.[](0..40) || "(empty)"
          preview += "..." if rev.text.to_s.length > 40
          say "     Text:   #{preview}"
        end
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "accept FILE REVISION_ID", "Accept a single revision"
    long_desc <<~DESC
      Accept a tracked change by its revision ID.

      Examples:
        $ uniword review accept document.docx 3
        $ uniword review accept document.docx 3 --output accepted.docx
    DESC
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def accept(path, revision_id)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      unless manager.accept(revision_id)
        say "Revision '#{revision_id}' not found.", :red
        exit 1
      end

      save_output(doc, path)
      say "Accepted revision '#{revision_id}'.", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "reject FILE REVISION_ID", "Reject a single revision"
    long_desc <<~DESC
      Reject a tracked change by its revision ID.

      Examples:
        $ uniword review reject document.docx 3
        $ uniword review reject document.docx 3 --output rejected.docx
    DESC
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def reject(path, revision_id)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      unless manager.reject(revision_id)
        say "Revision '#{revision_id}' not found.", :red
        exit 1
      end

      save_output(doc, path)
      say "Rejected revision '#{revision_id}'.", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "accept-all FILE", "Accept all tracked changes"
    long_desc <<~DESC
      Accept all tracked changes in the document.

      Examples:
        $ uniword review accept-all document.docx
        $ uniword review accept-all document.docx --output clean.docx
    DESC
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def accept_all(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      count = manager.accept_all
      save_output(doc, path)

      if count.positive?
        say "Accepted #{count} revision(s).", :green
      else
        say "No revisions to accept.", :yellow
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "reject-all FILE", "Reject all tracked changes"
    long_desc <<~DESC
      Reject all tracked changes in the document.

      Examples:
        $ uniword review reject-all document.docx
        $ uniword review reject-all document.docx --output reverted.docx
    DESC
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def reject_all(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      count = manager.reject_all
      save_output(doc, path)

      if count.positive?
        say "Rejected #{count} revision(s).", :green
      else
        say "No revisions to reject.", :yellow
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "interactive FILE", "Interactively review all changes"
    long_desc <<~DESC
      Step through comments and tracked changes one-by-one.
      For each item, choose to accept, reject, skip, or quit.

      Examples:
        $ uniword review interactive document.docx
    DESC
    def interactive(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      session = Review::InteractiveReview.new(
        manager,
        output: $stdout,
        input: $stdin
      )
      result = session.run

      if result[:accepted].positive? || result[:rejected].positive?
        save_output(doc, path)
        say "Document updated.", :green
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    private

    # Filter revisions based on CLI options.
    #
    # @param manager [Review::ReviewManager] The review manager
    # @return [Array<Uniword::Revision>] Filtered revisions
    def filtered_revisions(manager)
      revisions = manager.list_revisions

      if options[:author]
        revisions = revisions.select do |r|
          r.author == options[:author]
        end
      end

      if options[:type]
        type = options[:type].to_sym
        revisions = revisions.select { |r| r.type == type }
      end

      revisions
    end

    # Format revision type for display.
    #
    # @param type [Symbol] The revision type
    # @return [String] Human-readable label
    def format_type(type)
      case type
      when :insert then "Insertion"
      when :delete then "Deletion"
      when :format_change then "Format change"
      else type.to_s
      end
    end

    # Save the document to the specified output path or overwrite.
    #
    # @param doc [Uniword::Wordprocessingml::DocumentRoot] The document
    # @param original_path [String] The original file path
    # @return [void]
    def save_output(doc, original_path)
      output_path = options[:output] || original_path
      doc.save(output_path)
    end
  end
end
