# frozen_string_literal: true

require "thor"

module Uniword
  # Revisions subcommands for the Uniword CLI.
  #
  # The issue-#79 spelling of the tracked-changes verbs: `revisions
  # list` / `revisions accept` / `revisions reject` delegate to the
  # `review changes|accept|reject` implementations, so both groups
  # share one behavior surface (filters, JSON, exit codes).
  class RevisionsCLI < Thor
    include CLIHelpers

    desc "list FILE", "List tracked changes (alias of review changes)"
    long_desc <<~DESC
      List tracked changes with id, type, author, date, and text -
      identical to `uniword review changes`, under the revisions name.

      Examples:
        $ uniword revisions list document.docx
        $ uniword revisions list document.docx --author "John Doe" --json
        $ uniword revisions list document.docx --since 2026-01-01
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
    def list(path)
      ReviewCLI.new.invoke(:changes, [path], options.to_h)
    end

    desc "accept FILE [REVISION_ID]",
         "Accept revisions (alias of review accept)"
    long_desc <<~DESC
      Accept one revision by id, or every filter-matching revision when
      no id is given. Identical to `uniword review accept`.

      Examples:
        $ uniword revisions accept document.docx
        $ uniword revisions accept document.docx 4
        $ uniword revisions accept document.docx --author "John Doe" -o out.docx
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
      ReviewCLI.new.invoke(:accept, [path, revision_id].compact,
                           options.to_h)
    end

    desc "reject FILE [REVISION_ID]",
         "Reject revisions (alias of review reject)"
    long_desc <<~DESC
      Reject one revision by id, or every filter-matching revision when
      no id is given. Identical to `uniword review reject`.

      Examples:
        $ uniword revisions reject document.docx
        $ uniword revisions reject document.docx 4
        $ uniword revisions reject document.docx --author "John Doe" -o out.docx
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
      ReviewCLI.new.invoke(:reject, [path, revision_id].compact,
                           options.to_h)
    end
  end
end
