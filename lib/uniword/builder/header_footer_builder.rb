# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures Header or Footer objects.
    #
    # @example Create a header
    #   doc.header do |h|
    #     h << 'Document Title'
    #   end
    #
    # @example Create a footer with page number
    #   doc.footer do |f|
    #     f << 'Page '
    #     f << Builder.page_number_field
    #   end
    class HeaderFooterBuilder
      attr_reader :model, :kind, :allocator

      def initialize(kind, type: "default", allocator: nil)
        @kind = kind
        @allocator = allocator
        @model = if kind == :header
                   Wordprocessingml::Header.new
                 else
                   Wordprocessingml::Footer.new
                 end
      end

      # Append content to the header/footer
      #
      # @param element [String, Run, Paragraph, Table, ParagraphBuilder]
      # @return [self]
      def <<(element)
        case element
        when String
          para = ParagraphBuilder.new(allocator: @allocator)
          para << element
          @model.paragraphs << para.build
        when Wordprocessingml::Run
          if @model.paragraphs.empty?
            para = ParagraphBuilder.new(allocator: @allocator)
            para << element
            @model.paragraphs << para.build
          else
            @model.paragraphs.last.runs << element
          end
        when Wordprocessingml::Paragraph
          @model.paragraphs << element
        when Wordprocessingml::Table
          @model.tables << element
        when ParagraphBuilder
          @model.paragraphs << element.build
        else
          raise ArgumentError, "Cannot add #{element.class} to #{@kind}"
        end
        self
      end

      # Add a paragraph with configuration
      #
      # @param text [String, nil] Optional text content
      # @yield [ParagraphBuilder] Builder for paragraph configuration
      # @return [ParagraphBuilder]
      def paragraph(text = nil, &block)
        para = ParagraphBuilder.new(allocator: @allocator)
        para << text if text
        yield(para) if block
        @model.paragraphs << para.build
        para
      end

      # Return the underlying Header or Footer model
      def build
        @model
      end
    end
  end
end
