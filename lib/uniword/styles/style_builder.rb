# frozen_string_literal: true

require_relative 'style_library'
require_relative 'dsl/list_context'
require_relative 'dsl/table_context'
require_relative 'dsl/paragraph_context'

module Uniword
  module Styles
    # Style Builder DSL - fluent interface for applying styles
    #
    # Responsibility: Provide DSL for style application to documents
    # Single Responsibility: Style application only
    #
    # This class provides a fluent DSL for building styled documents using
    # external style libraries. It orchestrates style application from
    # StyleLibrary definitions to Document elements.
    #
    # @example Build a styled document
    #   builder = StyleBuilder.new(Document.new, style_library: 'iso_standard')
    #   doc = builder.build do
    #     paragraph :title, "Document Title"
    #     paragraph :heading_1, "Chapter 1"
    #     list :bullet_list do
    #       item "First point"
    #       item "Second point"
    #     end
    #   end
    class StyleBuilder
      attr_reader :document, :library

      # Initialize style builder
      #
      # @param document [Document] The document to build
      # @param style_library [String, Symbol] Name of the style library to use
      def initialize(document, style_library:)
        @document = document
        @library = StyleLibrary.load(style_library)
      end

      # Build document using DSL
      #
      # @yield Block to build document content
      # @return [Document] The built document
      #
      # @example
      #   builder.build do
      #     paragraph :title, "My Document"
      #     paragraph :body_text, "Content here..."
      #   end
      def build(&block)
        instance_eval(&block) if block_given?
        @document
      end

      # Add styled paragraph
      #
      # @param style_name [String, Symbol] Style name from library
      # @param text [String, nil] Paragraph text (optional)
      # @yield [ParagraphContext] Optional block for complex content
      # @return [Paragraph] The created paragraph
      #
      # @example Simple paragraph
      #   paragraph :title, "Document Title"
      #
      # @example Complex paragraph with mixed styles
      #   paragraph :body_text do |p|
      #     p.text "Normal text "
      #     p.text "bold text", :strong
      #   end
      def paragraph(style_name, text = nil, &block)
        style_def = @library.paragraph_style(style_name)

        para = Paragraph.new
        apply_paragraph_style(para, style_def)

        if text
          para.add_text(text)
        elsif block_given?
          # Use paragraph context for complex content
          context = DSL::ParagraphContext.new(para, @library)
          context.instance_eval(&block)
        end

        @document.add_paragraph(para)
        para
      end

      # Add styled list
      #
      # @param style_name [String, Symbol] List style name from library
      # @yield [ListContext] Block to define list items
      # @return [void]
      #
      # @example
      #   list :bullet_list do
      #     item "First point"
      #     item "Second point"
      #     item "Nested point", level: 1
      #   end
      def list(style_name, &block)
        style_def = @library.list_style(style_name)
        list_context = DSL::ListContext.new(@document, style_def)
        list_context.instance_eval(&block) if block_given?
      end

      # Add table with styling
      #
      # @yield [TableContext] Block to define table structure
      # @return [Table] The created table
      #
      # @example
      #   table do
      #     row header: true do
      #       cell "Column 1"
      #       cell "Column 2"
      #     end
      #     row do
      #       cell "Data 1"
      #       cell "Data 2"
      #     end
      #   end
      def table(&block)
        tbl = Table.new
        table_context = DSL::TableContext.new(tbl, @library)
        table_context.instance_eval(&block) if block_given?
        @document.add_table(tbl)
        tbl
      end

      private

      # Apply paragraph style definition to paragraph
      #
      # @param para [Paragraph] The paragraph to style
      # @param style_def [ParagraphStyleDefinition] The style definition
      # @return [void]
      def apply_paragraph_style(para, style_def)
        # Resolve inherited properties
        resolved = style_def.resolve_inheritance(@library)

        # Apply paragraph properties
        if resolved[:properties] && resolved[:properties].any?
          para.properties = Properties::ParagraphProperties.new(
            **resolved[:properties]
          )
        end

        # Store default run properties for text runs to inherit
        if resolved[:run_properties] && resolved[:run_properties].any?
          para.instance_variable_set(:@default_run_properties, resolved[:run_properties])
        end
      end

      # Apply run style definition to run
      #
      # @param run [Run] The run to style
      # @param style_def [CharacterStyleDefinition] The style definition
      # @return [void]
      def apply_run_style(run, style_def)
        resolved = style_def.resolve_inheritance(@library)

        if resolved && resolved.any?
          run.properties = Properties::RunProperties.new(**resolved)
        end
      end
    end
  end
end