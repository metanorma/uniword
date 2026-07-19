# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # DOC-201: every bookmarkStart must have a matching bookmarkEnd.
      #
      # Unpaired bookmark starts produce corrupt documents that Word
      # refuses to open.
      class BookmarkPairingRule < ModelRule
        def code = "DOC-201"
        def category = :bookmarks
        def severity = "error"

        def check(context)
          body = context.document.body
          return [] unless body

          end_ids = (body.bookmark_ends || []).filter_map(&:id).to_set
          (body.bookmark_starts || []).filter_map do |start|
            unpaired_issue(start, end_ids)
          end
        end

        private

        # @return [Report::ValidationIssue, nil] issue when unpaired
        def unpaired_issue(start, end_ids)
          return if end_ids.include?(start.id)

          issue("bookmarkStart id='#{start.id}' (name='#{start.name}') " \
                "has no matching bookmarkEnd",
                part: "word/document.xml")
        end
      end
    end
  end
end
