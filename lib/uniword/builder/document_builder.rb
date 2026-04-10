# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures DocumentRoot objects.
    #
    # Top-level builder for creating Word documents.
    #
    # @example Create a new document
    #   doc = DocumentBuilder.new
    #   doc.paragraph { |p| p << 'Hello World' }
    #   doc.heading('Title', level: 1)
    #   doc.save('output.docx')
    #
    # @example Load and modify a document
    #   doc = DocumentBuilder.from_file('template.docx')
    #   doc.paragraph { |p| p << 'New content' }
    #   doc.save('modified.docx')
    #
    # @example Complete document
    #   doc = DocumentBuilder.new
    #   doc.title('Report').author('Author')
    #   doc.theme('atlas')
    #   doc.toc
    #   doc.heading('Introduction', level: 1)
    #   doc.paragraph { |p| p << 'Content...' }
    #   doc.bullet_list { |l| l.item('First'); l.item('Second') }
    #   doc.page_break
    #   doc.footer { |f| f << Builder.page_number_field }
    #   doc.save('report.docx')
    class DocumentBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::DocumentRoot.new
        @bookmark_counter = 0
        @footnote_builder = FootnoteBuilder.new(self)
        @comment_counter = 0
      end

      # Load a document from file for manipulation
      #
      # @param path [String] Path to .docx file
      # @return [DocumentBuilder]
      def self.from_file(path)
        new(Uniword.load(path))
      end

      # Append a top-level element (paragraph or table)
      #
      # @param element [Paragraph, Table, ParagraphBuilder, TableBuilder]
      # @return [self]
      def <<(element)
        case element
        when Wordprocessingml::Paragraph
          @model.body.paragraphs << element
        when Wordprocessingml::Table
          @model.body.tables << element
        when ParagraphBuilder
          @model.body.paragraphs << element.build
        when TableBuilder
          @model.body.tables << element.build
        else
          raise ArgumentError, "Cannot add #{element.class} to document"
        end
        self
      end

      # Create and add a paragraph to the document
      #
      # @param text [String, nil] Optional text content
      # @yield [ParagraphBuilder] Builder for configuration
      # @return [ParagraphBuilder] The paragraph builder
      def paragraph(text = nil, &block)
        para = ParagraphBuilder.new
        para << text if text
        block.call(para) if block_given?
        @model.body.paragraphs << para.build
        para
      end

      # Create and add a heading paragraph
      #
      # @param text [String] Heading text
      # @param level [Integer] Heading level (1-9, default 1)
      # @yield [ParagraphBuilder] Builder for additional configuration
      # @return [ParagraphBuilder] The paragraph builder
      def heading(text, level: 1)
        para = ParagraphBuilder.new
        para.style = "Heading#{level}"
        para << text
        @model.body.paragraphs << para.build
        para
      end

      # Insert a page break
      #
      # @return [self]
      def page_break
        @model.body.paragraphs << Wordprocessingml::Paragraph.new(
          runs: [Builder.page_break]
        )
        self
      end

      # Create and add a table to the document
      #
      # @yield [TableBuilder] Builder for table configuration
      # @return [TableBuilder] The table builder
      def table(&block)
        tbl = TableBuilder.new
        block.call(tbl) if block_given?
        @model.body.tables << tbl.build
        tbl
      end

      # Configure section properties
      #
      # @param type [String] Section break type ('nextPage', 'continuous', 'evenPage', 'oddPage')
      # @yield [SectionBuilder] Builder for section configuration
      # @return [SectionBuilder] The section builder
      def section(type: 'nextPage', &block)
        sec = SectionBuilder.new
        sec.type = type
        block.call(sec) if block_given?
        @model.body.section_properties ||= sec.build
        sec
      end

      # Configure a header
      #
      # @param type [String] Header type ('default', 'first', 'even')
      # @yield [HeaderFooterBuilder] Builder for header content
      # @return [HeaderFooterBuilder] The header/footer builder
      def header(type: 'default', &block)
        hf = HeaderFooterBuilder.new(:header, type: type)
        block.call(hf) if block_given?
        (@model.headers ||= {})[type] = hf.build
        hf
      end

      # Configure a footer
      #
      # @param type [String] Footer type ('default', 'first', 'even')
      # @yield [HeaderFooterBuilder] Builder for footer content
      # @return [HeaderFooterBuilder] The header/footer builder
      def footer(type: 'default', &block)
        hf = HeaderFooterBuilder.new(:footer, type: type)
        block.call(hf) if block_given?
        (@model.footers ||= {})[type] = hf.build
        hf
      end

      # Insert a Table of Contents
      #
      # @param title [String] TOC title (default 'Table of Contents')
      # @param styles [Array<String>, nil] Heading styles to include
      # @return [self]
      def toc(title: 'Table of Contents', styles: nil)
        TocBuilder.build(title: title, styles: styles).each do |para|
          @model.body.paragraphs << para
        end
        self
      end

      # Create a list (bulleted or numbered)
      #
      # @param type [Symbol] List type (:bullet, :decimal, :roman, :letter)
      # @yield [ListBuilder] Builder for list items
      # @return [ListBuilder] The list builder
      def list(type: :bullet, &block)
        lb = ListBuilder.new(self, type: type)
        block.call(lb) if block_given?
        lb
      end

      # Shorthand: create a numbered list
      #
      # @yield [ListBuilder] Builder for list items
      # @return [ListBuilder] The list builder
      def numbered_list(&)
        list(type: :decimal, &)
      end

      # Shorthand: create a bullet list
      #
      # @yield [ListBuilder] Builder for list items
      # @return [ListBuilder] The list builder
      def bullet_list(&)
        list(type: :bullet, &)
      end

      # Create a bookmark wrapping the next content
      #
      # @param name [String] Bookmark name
      # @yield [ParagraphBuilder] Builder for bookmark content
      # @return [ParagraphBuilder] The paragraph builder
      def bookmark(name, &block)
        @bookmark_counter += 1
        id = @bookmark_counter.to_s

        para = ParagraphBuilder.new
        para.model.bookmark_starts <<
          Wordprocessingml::BookmarkStart.new(id: id, name: name)
        block.call(para) if block_given?
        para.model.bookmark_ends <<
          Wordprocessingml::BookmarkEnd.new(id: id)
        @model.body.paragraphs << para.build
        para
      end

      # Create a footnote and return a Run with a footnoteReference.
      #
      # The returned Run can be appended to a paragraph using <<.
      #
      # @param text [String] Footnote text
      # @yield [ParagraphBuilder] Builder for rich footnote content
      # @return [Wordprocessingml::Run] Run with footnote reference
      def footnote(text = nil, &)
        @footnote_builder.footnote(text, &)
      end

      # Create an endnote and return a Run with an endnoteReference.
      #
      # @param text [String] Endnote text
      # @yield [ParagraphBuilder] Builder for rich endnote content
      # @return [Wordprocessingml::Run] Run with endnote reference
      def endnote(text = nil, &)
        @footnote_builder.endnote(text, &)
      end

      # Apply or configure a document theme
      #
      # @param name [String, nil] Theme name to apply
      # @yield [ThemeBuilder] Builder for theme customization
      # @return [ThemeBuilder] The theme builder
      def theme(name = nil, &block)
        tb = ThemeBuilder.new(self)
        tb.apply(name) if name
        block.call(tb) if block_given?
        tb
      end

      # Define a paragraph style
      #
      # @param name [String] Style name
      # @param base_on [String] Base style (default 'Normal')
      # @yield [StyleBuilder] Builder for style configuration
      # @return [StyleBuilder] The style builder
      def define_style(name, base_on: 'Normal', &block)
        style = StyleBuilder.new(name, base_on: base_on)
        block.call(style) if block_given?
        @model.styles_configuration.add_style(style.build)
        style
      end

      # Set document title
      #
      # @param value [String] Title
      # @return [self]
      def title(value)
        @model.core_properties.title = value
        self
      end

      # Set document author (creator)
      #
      # @param value [String] Author name
      # @return [self]
      def author(value)
        @model.core_properties.creator = value
        self
      end

      # Set document description
      #
      # @param value [String] Description
      # @return [self]
      def description(value)
        @model.core_properties.description = value
        self
      end

      # Set document subject
      #
      # @param value [String] Subject
      # @return [self]
      def subject(value)
        @model.core_properties.subject = value
        self
      end

      # Set document keywords
      #
      # @param value [String] Keywords
      # @return [self]
      def keywords(value)
        @model.core_properties.keywords = value
        self
      end

      # Set document creation date
      #
      # @param value [Time, String] Creation date
      # @return [self]
      def created(value)
        @model.core_properties.created = value
        self
      end

      # Set document modification date
      #
      # @param value [Time, String] Modification date
      # @return [self]
      def modified(value)
        @model.core_properties.modified = value
        self
      end

      # Apply a bundled styleset to the document
      #
      # @param name [String] Styleset name (e.g., 'formal', 'modern', 'elegant')
      # @param strategy [Symbol] Conflict resolution (:keep_existing, :replace, :rename)
      # @return [self]
      def apply_styleset(name, strategy: :keep_existing)
        @model.apply_styleset(name, strategy: strategy)
        self
      end

      # Insert a horizontal rule (paragraph with bottom border)
      #
      # @param style [String] Border style (default 'single')
      # @param color [String] Border color (default 'auto')
      # @param size [Integer] Border size in eighths of a point (default 6)
      # @return [self]
      def horizontal_rule(style: 'single', color: 'auto', size: 6)
        para = ParagraphBuilder.new
        para.borders(
          bottom: { style: style, color: color, size: size }
        )
        para.spacing(after: 0)
        @model.body.paragraphs << para.build
        self
      end

      # Insert an inline image paragraph
      #
      # @param path [String] Path to image file
      # @param width [Integer, nil] Width in EMU (914400 = 1 inch)
      # @param height [Integer, nil] Height in EMU
      # @param alt_text [String, nil] Alternative text
      # @return [self]
      def image(path, width: nil, height: nil, alt_text: nil)
        para = Wordprocessingml::Paragraph.new
        para.runs << ImageBuilder.create_run(
          self, path, width: width, height: height, alt_text: alt_text
        )
        @model.body.paragraphs << para
        self
      end

      # Insert a floating image paragraph
      #
      # @param path [String] Path to image file
      # @param width [Integer, nil] Width in EMU
      # @param height [Integer, nil] Height in EMU
      # @param alt_text [String, nil] Alternative text
      # @param align [Symbol, nil] Horizontal alignment (:left, :center, :right)
      # @param vertical_align [Symbol, nil] Vertical alignment (:top, :middle, :bottom)
      # @param wrap [Symbol] Text wrapping (:square, :none, :top_and_bottom)
      # @param behind_text [Boolean] Place image behind text
      # @return [self]
      def floating_image(path, width: nil, height: nil, alt_text: nil,
                         align: nil, vertical_align: nil, wrap: :square,
                         behind_text: false)
        para = Wordprocessingml::Paragraph.new
        para.runs << ImageBuilder.create_floating_run(
          self, path, width: width, height: height, alt_text: alt_text,
                      align: align, wrap: wrap, behind_text: behind_text
        )
        @model.body.paragraphs << para
        self
      end

      # Add a watermark to the document header
      #
      # Creates a VML text shape in the default header that renders
      # as a semi-transparent watermark across the page.
      #
      # @param text [String, nil] Watermark text (nil to clear)
      # @param font [String] Font name (default 'Calibri')
      # @param size [Integer] Font size in points (default 60)
      # @param color [String] Fill color hex (default 'D0D0D0')
      # @param opacity [String] Opacity '0.0' to '1.0' (default '0.3')
      # @param angle [Integer] Rotation angle in degrees (default -45)
      # @return [self]
      def watermark(text, font: 'Calibri', size: 60, color: nil,
                    opacity: '0.3', angle: -45)
        if text.nil?
          (@model.headers ||= {}).delete('default')
          return self
        end

        para = WatermarkBuilder.build_paragraph(
          text, font: font, size: size, color: color,
                opacity: opacity, angle: angle
        )

        header = Wordprocessingml::Header.new
        header.paragraphs << para
        (@model.headers ||= {})['default'] = header
        self
      end

      # Create a comment and store it in the document's comments collection.
      #
      # The comment is created using CommentBuilder and stored in
      # document.comments for later serialization.
      #
      # @param author [String] Comment author name
      # @param text [String, nil] Comment text
      # @param initials [String, nil] Author initials
      # @yield [CommentBuilder] Builder for rich comment content
      # @return [Comment] The created Comment model
      def comment(author:, text: nil, initials: nil, &block)
        @comment_counter += 1
        cb = CommentBuilder.new(
          author: author,
          comment_id: @comment_counter.to_s,
          initials: initials
        )
        cb << text if text
        block.call(cb) if block_given?
        comment_obj = cb.build
        @model.comments ||= []
        @model.comments << comment_obj
        comment_obj
      end

      # Create a text content control paragraph
      #
      # @param tag [String, nil] Developer tag
      # @param alias_name [String, nil] Display name
      # @param placeholder_text [String, nil] Placeholder text
      # @return [SdtBuilder] The SDT builder
      def content_control(tag: nil, alias_name: nil, placeholder_text: nil)
        sdt = SdtBuilder.text(
          tag: tag, alias_name: alias_name,
          placeholder_text: placeholder_text
        )
        @model.body.paragraphs.last&.sdts&.<<(sdt.build)
        sdt
      end

      # Create and configure bibliography sources
      #
      # @param style [String] Citation style (default 'APA')
      # @yield [BibliographyBuilder] Builder for source configuration
      # @return [BibliographyBuilder] The bibliography builder
      def bibliography(style: 'APA', &block)
        bib = BibliographyBuilder.new(style: style)
        block.call(bib) if block_given?
        bib.attach(self)
        bib
      end

      # Insert a bibliography placeholder (SDT content control)
      #
      # @return [self]
      def bibliography_placeholder
        sdt = SdtBuilder.bibliography.build
        para = Wordprocessingml::Paragraph.new
        para.sdts << sdt
        @model.body.paragraphs << para
        self
      end

      # Insert a chart into the document
      #
      # @param type [Symbol] Chart type (:bar, :line, :pie, default :bar)
      # @param width [Integer] Width in EMU (default 5486400 ≈ 6 inches)
      # @param height [Integer] Height in EMU (default 3200400 ≈ 3.5 inches)
      # @yield [ChartBuilder] Builder for chart configuration
      # @return [ChartBuilder] The chart builder
      def chart(type: :bar, width: nil, height: nil, &block)
        cb = ChartBuilder.new(chart_type: type)
        cb.dimensions(width: width, height: height) if width || height
        block.call(cb) if block_given?

        drawing = cb.build_drawing(self)
        run = Wordprocessingml::Run.new
        run.drawings << drawing
        para = Wordprocessingml::Paragraph.new
        para.runs << run
        @model.body.paragraphs << para
        cb
      end

      # Insert a page number paragraph
      #
      # @return [self]
      def page_number
        @model.body.paragraphs << Builder.page_number_field
        self
      end

      # Insert a total pages paragraph
      #
      # @return [self]
      def total_pages
        @model.body.paragraphs << Builder.total_pages_field
        self
      end

      # Insert a date paragraph
      #
      # @param format [String] Date format (default 'M/d/yyyy')
      # @return [self]
      def date_field(format: 'M/d/yyyy')
        @model.body.paragraphs << Builder.date_field(format: format)
        self
      end

      # Insert a time paragraph
      #
      # @param format [String] Time format (default 'h:mm:ss am/pm')
      # @return [self]
      def time_field(format: 'h:mm:ss am/pm')
        @model.body.paragraphs << Builder.time_field(format: format)
        self
      end

      # Return the underlying DocumentRoot model
      #
      # @return [Wordprocessingml::DocumentRoot]
      def build
        @model
      end

      # Save document to file
      #
      # @param path [String] Output file path
      def save(path)
        @model.to_file(path)
      end
    end
  end
end
