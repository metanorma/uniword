# frozen_string_literal: true

module Uniword
  module Caption
    # Builds a Caption-styled paragraph for one caption.
    #
    # Layout of the produced paragraph:
    #
    #   <w:p>
    #     <w:pPr><w:pStyle w:val="Caption"/></w:pPr>
    #     <w:bookmarkStart w:id="N" w:name="_Figure1"/>
    #     <w:r><w:t xml:space="preserve">Figure </w:t></w:r>
    #     <w:fldSimple w:instr=" SEQ Figure \* ARABIC ">
    #       <w:r><w:t>1</w:t></w:r>
    #     </w:fldSimple>
    #     <w:r><w:t xml:space="preserve">: Caption text</w:t></w:r>
    #     <w:bookmarkEnd w:id="N"/>
    #   </w:p>
    #
    # The bookmark name is `_Figure1`, `_Table2`, etc. — `_` prefix
    # matches Word's convention for hidden bookmarks.
    class CaptionBuilder
      DEFAULT_SEPARATOR = ": "

      # @param counter [Counter]
      def initialize(counter)
        @counter = counter
      end

      # Build a caption paragraph.
      #
      # @param label [String] e.g. "Figure"
      # @param text [String] caption body text
      # @param separator [String] between label/number and body
      #   (default ": ")
      # @param bookmark_id [Integer, nil] bookmark id; auto-allocated
      #   when nil
      # @return [Array<Wordprocessingml::Paragraph, String>] the
      #   paragraph and the bookmark name (caller appends the
      #   paragraph to the document)
      def build(label:, text:, separator: DEFAULT_SEPARATOR,
                bookmark_id: nil)
        sequence = @counter.next_value(label)
        bookmark_name = bookmark_name_for(label, sequence)
        bookmark_id ||= sequence

        [
          build_paragraph(label: label,
                          sequence: sequence,
                          text: text,
                          separator: separator,
                          bookmark_name: bookmark_name,
                          bookmark_id: bookmark_id),
          bookmark_name,
        ]
      end

      private

      def build_paragraph(label:, sequence:, text:, separator:,
                          bookmark_name:, bookmark_id:)
        para = Wordprocessingml::Paragraph.new
        para.properties = paragraph_properties
        para.bookmark_starts = [start_bookmark(bookmark_id, bookmark_name)]
        para.runs = [
          label_run("#{label} "),
          seq_field(label, sequence),
          body_run("#{separator}#{text}"),
        ]
        para.bookmark_ends = [end_bookmark(bookmark_id)]
        para
      end

      def paragraph_properties
        props = Wordprocessingml::ParagraphProperties.new
        props.style = "Caption"
        props
      end

      def start_bookmark(id, name)
        Wordprocessingml::BookmarkStart.new(id: id.to_s, name: name)
      end

      def end_bookmark(id)
        Wordprocessingml::BookmarkEnd.new(id: id.to_s)
      end

      def label_run(text)
        run_with_text(text)
      end

      def body_run(text)
        run_with_text(text)
      end

      def run_with_text(text)
        Wordprocessingml::Run.new(text: [text_element(text)])
      end

      def text_element(content)
        Wordprocessingml::Text.new(content: content, xml_space: "preserve")
      end

      def seq_field(label, sequence)
        Wordprocessingml::SimpleField.new(
          instr: seq_instruction(label),
          runs: [run_with_text(sequence.to_s)],
        )
      end

      def seq_instruction(label)
        " SEQ #{label} \\* ARABIC "
      end

      def bookmark_name_for(label, sequence)
        "_#{label}#{sequence}"
      end
    end
  end
end
