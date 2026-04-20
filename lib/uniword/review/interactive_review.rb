# frozen_string_literal: true

require "io/console"

module Uniword
  module Review
    # Text-based user interface for interactively reviewing changes.
    #
    # Shows comments and revisions one-by-one, prompting the user to
    # accept, reject, skip, or quit. Merges both comments and revisions
    # into a single review queue sorted by position (date).
    #
    # @example Run interactive review
    #   manager = ReviewManager.new(doc)
    #   session = InteractiveReview.new(manager)
    #   session.run
    #
    # @see ReviewManager For the underlying review operations
    class InteractiveReview
      # Initialize an interactive review session.
      #
      # @param manager [ReviewManager] The review manager
      # @param output [IO] Output stream (default: $stdout)
      # @param input [IO] Input stream (default: $stdin)
      def initialize(manager, output: $stdout, input: $stdin)
        @manager = manager
        @output = output
        @input = input
        @accepted = 0
        @rejected = 0
        @skipped = 0
      end

      # Run the interactive review session.
      #
      # Displays each comment and revision in order, prompting the
      # user for action. Returns a summary hash when done.
      #
      # @return [Hash] Summary with :accepted, :rejected, :skipped counts
      def run
        queue = @manager.review_queue

        if queue.empty?
          @output.puts "No comments or tracked changes to review."
          return summary
        end

        @output.puts "Reviewing #{queue.size} item(s)..."
        @output.puts "Keys: [a]ccept [r]eject [s]kip [q]uit"
        @output.puts separator

        queue.each_with_index do |entry, idx|
          display_item(entry, idx, queue.size)

          case prompt_user
          when :accept
            handle_accept(entry)
          when :reject
            handle_reject(entry)
          when :skip
            @skipped += 1
            @output.puts "  Skipped."
          when :quit
            @output.puts "Stopping review."
            break
          end

          @output.puts separator
        end

        display_summary
        summary
      end

      # Get the review session summary.
      #
      # @return [Hash] Counts of :accepted, :rejected, :skipped
      def summary
        {
          accepted: @accepted,
          rejected: @rejected,
          skipped: @skipped
        }
      end

      private

      # Display a single review item.
      #
      # @param entry [Hash] The review queue entry
      # @param idx [Integer] Current index (0-based)
      # @param total [Integer] Total items in queue
      # @return [void]
      def display_item(entry, idx, total)
        item = entry[:item]
        @output.puts "[#{idx + 1}/#{total}] " \
                     "#{entry[:type] == :comment ? "Comment" : "Revision"}"

        if entry[:type] == :comment
          display_comment(item)
        else
          display_revision(item)
        end
      end

      # Display a comment item.
      #
      # @param comment [Uniword::Comment] The comment
      # @return [void]
      def display_comment(comment)
        @output.puts "  Author: #{comment.author || "(unknown)"}"
        @output.puts "  Date:   #{comment.date || "(unknown)"}"
        @output.puts "  Text:   #{truncate(comment.text, 60)}"
      end

      # Display a revision item.
      #
      # @param revision [Uniword::Revision] The revision
      # @return [void]
      def display_revision(revision)
        @output.puts "  Author: #{revision.author || "(unknown)"}"
        @output.puts "  Date:   #{revision.date || "(unknown)"}"
        @output.puts "  Type:   #{format_revision_type(revision.type)}"
        @output.puts "  Text:   #{truncate(revision.text, 60)}"
      end

      # Prompt the user for a single-key response.
      #
      # @return [Symbol] :accept, :reject, :skip, or :quit
      def prompt_user
        @output.print "  Action (a/r/s/q): "
        char = read_single_char
        @output.puts

        case char
        when "a", "A" then :accept
        when "r", "R" then :reject
        when "s", "S" then :skip
        when "q", "Q" then :quit
        else
          @output.puts "  Invalid key. Use a/r/s/q."
          prompt_user
        end
      end

      # Read a single character from input without echo.
      #
      # Falls back to gets if io/console is unavailable.
      #
      # @return [String] The character read
      def read_single_char
        if @input.respond_to?(:getch)
          @input.getch
        else
          @input.gets&.chomp&.first || "q"
        end
      end

      # Handle accepting a review item.
      #
      # @param entry [Hash] The review queue entry
      # @return [void]
      def handle_accept(entry)
        item = entry[:item]
        if entry[:type] == :revision
          @manager.accept(item.revision_id)
        else
          @manager.resolve_comment(item.comment_id)
        end
        @accepted += 1
        @output.puts "  Accepted."
      end

      # Handle rejecting a review item.
      #
      # @param entry [Hash] The review queue entry
      # @return [void]
      def handle_reject(entry)
        item = entry[:item]
        if entry[:type] == :revision
          @manager.reject(item.revision_id)
        else
          @manager.remove_comment(item.comment_id)
        end
        @rejected += 1
        @output.puts "  Rejected."
      end

      # Display the review session summary.
      #
      # @return [void]
      def display_summary
        @output.puts "Review complete."
        @output.puts "  Accepted: #{@accepted}"
        @output.puts "  Rejected: #{@rejected}"
        @output.puts "  Skipped:  #{@skipped}"
      end

      # Format revision type for display.
      #
      # @param type [Symbol] The revision type
      # @return [String] Human-readable type label
      def format_revision_type(type)
        case type
        when :insert then "Insertion"
        when :delete then "Deletion"
        when :format_change then "Format change"
        else type.to_s
        end
      end

      # Truncate text to max length with ellipsis.
      #
      # @param text [String] The text
      # @param max_len [Integer] Maximum length
      # @return [String] Truncated text
      def truncate(text, max_len)
        return "(empty)" if text.nil? || text.empty?

        return text if text.length <= max_len

        "#{text[0...max_len]}..."
      end

      # Separator line for display.
      #
      # @return [String]
      def separator
        "-" * 50
      end
    end
  end
end
