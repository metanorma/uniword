# frozen_string_literal: true

require "json"

module Uniword
  module Diff
    # Value object holding the result of redlining two documents.
    #
    # Carries the redlined base document plus change statistics.
    #
    # @example
    #   result = Redliner.new(base_doc, revised_doc).redline
    #   result.document.save("redline.docx")
    #   puts result.summary
    class RedlineResult
      attr_reader :document, :stats

      # @param document [Wordprocessingml::DocumentRoot] redlined base
      # @param stats [Hash{Symbol => Integer}] change counts by kind
      #   (:kept, :modified, :added, :removed paragraphs)
      def initialize(document:, stats: {})
        @document = document
        @stats = stats
      end

      # Number of tracked insertion wrappers (w:ins) emitted.
      #
      # @return [Integer]
      def insertions
        document.body.paragraphs.sum { |p| p.insertions.size }
      end

      # Number of tracked deletion wrappers (w:del) emitted.
      #
      # @return [Integer]
      def deletions
        document.body.paragraphs.sum { |p| p.deletions.size }
      end

      # Whether the redline carries no tracked changes.
      #
      # @return [Boolean]
      def empty?
        insertions.zero? && deletions.zero? &&
          stats[:added].to_i.zero? && stats[:removed].to_i.zero? &&
          stats[:modified].to_i.zero?
      end

      # Human-readable summary of the redline.
      #
      # @return [String]
      def summary
        return "No differences found." if empty?

        parts = []
        if stats[:added].positive?
          parts << "#{stats[:added]} paragraph(s) inserted"
        end
        if stats[:removed].positive?
          parts << "#{stats[:removed]} paragraph(s) deleted"
        end
        if stats[:modified].positive?
          parts << "#{stats[:modified]} paragraph(s) modified"
        end
        parts << "#{insertions} insertion(s), #{deletions} deletion(s)"
        parts.join(", ")
      end

      # Serialize to a JSON string.
      #
      # @return [String] Pretty-printed JSON
      def to_json(*_args)
        JSON.pretty_generate(to_h)
      end

      # Convert to a plain Hash suitable for serialization.
      #
      # @return [Hash]
      def to_h
        {
          paragraphs: {
            kept: stats[:kept].to_i,
            modified: stats[:modified].to_i,
            added: stats[:added].to_i,
            removed: stats[:removed].to_i,
          },
          insertions: insertions,
          deletions: deletions,
          summary: summary,
        }
      end
    end
  end
end
