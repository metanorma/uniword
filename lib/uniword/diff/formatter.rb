# frozen_string_literal: true

require "json"

module Uniword
  module Diff
    # Formats DiffResult for terminal and JSON output.
    #
    # @example Terminal output
    #   formatter = Formatter.new
    #   puts formatter.terminal(result, verbose: true)
    #
    # @example JSON output
    #   puts formatter.json(result)
    class Formatter
      # Format a DiffResult as JSON string.
      #
      # @param result [DiffResult] The diff result
      # @return [String] Pretty-printed JSON
      def json(result)
        result.to_json
      end

      # Format a DiffResult for terminal display.
      #
      # @param result [DiffResult] The diff result
      # @param verbose [Boolean] Show detailed listing
      # @return [String] Formatted terminal output
      def terminal(result, verbose: false)
        return "No differences found.\n" if result.empty?

        lines = []
        lines << "Differences found:\n"
        lines << "  #{result.summary}\n"

        if verbose
          lines.concat(format_text_changes(result.text_changes))
          lines.concat(format_format_changes(result.format_changes))
          lines.concat(format_structure(result.structure_changes))
          lines.concat(format_metadata(result.metadata_changes))
          lines.concat(format_styles(result.style_changes))
        end

        lines.join
      end

      private

      def format_text_changes(changes)
        return [] unless changes.any?

        lines = ["\nText changes:\n"]
        changes.each do |c|
          case c[:change]
          when :added
            lines << "  + [p#{c[:position]}] " \
                     "#{truncate(c[:new])}\n"
          when :removed
            lines << "  - [p#{c[:position]}] " \
                     "#{truncate(c[:old])}\n"
          when :modified
            lines << "  ~ [p#{c[:position]}] " \
                     "#{truncate(c[:old])} -> " \
                     "#{truncate(c[:new])}\n"
          end
        end
        lines
      end

      def format_format_changes(changes)
        return [] unless changes.any?

        lines = ["\nFormat changes:\n"]
        changes.each do |c|
          lines << "  ~ [p#{c[:paragraph]}] #{c[:field]}: " \
                   "#{c[:old]} -> #{c[:new]}\n"
        end
        lines
      end

      def format_structure(changes)
        return [] unless changes.any?

        lines = ["\nStructural changes:\n"]
        changes.each do |c|
          lines << "  #{c[:change]}: #{c[:old_count]} -> " \
                   "#{c[:new_count]}\n"
        end
        lines
      end

      def format_metadata(changes)
        return [] unless changes.any?

        lines = ["\nMetadata changes:\n"]
        changes.each do |field, vals|
          lines << "  #{field}: #{vals[:old]} -> #{vals[:new]}\n"
        end
        lines
      end

      def format_styles(changes)
        return [] unless changes.any?

        lines = ["\nStyle changes:\n"]
        changes.each do |c|
          label = c[:change] == :added ? "+" : "-"
          lines << "  #{label} #{c[:style_id]} (#{c[:name]})\n"
        end
        lines
      end

      def truncate(text, max_len = 60)
        return "" if text.nil?

        text.length > max_len ? "#{text[0...max_len]}..." : text
      end
    end
  end
end
