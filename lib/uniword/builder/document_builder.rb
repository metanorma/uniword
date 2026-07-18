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
    class DocumentBuilder < BaseBuilder
      attr_reader :allocator

      def self.default_model_class
        Wordprocessingml::DocumentRoot
      end

      def initialize(model = nil, allocator: nil)
        super(model)
        @allocator = allocator
        @model.allocator = allocator if allocator
        @footnote_builder = FootnoteBuilder.new(self, allocator: @allocator)
      end

      # Load a document from file for manipulation
      #
      # @param path [String] Path to .docx file
      # @return [DocumentBuilder]
      def self.from_file(path)
        new(Uniword.load(path))
      end

      # Load a DOCX as a template, reset its body to a clean state, and
      # seed the IdAllocator from the template's existing relationships.
      #
      # Use this when you want the template's OOXML scaffolding (settings,
      # fonts, styles, theme, content_types, namespace declarations) but
      # will replace the document body with new content. This is the
      # recommended path to producing Word-valid output: starting from a
      # known-good DOCX preserves mc:Ignorable prefixes, rsid values, and
      # other structural guarantees that Word expects.
      #
      # Resets performed:
      # - Body content cleared (paragraphs, tables, SDTs, bookmarks,
      #   element_order, section_properties)
      # - User footnotes/endnotes cleared (separator/continuation kept)
      # - custom_properties and custom_xml_items cleared
      # - Stale image and customXml relationships removed
      # - IdAllocator seeded from document_rels and package_rels
      #
      # @param path [String] Path to .docx template file
      # @return [DocumentBuilder]
      # @raise [ArgumentError] if path does not exist
      def self.from_template(path)
        raise ArgumentError, "Template not found: #{path}" unless File.exist?(path)

        root = Uniword.load(path)
        reset_template_body(root)
        clear_user_notes(root)
        root.custom_properties = nil
        root.custom_xml_items = nil
        remove_stale_relationships(root)
        seed_allocator(root)
        new(root, allocator: root.allocator)
      end

      def self.reset_template_body(root)
        return unless root.body

        root.body.paragraphs.clear
        root.body.tables.clear
        root.body.structured_document_tags.clear
        root.body.bookmark_starts.clear
        root.body.bookmark_ends.clear
        root.body.element_order = [] if root.body.element_order
        root.body.section_properties = nil
      end
      private_class_method :reset_template_body

      def self.clear_user_notes(root)
        clear_user_note_entries(root.footnotes, :footnote) if root.footnotes
        clear_user_note_entries(root.endnotes, :endnote) if root.endnotes
      end
      private_class_method :clear_user_notes

      def self.clear_user_note_entries(notes, kind)
        entries = kind == :footnote ? notes.footnote_entries : notes.endnote_entries
        entries.reject! { |e| e.type != "separator" && e.type != "continuationSeparator" }
        notes.element_order = [] if notes.element_order
      end
      private_class_method :clear_user_note_entries

      def self.remove_stale_relationships(root)
        remove_rels_by_type_fragment(root.document_rels, "/image")
        remove_rels_by_type_fragment(root.document_rels, "/customXml")
        remove_rels_by_type_fragment(root.package_rels, "custom-properties")
        root.content_types&.overrides&.reject! do |o|
          part = o.part_name.to_s
          part == "/docProps/custom.xml" || part.include?("customXml/")
        end
        root.image_parts = nil
      end
      private_class_method :remove_stale_relationships

      def self.remove_rels_by_type_fragment(rels, fragment)
        return unless rels&.relationships

        rels.relationships.reject! { |r| r.type.to_s.include?(fragment) }
      end
      private_class_method :remove_rels_by_type_fragment

      def self.seed_allocator(root)
        root.allocator = Docx::IdAllocator.populate_from_package(root)
      end
      private_class_method :seed_allocator

      # Append a top-level element (paragraph or table)
      #
      # @param element [Paragraph, Table, ParagraphBuilder, TableBuilder]
      # @return [self]
      def <<(element)
        case element
        when Wordprocessingml::Paragraph
          @model.body.paragraphs << element
          @model.body.append_to_element_order("p")
        when Wordprocessingml::Table
          @model.body.tables << element
          @model.body.append_to_element_order("tbl")
        when ParagraphBuilder
          @model.body.paragraphs << element.build
          @model.body.append_to_element_order("p")
        when TableBuilder
          @model.body.tables << element.build
          @model.body.append_to_element_order("tbl")
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
        para = ParagraphBuilder.new(allocator: @allocator)
        para << text if text
        block.call(para) if block_given?
        self << para
        para
      end

      # Create and add a heading paragraph
      #
      # @param text [String] Heading text
      # @param level [Integer] Heading level (1-9, default 1)
      # @yield [ParagraphBuilder] Builder for additional configuration
      # @return [ParagraphBuilder] The paragraph builder
      def heading(text, level: 1)
        para = ParagraphBuilder.new(allocator: @allocator)
        para.style = "Heading#{level}"
        para << text
        self << para
        para
      end

      # Insert a page break
      #
      # @return [self]
      def page_break
        self << Wordprocessingml::Paragraph.new(
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
        self << tbl
        tbl
      end

      # Configure section properties
      #
      # @param type [String] Section break type ('nextPage', 'continuous', 'evenPage', 'oddPage')
      # @yield [SectionBuilder] Builder for section configuration
      # @return [SectionBuilder] The section builder
      def section(type: "nextPage", &block)
        sec = SectionBuilder.new
        sec.type = type
        block.call(sec) if block_given?
        @model.body.section_properties ||= sec.build
        # Register section-level headers/footers so their sectPr
        # references resolve to real parts at save time.
        sec.header_models.each { |t, hf| (@model.headers ||= {})[t] = hf }
        sec.footer_models.each { |t, hf| (@model.footers ||= {})[t] = hf }
        sec
      end

      # Configure a header
      #
      # @param type [String] Header type ('default', 'first', 'even')
      # @yield [HeaderFooterBuilder] Builder for header content
      # @return [HeaderFooterBuilder] The header/footer builder
      def header(type: "default", &block)
        hf = HeaderFooterBuilder.new(:header, type: type, allocator: @allocator)
        block.call(hf) if block_given?
        (@model.headers ||= {})[type] = hf.build
        hf
      end

      # Configure a footer
      #
      # @param type [String] Footer type ('default', 'first', 'even')
      # @yield [HeaderFooterBuilder] Builder for footer content
      # @return [HeaderFooterBuilder] The header/footer builder
      def footer(type: "default", &block)
        hf = HeaderFooterBuilder.new(:footer, type: type, allocator: @allocator)
        block.call(hf) if block_given?
        (@model.footers ||= {})[type] = hf.build
        hf
      end

      # Insert a Table of Contents
      #
      # @param title [String] TOC title (default 'Table of Contents')
      # @param styles [Array<String>, nil] Heading styles to include
      # @return [self]
      def toc(title: "Table of Contents", styles: nil)
        TocBuilder.build(title: title, styles: styles).each do |para|
          self << para
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
        id = @allocator ? @allocator.alloc_bookmark_id : begin
          @bookmark_counter ||= 0
          @bookmark_counter += 1
          @bookmark_counter.to_s
        end

        para = ParagraphBuilder.new(allocator: @allocator)
        para << Wordprocessingml::BookmarkStart.new(id: id, name: name)
        block.call(para) if block_given?
        para << Wordprocessingml::BookmarkEnd.new(id: id)
        self << para
        para
      end

      # Create a footnote and return a Run with a footnoteReference.
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
      def define_style(name, base_on: "Normal", &block)
        style = StyleBuilder.new(name, base_on: base_on)
        block.call(style) if block_given?
        @model.styles_configuration.add_style(style.build)
        style
      end

      def title(value)
        @model.core_properties.title = value
        self
      end

      def author(value)
        @model.core_properties.creator = value
        self
      end

      def description(value)
        @model.core_properties.description = value
        self
      end

      def subject(value)
        @model.core_properties.subject = value
        self
      end

      def keywords(value)
        @model.core_properties.keywords = value
        self
      end

      def created(value)
        @model.core_properties.created = value
        self
      end

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
      def horizontal_rule(style: "single", color: "auto", size: 6)
        para = ParagraphBuilder.new(allocator: @allocator)
        para.borders(
          bottom: { style: style, color: color, size: size }
        )
        para.spacing(after: 0)
        self << para
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
        self << para
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
        self << para
        self
      end

      # Add a watermark to the document header
      #
      # @param text [String, nil] Watermark text (nil to clear)
      # @param font [String] Font name (default 'Calibri')
      # @param size [Integer] Font size in points (default 60)
      # @param color [String] Fill color hex (default 'D0D0D0')
      # @param opacity [String] Opacity '0.0' to '1.0' (default '0.3')
      # @param angle [Integer] Rotation angle in degrees (default -45)
      # @return [self]
      def watermark(text, font: "Calibri", size: 60, color: nil,
                    opacity: "0.3", angle: -45)
        if text.nil?
          (@model.headers ||= {}).delete("default")
          return self
        end

        para = WatermarkBuilder.build_paragraph(
          text, font: font, size: size, color: color,
                opacity: opacity, angle: angle
        )

        header = Wordprocessingml::Header.new
        header.paragraphs << para
        (@model.headers ||= {})["default"] = header
        self
      end

      # Create a comment and store it in the document's comments collection.
      #
      # @param author [String] Comment author name
      # @param text [String, nil] Comment text
      # @param initials [String, nil] Author initials
      # @yield [CommentBuilder] Builder for rich comment content
      # @return [Comment] The created Comment model
      def comment(author:, text: nil, initials: nil, &block)
        comment_id = @allocator ? @allocator.alloc_comment_id : begin
          @comment_counter ||= 0
          @comment_counter += 1
          @comment_counter.to_s
        end
        cb = CommentBuilder.new(
          author: author,
          comment_id: comment_id,
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
      def bibliography(style: "APA", &block)
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
        self << para
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
        self << para
        cb
      end

      # Insert a page number paragraph
      #
      # @return [self]
      def page_number
        self << Builder.page_number_field
        self
      end

      # Insert a total pages paragraph
      #
      # @return [self]
      def total_pages
        self << Builder.total_pages_field
        self
      end

      # Insert a date paragraph
      #
      # @param format [String] Date format (default 'M/d/yyyy')
      # @return [self]
      def date_field(format: "M/d/yyyy")
        self << Builder.date_field(format: format)
        self
      end

      # Insert a time paragraph
      #
      # @param format [String] Time format (default 'h:mm:ss am/pm')
      # @return [self]
      def time_field(format: "h:mm:ss am/pm")
        self << Builder.time_field(format: format)
        self
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
