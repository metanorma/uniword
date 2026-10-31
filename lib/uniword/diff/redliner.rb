# frozen_string_literal: true

module Uniword
  module Diff
    # Produces a tracked-changes (redline) document from two revisions.
    #
    # The base document (the old revision) is rewritten in place: a
    # paragraph removed in the new revision has its runs wrapped in
    # w:del and its paragraph mark marked deleted; an added paragraph
    # is inserted with its runs wrapped in w:ins and its paragraph
    # mark marked inserted; a modified paragraph keeps the base text
    # with the word-level delta emitted as interleaved w:del / w:ins
    # runs. Tables pass through unchanged (issue #77 scope item 3).
    #
    # Revision identity (w:id, author, date) is deterministic per
    # change position, so the same pair of documents always produces
    # the same redline.
    #
    # @example
    #   base = DocumentFactory.from_file("old.docx")
    #   revised = DocumentFactory.from_file("new.docx")
    #   result = Redliner.new(base, revised, author: "Alice").redline
    #   result.document.save("redline.docx")
    class Redliner
      include Builder::DeterministicId

      DEFAULT_AUTHOR = "uniword"

      # Tokenizer: words and whitespace runs, originals preserved so
      # concatenation reproduces the paragraph text exactly.
      TOKEN_PATTERN = /\S+|\s+/

      # Wordprocessingml::Paragraph children the redliner does not
      # rebuild; their element_order entries are carried over on
      # rewritten paragraphs.
      REBUILT_CHILDREN = %w[pPr r ins del].freeze

      # @param old_doc [Wordprocessingml::DocumentRoot] base revision,
      #   rewritten in place into the redline
      # @param new_doc [Wordprocessingml::DocumentRoot] revised version
      # @param author [String] revision author for emitted changes
      # @param date [String, nil] revision date (ISO 8601) for emitted
      #   changes; omitted from the XML when nil
      def initialize(old_doc, new_doc, author: DEFAULT_AUTHOR, date: nil)
        @old_doc = old_doc
        @new_doc = new_doc
        @author = author
        @date = date
        @inserted = 0
        @old_cursor = 0
        @seq = 0
        @stats = Hash.new(0)
      end

      # Rewrite the base document into a redline.
      #
      # @return [RedlineResult] the redlined document plus change stats
      def redline
        Lcs.alignment(old_texts, new_texts).each { |step| apply(step) }
        RedlineResult.new(document: @old_doc, stats: @stats)
      end

      private

      def body
        @old_doc.body
      end

      def old_paras
        body.paragraphs
      end

      def new_paras
        @new_doc.body&.paragraphs || []
      end

      def old_texts
        old_paras.map { |p| p.text.to_s }
      end

      def new_texts
        new_paras.map { |p| p.text.to_s }
      end

      def apply((action, old_i, new_i))
        case action
        when :kept
          @stats[:kept] += 1
          @old_cursor += 1
        when :modified
          if old_paras[old_i].text == new_paras[new_i].text
            @stats[:kept] += 1
          else
            rewrite_modified(old_paras[old_i], new_paras[new_i])
            @stats[:modified] += 1
          end
          @old_cursor += 1
        when :removed
          mark_deleted(old_paras[old_i])
          @stats[:removed] += 1
          @old_cursor += 1
        when :added
          insert_added(new_paras[new_i])
          @stats[:added] += 1
        end
      end

      # Word-level delta of two paragraphs as ordered segments.
      #
      # Contiguous tokens from the same source run merge into one
      # segment, so a single-span change yields exactly one revision
      # element, the way Word writes redlines.
      #
      # @return [Array<Hash>] { kind: :keep/:del/:ins, text:, properties: }
      def diff_segments(old_para, new_para)
        old_tokens = tokenize(old_para)
        new_tokens = tokenize(new_para)

        segments = []
        current = nil
        Lcs.alignment(old_tokens.map(&:last), new_tokens.map(&:last))
          .each do |action, old_i, new_i|
          case action
          when :kept
            current = merge(segments, current, :keep,
                            old_tokens[old_i].last,
                            old_tokens[old_i].first.properties)
          when :removed, :modified
            current = merge(segments, current, :del,
                            old_tokens[old_i].last,
                            old_tokens[old_i].first.properties)
          end
          next unless %i[added modified].include?(action)

          current = merge(segments, current, :ins,
                          new_tokens[new_i].last,
                          new_tokens[new_i].first.properties)
        end
        merge(segments, current, nil, nil, nil)
        segments.reject { |segment| segment[:text].empty? }
      end

      # Append a token to the current segment, or start a new one when
      # the kind or the owning run's properties change.
      def merge(segments, current, kind, text, properties)
        if current && current[:kind] == kind &&
            current[:properties].equal?(properties)
          current[:text] << text
          return current
        end

        segments << current if current
        segment = { kind: kind, text: +"", properties: properties }
        segment[:text] << text if text
        segment
      end

      # Tokens of a paragraph as [run, text] pairs.
      def tokenize(para)
        para.runs.flat_map do |run|
          run.text_string.to_s.scan(TOKEN_PATTERN).map { |t| [run, t] }
        end
      end

      def rewrite_modified(old_para, new_para)
        kept_runs = []
        deletions = []
        insertions = []
        names = []
        names << "pPr" if old_para.properties

        diff_segments(old_para, new_para).each do |segment|
          case segment[:kind]
          when :keep
            kept_runs << Wordprocessingml::Run.new(
              properties: segment[:properties], text: segment[:text],
            )
            names << "r"
          when :del
            deletions << Wordprocessingml::Deletion.new(
              id: next_id, author: @author, date: @date,
              runs: [Wordprocessingml::Run.new(
                properties: segment[:properties],
                del_text: deleted_text(segment[:text]),
              )]
            )
            names << "del"
          when :ins
            insertions << Wordprocessingml::Insertion.new(
              id: next_id, author: @author, date: @date,
              runs: [Wordprocessingml::Run.new(
                properties: segment[:properties], text: segment[:text],
              )]
            )
            names << "ins"
          end
        end

        old_para.runs = kept_runs
        old_para.deletions = deletions
        old_para.insertions = insertions
        set_paragraph_order(old_para, names)
      end

      # Wrap every run of a removed paragraph in w:del and mark the
      # paragraph mark deleted, so accepting the revision drops the
      # whole paragraph.
      def mark_deleted(para)
        deleted_runs = para.runs.map { |run| deleted_run(run) }
        para.runs = []

        names = []
        names << "pPr" if para.properties
        unless deleted_runs.empty?
          para.deletions = [Wordprocessingml::Deletion.new(
            id: next_id, author: @author, date: @date, runs: deleted_runs,
          )]
          names << "del"
        end

        props = ensure_mark(para)
        props.run_properties ||= Wordprocessingml::RunProperties.new
        props.run_properties.del =
          Wordprocessingml::DeletedParagraphMark.new(
            id: next_id, author: @author, date: @date,
          )
        set_paragraph_order(para, names)
      end

      def deleted_text(text)
        deleted = Wordprocessingml::DeletedText.new(content: text)
        if Wordprocessingml::Text.preserve_whitespace?(text)
          deleted.xml_space = "preserve"
        end
        deleted
      end

      def deleted_run(run)
        text = run.text_string.to_s
        return run if text.empty?

        Wordprocessingml::Run.new(properties: run.properties,
                                  del_text: deleted_text(text))
      end

      # Insert a new-only paragraph with its runs wrapped in w:ins and
      # its paragraph mark marked inserted, right before the base
      # paragraph the alignment cursor sits on.
      def insert_added(new_para)
        para = Wordprocessingml::Paragraph.new
        para.properties =
          new_para.properties || Wordprocessingml::ParagraphProperties.new
        para.properties.run_properties ||= Wordprocessingml::RunProperties.new
        para.properties.run_properties.ins =
          Wordprocessingml::InsertedParagraphMark.new(
            id: next_id, author: @author, date: @date,
          )

        names = ["pPr"]
        if new_para.runs.any?
          para.insertions = [Wordprocessingml::Insertion.new(
            id: next_id, author: @author, date: @date,
            runs: new_para.runs.dup
          )]
          names << "ins"
        end
        set_paragraph_order(para, names)

        position = @old_cursor + @inserted
        body.paragraphs.insert(position, para)
        insert_order_entry(position)
        @inserted += 1
      end

      # Record the paragraph's child sequence in element_order so the
      # interleaved runs / del / ins serialize in emission order and
      # untouched children (hyperlinks, bookmarks, comments) survive.
      def set_paragraph_order(para, names)
        order = para.element_order
        carried = if order.nil? || order.empty?
                    []
                  else
                    order.map(&:name).reject do |name|
                      REBUILT_CHILDREN.include?(name)
                    end
                  end
        para.element_order = (names + carried).map do |name|
          Lutaml::Xml::Element.new("Element", name)
        end
      end

      # Insert the element_order entry for a body paragraph added at
      # +paragraph_index+ so it serializes at its document position.
      def insert_order_entry(paragraph_index)
        order = body.element_order
        return if order.nil? || order.empty?

        order = Ooxml::ElementOrder.mutable_order(body)
        p_positions = order.each_index.select { |i| order[i].name == "p" }
        at = if paragraph_index < p_positions.size
               p_positions[paragraph_index]
             else
               order.index { |e| e.name == "sectPr" } || order.size
             end
        order.insert(at, Lutaml::Xml::Element.new("Element", "p"))
      end

      def ensure_mark(para)
        para.properties ||= Wordprocessingml::ParagraphProperties.new
        para.properties
      end

      def next_id
        @seq += 1
        deterministic_id("uniword-redline", @seq).to_s
      end
    end
  end
end
