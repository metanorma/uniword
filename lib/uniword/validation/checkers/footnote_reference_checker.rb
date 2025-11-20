# frozen_string_literal: true

require_relative '../link_checker'

module Uniword
  module Validation
    module Checkers
      # Validates footnote and endnote references.
      #
      # Responsibility: Validate footnote references point to existing notes.
      # Single Responsibility: Footnote reference validation only.
      #
      # Verifies:
      # - Footnote/endnote targets exist in document
      # - Reference IDs are valid
      #
      # Configuration options:
      # - check_targets_exist: Whether to verify footnote targets exist
      #
      # @example Create and use checker
      #   checker = FootnoteReferenceChecker.new(config: {
      #     check_targets_exist: true
      #   })
      #   result = checker.check(footnote_ref, document)
      class FootnoteReferenceChecker < LinkChecker
        # Default configuration values
        DEFAULTS = {
          check_targets_exist: true
        }.freeze

        # Check if this checker can validate the given link.
        #
        # @param link [Object] The link to check
        # @return [Boolean] true if link is a footnote reference
        #
        # @example
        #   checker.can_check?(footnote_ref) # => true
        def can_check?(link)
          return false unless enabled?

          # Check if link is a footnote reference
          link.respond_to?(:footnote_id) ||
            link.respond_to?(:endnote_id) ||
            (link.respond_to?(:type) && (link.type == :footnote || link.type == :endnote))
        end

        # Validate the footnote reference.
        #
        # @param link [Object] The link to validate
        # @param document [Object] The document containing footnotes
        # @return [ValidationResult] The validation result
        #
        # @example
        #   result = checker.check(footnote_ref, document)
        def check(link, document = nil)
          return ValidationResult.unknown(link, "Checker disabled") unless enabled?

          unless config_value(:check_targets_exist, DEFAULTS[:check_targets_exist])
            return ValidationResult.warning(
              link,
              "Footnote target checking disabled"
            )
          end

          unless document
            return ValidationResult.warning(
              link,
              "Cannot validate without document context"
            )
          end

          # Extract footnote/endnote ID
          note_id = extract_note_id(link)
          return ValidationResult.failure(link, "No footnote ID specified") unless note_id

          # Determine note type
          note_type = determine_note_type(link)

          # Get footnotes/endnotes from document
          notes = extract_notes(document, note_type)

          # Check if note exists
          if note_exists?(note_id, notes)
            ValidationResult.success(
              link,
              metadata: {
                note_id: note_id,
                note_type: note_type,
                note_count: notes.size
              }
            )
          else
            ValidationResult.failure(
              link,
              "#{note_type.to_s.capitalize} not found: #{note_id}",
              metadata: {
                note_id: note_id,
                note_type: note_type,
                available_notes: notes.keys
              }
            )
          end
        end

        private

        # Extract note ID from link object.
        #
        # @param link [Object] The link object
        # @return [String, Integer, nil] Note ID
        def extract_note_id(link)
          if link.respond_to?(:footnote_id)
            link.footnote_id
          elsif link.respond_to?(:endnote_id)
            link.endnote_id
          elsif link.respond_to?(:id)
            link.id
          end
        end

        # Determine note type (footnote or endnote).
        #
        # @param link [Object] The link object
        # @return [Symbol] Note type (:footnote or :endnote)
        def determine_note_type(link)
          if link.respond_to?(:type)
            link.type
          elsif link.respond_to?(:endnote_id)
            :endnote
          else
            :footnote
          end
        end

        # Extract footnotes or endnotes from document.
        #
        # @param document [Object] The document
        # @param note_type [Symbol] Type of note (:footnote or :endnote)
        # @return [Hash] Notes indexed by ID
        def extract_notes(document, note_type)
          notes = {}

          # Try to get notes from document
          collection_name = note_type == :endnote ? :endnotes : :footnotes

          if document.respond_to?(collection_name)
            collection = document.send(collection_name)

            case collection
            when Hash
              notes = collection
            when Array
              # Convert array to hash indexed by ID
              collection.each do |note|
                id = note.respond_to?(:id) ? note.id : note.to_s
                notes[id] = note
              end
            end
          end

          notes
        end

        # Check if note exists in collection.
        #
        # @param note_id [String, Integer] Note ID
        # @param notes [Hash] Available notes
        # @return [Boolean] true if note exists
        def note_exists?(note_id, notes)
          # Try both as-is and as string/integer
          notes.key?(note_id) ||
            notes.key?(note_id.to_s) ||
            notes.key?(note_id.to_i)
        end
      end
    end
  end
end