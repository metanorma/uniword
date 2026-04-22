# frozen_string_literal: true

module Uniword
  module Resource
    # Converts document element templates into OOXML document structures.
    class DocumentElementConverter
      # Convert a template element to an array of OOXML paragraphs
      #
      # @param element [Hash] Template element definition
      # @return [Array<Uniword::Wordprocessingml::Paragraph>] OOXML paragraphs
      def to_paragraphs(element)
        return [] unless element && element["body"] && element["body"]["paragraphs"]

        element["body"]["paragraphs"].map do |para_def|
          build_paragraph(para_def)
        end
      end

      # Convert a template element to a standalone DocumentRoot
      #
      # @param element [Hash] Template element definition
      # @return [Uniword::Wordprocessingml::DocumentRoot] Document with content
      def to_document(element)
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        to_paragraphs(element).each do |para|
          doc.body.paragraphs << para
        end
        doc
      end

      private

      # Build a single OOXML paragraph from a template definition
      def build_paragraph(para_def)
        para = Uniword::Wordprocessingml::Paragraph.new

        # Set properties
        props = Uniword::Wordprocessingml::ParagraphProperties.new
        props.style = para_def["style"] if para_def["style"]
        props.alignment = para_def["alignment"] if para_def["alignment"]
        props.spacing_before = para_def["space_before"].to_i if para_def["space_before"]
        props.spacing_after = para_def["space_after"].to_i if para_def["space_after"]
        para.properties = props

        # Add run with text
        text = para_def["text"] || ""
        run = Uniword::Wordprocessingml::Run.new(text: text)

        # Run properties
        if para_def["bold"] || para_def["italic"] || para_def["size"] || para_def["color"]
          run_props = Uniword::Wordprocessingml::RunProperties.new
          run_props.bold = true if para_def["bold"]
          run_props.italic = true if para_def["italic"]
          run_props.size = para_def["size"].to_i if para_def["size"]
          run.properties = run_props
        end

        para.runs << run
        para
      end
    end
  end
end
