# frozen_string_literal: true

module Uniword
  module Builder
    # Anchors a comment to a body paragraph.
    #
    # Word anchors a comment with three pieces of markup around the
    # commented content:
    #
    #   <w:commentRangeStart w:id="0"/>
    #   ... commented runs ...
    #   <w:commentRangeEnd w:id="0"/>
    #   <w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr>
    #       <w:commentReference w:id="0"/></w:r>
    #
    # Paragraph uses mixed-content serialization, so the anchor elements
    # must also be recorded in the paragraph's element_order — fresh
    # paragraphs get a complete order built from their current content,
    # parsed paragraphs get the new entries inserted in place (a second
    # anchor on the same paragraph nests inside the first, matching
    # Word's canonical output).
    #
    # @example Anchor a comment on the last paragraph of a document
    #   CommentAnchorer.anchor(document.body.paragraphs.last, "1")
    class CommentAnchorer
      # Character style Word applies to comment reference runs.
      REFERENCE_STYLE = "CommentReference"

      # Paragraph content element names in mapping declaration order,
      # excluding pPr and the comment anchor elements (handled
      # separately). Mirrors Paragraph's `xml do` block; used to rebuild
      # element_order for programmatically anchored paragraphs.
      CONTENT_ELEMENTS = %w[
        hyperlink bookmarkStart bookmarkEnd fldChar instrText
        commentReference AlternateContent sdt oMathPara oMath proofErr
        fldSimple
      ].freeze

      # Element name → collection reader, used to size element_order
      # entries without dynamic dispatch.
      COLLECTION_READERS = {
        "hyperlink" => :hyperlinks.to_proc,
        "bookmarkStart" => :bookmark_starts.to_proc,
        "bookmarkEnd" => :bookmark_ends.to_proc,
        "fldChar" => :field_chars.to_proc,
        "instrText" => :instr_text.to_proc,
        "commentReference" => :comment_references.to_proc,
        "AlternateContent" => :alternate_content.to_proc,
        "sdt" => :sdts.to_proc,
        "oMathPara" => :o_math_paras.to_proc,
        "oMath" => :o_maths.to_proc,
        "proofErr" => :proof_errors.to_proc,
        "fldSimple" => :simple_fields.to_proc,
      }.freeze

      class << self
        # Anchor a comment around the paragraph's current content.
        # No-op when the paragraph is nil (comment stays unanchored but
        # remains valid in word/comments.xml).
        #
        # @param paragraph [Wordprocessingml::Paragraph, nil] anchor target
        # @param comment_id [String, Integer] ID of the comment entry
        # @return [void]
        def anchor(paragraph, comment_id)
          return unless paragraph

          id = comment_id.to_s
          paragraph.comment_range_starts << range_start(id)
          paragraph.comment_range_ends << range_end(id)
          paragraph.runs << reference_run(id)
          sync_element_order(paragraph)
        end

        private

        def range_start(id)
          Wordprocessingml::CommentRangeStart.new(id: id)
        end

        def range_end(id)
          Wordprocessingml::CommentRangeEnd.new(id: id)
        end

        # The run carrying w:commentReference, styled with Word's
        # CommentReference character style.
        def reference_run(id)
          run = Wordprocessingml::Run.new
          run.properties = Wordprocessingml::RunProperties.new
          run.properties.style =
            Properties::RunStyleReference.new(value: REFERENCE_STYLE)
          run.comment_reference = Wordprocessingml::CommentReference.new(id: id)
          run
        end

        # Record the anchor elements in element_order so mixed-content
        # serialization emits them in anchor position. Parsed paragraphs
        # with a consistent order get in-place insertion; anything else
        # gets a full rebuild from current content.
        def sync_element_order(paragraph)
          order = paragraph.element_order
          paragraph.element_order =
            if order.nil? || order.empty? || inconsistent?(order, paragraph)
              fresh_element_order(paragraph)
            else
              inserted_element_order(order, paragraph)
            end
        end

        # element_order tracks every collection except the just-added
        # anchor elements; any mismatch means it is stale and a rebuild
        # is safer than insertion.
        def inconsistent?(order, paragraph)
          count(order, "r") != paragraph.runs.size - 1 ||
            count(order, "commentRangeStart") !=
              paragraph.comment_range_starts.size - 1 ||
            count(order, "commentRangeEnd") !=
              paragraph.comment_range_ends.size - 1
        end

        def count(order, name)
          order.count { |e| e.name == name }
        end

        # Insert the new anchor entries into an existing order: the start
        # marker after the last existing start marker (or pPr), the end
        # marker before the first reference run, and the new reference
        # run's entry last.
        def inserted_element_order(order, paragraph)
          entries = order.dup
          insert_start_entry(entries)
          insert_end_entry(entries, paragraph)
          entries << xml_element("r")
          entries
        end

        def insert_start_entry(entries)
          pos = entries.rindex { |e| e.name == "commentRangeStart" }
          pos ||= entries.index { |e| e.name == "pPr" }
          entries.insert(pos ? pos + 1 : 0, xml_element("commentRangeStart"))
        end

        def insert_end_entry(entries, paragraph)
          ref_index = paragraph.runs.index(&:comment_reference)
          r_positions = entries.each_index.select do |i|
            entries[i].name == "r"
          end
          if ref_index && r_positions[ref_index]
            entries.insert(r_positions[ref_index],
                           xml_element("commentRangeEnd"))
          else
            entries << xml_element("commentRangeEnd")
          end
        end

        # Build a complete element_order from the paragraph's current
        # content: pPr, start markers, content runs and other content,
        # end markers, then the reference runs — Word's canonical
        # anchor layout.
        def fresh_element_order(paragraph)
          prefix_entries(paragraph) + content_entries(paragraph) +
            suffix_entries(paragraph)
        end

        # pPr plus all commentRangeStart entries.
        def prefix_entries(paragraph)
          entries = []
          entries << xml_element("pPr") if paragraph.properties
          paragraph.comment_range_starts.size.times do
            entries << xml_element("commentRangeStart")
          end
          entries
        end

        # All commentRangeEnd entries plus the reference runs' entries.
        def suffix_entries(paragraph)
          entries = []
          paragraph.comment_range_ends.size.times do
            entries << xml_element("commentRangeEnd")
          end
          reference_runs(paragraph).size.times { entries << xml_element("r") }
          entries
        end

        # Entries for all non-anchor content in mapping declaration
        # order, excluding reference runs (appended after end markers).
        def content_entries(paragraph)
          entries = []
          content_run_count(paragraph).times { entries << xml_element("r") }
          CONTENT_ELEMENTS.each do |name|
            count = element_count(paragraph, name)
            count.times { entries << xml_element(name) }
          end
          entries
        end

        def content_run_count(paragraph)
          paragraph.runs.size - reference_runs(paragraph).size
        end

        def reference_runs(paragraph)
          paragraph.runs.select(&:comment_reference)
        end

        # Collection size for a named content element, derived from the
        # paragraph's mapped collections (single elements count as 1).
        def element_count(paragraph, name)
          reader = COLLECTION_READERS[name]
          collection = reader&.call(paragraph)
          return 0 if collection.nil?
          return collection.size if collection.is_a?(Array)

          1
        end

        def xml_element(name)
          Lutaml::Xml::Element.new("Element", name)
        end
      end
    end
  end
end
