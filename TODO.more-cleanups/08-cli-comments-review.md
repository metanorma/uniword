# 08: CLI `review` — comments, tracked changes, accept/reject, interactive review

**Priority:** P1
**Effort:** Large (~6 hours)
**Files:**
- `lib/uniword/cli.rb` (add `review` subcommand)
- `lib/uniword/review/review_manager.rb` (new — orchestrator)
- `lib/uniword/review/interactive_review.rb` (new — TUI)
- `lib/uniword/review/accept_reject.rb` (new — individual change handling)

## Use Case

ISO editors review documents with tracked changes and comments. They need to see
all changes, read comments, reply to them, and accept or reject individual
revisions — without opening Word.

This is the core collaborative editing workflow for standards organizations.

## Existing Infrastructure

The codebase already has:
- `TrackedChanges` model — `add_insertion`, `add_deletion`, `add_format_change`,
  `revisions_by_author`, `revisions_by_type`, `accept_all`, `reject_all`
- `Revision` model — `:insert`, `:delete`, `:format_change` types with
  `revision_id`, `author`, `date`, `content`
- `Comment`, `CommentRange`, `CommentsPart` models
- `CommentBuilder` in the Builder API
- RSID attributes on Paragraph, TableRow, SectionProperties (preserved in
  round-trips but not generated)

**What's missing:**
1. Individual accept/reject (not just accept_all/reject_all)
2. CLI commands for listing/viewing/managing comments and revisions
3. Interactive TUI for reviewing changes one-by-one
4. Comment reply support (Word 2013+ threaded comments via `w15:commentEx`)

## Proposed CLI Syntax

```bash
# --- Comments ---

# List all comments
uniword review comments report.docx

# List with full text and replies
uniword review comments report.docx --verbose

# Output as JSON
uniword review comments report.docx --json

# Add a comment on a specific paragraph
uniword review add-comment report.docx output.docx --text "Check this" --paragraph 5 --author "Editor"

# Reply to a comment
uniword review reply-comment report.docx output.docx --id 3 --text "Fixed" --author "Author"

# Resolve a comment
uniword review resolve-comment report.docx output.docx --id 3

# Remove a comment
uniword review remove-comment report.docx output.docx --id 3

# Remove all comments
uniword review clear-comments report.docx output.docx

# --- Tracked Changes ---

# List all tracked changes
uniword review changes report.docx

# List by author
uniword review changes report.docx --author "John"

# List by type (insert, delete, format_change)
uniword review changes report.docx --type insert

# Accept all changes
uniword review accept-all report.docx output.docx

# Reject all changes
uniword review reject-all report.docx output.docx

# Accept a specific change by revision ID
uniword review accept report.docx output.docx --revision-id 42

# Reject a specific change by revision ID
uniword review reject report.docx output.docx --revision-id 42

# --- Interactive Review ---

# Start interactive review session (TUI)
uniword review interactive report.docx output.docx

# Interactive with filter
uniword review interactive report.docx output.docx --author "Reviewer1"
```

## Implementation

### Review Manager (orchestrator)

```ruby
module Uniword
  module Review
    class ReviewManager
      def initialize(document)
        @document = document
      end

      # --- Comments ---

      def comments
        @document.comments || []
      end

      def add_comment(text, paragraph_index:, author:, date: Time.now)
        id = next_comment_id
        comment = CommentBuilder.new(id: id, author: author, date: date).build(text)
        @document.comments_part.add_comment(comment)

        paragraph = @document.paragraphs[paragraph_index]
        paragraph&.add_comment_range(id)

        @document
      end

      def reply_to_comment(comment_id, text, author:, date: Time.now)
        id = next_comment_id
        reply = CommentBuilder.new(id: id, author: author, date: date,
                                   parent_id: comment_id).build(text)
        @document.comments_part.add_comment(reply)
        @document
      end

      def resolve_comment(comment_id)
        comment = find_comment(comment_id)
        comment&.resolve!
        @document
      end

      def remove_comment(comment_id)
        @document.comments_part.remove_comment(comment_id)
        @document.body.remove_comment_range(comment_id)
        @document
      end

      def clear_comments
        @document.comments_part.clear
        @document.body.remove_all_comment_ranges
        @document
      end

      # --- Tracked Changes ---

      def revisions
        @document.tracked_changes&.revisions || []
      end

      def revisions_by_author(author)
        @document.tracked_changes&.revisions_by_author(author) || []
      end

      def revisions_by_type(type)
        @document.tracked_changes&.revisions_by_type(type) || []
      end

      # Accept a single revision by ID
      def accept(revision_id)
        revision = find_revision(revision_id)
        raise Error, "Revision #{revision_id} not found" unless revision

        case revision.type
        when :insert
          # Keep the inserted content, remove the revision markers
          revision.accept!
        when :delete
          # Remove the deleted content
          revision.accept!
        when :format_change
          # Keep the new formatting, remove the revision markers
          revision.accept!
        end

        @document
      end

      # Reject a single revision by ID
      def reject(revision_id)
        revision = find_revision(revision_id)
        raise Error, "Revision #{revision_id} not found" unless revision

        case revision.type
        when :insert
          # Remove the inserted content
          revision.reject!
        when :delete
          # Restore the deleted content
          revision.reject!
        when :format_change
          # Revert to the old formatting
          revision.reject!
        end

        @document
      end

      def accept_all
        @document.tracked_changes&.accept_all
        @document
      end

      def reject_all
        @document.tracked_changes&.reject_all
        @document
      end

      private

      def next_comment_id
        (comments.map { |c| c.id.to_i }.max || 0) + 1
      end

      def find_comment(id)
        comments.find { |c| c.id == id || c.id == id.to_s }
      end

      def find_revision(id)
        revisions.find { |r| r.revision_id == id || r.revision_id == id.to_s }
      end
    end
  end
end
```

### Individual Accept/Reject

The current `TrackedChanges#accept_all` just clears the collection. Real
accept/reject requires operating on the OOXML tree:

```ruby
module Uniword::Review
  class AcceptReject
    # Accept: for <w:ins>, remove the ins wrapper, keep content.
    #         For <w:del>, remove the del wrapper AND its content.
    #         For <w:rPrChange>, keep new properties, remove history.
    #
    # Reject: for <w:ins>, remove the ins wrapper AND its content.
    #         For <w:del>, remove the del wrapper, restore content.
    #         For <w:rPrChange>, restore old properties, remove new.

    def self.accept_insert(paragraph, run)
      # The run is inside a <w:ins> wrapper. Remove the wrapper,
      # keep the run as a regular run in the paragraph.
    end

    def self.accept_delete(paragraph, deleted_content)
      # The content is inside a <w:del> wrapper. Remove both wrapper
      # and content entirely.
    end

    def self.reject_insert(paragraph, run)
      # The run is inside a <w:ins> wrapper. Remove both wrapper and run.
    end

    def self.reject_delete(paragraph, deleted_content)
      # The content is inside a <w:del> wrapper. Remove the wrapper,
      # restore the content as regular content.
    end
  end
end
```

### Interactive Review (TUI)

Uses `io/console` for terminal interaction (no external TUI gem needed):

```ruby
module Uniword::Review
  class InteractiveReview
    def initialize(document, output_path, author: nil)
      @manager = ReviewManager.new(document)
      @output_path = output_path
      @filter_author = author
    end

    def start
      all_items = build_review_queue
      if all_items.empty?
        puts "No comments or tracked changes to review."
        return
      end

      puts "Review session: #{all_items.count} items"
      puts "Commands: [a]ccept, [r]eject, [c]omment, [s]kip, [q]uit\n\n"

      all_items.each_with_index do |item, i|
        display_item(item, index: i, total: all_items.count)

        loop do
          print "[a]ccept/[r]eject/[c]omment/[s]kip/[q]uit > "
          cmd = $stdin.getch.downcase

          case cmd
          when 'a'
            handle_accept(item)
            break
          when 'r'
            handle_reject(item)
            break
          when 'c'
            handle_comment(item)
            break
          when 's'
            break
          when 'q'
            save_and_exit
          end
        end
      end

      @manager.instance_variable_get(:@document).save(@output_path)
      puts "\nReview complete. Saved to #{@output_path}"
    end

    private

    def build_review_queue
      items = []

      # Collect tracked changes
      revisions = @filter_author ? @manager.revisions_by_author(@filter_author)
                                 : @manager.revisions
      revisions.each do |rev|
        items << { type: :revision, data: rev }
      end

      # Collect comments
      @manager.comments.each do |comment|
        items << { type: :comment, data: comment }
      end

      items.sort_by { |item| position_in_document(item) }
    end

    def display_item(item, index:, total:)
      puts "─── #{index + 1}/#{total} ───"
      case item[:type]
      when :revision
        rev = item[:data]
        color = case rev.type
                when :insert then :green
                when :delete then :red
                when :format_change then :yellow
                end
        puts "[#{rev.type.upcase}] by #{rev.author} at #{rev.date}"
        puts "  Content: #{rev.content_preview}"
      when :comment
        c = item[:data]
        puts "[COMMENT] by #{c.author} at #{c.date}"
        puts "  #{c.text}"
      end
    end
  end
end
```

### CLI Integration

```ruby
class ReviewCLI < Thor
  desc "comments FILE", "List document comments"
  option :verbose, aliases: "-v", type: :boolean, default: false
  option :json, type: :boolean, default: false
  def comments(path)
    doc = DocumentFactory.from_file(path)
    manager = Review::ReviewManager.new(doc)
    # ... display comments
  end

  desc "changes FILE", "List tracked changes"
  option :author, desc: "Filter by author"
  option :type, desc: "Filter by type (insert/delete/format_change)"
  option :json, type: :boolean, default: false
  def changes(path)
    doc = DocumentFactory.from_file(path)
    manager = Review::ReviewManager.new(doc)
    # ... display changes
  end

  desc "accept FILE OUTPUT", "Accept changes"
  option :revision_id, type: :numeric, desc: "Accept specific revision"
  def accept(path, output_path)
    doc = DocumentFactory.from_file(path)
    manager = Review::ReviewManager.new(doc)
    if options[:revision_id]
      manager.accept(options[:revision_id])
    else
      manager.accept_all
    end
    doc.save(output_path)
  end

  desc "reject FILE OUTPUT", "Reject changes"
  option :revision_id, type: :numeric, desc: "Reject specific revision"
  def reject(path, output_path)
    doc = DocumentFactory.from_file(path)
    manager = Review::ReviewManager.new(doc)
    if options[:revision_id]
      manager.reject(options[:revision_id])
    else
      manager.reject_all
    end
    doc.save(output_path)
  end

  desc "interactive FILE OUTPUT", "Interactive review session"
  option :author, desc: "Filter by author"
  def interactive(path, output_path)
    doc = DocumentFactory.from_file(path)
    Review::InteractiveReview.new(doc, output_path, author: options[:author]).start
  end
end
```

## Key Design Decisions

1. **Reuses existing models**: `TrackedChanges`, `Comment`, `CommentRange`,
   `Revision` already exist. This adds orchestration and CLI, not new models.
2. **Individual accept/reject**: the hard part — requires OOXML tree surgery
   to remove `<w:ins>`/`<w:del>` wrappers while keeping or removing content.
3. **Interactive mode uses stdlib**: `io/console` for single-key input, no
   external TUI gem dependency.
4. **Review queue**: merges comments and tracked changes into a single queue
   sorted by document position, so the reviewer proceeds top-to-bottom.

## Verification

```bash
bundle exec rspec spec/uniword/review/
# Test with ISO DIS document that has track changes:
bundle exec uniword review changes "spec/fixtures/uniword-private/fixtures/iso/ISO_DIS 5878 ed.2 - id.90974 Enquiry Trackchange Word (en).docx"
```
