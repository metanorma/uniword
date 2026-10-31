# frozen_string_literal: true

require "thor"
require "time"
require "date"

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
        $ uniword review comments document.docx --json
    DESC
    option :verbose, aliases: "-v", desc: "Show detailed information",
                     type: :boolean, default: false
    option :json, desc: "Output as JSON (machine-readable)",
                  type: :boolean, default: false
    def comments(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)
      comment_list = manager.list_comments

      if comment_list.empty?
        say "No comments found.", :yellow
        return
      end

      if options[:json]
        require "json"
        anchors = manager.comment_anchor_texts
        puts JSON.pretty_generate(comment_list.map do |comment|
          {
            id: comment.comment_id,
            author: comment.author,
            date: comment.date,
            text: comment.text,
            anchored_text: anchors[comment.comment_id.to_s],
          }
        end)
        return
      end

      say "Comments (#{comment_list.count}):", :green
      comment_list.each_with_index do |comment, idx|
        say "  #{idx + 1}. ID: #{comment.comment_id}"
        say "     Author: #{comment.author || '(unknown)'}"
        say "     Date:   #{comment.date || '(unknown)'}"

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
        $ uniword review changes document.docx --since 2026-01-01 --json
    DESC
    option :author, desc: "Filter revisions by author", type: :string
    option :type, desc: "Filter by type (insert/delete/format_change)",
                  type: :string
    option :since, desc: "Only revisions dated on/after (ISO 8601)",
                   type: :string
    option :until, desc: "Only revisions dated on/before (ISO 8601)",
                   type: :string
    option :verbose, aliases: "-v", desc: "Show detailed information",
                     type: :boolean, default: false
    option :json, desc: "Output as JSON (machine-readable)",
                  type: :boolean, default: false
    def changes(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      revisions = filtered_revisions(manager)

      if revisions.empty?
        say "No tracked changes found.", :yellow
        return
      end

      if options[:json]
        require "json"
        puts JSON.pretty_generate(revisions.map do |rev|
          {
            id: rev.revision_id,
            author: rev.author,
            date: rev.date,
            type: rev.type.to_s,
            text: rev.text,
          }
        end)
        return
      end

      say "Tracked changes (#{revisions.count}):", :green
      revisions.each_with_index do |rev, idx|
        say "  #{idx + 1}. ID: #{rev.revision_id}"
        say "     Type:   #{format_type(rev.type)}"
        say "     Author: #{rev.author || '(unknown)'}"
        say "     Date:   #{rev.date || '(unknown)'}"

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

    desc "accept FILE [REVISION_ID]",
         "Accept a revision, or all matching filters"
    long_desc <<~DESC
      Accept a tracked change by its revision ID. Without an ID, every
      revision matching the --author/--since/--until filters is accepted
      (default: all).

      Examples:
        $ uniword review accept document.docx 3
        $ uniword review accept document.docx 3 --output accepted.docx
        $ uniword review accept document.docx --author "John Doe" -o out.docx
        $ uniword review accept document.docx --since 2026-01-01 -o out.docx
    DESC
    option :author, desc: "With no ID: only revisions by this author",
                    type: :string
    option :since, desc: "With no ID: only revisions dated on/after",
                   type: :string
    option :until, desc: "With no ID: only revisions dated on/before",
                   type: :string
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def accept(path, revision_id = nil)
      apply_decisions(path, revision_id, :accept, "Accepted")
    end

    desc "reject FILE [REVISION_ID]",
         "Reject a revision, or all matching filters"
    long_desc <<~DESC
      Reject a tracked change by its revision ID. Without an ID, every
      revision matching the --author/--since/--until filters is rejected
      (default: all).

      Examples:
        $ uniword review reject document.docx 3
        $ uniword review reject document.docx 3 --output rejected.docx
        $ uniword review reject document.docx --author "John Doe" -o out.docx
    DESC
    option :author, desc: "With no ID: only revisions by this author",
                    type: :string
    option :since, desc: "With no ID: only revisions dated on/after",
                   type: :string
    option :until, desc: "With no ID: only revisions dated on/before",
                   type: :string
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def reject(path, revision_id = nil)
      apply_decisions(path, revision_id, :reject, "Rejected")
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

    desc "track-changes SUBCOMMAND", "Toggle or query change tracking"
    long_desc <<~DESC
      Turn Word's Review → Track Changes toggle on or off, or query
      its current state.

      Examples:
        $ uniword review track-changes on input.docx output.docx
        $ uniword review track-changes off input.docx output.docx
        $ uniword review track-changes status input.docx
    DESC
    def track_changes(command, input_path, output_path = nil)
      doc = load_document(input_path)

      case command.to_sym
      when :on
        doc.track_changes_on!
        doc.save(output_path || input_path)
        say "Change tracking ON in #{output_path || input_path}", :green
      when :off
        doc.track_changes_off!
        doc.save(output_path || input_path)
        say "Change tracking OFF in #{output_path || input_path}", :green
      when :status
        say doc.track_changes_enabled? ? "ON" : "OFF"
      else
        say "Unknown subcommand: #{command}. Use on, off, or status.", :red
        exit 1
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
        input: $stdin,
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

    # Apply accept/reject to one revision ID or to all revisions
    # matching the author/date filters, then save.
    #
    # @param path [String] document path
    # @param revision_id [String, nil] single target ID (filters unused)
    # @param action [Symbol] :accept or :reject
    # @param label [String] past-tense verb for the report line
    # @return [void]
    def apply_decisions(path, revision_id, action, label)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      if revision_id
        found = decide(manager, action, revision_id)
        unless found
          say "Revision '#{revision_id}' not found.", :red
          exit 1
        end
        count = 1
      else
        targets = filtered_revisions(manager)
        targets.each { |rev| decide(manager, action, rev.revision_id) }
        count = targets.count
      end

      save_output(doc, path)

      if count.positive?
        say "#{label} #{count} revision(s).", :green
      else
        say "No matching revisions found.", :yellow
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    # Dispatch one revision decision to the review manager.
    #
    # @param manager [Review::ReviewManager]
    # @param action [Symbol] :accept or :reject
    # @param revision_id [String]
    # @return [Boolean, nil] outcome reported by the manager
    def decide(manager, action, revision_id)
      if action == :accept
        manager.accept(revision_id)
      else
        manager.reject(revision_id)
      end
    end

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

      revisions = filter_by_date_range(revisions, options[:since],
                                       options[:until])

      if options[:type]
        type = options[:type].to_sym
        revisions = revisions.select { |r| r.type == type }
      end

      revisions
    end

    # Keep revisions whose date falls within [since, until]. Dates are
    # ISO 8601; unparseable revision dates are dropped when a date
    # filter is active. Date-only bounds are interpreted as UTC days
    # (inclusive on both ends).
    #
    # @param revisions [Array<Uniword::Revision>]
    # @param since [String, nil] inclusive lower bound (ISO 8601)
    # @param until_date [String, nil] inclusive upper bound (ISO 8601)
    # @return [Array<Uniword::Revision>]
    def filter_by_date_range(revisions, since, until_date)
      lower = parse_filter_time(since)
      upper = parse_filter_time(until_date, end_of_day: true)
      return revisions unless lower || upper

      revisions.select do |revision|
        date = parse_filter_time(revision.date)
        next false unless date

        (lower.nil? || date >= lower) && (upper.nil? || date <= upper)
      end
    end

    # Parse an ISO 8601 timestamp or date (2026-01-31 or
    # 2026-01-31T12:00:00Z); nil when blank, exit 1 when unparseable.
    # Date-only values resolve to the start of the UTC day, or to the
    # last second of that day with end_of_day.
    #
    # @param value [String, nil]
    # @param end_of_day [Boolean] resolve date-only values to 23:59:59Z
    # @return [Time, nil]
    def parse_filter_time(value, end_of_day: false)
      return nil if value.nil? || value.to_s.empty?

      Time.iso8601(value.to_s)
    rescue ArgumentError
      date = begin
        Date.iso8601(value.to_s)
      rescue ArgumentError
        say "Invalid date: '#{value}' (expected ISO 8601, " \
            "e.g. 2026-01-31 or 2026-01-31T12:00:00Z)", :red
        exit 1
      end
      start_of_day = Time.utc(date.year, date.month, date.day)
      end_of_day ? start_of_day + 86_399 : start_of_day
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
