# frozen_string_literal: true

require "zip"
require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates relationship integrity: rId references resolve to real parts.
      #
      # DOC-108: All rId references in XML parts must have matching
      # Relationship entries, and targets must exist in the ZIP.
      # Validity rule: R6
      class RelationshipIntegrityRule < Base
        R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
        RELS_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

        def code = "DOC-108"
        def validity_rule = "R6"
        def description = "All rId references must resolve through .rels files to existing parts"
        def category = :relationships
        def severity = "error"

        def applicable?(context)
          context.part_exists?("[Content_Types].xml")
        end

        def check(context)
          issues = []

          check_document_rels(context, issues)
          check_package_rels(context, issues)

          issues
        end

        private

        def check_document_rels(context, issues)
          rels = context.relationships("word/_rels/document.xml.rels")
          entries = context.zip_entries.to_set

          rels.each do |rel|
            target = rel[:target]
            next unless target

            resolved = target.start_with?("/") ? target.delete_prefix("/") : "word/#{target}"
            next if entries.include?(resolved)

            issues << issue(
              "Relationship #{rel[:id]} target '#{target}' " \
              "(resolved: '#{resolved}') not found in ZIP",
              part: "word/_rels/document.xml.rels",
              suggestion: "Add the missing part or remove the relationship.",
            )
          end
        end

        def check_package_rels(context, issues)
          rels = context.relationships("_rels/.rels")
          entries = context.zip_entries.to_set

          rels.each do |rel|
            target = rel[:target]
            next unless target

            resolved = target.start_with?("/") ? target.delete_prefix("/") : target
            next if entries.include?(resolved)

            issues << issue(
              "Package relationship #{rel[:id]} target '#{target}' " \
              "(resolved: '#{resolved}') not found in ZIP",
              part: "_rels/.rels",
              suggestion: "Add the missing part or remove the relationship.",
            )
          end
        end
      end
    end
  end
end
