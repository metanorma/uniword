# frozen_string_literal: true

require 'nokogiri'

module Uniword
  # Streaming parser for large DOCX documents.
  #
  # This parser uses SAX-based parsing to process large documents
  # without loading the entire DOM into memory. It's designed for
  # scenarios where memory efficiency is critical.
  #
  # @example Parse a large document
  #   parser = Uniword::StreamingParser.new
  #   document = parser.parse_file('large_document.docx')
  class StreamingParser
    # Threshold for when to use streaming (in bytes)
    # Documents larger than this will use streaming by default
    STREAMING_THRESHOLD = 10 * 1024 * 1024 # 10MB

    # Initialize the streaming parser
    def initialize
      @paragraph_limit = nil
      @table_limit = nil
    end

    # Set limits for how many elements to parse
    #
    # @param paragraphs [Integer, nil] Maximum paragraphs to parse
    # @param tables [Integer, nil] Maximum tables to parse
    # @return [void]
    def set_limits(paragraphs: nil, tables: nil)
      @paragraph_limit = paragraphs
      @table_limit = tables
    end

    # Determine if file should use streaming based on size
    #
    # @param file_path [String] Path to the file
    # @return [Boolean] true if file is large enough for streaming
    def self.should_stream?(file_path)
      File.size(file_path) > STREAMING_THRESHOLD
    rescue StandardError
      false
    end

    # Parse a large DOCX document with streaming
    #
    # @param zip_content [Hash] Extracted ZIP content from DOCX
    # @return [Document] The parsed document
    def parse_streaming(zip_content)
      document = Document.new
      document_xml = zip_content['word/document.xml']

      return document unless document_xml

      # Use Nokogiri's SAX parser for streaming
      handler = DocumentSaxHandler.new(document, @paragraph_limit, @table_limit)
      parser = Nokogiri::XML::SAX::Parser.new(handler)
      parser.parse(document_xml)

      document
    end

    # SAX handler for streaming document parsing
    class DocumentSaxHandler < Nokogiri::XML::SAX::Document
      attr_reader :document

      def initialize(document, paragraph_limit = nil, table_limit = nil)
        super()
        @document = document
        @paragraph_limit = paragraph_limit
        @table_limit = table_limit
        @paragraph_count = 0
        @table_count = 0

        # State tracking
        @current_element = nil
        @current_paragraph = nil
        @current_run = nil
        @current_text = nil
        @current_table = nil
        @current_row = nil
        @current_cell = nil
        @in_properties = false
        @element_stack = []
      end

      # Called when an element starts
      def start_element(name, attributes = [])
        attrs = attributes.to_h
        @element_stack.push(name)

        case name
        when 'p'
          start_paragraph
        when 'r'
          start_run
        when 't'
          start_text(attrs)
        when 'tbl'
          start_table
        when 'tr'
          start_table_row
        when 'tc'
          start_table_cell
        when 'pPr', 'rPr', 'tblPr', 'trPr', 'tcPr'
          @in_properties = true
        end
      end

      # Called when an element ends
      def end_element(name)
        @element_stack.pop

        case name
        when 'p'
          end_paragraph
        when 'r'
          end_run
        when 't'
          end_text
        when 'tbl'
          end_table
        when 'tr'
          end_table_row
        when 'tc'
          end_table_cell
        when 'pPr', 'rPr', 'tblPr', 'trPr', 'tcPr'
          @in_properties = false
        end
      end

      # Called when text content is encountered
      def characters(string)
        return unless @current_text

        @current_text << string
      end

      private

      # Check if we've hit paragraph limit
      def paragraph_limit_reached?
        @paragraph_limit && @paragraph_count >= @paragraph_limit
      end

      # Check if we've hit table limit
      def table_limit_reached?
        @table_limit && @table_count >= @table_limit
      end

      # Start parsing a paragraph
      def start_paragraph
        return if paragraph_limit_reached?

        @current_paragraph = Paragraph.new
        @paragraph_count += 1
      end

      # End parsing a paragraph
      def end_paragraph
        return unless @current_paragraph

        if @current_table
          # Paragraph inside table cell
          @current_cell&.add_paragraph(@current_paragraph)
        else
          # Top-level paragraph
          @document.add_element(@current_paragraph)
        end

        @current_paragraph = nil
      end

      # Start parsing a run
      def start_run
        return unless @current_paragraph

        @current_run = Run.new
      end

      # End parsing a run
      def end_run
        return unless @current_run && @current_paragraph

        @current_paragraph.add_run(@current_run)
        @current_run = nil
      end

      # Start parsing text
      def start_text(_attrs)
        return unless @current_run

        @current_text = String.new
      end

      # End parsing text
      def end_text
        return unless @current_text && @current_run

        text_element = TextElement.new(content: @current_text)
        @current_run.text_element = text_element
        @current_text = nil
      end

      # Start parsing a table
      def start_table
        return if table_limit_reached?

        @current_table = Table.new
        @table_count += 1
      end

      # End parsing a table
      def end_table
        return unless @current_table

        @document.add_element(@current_table)
        @current_table = nil
      end

      # Start parsing a table row
      def start_table_row
        return unless @current_table

        @current_row = TableRow.new
      end

      # End parsing a table row
      def end_table_row
        return unless @current_row && @current_table

        @current_table.add_row(@current_row)
        @current_row = nil
      end

      # Start parsing a table cell
      def start_table_cell
        return unless @current_row

        @current_cell = TableCell.new
      end

      # End parsing a table cell
      def end_table_cell
        return unless @current_cell && @current_row

        @current_row.add_cell(@current_cell)
        @current_cell = nil
      end
    end

    # Parse document metadata without loading full content
    #
    # This is useful for getting document stats quickly
    #
    # @param zip_content [Hash] Extracted ZIP content
    # @return [Hash] Document metadata
    def parse_metadata_only(zip_content)
      document_xml = zip_content['word/document.xml']
      return {} unless document_xml

      metadata = {
        paragraph_count: 0,
        table_count: 0,
        has_images: false
      }

      # Use simple regex for fast counting (not parsing full DOM)
      metadata[:paragraph_count] = document_xml.scan(/<w:p[ >]/).size
      metadata[:table_count] = document_xml.scan(/<w:tbl[ >]/).size
      metadata[:has_images] = document_xml.include?('<w:drawing')

      metadata
    end
  end
end
