# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures SectionProperties objects.
    #
    # @example Configure page setup
    #   doc.section do |s|
    #     s.page_size(width: 12240, height: 15840)
    #     s.margins(top: 1440, bottom: 1440, left: 1440, right: 1440)
    #   end
    #
    # @example Configure section with page numbering
    #   doc.section(type: 'nextPage') do |s|
    #     s.page_size(orientation: 'landscape')
    #     s.page_numbering(start: 1, format: 'lowerRoman')
    #     s.margins(top: 720, bottom: 720)
    #   end
    class SectionBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::SectionProperties.new
      end

      # Wrap an existing SectionProperties model
      def self.from_model(model)
        new(model)
      end

      # Set section break type
      #
      # @param value [String] 'nextPage', 'continuous', 'evenPage', 'oddPage'
      # @return [self]
      def type=(value)
        @model.type = value
        self
      end

      # Set page size
      #
      # @param width [Integer] Page width in twips (default US Letter: 12240)
      # @param height [Integer] Page height in twips (default US Letter: 15840)
      # @param orientation [String] 'portrait' or 'landscape'
      # @return [self]
      def page_size(width: 12240, height: 15840, orientation: 'portrait')
        @model.page_size ||= Wordprocessingml::PageSize.new
        @model.page_size.width = width
        @model.page_size.height = height
        @model.page_size.orientation = orientation
        self
      end

      # Set page margins
      #
      # @param top [Integer] Top margin in twips (default 1440 = 1 inch)
      # @param bottom [Integer] Bottom margin in twips
      # @param left [Integer] Left margin in twips
      # @param right [Integer] Right margin in twips
      # @param header [Integer] Header distance from edge in twips
      # @param footer [Integer] Footer distance from edge in twips
      # @param gutter [Integer] Gutter margin in twips
      # @return [self]
      def margins(top: 1440, bottom: 1440, left: 1440, right: 1440,
                  header: 720, footer: 720, gutter: 0)
        @model.page_margins ||= Wordprocessingml::PageMargins.new
        @model.page_margins.top = top
        @model.page_margins.bottom = bottom
        @model.page_margins.left = left
        @model.page_margins.right = right
        @model.page_margins.header = header
        @model.page_margins.footer = footer
        @model.page_margins.gutter = gutter
        self
      end

      # Set number of columns
      #
      # @param count [Integer] Number of columns
      # @param spacing [Integer] Space between columns in twips
      # @return [self]
      def columns(count: 1, spacing: 720)
        @model.columns ||= Wordprocessingml::Columns.new
        @model.columns.num = count
        @model.columns.space = spacing
        self
      end

      # Set page borders
      #
      # @param options [Hash] Border options
      # @return [self]
      def page_borders(**options)
        @model.page_borders ||= Wordprocessingml::PageBorders.new
        self
      end

      # Set line numbering
      #
      # @param count_by [Integer] Line numbering interval
      # @param start [Integer] Starting line number
      # @param restart [String] Restart setting ('continuous', 'newPage', 'newSection')
      # @return [self]
      def line_numbering(count_by: 1, start: 1, restart: 'continuous')
        @model.line_numbering ||= Wordprocessingml::LineNumbering.new
        @model.line_numbering.count_by = count_by
        @model.line_numbering.start = start
        @model.line_numbering.restart = restart
        self
      end

      # Set page numbering for this section
      #
      # @param start [Integer, nil] Starting page number
      # @param format [String, nil] Number format ('decimal', 'lowerRoman', 'upperRoman')
      # @return [self]
      def page_numbering(start: nil, format: nil)
        @model.page_numbering ||= Wordprocessingml::PageNumbering.new
        @model.page_numbering.start = start if start
        @model.page_numbering.format = format if format
        self
      end

      # Configure a header for this section
      #
      # Creates a HeaderReference attached to the section properties.
      # The header content is built using a HeaderFooterBuilder.
      #
      # @param type [String] Header type ('default', 'first', 'even')
      # @yield [HeaderFooterBuilder] Builder for header content
      # @return [HeaderFooterBuilder] The header/footer builder
      def header(type: 'default', &block)
        hf = HeaderFooterBuilder.new(:header, type: type)
        block.call(hf) if block_given?

        ref = Wordprocessingml::HeaderReference.new(
          type: type, r_id: "rIdHdr#{type}"
        )
        @model.header_references << ref
        hf
      end

      # Configure a footer for this section
      #
      # Creates a FooterReference attached to the section properties.
      # The footer content is built using a HeaderFooterBuilder.
      #
      # @param type [String] Footer type ('default', 'first', 'even')
      # @yield [HeaderFooterBuilder] Builder for footer content
      # @return [HeaderFooterBuilder] The header/footer builder
      def footer(type: 'default', &block)
        hf = HeaderFooterBuilder.new(:footer, type: type)
        block.call(hf) if block_given?

        ref = Wordprocessingml::FooterReference.new(
          type: type, r_id: "rIdFtr#{type}"
        )
        @model.footer_references << ref
        hf
      end

      # Return the underlying SectionProperties model
      #
      # @return [Wordprocessingml::SectionProperties]
      def build
        @model
      end
    end
  end
end
