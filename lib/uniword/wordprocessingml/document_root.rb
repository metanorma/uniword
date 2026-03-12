# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Root element of a WordprocessingML document
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:document>
    class DocumentRoot < Lutaml::Model::Serializable
      attribute :body, Body, default: -> { Body.new }

      xml do
        element 'document'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'body', to: :body
      end

      # Additional attributes for DOCX metadata (not part of document.xml)
      # These are stored in separate files within the DOCX package
      attr_accessor :core_properties # docProps/core.xml
      attr_accessor :app_properties, :theme, :raw_html, :revisions, :comments, :bookmarks # docProps/app.xml                # word/theme/theme1.xml # word/numbering.xml # Raw HTML content for MHTML format support # API compatibility

      # Lazy initialization for numbering_configuration
      def numbering_configuration
        @numbering_configuration ||= Uniword::NumberingConfiguration.new
      end

      # Setter for numbering_configuration
      attr_writer :numbering_configuration

      # Set document title (convenience method for core_properties)
      #
      # @param value [String] The document title
      # @return [self] For method chaining
      def title=(value)
        self.core_properties ||= {}
        core_properties[:title] = value
        self
      end

      # Get document title
      #
      # @return [String, nil] The document title
      def title
        core_properties&.dig(:title)
      end

      # Lazy initialization for styles_configuration
      def styles_configuration
        @styles_configuration ||= StylesConfiguration.new
      end

      # Setter for styles_configuration
      attr_writer :styles_configuration

      # Get all sections (paragraphs with section properties)
      #
      # @return [Array<Paragraph>] Paragraphs that define sections
      def sections
        # In OOXML, sections are defined by sectPr elements within paragraphs
        # Return paragraphs that have section_properties
        body&.paragraphs&.select { |p| p.properties&.section_properties } || []
      end

      # Get current section (last section with section properties)
      #
      # @return [Paragraph, nil] The current section or nil
      def current_section
        sections.last
      end

      # Set sections (API compatibility - no-op)
      #
      # @param value [Array] Section data
      # @return [Array]
      def sections=(_value)
        # Sections are determined by section_properties in paragraphs
        # This is a no-op for API compatibility
      end

      # Add chart (API compatibility placeholder)
      #
      # @param type [Symbol] Chart type
      # @return [Chart] The created chart
      def add_chart(_type = nil)
        Drawingml::Chart::Chart.new
        # TODO: Implement chart addition to document
      end

      # Add element to document (API compatibility)
      #
      # @param element [Paragraph, Table, etc.] The element to add
      # @return [Object] The added element
      def add_element(element)
        case element
        when Paragraph
          body.paragraphs << element
        when Table
          body.tables << element
        else
          # Try to add as paragraph if it responds to runs
          body.paragraphs << element if element.respond_to?(:runs)
        end
        element
      end

      # Add paragraph with optional text and formatting
      #
      # @param text [String, nil] Optional text content
      # @param options [Hash] Formatting options (bold, italic, style, etc.)
      # @return [Paragraph] The created paragraph
      def add_paragraph(text = nil, **options)
        para = Paragraph.new

        # Add text if provided
        if text
          run = Run.new
          run.text = text

          # Apply run formatting from options
          if options.any?
            run.properties ||= RunProperties.new
            run.properties.bold = true if options[:bold]
            run.properties.italic = true if options[:italic]
            run.properties.underline = options[:underline] if options[:underline]
            run.properties.color = options[:color] if options[:color]
            run.properties.size = options[:size] * 2 if options[:size] # half-points
            run.properties.font = options[:font] if options[:font]
          end

          para.runs << run
        end

        # Apply paragraph formatting from options
        if options[:style] || options[:alignment] || options[:heading]
          para.properties ||= ParagraphProperties.new

          # Handle heading option
          if options[:heading]
            heading_num = options[:heading].to_s.gsub(/[^\d]/, '')
            para.properties.style = "Heading#{heading_num}"
          elsif options[:style]
            para.properties.style = options[:style]
          end

          para.properties.alignment = options[:alignment] if options[:alignment]
        end

        # Ensure body exists
        self.body ||= Body.new

        # Add paragraph to body
        body.paragraphs << para
        para
      end

      # Add table with optional dimensions
      #
      # Add a table to the document
      #
      # @param table_or_rows [Table, Integer, nil] Table object or number of rows
      # @param cols [Integer, nil] Number of columns (if first arg is rows)
      # @return [Table] The added/created table
      def add_table(table_or_rows = nil, cols = nil)
        # Handle different argument patterns
        case table_or_rows
        when Table
          # Add the provided table directly
          table = table_or_rows
        when Integer
          # Create a new table with specified dimensions
          table = Table.new
          rows = table_or_rows

          rows.times do
            row = TableRow.new
            row.cells = []

            cols.times do
              cell = TableCell.new
              cell.paragraphs = [Paragraph.new]
              row.cells << cell
            end

            table.rows ||= []
            table.rows << row
          end
        else
          # Create empty table
          table = Table.new
        end

        # Ensure body exists
        self.body ||= Body.new

        # Add table to body
        body.tables << table
        table
      end

      # Save document to file
      #
      # @param path [String] Output file path
      # @param format [Symbol] Format (:docx, :mhtml, :auto)
      def save(path, format: :auto)
        writer = DocumentWriter.new(self)
        writer.save(path, format: format)
      end

      # Get all paragraph text
      #
      # @return [String] Combined text from all paragraphs
      def text
        return '' unless body&.paragraphs

        body.paragraphs.map(&:text).join("\n")
      end

      # Get all paragraphs (convenience accessor)
      #
      # @return [Array<Paragraph>] All paragraphs in document
      def paragraphs
        body&.paragraphs || []
      end

      # Get all tables (convenience accessor)
      #
      # @return [Array<Table>] All tables in document
      def tables
        body&.tables || []
      end

      # Apply theme to document
      #
      # @param name [String, Symbol] Theme name (e.g., 'celestial', 'atlas')
      # @return [self] For method chaining
      def apply_theme(name)
        theme = Uniword::Themes::YamlThemeLoader.load_bundled(name.to_s)
        self.theme = theme
        self
      end

      # Apply StyleSet to document
      #
      # @param name [String, Symbol] StyleSet name (e.g., 'distinctive', 'formal')
      # @param strategy [Symbol] Application strategy (:keep_existing, :replace, :rename)
      # @return [self] For method chaining
      def apply_styleset(name, strategy: :keep_existing)
        styleset = Uniword::StyleSets::YamlStyleSetLoader.load_bundled(name.to_s)
        styleset.apply_to(self, strategy: strategy)
        self
      end

      # Get styles from document
      #
      # @return [Array<Style>] Array of styles
      def styles
        @styles ||= []
      end

      # Set styles on document
      #
      # @param value [Array<Style>] Styles to set
      # @return [Array<Style>] The styles
      attr_writer :styles
    end
  end
end
