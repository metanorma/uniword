# frozen_string_literal: true

module Uniword
  module Generation
    # Generates DOCX documents from structured content and style sources.
    #
    # Combines a style source DOCX (provides styles), a style mapping
    # (maps semantic element names to OOXML style names), and structured
    # content (from YAML/Markdown) into a new DOCX file.
    #
    # @example Generate a document
    #   generator = DocumentGenerator.new(
    #     style_source: "iso_template.docx",
    #     style_mapping: "config/style_mappings/iso_publication.yml"
    #   )
    #   content = StructuredTextParser.parse("content.yml")
    #   generator.generate(content, "output.docx")
    class DocumentGenerator
      # Initialize the generator with style source and optional mapping.
      #
      # @param style_source [String] Path to DOCX file providing styles
      # @param style_mapping [String, nil] Path to YAML style mapping
      #   config. Falls back to default mapping when nil.
      def initialize(style_source:, style_mapping: nil)
        @style_source = style_source
        @mapper = StyleMapper.new(style_mapping)
      end

      # Generate a DOCX from structured content elements.
      #
      # @param structured_content [Array<Hash>] Content elements from
      #   StructuredTextParser, each with :element, :text, optional
      #   :style and :children
      # @param output_path [String] Output DOCX file path
      # @return [void]
      def generate(structured_content, output_path)
        builder = create_builder

        structured_content.each do |element|
          add_element(builder, element)
        end

        builder.save(output_path)
      end

      private

      def create_builder
        doc = Builder::DocumentBuilder.new

        source_doc = load_style_source
        if source_doc
          import_styles(doc, source_doc)
          import_theme(doc, source_doc)
        end

        doc
      end

      def load_style_source
        return nil unless File.exist?(@style_source)

        DocumentFactory.from_file(@style_source)
      rescue StandardError
        nil
      end

      def import_styles(builder, source_doc)
        return unless source_doc.respond_to?(:styles_configuration)
        return unless source_doc.styles_configuration

        source_doc.styles_configuration.styles.each do |style|
          builder.model.styles_configuration.add_style(
            style.dup,
            allow_overwrite: true
          )
        end
      end

      def import_theme(builder, source_doc)
        return unless source_doc.respond_to?(:theme)
        return unless source_doc.theme

        builder.model.theme = source_doc.theme
      end

      def add_element(builder, element)
        element_type = element[:element].to_s
        text = element[:text].to_s

        case element_type
        when /\Aheading_(\d+)\z/
          level = ::Regexp.last_match(1).to_i
          add_heading(builder, text, level)
        when "table"
          add_table(builder, element)
        else
          add_styled_paragraph(builder, element_type, text)
        end
      end

      def add_heading(builder, text, level)
        style_name = @mapper.style_for("heading_#{level}")
        para = Builder::ParagraphBuilder.new
        para.style = style_name
        para << text
        builder.model.body.paragraphs << para.build
      end

      def add_styled_paragraph(builder, element_type, text)
        style_name = @mapper.style_for(element_type)
        para = Builder::ParagraphBuilder.new
        para.style = style_name
        para << text unless text.empty?
        builder.model.body.paragraphs << para.build
      end

      def add_table(builder, element)
        builder.table do |tbl|
          if element[:children].is_a?(Array)
            element[:children].each do |row_data|
              tbl.row do |row|
                cells = row_data.is_a?(Hash) ? row_data["cells"] : row_data
                Array(cells).each do |cell_text|
                  row.cell(text: cell_text.to_s)
                end
              end
            end
          end
        end
      end
    end
  end
end
