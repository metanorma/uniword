# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates that every ZIP entry has content type coverage.
      #
      # DOC-106: All ZIP entries must be covered by Content_Types
      # Validity rule: R7
      class ContentTypesCoverageRule < Base
        CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"

        def code = "DOC-106"
        def validity_rule = "R7"
        def description = "Every ZIP entry must have content type coverage"
        def category = :content_types
        def severity = "error"

        def applicable?(context)
          context.part_exists?("[Content_Types].xml")
        end

        def check(context)
          issues = []

          content_types = context.content_types
          override_parts, default_extensions = content_types.keys.partition do |k|
            k.start_with?("/")
          end

          context.zip_entries.each do |entry|
            next if entry.end_with?("/")
            next if entry.end_with?(".rels")
            next if entry == "[Content_Types].xml"
            next if covered?(entry, default_extensions, override_parts)

            issues << issue(
              "ZIP entry '#{entry}' has no content type coverage " \
              "in [Content_Types].xml",
              part: "[Content_Types].xml",
              suggestion: "Add a <Default Extension=\"#{File.extname(entry).delete_prefix('.')}" \
                          "\" .../> or <Override PartName=\"/#{entry}\" .../> entry.",
            )
          end

          issues
        end

        private

        def covered?(entry, default_extensions, override_parts)
          # Check override (exact match with leading /)
          return true if override_parts.include?("/#{entry}")

          # Check default (extension match)
          ext = File.extname(entry).delete_prefix(".")
          default_extensions.include?(ext)
        end
      end
    end
  end
end
