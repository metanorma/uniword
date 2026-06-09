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
    class SectionBuilder < BaseBuilder
      def self.default_model_class
        Wordprocessingml::SectionProperties
      end

      def initialize(model = nil)
        super
        ensure_section_defaults
      end

      def type=(value)
        @model.type = value
        self
      end

      def page_size(width: Wordprocessingml::PageDefaults::LETTER_WIDTH,
                     height: Wordprocessingml::PageDefaults::LETTER_HEIGHT,
                     orientation: "portrait")
        @model.page_size ||= Wordprocessingml::PageSize.new
        @model.page_size.width = width
        @model.page_size.height = height
        @model.page_size.orientation = orientation
        self
      end

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

      def page_numbering(start: nil, format: nil)
        @model.page_numbering ||= Wordprocessingml::PageNumbering.new
        @model.page_numbering.start = start if start
        @model.page_numbering.format = format if format
        self
      end

      def columns(count: 1, spacing: 720)
        @model.columns ||= Wordprocessingml::Columns.new
        @model.columns.num = count
        @model.columns.space = spacing
        self
      end

      def header(type: "default", &block)
        hf = HeaderFooterBuilder.new(:header, type: type)
        block&.call(hf)
        ref = Wordprocessingml::HeaderReference.new(
          type: type, r_id: "rIdHdr#{type}",
        )
        @model.header_references << ref
        @header_builders ||= {}
        @header_builders[type] = hf
        hf
      end

      def footer(type: "default", &block)
        hf = HeaderFooterBuilder.new(:footer, type: type)
        block&.call(hf)
        ref = Wordprocessingml::FooterReference.new(
          type: type, r_id: "rIdFtr#{type}",
        )
        @model.footer_references << ref
        @footer_builders ||= {}
        @footer_builders[type] = hf
        hf
      end

      # Built header content models keyed by type.
      def header_models
        (@header_builders || {}).transform_values(&:build)
      end

      # Built footer content models keyed by type.
      def footer_models
        (@footer_builders || {}).transform_values(&:build)
      end

      private

      def ensure_section_defaults
        page_size
        margins
        columns
        @model.doc_grid ||= Wordprocessingml::PageDefaults.default_doc_grid
      end
    end
  end
end
