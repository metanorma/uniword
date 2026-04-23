# frozen_string_literal: true

module Uniword
  module Validation
    # Validates in-memory DocumentRoot structure.
    #
    # Performs structural checks on the document model without requiring
    # file access. Complements DocumentValidator (file-level 7-layer
    # pipeline) for quick in-process validation.
    #
    # Follows Open/Closed: add new check methods and register them in
    # CHECKS without modifying existing code.
    #
    # @example
    #   validator = StructuralValidator.new(document)
    #   validator.valid?          # => true/false
    #   validator.errors          # => ["bookmarkStart id='42' has no bookmarkEnd"]
    #   validator.warnings        # => ["Empty paragraph at index 7"]
    class StructuralValidator
      # Registered check methods. Each returns an array of
      # { severity:, message: } hashes.
      CHECKS = %i[
        check_body_present
        check_bookmark_pairing
        check_bookmark_uniqueness
        check_empty_paragraphs
      ].freeze

      attr_reader :document

      def initialize(document)
        @document = document
      end

      # @return [Boolean] true if no errors (warnings are non-fatal)
      def valid?
        errors.empty?
      end

      # @return [Array<String>] Error messages (severity: error)
      def errors
        @errors ||= issues
          .select { |i| i[:severity] == :error }
          .map { |i| i[:message] }
      end

      # @return [Array<String>] Warning messages (severity: warning)
      def warnings
        @warnings ||= issues
          .select { |i| i[:severity] == :warning }
          .map { |i| i[:message] }
      end

      # @return [Array<Hash>] All issues
      def issues
        @issues ||= CHECKS.flat_map { |check| send(check) }
      end

      private

      def check_body_present
        return [] if document.body

        [{ severity: :error,
           message: "Document body is missing" }]
      end

      def check_bookmark_pairing
        return [] unless document.body

        starts = document.body.bookmark_starts || []
        ends = document.body.bookmark_ends || []
        end_ids = ends.filter_map(&:id).to_set

        starts.filter_map do |bs|
          next if end_ids.include?(bs.id)

          { severity: :error,
            message: "bookmarkStart id='#{bs.id}' (name='#{bs.name}') " \
                     "has no matching bookmarkEnd" }
        end
      end

      def check_bookmark_uniqueness
        return [] unless document.body

        starts = document.body.bookmark_starts || []
        seen = {}
        starts.filter_map do |bs|
          next unless bs.name
          next if bs.name.to_s == "_GoBack" # Word internal bookmark

          if seen[bs.name.to_s]
            { severity: :warning,
              message: "Duplicate bookmark name '#{bs.name}'" }
          else
            seen[bs.name.to_s] = true
            nil
          end
        end
      end

      def check_empty_paragraphs
        return [] unless document.body

        paragraphs = document.body.paragraphs || []
        paragraphs.each_with_index.filter_map do |para, idx|
          next unless para.runs.nil? || para.runs.empty?

          { severity: :warning,
            message: "Empty paragraph at index #{idx}" }
        end
      end
    end
  end
end
