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
      attr_reader :model, :kind

      def initialize(kind, type: 'default')
        @kind = kind
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
          para = Wordprocessingml::Paragraph.new
          para.runs << Wordprocessingml::Run.new(text: element)
          @model.paragraphs << para
        when Wordprocessingml::Run
          # Auto-wrap Run in a paragraph, appending to the last one if possible
          if @model.paragraphs.empty?
            para = Wordprocessingml::Paragraph.new
            para.runs << element
            @model.paragraphs << para
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
        para = ParagraphBuilder.new
        para << text if text
        block.call(para) if block_given?
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
