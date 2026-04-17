# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates bookmark consistency.
      #
      # DOC-040: bookmarkStart/bookmarkEnd IDs are paired
      # DOC-041: bookmarkStart name uniqueness
      # DOC-042: hyperlink bookmark targets exist
      class BookmarksRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-040"
        def category = :bookmarks
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          doc = context.document_xml
          return issues unless doc

          # DOC-040: Paired bookmarks
          start_ids = doc.root.xpath(".//w:bookmarkStart/@w:id",
                                     "w" => W_NS).map(&:value)
          end_ids = doc.root.xpath(".//w:bookmarkEnd/@w:id",
                                   "w" => W_NS).map(&:value).to_set

          start_ids.each do |id|
            next if end_ids.include?(id)

            issues << issue(
              "bookmarkStart id='#{id}' has no matching bookmarkEnd",
              part: "word/document.xml",
              suggestion: "Add a <w:bookmarkEnd w:id='#{id}'/> to close " \
                          "this bookmark."
            )
          end

          # DOC-041: Name uniqueness
          names = doc.root.xpath(".//w:bookmarkStart/@w:name",
                                 "w" => W_NS).map(&:value)
          seen = {}
          names.each do |name|
            if seen[name]
              issues << issue(
                "Duplicate bookmark name '#{name}'",
                code: "DOC-041",
                severity: "warning",
                part: "word/document.xml",
                suggestion: "Bookmark names should be unique within a document."
              )
            else
              seen[name] = true
            end
          end

          # DOC-042: Hyperlink anchor targets
          anchors = Set.new(names)
          doc.root.xpath(".//w:hyperlink/@w:anchor",
                         "w" => W_NS).each do |anchor|
            next if anchors.include?(anchor.value)

            issues << issue(
              "Hyperlink target bookmark '#{anchor.value}' does not exist",
              code: "DOC-042",
              part: "word/document.xml",
              suggestion: "Create a bookmark named '#{anchor.value}' or " \
                          "fix the hyperlink anchor."
            )
          end

          issues
        end
      end
    end
  end
end
