# frozen_string_literal: true

module Uniword
  module Builder
    # Builds footnotes and endnotes for documents.
    #
    # Manages footnote/endnote creation, ID assignment, and wiring
    # references into the document body.
    #
    # @example Add footnotes to a document
    #   doc = DocumentBuilder.new
    #   doc.paragraph { |p| p << 'See the '; p << doc.footnote('A note') }
    #
    # @example Add endnotes
    #   doc.paragraph { |p| p << 'See '; p << doc.endnote('An endnote') }
    class FootnoteBuilder
      def initialize(document)
        @document = document
      end

      # Create a footnote and return a Run with a footnoteReference.
      #
      # The footnote body is stored in the document's footnotes collection.
      # The returned Run contains a <w:footnoteReference> element that
      # Word uses to link to the footnote body.
      #
      # @param text [String] Footnote text content
      # @yield [ParagraphBuilder] Builder for rich footnote content
      # @return [Wordprocessingml::Run] Run with footnote reference
      def footnote(text = nil, &)
        id = next_footnote_id
        run = Wordprocessingml::Run.new(
          footnote_reference: Wordprocessingml::FootnoteReference.new(id: id.to_s)
        )
        create_footnote_entry(id, text, &)
        run
      end

      # Create an endnote and return a Run with an endnoteReference.
      #
      # @param text [String] Endnote text content
      # @yield [ParagraphBuilder] Builder for rich endnote content
      # @return [Wordprocessingml::Run] Run with endnote reference
      def endnote(text = nil, &)
        id = next_endnote_id
        run = Wordprocessingml::Run.new(
          endnote_reference: Wordprocessingml::EndnoteReference.new(id: id.to_s)
        )
        create_endnote_entry(id, text, &)
        run
      end

      private

      def footnotes
        @document.model.footnotes ||= Wordprocessingml::Footnotes.new
      end

      def endnotes
        @document.model.endnotes ||= Wordprocessingml::Endnotes.new
      end

      def next_footnote_id
        @footnote_counter ||= 1
        id = @footnote_counter
        @footnote_counter += 1
        id
      end

      def next_endnote_id
        @endnote_counter ||= 1
        id = @endnote_counter
        @endnote_counter += 1
        id
      end

      def create_footnote_entry(id, text, &block)
        entry = Wordprocessingml::Footnote.new(id: id.to_s, type: "normal")
        para = ParagraphBuilder.new
        if block_given?
          block.call(para)
        elsif text
          para << text
        end
        entry.paragraphs << para.build
        footnotes.footnote_entries << entry
      end

      def create_endnote_entry(id, text, &block)
        entry = Wordprocessingml::Endnote.new(id: id.to_s, type: "normal")
        para = ParagraphBuilder.new
        if block_given?
          block.call(para)
        elsif text
          para << text
        end
        entry.paragraphs << para.build
        endnotes.endnote_entries << entry
      end
    end
  end
end
