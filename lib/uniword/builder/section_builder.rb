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

      def page_size(width: 12_240, height: 15_840, orientation: "portrait")
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

      def columns(count: 1, spacing: 720)
        @model.columns ||= Wordprocessingml::Columns.new
        @model.columns.num = count
        @model.columns.space = spacing
        self
      end

      private

      def ensure_section_defaults
        page_size
        margins
        columns
        @model.doc_grid ||= Wordprocessingml::DocGrid.new(line_pitch: 360)
      end
    end
  end
end
