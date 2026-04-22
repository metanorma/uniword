# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates footnotes and endnotes consistency.
      #
      # DOC-020: footnotePr/endnotePr implies footnotes.xml/endnotes.xml exists
      # DOC-021: footnoteReference/endnoteReference IDs exist in parts
      # DOC-022: Separator entries present when footnotePr defined
      class FootnotesRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-020"
        def category = :footnotes
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/settings.xml")
        end

        def check(context)
          issues = []

          settings = context.settings_xml
          return issues unless settings

          has_footnote_pr = settings.root.xpath(".//w:footnotePr",
                                                "w" => W_NS).any?
          has_endnote_pr = settings.root.xpath(".//w:endnotePr",
                                               "w" => W_NS).any?

          # DOC-020: Check parts exist when properties are declared
          if has_footnote_pr && !context.part_exists?("word/footnotes.xml")
            issues << issue(
              "settings.xml declares footnotePr but word/footnotes.xml is missing",
              part: "word/settings.xml",
              suggestion: "Add a minimal footnotes.xml with separator entries " \
                          "(id=-1, id=0), or remove footnotePr from settings.xml " \
                          "if no footnotes are used."
            )
          end

          if has_endnote_pr && !context.part_exists?("word/endnotes.xml")
            issues << issue(
              "settings.xml declares endnotePr but word/endnotes.xml is missing",
              part: "word/settings.xml",
              suggestion: "Add a minimal endnotes.xml with separator entries " \
                          "(id=-1, id=0), or remove endnotePr from settings.xml " \
                          "if no endnotes are used."
            )
          end

          # DOC-022: Check separator entries
          check_separators(context, has_footnote_pr, has_endnote_pr, issues)

          # DOC-021: Check reference IDs
          check_footnote_references(context, issues)

          issues
        end

        private

        def check_separators(context, has_footnote_pr, has_endnote_pr, issues)
          if has_footnote_pr && context.part_exists?("word/footnotes.xml")
            fn_doc = context.part("word/footnotes.xml")
            if fn_doc
              fn_ids = fn_doc.root.xpath(".//w:footnote/@w:id",
                                         "w" => W_NS).map(&:value).to_set
              unless fn_ids.include?("-1")
                issues << issue(
                  "Footnotes missing separator entry (id=-1)",
                  code: "DOC-022",
                  severity: "warning",
                  part: "word/footnotes.xml",
                  suggestion: "Add a separator footnote with id=-1."
                )
              end
            end
          end

          return unless has_endnote_pr && context.part_exists?("word/endnotes.xml")

          en_doc = context.part("word/endnotes.xml")
          return unless en_doc

          en_ids = en_doc.root.xpath(".//w:endnote/@w:id",
                                     "w" => W_NS).map(&:value).to_set
          return if en_ids.include?("-1")

          issues << issue(
            "Endnotes missing separator entry (id=-1)",
            code: "DOC-022",
            severity: "warning",
            part: "word/endnotes.xml",
            suggestion: "Add a separator endnote with id=-1."
          )
        end

        def check_footnote_references(context, issues)
          doc = context.document_xml
          return unless doc

          # Collect referenced footnote IDs
          fn_refs = doc.root.xpath(".//w:footnoteReference/@w:id",
                                   "w" => W_NS).map(&:value).to_set
          en_refs = doc.root.xpath(".//w:endnoteReference/@w:id",
                                   "w" => W_NS).map(&:value).to_set

          # Collect defined footnote IDs
          fn_defined = if context.part_exists?("word/footnotes.xml")
                         fn_doc = context.part("word/footnotes.xml")
                         if fn_doc
                           fn_doc.root.xpath(".//w:footnote/@w:id",
                                             "w" => W_NS).map(&:value).to_set
                         else
                           Set.new
                         end
                       else
                         Set.new
                       end

          en_defined = if context.part_exists?("word/endnotes.xml")
                         en_doc = context.part("word/endnotes.xml")
                         if en_doc
                           en_doc.root.xpath(".//w:endnote/@w:id",
                                             "w" => W_NS).map(&:value).to_set
                         else
                           Set.new
                         end
                       else
                         Set.new
                       end

          # Check content footnote refs (exclude separators: id < 0)
          content_fn_refs = fn_refs.reject { |id| id.to_i.negative? }
          (content_fn_refs - fn_defined.to_a).each do |id|
            issues << issue(
              "footnoteReference id='#{id}' not found in footnotes.xml",
              code: "DOC-021",
              part: "word/document.xml",
              suggestion: "Add footnote entry with id='#{id}' to " \
                          "word/footnotes.xml."
            )
          end

          content_en_refs = en_refs.reject { |id| id.to_i.negative? }
          (content_en_refs - en_defined.to_a).each do |id|
            issues << issue(
              "endnoteReference id='#{id}' not found in endnotes.xml",
              code: "DOC-021",
              part: "word/document.xml",
              suggestion: "Add endnote entry with id='#{id}' to " \
                          "word/endnotes.xml."
            )
          end
        end
      end
    end
  end
end
