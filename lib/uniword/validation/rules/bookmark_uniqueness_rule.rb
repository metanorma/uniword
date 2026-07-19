# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # DOC-202: bookmark names should be unique.
      #
      # Duplicate names confuse cross-references and GoTo navigation.
      # The Word-internal "_GoBack" bookmark is exempt.
      class BookmarkUniquenessRule < ModelRule
        def code = "DOC-202"
        def category = :bookmarks
        def severity = "warning"

        def check(context)
          body = context.document.body
          return [] unless body

          duplicates(body.bookmark_starts || []).map do |name|
            issue("Duplicate bookmark name '#{name}'",
                  part: "word/document.xml")
          end
        end

        private

        # @param starts [Array] bookmarkStart models
        # @return [Array<String>] names seen more than once
        def duplicates(starts)
          seen = {}
          starts.each_with_object([]) do |start, dups|
            name = tracked_name(start)
            next unless name

            dups << name if seen[name]
            seen[name] = true
          end
        end

        # @return [String, nil] name worth tracking, nil when exempt
        def tracked_name(start)
          name = start.name.to_s
          name unless name.empty? || name == "_GoBack"
        end
      end
    end
  end
end
