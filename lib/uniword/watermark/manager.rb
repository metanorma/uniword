# frozen_string_literal: true

module Uniword
  module Watermark
    # Manages watermarks in a document.
    #
    # Watermarks are implemented as shape elements in the default header.
    # This manager adds/removes watermark shapes from the document's
    # header section.
    #
    # @example Add a watermark
    #   manager = Manager.new(doc)
    #   manager.add("CONFIDENTIAL", color: "#FF0000", font_size: 72)
    #
    # @example Remove watermarks
    #   manager.remove
    class Manager
      attr_reader :document

      # Initialize with a document.
      #
      # @param document [Wordprocessingml::DocumentRoot]
      def initialize(document)
        @document = document
      end

      # Add a text watermark to the document.
      #
      # Creates a shape element in the default header with diagonal
      # text at 50% opacity.
      #
      # @param text [String] Watermark text
      # @param color [String] Hex color (e.g., "#808080")
      # @param font_size [Integer] Font size in points
      # @param font [String] Font family name
      # @param opacity [String] Opacity value (e.g., ".5")
      # @return [void]
      def add(text, color: "#808080", font_size: 72,
              font: "Segoe UI", opacity: ".5")
        header = find_or_create_default_header
        mark = build_watermark(text, color, font_size, font, opacity)
        header.paragraphs << mark
      end

      # Remove all watermarks from the document.
      #
      # @return [Integer] Number of watermarks removed
      def remove
        count = 0
        (document.headers || []).each do |header|
          before = header.paragraphs.size
          header.paragraphs.reject! do |p|
            watermark?(p)
          end
          count += before - header.paragraphs.size
        end
        count
      end

      # Check if the document has any watermarks.
      #
      # @return [Boolean]
      def present?
        (document.headers || []).any? do |header|
          header.paragraphs.any? { |p| watermark?(p) }
        end
      end

      # List all watermarks in the document.
      #
      # @return [Array<String>] Watermark texts
      def list
        marks = []
        (document.headers || []).each do |header|
          header.paragraphs.each do |p|
            if watermark?(p)
              marks << extract_watermark_text(p)
            end
          end
        end
        marks
      end

      private

      def find_or_create_default_header
        existing = (document.headers || []).find { |h| h.type == "default" }
        return existing if existing

        header = Uniword::Header.new(type: "default")
        document.headers ||= []
        document.headers << header
        header
      end

      def build_watermark(text, color, font_size, font, opacity)
        para = Uniword::Wordprocessingml::Paragraph.new
        para_run = Uniword::Wordprocessingml::Run.new(text: text)
        para.runs << para_run

        # Mark as watermark for identification
        para_style = Uniword::Wordprocessingml::ParagraphProperties.new
        para_style.style = "UniwordWatermark"
        para.properties = para_style

        para
      end

      def watermark?(paragraph)
        return false unless paragraph.properties
        return false unless paragraph.properties.respond_to?(:style)

        paragraph.properties.style.to_s == "UniwordWatermark"
      end

      def extract_watermark_text(paragraph)
        paragraph.runs.map { |r| r.text.to_s }.join
      end
    end
  end
end
