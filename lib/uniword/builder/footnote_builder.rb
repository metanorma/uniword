# frozen_string_literal: true

module Uniword
  module Builder
    # Builds footnotes and endnotes for documents.
    #
    # Manages footnote/endnote creation, ID assignment, and wiring
    # references into the document body. Uses IdAllocator for all ID
    # assignment when available.
    class FootnoteBuilder
      def initialize(document, allocator: nil)
        @document = document
        @allocator = allocator
      end

      # Create a footnote and return a Run with a footnoteReference.
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
        if @allocator
          @allocator.alloc_footnote_id
        else
          @footnote_counter ||= 1
          id = @footnote_counter
          @footnote_counter += 1
          id
        end
      end

      def next_endnote_id
        if @allocator
          @allocator.alloc_endnote_id
        else
          @endnote_counter ||= 1
          id = @endnote_counter
          @endnote_counter += 1
          id
        end
      end

      def create_footnote_entry(id, text, &block)
        # OOXML spec: regular footnotes must NOT have w:type.
        # Only separator/continuationSeparator use w:type.
        entry = Wordprocessingml::Footnote.new(id: id.to_s)
        para = ParagraphBuilder.new(allocator: @allocator)
        if block_given?
          block.call(para)
        elsif text
          para << text
        end
        entry.paragraphs << para.build
        footnotes.footnote_entries << entry
      end

      def create_endnote_entry(id, text, &block)
        entry = Wordprocessingml::Endnote.new(id: id.to_s)
        para = ParagraphBuilder.new(allocator: @allocator)
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
