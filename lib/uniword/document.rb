# frozen_string_literal: true

require_relative 'body'
require_relative 'styles_configuration'
require_relative 'numbering_configuration'
require_relative 'section'
require_relative 'footnote'
require_relative 'endnote'
require_relative 'bookmark'
require_relative 'lazy_loader'
require_relative 'theme'
require_relative 'comments_part'
require_relative 'tracked_changes'
require_relative 'ooxml/core_properties'
require_relative 'ooxml/app_properties'

module Uniword
  # Main document class representing a Word document.
  #
  # Represents the document structure (domain model).
  # Holds document elements and provides access to them.
  #
  # Does NOT handle: File I/O, format conversion, serialization.
  # Factory and Writer classes handle I/O operations to maintain SRP.
  # Convenience class methods delegate to those classes.
  #
  # Uses lazy loading for efficient memory usage with large documents.
  #
  # @example Create a new document
  #   doc = Uniword::Document.new
  #   para = Uniword::Paragraph.new
  #   para.add_text("Hello World")
  #   doc.add_element(para)
  #
  # @example Read an existing document
  #   doc = Uniword::Document.open('input.docx')
  #   puts doc.text
  #
  # @example Create a simple document
  #   doc = Uniword::Document.create_simple("Hello World")
  #   doc.save('output.docx')
  #
  # @attr_reader [Body] body Document body containing all content
  # @attr_accessor [StylesConfiguration] styles_configuration Document styles
  # @attr_accessor [NumberingConfiguration] numbering_configuration Numbering
  # @attr_accessor [Theme] theme Document theme (colors and fonts)
  # @attr_accessor [Ooxml::CoreProperties] core_properties Core document metadata
  # @attr_accessor [Ooxml::AppProperties] app_properties Application properties
  # @attr_accessor [Array<Section>] sections Document sections
  # @attr_accessor [Array<Footnote>] footnotes Document footnotes
  # @attr_accessor [Array<Endnote>] endnotes Document endnotes
  # @attr_accessor [Array<Bookmark>] bookmarks Document bookmarks
  # @attr_accessor [CommentsPart] comments_part Document comments collection
  # @attr_accessor [TrackedChanges] tracked_changes Document revision tracking
  #
  # @see DocumentFactory For reading documents from files
  # @see DocumentWriter For writing documents to files
  # @see Builder For fluent document creation
  class Document < Lutaml::Model::Serializable
    extend LazyLoader
    # OOXML namespace configuration for WordProcessingML
    xml do
      root 'document'
      # Note: First namespace is used for root element prefix
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
      namespace 'http://schemas.openxmlformats.org/officeDocument/2006/relationships', 'r'

      map_element 'body', to: :body
    end

    # Document body containing all content
    attribute :body, Body, default: -> { Body.new }

    # Document styles configuration (not serialized in document.xml)
    # This is managed separately and written to styles.xml
    attr_accessor :styles_configuration

    # Document numbering configuration (not serialized in document.xml)
    # This is managed separately and written to numbering.xml
    attr_accessor :numbering_configuration

    # Document theme (not serialized in document.xml)
    # This is managed separately and written to theme/theme1.xml
    attr_accessor :theme

    # Document core properties (not serialized in document.xml)
    # This is managed separately and written to docProps/core.xml
    # Replaces metadata Hash with proper lutaml-model for round-trip fidelity
    attr_accessor :core_properties

    # Document application properties (not serialized in document.xml)
    # This is managed separately and written to docProps/app.xml
    # Replaces metadata Hash with proper lutaml-model for round-trip fidelity
    attr_accessor :app_properties

    # Document sections (for headers/footers/page setup)
    attr_accessor :sections

    # Document footnotes collection
    attr_accessor :footnotes

    # Document endnotes collection
    attr_accessor :endnotes

    # Document bookmarks collection (Hash for docx gem compatibility)
    attr_accessor :bookmarks

    # Raw XML preservation for perfect round-trip (temporary until full modeling)
    attr_accessor :raw_styles_xml
    attr_accessor :raw_font_table_xml
    attr_accessor :raw_numbering_xml
    attr_accessor :raw_settings_xml

    # Document comments collection (not serialized in document.xml)
    # This is managed separately and written to comments.xml
    attr_accessor :comments_part

    # Document tracked changes (not serialized in document.xml)
    # This is managed separately
    attr_accessor :tracked_changes

    # Document charts collection (not serialized in document.xml)
    # Charts are stored in separate chart*.xml files
    attr_accessor :charts

    # Initialize document with optional styles
    #
    # @param attributes [Hash] Document attributes
    def initialize(attributes = {})
      super
      @styles_configuration = StylesConfiguration.new
      @numbering_configuration = NumberingConfiguration.new
      @theme = nil
      @core_properties = Ooxml::CoreProperties.new
      @app_properties = Ooxml::AppProperties.new
      @sections = [Section.new]
      @footnotes = []
      @endnotes = []
      @bookmarks = {}  # Hash for docx gem compatibility
      @comments_part = CommentsPart.new
      @tracked_changes = TrackedChanges.new
      @charts = []
    end

    # Get the current section (last section)
    def current_section
      sections.last
    end

    # Add a new section
    def add_section(section = nil)
      sect = section || Section.new
      sections << sect
      sect
    end

    # Legacy elements accessor for backward compatibility
    # Delegates to body.paragraphs
    def elements
      body.paragraphs
    end

    # Convenience class methods that delegate to DocumentFactory
    class << self
      # Create a new empty document.
      #
      # Delegates to DocumentFactory.create
      #
      # @return [Document] A new empty document
      #
      # @example Create empty document
      #   document = Document.new

      # Open a document from a file.
      #
      # Delegates to DocumentFactory.from_file
      #
      # @param path [String] The file path
      # @param format [Symbol] The format (:auto, :docx, :mhtml)
      # @return [Document] The loaded document
      #
      # @example Open DOCX file
      #   document = Document.open("document.docx")
      def open(path, format: :auto)
        require_relative 'document_factory'
        DocumentFactory.from_file(path, format: format)
      rescue FileNotFoundError => e
        # For docx gem compatibility, convert FileNotFoundError to Errno::ENOENT
        raise Errno::ENOENT, e.message
      end
    end

    # Convenience accessors with lazy loading
    # These cache the results for efficient repeated access
    def paragraphs
      @cached_paragraphs ||= body.paragraphs
    end

    def tables
      @cached_tables ||= body.tables
    end

    # Clear cached collections when body changes
    def clear_element_cache
      @cached_paragraphs = nil
      @cached_tables = nil
      @cached_images = nil
      @cached_hyperlinks = nil
      @cached_charts = nil
    end

    # Element management
    # Adds paragraph or table to body
    #
    # Automatically wraps Run and Image objects in a Paragraph for convenience.
    #
    # @param element [Element] The element to add
    # @return [Element] The added element (or wrapping paragraph for Run/Image)
    # @raise [ArgumentError] if element is not a valid Element subclass
    def add_element(element)
      unless element.is_a?(Element)
        raise ArgumentError,
              'Element must inherit from Uniword::Element'
      end

      # Clear cache when adding elements
      clear_element_cache

      # Handle different element types
      case element
      when Paragraph
        # Set parent document reference
        element.parent_document = self if element.respond_to?(:parent_document=)
        body.add_paragraph(element)
        element
      when Table
        body.add_table(element)
        element
      when Run, Image
        # Auto-wrap Run or Image in a Paragraph for convenience
        para = Paragraph.new
        para.add_run(element)
        para.parent_document = self if para.respond_to?(:parent_document=)
        body.add_paragraph(para)
        para
      else
        # For abstract Element or other Element subclasses (e.g., for testing)
        # Try to add as paragraph if it responds to paragraph-like interface
        if element.class == Element || element.respond_to?(:add_run)
          # Allow abstract Element for testing purposes
          # This provides flexibility while maintaining type safety
          if element.class == Element
            # For pure Element instances, create a placeholder paragraph
            para = Paragraph.new
            para.parent_document = self if para.respond_to?(:parent_document=)
            body.add_paragraph(para)
            para
          else
            # Treat as paragraph-like object
            element.parent_document = self if element.respond_to?(:parent_document=)
            body.add_paragraph(element)
            element
          end
        else
          raise ArgumentError,
                "Unsupported element type: #{element.class}. " \
                "Supported types: Paragraph, Table, Run, Image (auto-wrapped in Paragraph)"
        end
      end
    end

    # Convenience method to add a paragraph to the document
    # Compatible with docx-js API
    #
    # @param paragraph [Paragraph, String, nil] Paragraph instance, text string, or nil
    # @param options [Hash] Formatting options (alignment, style, numbering, etc.)
    # @yield [Paragraph] Optional block to configure the paragraph
    # @return [Paragraph] The paragraph (new or provided)
    def add_paragraph(paragraph = nil, **options, &block)
      para = case paragraph
             when nil
               Paragraph.new
             when String
               # Create paragraph with text
               p = Paragraph.new
               p.add_text(paragraph)
               p
             when Paragraph
               paragraph
             else
               # Try to use as-is if it's an Element subclass
               if paragraph.is_a?(Element)
                 paragraph
               else
                 raise ArgumentError,
                       "paragraph must be a Paragraph instance, String, or nil, got #{paragraph.class}"
               end
             end

      # Apply options if provided
      if options.any?
        # Handle alignment
        if options[:alignment]
          para.properties ||= Properties::ParagraphProperties.new
          para.align(options[:alignment])
        end

        # Handle style
        if options[:style]
          para.set_style(options[:style])
        end

        # Handle heading shortcut
        if options[:heading]
          heading_style = case options[:heading]
                          when :heading_1 then 'Heading 1'
                          when :heading_2 then 'Heading 2'
                          when :heading_3 then 'Heading 3'
                          when :heading_4 then 'Heading 4'
                          when :heading_5 then 'Heading 5'
                          when :heading_6 then 'Heading 6'
                          else options[:heading].to_s
                          end
          para.set_style(heading_style)
        end

        # Handle numbering
        if options[:numbering]
          num_opts = options[:numbering]
          if num_opts.is_a?(Hash)
            # Use paragraph's numbering= setter which handles the hash format
            para.numbering = num_opts
          end
        end

        # Handle bold text formatting
        if options[:bold] && para.runs.any?
          para.runs.each do |run|
            run.properties ||= Properties::RunProperties.new
            run.properties.bold = true
          end
        end
      end

      # Yield to block if provided (for docx-js style API)
      yield(para) if block_given?

      add_element(para)
      para
    end

    # Convenience method to add a table to the document
    # Compatible with docx-js API
    #
    # @param table_or_rows [Table, Integer, nil] Optional table instance, row count, or nil
    # @param cols [Integer, nil] Number of columns (when first arg is row count)
    # @param options [Hash] Table options
    # @yield [Table] Optional block to configure the table
    # @return [Table] The table (new or provided)
    def add_table(table_or_rows = nil, cols = nil, **options, &block)
      tbl = case table_or_rows
            when Table
              table_or_rows
            when Integer
              # New API: add_table(rows, cols)
              table = Table.new
              # Create rows x cols table
              table_or_rows.times do
                row = TableRow.new
                cols.to_i.times do
                  row.add_cell(TableCell.new)
                end
                table.add_row(row)
              end
              table
            when nil
              Table.new
            else
              raise ArgumentError, "table must be a Table instance, Integer, or nil"
            end

      # Yield to block if provided (for docx-js style API)
      yield(tbl) if block_given?

      add_element(tbl)
      tbl
    end

    # Save the document to a file.
    #
    # Delegates to DocumentWriter
    #
    # @param path [String] The output file path
    # @param format [Symbol] The format (:auto, :docx, :mhtml)
    # @return [void]
    #
    # @example Save as DOCX
    #   document.save("output.docx")
    def save(path, format: :auto)
      require_relative 'document_writer'
      writer = DocumentWriter.new(self)
      writer.save(path, format: format)
    end

    # Apply theme from another document
    #
    # @param source_document_path [String] Path to source document
    # @return [void]
    def apply_theme_from(source_document_path)
      require_relative 'document_factory'
      source = DocumentFactory.from_file(source_document_path)
      self.theme = source.theme.dup if source.theme
    end

    # Apply styles from another document
    #
    # @param source_document_path [String] Path to source document
    # @param conflict_resolution [Symbol] How to handle conflicts (:keep_existing, :replace, :rename)
    # @return [void]
    def apply_styles_from(source_document_path, conflict_resolution: :keep_existing)
      require_relative 'document_factory'
      source = DocumentFactory.from_file(source_document_path)
      styles_configuration.merge(source.styles_configuration, conflict_resolution: conflict_resolution)
    end

    # Apply both theme and styles from a template
    #
    # @param template_path [String] Path to template document
    # @return [void]
    def apply_template(template_path)
      apply_theme_from(template_path)
      apply_styles_from(template_path, conflict_resolution: :replace)
    end

    # Apply theme from .thmx file
    #
    # Loads and applies a theme from a .thmx theme package file.
    # Optionally applies a specific variant.
    #
    # @param theme_path [String] Path to .thmx file
    # @param variant [String, Integer, nil] Optional variant identifier
    # @return [void]
    #
    # @example Apply theme
    #   doc.apply_theme_file('themes/Atlas.thmx')
    #
    # @example Apply theme with variant
    #   doc.apply_theme_file('themes/Atlas.thmx', variant: 2)
    #   doc.apply_theme_file('themes/Atlas.thmx', variant: 'variant2')
    def apply_theme_file(theme_path, variant: nil)
      self.theme = Theme.from_thmx(theme_path, variant: variant)
    end

    # Apply bundled theme by name
    #
    # Shorthand for loading and applying a bundled theme.
    #
    # @param theme_name [String] Name of bundled theme
    # @param variant [String, Integer, nil] Optional variant identifier
    # @return [void]
    #
    # @example Apply bundled theme
    #   doc.apply_theme('atlas')
    #   doc.apply_theme('atlas', variant: 2)
    def apply_theme(theme_name, variant: nil)
      self.theme = Theme.load(theme_name, variant: variant)
    end

    # Apply bundled StyleSet by name
    #
    # Shorthand for loading and applying a bundled StyleSet.
    #
    # @param styleset_name [String] Name of bundled StyleSet
    # @param strategy [Symbol] Conflict resolution strategy
    #   - :keep_existing (default) - Keep existing styles
    #   - :replace - Replace existing with StyleSet styles
    #   - :rename - Keep both, rename imported styles
    # @return [void]
    #
    # @example Apply bundled StyleSet
    #   doc.apply_styleset('distinctive')
    #   doc.apply_styleset('distinctive', strategy: :replace)
    def apply_styleset(styleset_name, strategy: :keep_existing)
      require_relative 'styleset'
      styleset = StyleSet.load(styleset_name)
      styleset.apply_to(self, strategy: strategy)
    end

    # Build styled content using external style library
    #
    # @param library_name [String, Symbol] Name of the style library to use
    # @yield Block to build document content using DSL
    # @return [Document] self for method chaining
    #
    # @example Build ISO standard document
    #   doc.styled_content('iso_standard') do
    #     paragraph :title, "ISO 8601-2:2026"
    #     paragraph :heading_1, "1. Scope"
    #     paragraph :body_text, "This document specifies..."
    #   end
    def styled_content(library_name, &block)
      require_relative 'styles/style_builder'
      builder = Styles::StyleBuilder.new(self, style_library: library_name)
      builder.build(&block) if block_given?
      self
    end

    # Apply style library definitions to document
    #
    # Imports all styles from the library into the document's
    # styles configuration for use in the document.
    #
    # @param library_name [String, Symbol] Name of the style library
    # @return [void]
    #
    # @example Apply ISO standard styles
    #   doc.apply_style_library('iso_standard')
    def apply_style_library(library_name)
      require_relative 'styles/style_library'
      library = Styles::StyleLibrary.load(library_name)

      # Import paragraph styles
      library.paragraph_style_names.each do |name|
        definition = library.paragraph_style(name)
        # Create style from definition and add to configuration
        # Note: This is a simplified version - full implementation would
        # create proper Style objects with all properties
        style = Style.new(
          style_id: name.to_s,
          name: definition.name,
          type: 'paragraph'
        )
        styles_configuration.add_style(style)
      end

      # Import character styles
      library.character_style_names.each do |name|
        definition = library.character_style(name)
        style = Style.new(
          style_id: name.to_s,
          name: definition.name,
          type: 'character'
        )
        styles_configuration.add_style(style)
      end
    end


    # Add a comment to the document
    #
    # @param comment [Comment] The comment to add
    # @return [Comment] The added comment
    def add_comment(comment)
      comments_part.add_comment(comment)
    end

    # Find a comment by ID
    #
    # @param comment_id [String] The comment ID
    # @return [Comment, nil] The comment if found
    def find_comment(comment_id)
      comments_part.find_comment(comment_id)
    end

    # Get all comments
    #
    # @return [Array<Comment>] All comments in the document
    def comments
      comments_part.comments
    end

    # Enable track changes for this document
    #
    # @return [void]
    def enable_track_changes
      tracked_changes.enabled = true
    end

    # Disable track changes for this document
    #
    # @return [void]
    def disable_track_changes
      tracked_changes.enabled = false
    end

    # Check if track changes is enabled
    #
    # @return [Boolean] true if enabled
    def track_changes_enabled?
      tracked_changes.enabled
    end

    # Add an insertion revision
    #
    # @param text [String] The inserted text
    # @param author [String] The author name
    # @return [Revision] The created revision
    def add_insertion(text, author:)
      tracked_changes.add_insertion(text, author: author)
    end

    # Add a deletion revision
    #
    # @param text [String] The deleted text
    # @param author [String] The author name
    # @return [Revision] The created revision
    def add_deletion(text, author:)
      tracked_changes.add_deletion(text, author: author)
    end

    # Add a format change revision
    #
    # @param content [String] Description of format change
    # @param author [String] The author name
    # @return [Revision] The created revision
    def add_format_change(content, author:)
      tracked_changes.add_format_change(content, author: author)
    end

    # Get all revisions
    #
    # @return [Array<Revision>] All revisions in the document
    def revisions
      tracked_changes.revisions
    end

    # Accept all tracked changes
    #
    # @return [Integer] Number of changes accepted
    def accept_all_changes
      tracked_changes.accept_all
    end

    # Reject all tracked changes
    #
    # @return [Integer] Number of changes rejected
    def reject_all_changes
      tracked_changes.reject_all
    end

    # Visitor pattern for traversal
    def accept(visitor)
      visitor.visit_document(self)
      elements.each { |e| e.accept(visitor) }
    end

    # Validate the document
    #
    # @return [Boolean] true if valid, false otherwise
    def valid?
      # Document is valid if all elements are valid
      elements.all? { |e| e.respond_to?(:valid?) ? e.valid? : true }
    end

    # Get all styles in the document
    # Compatible with docx gem API
    #
    # @return [Array<Style>] Array of all styles
    def styles
      return [] unless styles_configuration
      styles_configuration.styles
    end

    # Get all images in the document
    # Compatible with docx gem API
    #
    # @return [Array<Image>] Array of all images in the document
    def images
      @cached_images ||= collect_images
    end

    # Get all hyperlinks in the document
    # Compatible with docx gem API
    #
    # @return [Array<Hyperlink>] Array of all hyperlinks in the document
    def hyperlinks
      @cached_hyperlinks ||= collect_hyperlinks
    end

    # Get all charts in the document
    #
    # @return [Array<Chart>] Array of all charts in the document
    def charts
      @charts ||= []
    end

    # Add a chart to the document
    #
    # @param chart [Chart] The chart to add
    # @return [Chart] The added chart
    def add_chart(chart)
      unless chart.is_a?(Chart)
        raise ArgumentError, 'chart must be a Chart instance'
      end

      @charts ||= []
      @charts << chart
      clear_element_cache
      chart
    end

    # Get all plain text content from the document
    # Concatenates text from all paragraphs with newlines
    #
    # @return [String] The combined text from all paragraphs
    def text
      paragraphs.map(&:text).join("\n")
    end

    # Get document as HTML
    # Compatible with docx gem API
    #
    # @return [String] HTML representation of the document
    def to_html
      paragraphs.map(&:to_html).join("\n")
    end

    # Get document as StringIO for web responses
    # Compatible with docx gem API
    #
    # @return [StringIO] Document as StringIO buffer
    def stream
      require 'stringio'
      io = StringIO.new

      # Use DocumentWriter to write to StringIO
      require_relative 'document_writer'
      writer = DocumentWriter.new(self)
      writer.write_to_stream(io)

      io.rewind
      io
    end

    # Calculate word count for the document
    #
    # @return [Integer] Total word count
    def word_count
      text.split(/\s+/).reject(&:empty?).size
    end

    # Calculate character count for the document (without spaces)
    #
    # @return [Integer] Total character count
    def character_count
      text.gsub(/\s+/, '').length
    end

    # Calculate character count with spaces for the document
    #
    # @return [Integer] Total character count with spaces
    def character_count_with_spaces
      text.length
    end

    # Get page count (defaults to 1 for now, needs layout engine for accurate count)
    #
    # @return [Integer] Page count
    def page_count
      # Future enhancement: Calculate based on page size, margins, content
      1
    end

    # Get document title from metadata
    #
    # @return [String] Document title
    def title
      @core_properties&.title || ''
    end

    # Set document title in metadata
    #
    # @param value [String] Document title
    def title=(value)
      @core_properties ||= Ooxml::CoreProperties.new
      @core_properties.title = value
    end

    # Quick document creation helper
    # Creates a document with a single paragraph containing the given text
    #
    # @param text [String] The text content
    # @return [Document] A new document with the text
    #
    # @example Create simple document
    #   doc = Document.create_simple("Hello World")
    def self.create_simple(text)
      doc = new
      para = Paragraph.new
      para.add_text(text)
      doc.add_element(para)
      doc
    end

    # Return document as string (plain text content)
    # Compatible with docx gem API
    #
    # @return [String] Document text content
    def to_s
      text
    end

    # Provide detailed inspection for debugging
    # Includes instance variables for docx gem compatibility
    #
    # @return [String] A readable representation of the document
    def inspect
      vars = instance_variables.map { |v| "#{v}=..." }.join(' ')
      "#<Uniword::Document:#{object_id} #{vars}>"
    end

    private

    # Collect all images from document paragraphs
    # Recursively searches through runs to find Image elements
    #
    # @return [Array<Image>] All images found in the document
    def collect_images
      images = []
      paragraphs.each do |para|
        para.runs.each do |run|
          images << run if run.is_a?(Image)
        end
      end
      images
    end

    # Collect all hyperlinks from document paragraphs
    # Searches through runs to find Hyperlink elements
    #
    # @return [Array<Hyperlink>] All hyperlinks found in the document
    def collect_hyperlinks
      hyperlinks = []
      paragraphs.each do |para|
        para.runs.each do |run|
          hyperlinks << run if run.is_a?(Hyperlink)
        end
      end
      hyperlinks
    end

    # Check if document is a template
    #
    # A document is considered a template if it contains Uniword
    # template syntax in comments.
    #
    # @return [Boolean] true if document contains template markers
    def template?
      # Check if any paragraph has comments with template syntax
      paragraphs.any? do |para|
        next false unless para.respond_to?(:comments)
        para.comments.any? { |c| c.text&.match?(/^\{\{.+\}\}$/) }
      end
    end

    # Render this document as a template
    #
    # Fills the document with provided data using the template system.
    # The document must contain Uniword template syntax in comments.
    #
    # @param data [Hash, Object] Data to fill template
    # @param context [Hash] Additional context variables
    # @return [Document] Rendered document
    #
    # @example Render document as template
    #   doc = Document.open('template.docx')
    #   filled = doc.render_template(title: "My Report")
    #   filled.save('report.docx')
    def render_template(data, context: {})
      require_relative 'template/template'
      template = Uniword::Template::Template.new(self)
      template.render(data, context: context)
    end

    # Preview template structure
    #
    # Returns information about template markers for debugging.
    # Only works if document is a template.
    #
    # @return [Hash, nil] Template structure info or nil
    #
    # @example Preview template
    #   doc = Document.open('template.docx')
    #   if doc.template?
    #     info = doc.template_preview
    #     puts "Variables: #{info[:variables]}"
    #     puts "Loops: #{info[:loops]}"
    #   end
    def template_preview
      return nil unless template?

      require_relative 'template/template'
      template = Uniword::Template::Template.new(self)
      template.preview
    end
  end
end
