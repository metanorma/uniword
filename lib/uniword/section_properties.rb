# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents section properties
  # Includes page setup, headers, footers, and other section-level formatting
  class SectionProperties < Lutaml::Model::Serializable
    # Page size (width x height in twips)
    attribute :page_width, :integer
    attribute :page_height, :integer

    # Page margins (in twips)
    attribute :margin_top, :integer
    attribute :margin_bottom, :integer
    attribute :margin_left, :integer
    attribute :margin_right, :integer
    attribute :margin_header, :integer
    attribute :margin_footer, :integer

    # Page orientation
    attribute :orientation, :string, default: -> { "portrait" }

    # Title page (different first page header/footer)
    attribute :title_page, :boolean, default: -> { false }

    # Different odd and even pages
    attribute :different_odd_and_even_pages, :boolean, default: -> { false }

    # Page numbering
    attribute :page_number_format, :string
    attribute :page_number_start, :integer

    # Section type (continuous, nextPage, nextColumn, evenPage, oddPage)
    attribute :section_type, :string, default: -> { "nextPage" }

    # Header/footer references (relationship IDs)
    attribute :header_default_rel_id, :string
    attribute :header_first_rel_id, :string
    attribute :header_even_rel_id, :string
    attribute :footer_default_rel_id, :string
    attribute :footer_first_rel_id, :string
    attribute :footer_even_rel_id, :string

    # Page borders
    attribute :page_borders, PageBorders

    # Column configuration
    attribute :columns, ColumnConfiguration

    # Line numbering
    attribute :line_numbering, LineNumbering

    # Page size presets (width x height in twips)
    PAGE_SIZES = {
      letter: [12_240, 15_840], # 8.5" x 11"
      a4: [11_906, 16_838],        # 210mm x 297mm
      a3: [16_838, 23_811],        # 297mm x 420mm
      legal: [12_240, 20_160],     # 8.5" x 14"
      tabloid: [15_840, 24_480],   # 11" x 17"
      a5: [8391, 11_906], # 148mm x 210mm
    }.freeze

    # Valid orientations
    ORIENTATIONS = %w[portrait landscape].freeze

    # Valid section types
    SECTION_TYPES = %w[continuous nextPage nextColumn evenPage oddPage].freeze

    def initialize(**attributes)
      super
      validate_orientation
      validate_section_type
    end

    # Set A4 page size (portrait)
    def self.a4_portrait
      new(
        page_width: 11_906,  # 210mm in twips
        page_height: 16_838, # 297mm in twips
        orientation: "portrait",
      )
    end

    # Set A4 page size (landscape)
    def self.a4_landscape
      new(
        page_width: 16_838,  # 297mm in twips
        page_height: 11_906, # 210mm in twips
        orientation: "landscape",
      )
    end

    # Set Letter page size (portrait)
    def self.letter_portrait
      new(
        page_width: 12_240,  # 8.5in in twips
        page_height: 15_840, # 11in in twips
        orientation: "portrait",
      )
    end

    # Set Letter page size (landscape)
    def self.letter_landscape
      new(
        page_width: 15_840,  # 11in in twips
        page_height: 12_240, # 8.5in in twips
        orientation: "landscape",
      )
    end

    # Set page size by name
    #
    # @param name [Symbol] Page size name (:letter, :a4, etc.)
    # @param orientation [Symbol] Orientation (:portrait or :landscape)
    # @return [void]
    def set_page_size(name, orientation: :portrait)
      unless PAGE_SIZES.key?(name)
        raise ArgumentError,
              "Unknown page size: #{name}. Available: #{PAGE_SIZES.keys.join(', ')}"
      end

      width, height = PAGE_SIZES[name]
      if orientation == :landscape
        self.page_width = height
        self.page_height = width
        self.orientation = "landscape"
      else
        self.page_width = width
        self.page_height = height
        self.orientation = "portrait"
      end
    end

    # Set multi-column layout
    #
    # @param count [Integer] Number of columns
    # @param space [Integer] Space between columns
    # @param separator [Boolean] Show separator line
    # @return [void]
    def set_columns(count, space: 720, separator: false)
      self.columns = ColumnConfiguration.equal(count, space: space,
                                                      separator: separator)
    end

    # Enable line numbering
    #
    # @param start [Integer] Starting line number
    # @param count_by [Integer] Increment
    # @param restart [String] When to restart (continuous, newPage, newSection)
    # @param distance [Integer] Distance from text
    # @return [void]
    def enable_line_numbering(start: 1, count_by: 1, restart: "newPage",
distance: 360)
      self.line_numbering = LineNumbering.new(
        start: start,
        count_by: count_by,
        restart: restart,
        distance: distance,
      )
    end

    # Page size preset accessor
    attr_accessor :page_size

    private

    def validate_orientation
      return unless orientation && !ORIENTATIONS.include?(orientation)

      raise ArgumentError,
            "Invalid orientation: #{orientation}. Must be one of: #{ORIENTATIONS.join(', ')}"
    end

    def validate_section_type
      return unless section_type && !SECTION_TYPES.include?(section_type)

      raise ArgumentError,
            "Invalid section type: #{section_type}. Must be one of: #{SECTION_TYPES.join(', ')}"
    end
  end
end
