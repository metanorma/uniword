# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/wordprocessingml/paragraph_properties'
require_relative '../ooxml/wordprocessingml/run_properties'

module Uniword
  module Wordprocessingml
    # Root element of a WordprocessingML document
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:document>
    class DocumentRoot < Lutaml::Model::Serializable
      attribute :body, Body

      xml do
        element 'document'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'body', to: :body
      end

      # Additional attributes for DOCX metadata (not part of document.xml)
      # These are stored in separate files within the DOCX package
      attr_accessor :core_properties      # docProps/core.xml
      attr_accessor :app_properties       # docProps/app.xml
      attr_accessor :theme                # word/theme/theme1.xml
      attr_accessor :styles_configuration # word/styles.xml
      attr_accessor :numbering_configuration # word/numbering.xml

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
            run.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
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
          para.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new

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
      # @param rows [Integer, nil] Number of rows
      # @param cols [Integer, nil] Number of columns
      # @return [Table] The created table
      def add_table(rows = nil, cols = nil)
        table = Table.new

        # Create rows and cells if dimensions provided
        if rows && cols
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
        require_relative '../document_writer'
        writer = DocumentWriter.new(self)
        writer.save(path, format: format)
      end

      # Get all paragraph text
      #
      # @return [String] Combined text from all paragraphs
      def text
        return '' unless body && body.paragraphs
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
        require_relative '../themes/yaml_theme_loader'
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
        require_relative '../stylesets/yaml_styleset_loader'
        styleset = Uniword::StyleSets::YamlStyleSetLoader.load_bundled(name.to_s)
        styleset.apply_to(self, strategy: strategy)
        self
      end
    end
  end
end
