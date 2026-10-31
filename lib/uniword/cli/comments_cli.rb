# frozen_string_literal: true

require "thor"
require "json"

module Uniword
  # Comments subcommands for Uniword CLI.
  #
  # Provides Word-style comment management:
  # - list: list comments with anchored text
  # - add: add a comment anchored to a paragraph found by search text
  # - resolve: remove a comment and its anchor markers (Word semantics)
  class CommentsCLI < Thor
    include CLIHelpers

    desc "list FILE", "List all comments with anchored text"
    long_desc <<~DESC
      Display all comments in a document with ID, author, date, text,
      and the text of the paragraph each comment anchors.

      Examples:
        $ uniword comments list document.docx
        $ uniword comments list document.docx --json
    DESC
    option :json, desc: "Output as JSON (machine-readable)",
                  type: :boolean, default: false
    def list(path)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)
      comment_list = manager.list_comments

      if comment_list.empty?
        say "No comments found.", :yellow
        return
      end

      anchors = manager.comment_anchor_texts

      if options[:json]
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
        say "     Text:   #{comment.text}"
        anchored = anchors[comment.comment_id.to_s]
        preview = anchored ? anchored[0..60] : "(unanchored)"
        preview += "..." if anchored.to_s.length > 60
        say "     Anchor: #{preview}"
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "add FILE", "Add a comment anchored to a paragraph"
    long_desc <<~DESC
      Add a comment by an author, anchored to the first paragraph whose
      text contains the --at search phrase. Without --at, the comment is
      anchored to the document's last paragraph (unanchored when the
      document has no paragraphs).

      Examples:
        $ uniword comments add document.docx --author "Jane" \\
            --text "Please verify" --at "Conclusion"
        $ uniword comments add document.docx --author "Jane" \\
            --text "Looks good" -o reviewed.docx
    DESC
    option :author, desc: "Comment author", type: :string, required: true
    option :text, desc: "Comment text", type: :string, required: true
    option :initials, desc: "Author initials", type: :string
    option :at, desc: "Anchor to the first paragraph containing this " \
                      "search text", type: :string
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def add(path)
      doc = load_document(path)
      paragraph = find_anchor_paragraph(doc, options[:at])
      if options[:at] && paragraph.nil?
        say "No paragraph containing '#{options[:at]}' found.", :red
        exit 1
      end

      manager = Review::ReviewManager.new(doc)
      comment = manager.add_comment(
        text: options[:text],
        author: options[:author],
        initials: options[:initials],
      )
      manager.anchor_comment(comment.comment_id, paragraph)

      save_output(doc, path)
      target = options[:output] || path
      say "Added comment #{comment.comment_id} by #{options[:author]} " \
          "to #{target}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "resolve FILE COMMENT_ID", "Remove a comment and its anchor markers"
    long_desc <<~DESC
      Resolve a comment with Word semantics: the comment entry is removed
      from word/comments.xml and its commentRangeStart, commentRangeEnd,
      and commentReference markers are removed from the body.

      Examples:
        $ uniword comments resolve document.docx 1
        $ uniword comments resolve document.docx 1 -o resolved.docx
    DESC
    option :output, aliases: "-o", desc: "Output file (overwrites if omitted)",
                    type: :string
    def resolve(path, comment_id)
      doc = load_document(path)
      manager = Review::ReviewManager.new(doc)

      unless manager.resolve_comment!(comment_id)
        say "Comment '#{comment_id}' not found.", :red
        exit 1
      end

      save_output(doc, path)
      say "Resolved comment '#{comment_id}'.", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    private

    # Find the paragraph a new comment anchors to: the first paragraph
    # whose text contains the search phrase, or the document's last
    # paragraph when no phrase is given.
    #
    # @param doc [Uniword::Wordprocessingml::DocumentRoot]
    # @param search_text [String, nil]
    # @return [Wordprocessingml::Paragraph, nil]
    def find_anchor_paragraph(doc, search_text)
      paragraphs = []
      FindReplace::ParagraphWalker.each_paragraph([doc.body].compact) do |p|
        paragraphs << p
      end
      return paragraphs.last if search_text.nil?

      paragraphs.find { |paragraph| paragraph.text.include?(search_text) }
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
