# frozen_string_literal: true

module Uniword
  module Review
    # Handles individual revision accept/reject operations.
    #
    # Each revision type has specific semantics:
    # - Accept insert: remove w:ins wrapper, keep content
    # - Accept delete: remove w:del wrapper AND content
    # - Reject insert: remove w:ins wrapper AND content
    # - Reject delete: remove w:del wrapper, restore content
    # - Reject format change: restore old properties
    #
    # @see ReviewManager For the orchestrator that delegates to this class
    class AcceptReject
      # Accept a single revision by incorporating it into the document.
      #
      # @param revision [Uniword::Revision] The revision to accept
      # @return [Boolean] true if accepted successfully
      # @raise [ArgumentError] If revision type is unknown
      def accept(revision)
        case revision.type
        when :insert
          accept_insert(revision)
        when :delete
          accept_delete(revision)
        when :format_change
          accept_format_change(revision)
        else
          raise ArgumentError,
                "Unknown revision type: #{revision.type}"
        end
      end

      # Reject a single revision by reverting its effect.
      #
      # @param revision [Uniword::Revision] The revision to reject
      # @return [Boolean] true if rejected successfully
      # @raise [ArgumentError] If revision type is unknown
      def reject(revision)
        case revision.type
        when :insert
          reject_insert(revision)
        when :delete
          reject_delete(revision)
        when :format_change
          reject_format_change(revision)
        else
          raise ArgumentError,
                "Unknown revision type: #{revision.type}"
        end
      end

      private

      # Accept insertion: remove wrapper, keep content.
      # The inserted text becomes permanent in the document.
      #
      # @param revision [Uniword::Revision] The insertion revision
      # @return [Boolean] true
      def accept_insert(revision)
        revision.type = :accepted
        true
      end

      # Accept deletion: remove wrapper and content.
      # The deleted text is permanently removed.
      #
      # @param revision [Uniword::Revision] The deletion revision
      # @return [Boolean] true
      def accept_delete(revision)
        revision.type = :accepted
        revision.content = nil
        true
      end

      # Reject insertion: remove wrapper and content.
      # The inserted text is removed from the document.
      #
      # @param revision [Uniword::Revision] The insertion revision
      # @return [Boolean] true
      def reject_insert(revision)
        revision.type = :rejected
        revision.content = nil
        true
      end

      # Reject deletion: remove wrapper, restore content.
      # The deleted text is restored to the document.
      #
      # @param revision [Uniword::Revision] The deletion revision
      # @return [Boolean] true
      def reject_delete(revision)
        revision.type = :rejected
        true
      end

      # Accept format change: keep new properties.
      # The formatting change becomes permanent.
      #
      # @param revision [Uniword::Revision] The format change revision
      # @return [Boolean] true
      def accept_format_change(revision)
        revision.type = :accepted
        true
      end

      # Reject format change: restore old properties.
      # The formatting change is reverted.
      #
      # @param revision [Uniword::Revision] The format change revision
      # @return [Boolean] true
      def reject_format_change(revision)
        revision.type = :rejected
        revision.content = nil
        true
      end
    end
  end
end
