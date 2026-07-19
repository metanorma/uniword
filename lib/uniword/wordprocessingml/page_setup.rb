# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Applies uniform page setup across every section of a document —
    # Word's Layout dialog as an API.
    #
    # Paper size (named presets), orientation (with dimension swap, like
    # Word), and margins (twips, or strings with in/cm/mm suffix).
    # Header/footer/gutter margins are left untouched.
    #
    # @example A4 landscape with 2 cm margins
    #   setup = PageSetup.new(size: "a4", orientation: "landscape",
    #                         margins: "2cm")
    #   setup.apply(document)
    #   setup.sections_updated # => 1
    class PageSetup
      # Named paper sizes in twips [width, height] (portrait).
      PAPER_SIZES = {
        "letter" => [12_240, 15_840],
        "legal" => [12_240, 20_160],
        "a4" => [11_906, 16_838],
        "a5" => [8_391, 11_906],
        "executive" => [10_440, 15_120],
      }.freeze

      TWIPS_PER_INCH = 1440
      TWIPS_PER_CM = 567
      TWIPS_PER_MM = 57

      ORIENTATIONS = %w[portrait landscape].freeze

      # @return [Integer] number of sections updated
      attr_reader :sections_updated

      # @param size [String, nil] Paper size name (see PAPER_SIZES)
      # @param orientation [String, nil] "portrait" or "landscape"
      # @param margins [Integer, String, nil] Uniform margin for all four
      #   sides (twips, or "1in" / "2.5cm" / "25mm")
      # @param side_margins [Hash] Per-side overrides
      #   (:top, :right, :bottom, :left)
      # @raise [ArgumentError] on unknown size, orientation, or margin
      def initialize(size: nil, orientation: nil, margins: nil,
                     **side_margins)
        @size = normalize_size(size)
        @orientation = normalize_orientation(orientation)
        @margins = side_margins.to_h do |side, value|
          [side, parse_margin(value)]
        end
        uniform = parse_margin(margins)
        %i[top right bottom left].each do |side|
          @margins[side] = uniform if @margins[side].nil?
        end
        @sections_updated = 0
      end

      # Apply the setup to every section in the document.
      #
      # @param document [DocumentRoot] Document to update (mutated)
      # @return [Integer] number of sections updated
      def apply(document)
        each_section_properties(document) do |sect_pr|
          apply_page_size(sect_pr) if @size || @orientation
          apply_margins(sect_pr)
          @sections_updated += 1
        end
        sections_updated
      end

      private

      def normalize_size(size)
        return nil if size.nil?

        dims = PAPER_SIZES[size.to_s.downcase]
        unless dims
          raise ArgumentError,
                "Unknown paper size '#{size}'. " \
                "Available: #{PAPER_SIZES.keys.join(', ')}"
        end

        dims
      end

      def normalize_orientation(orientation)
        return nil if orientation.nil?

        value = orientation.to_s.downcase
        return value if ORIENTATIONS.include?(value)

        raise ArgumentError,
              "Unknown orientation '#{orientation}'. " \
              "Available: #{ORIENTATIONS.join(', ')}"
      end

      # Parse a margin value: Integer (twips) or String with an
      # in/cm/mm/dxa suffix (bare numbers are inches).
      def parse_margin(value)
        case value
        when nil then nil
        when Numeric then value.round
        when /\A([\d.]+)\s*(in|cm|mm|dxa|twips?)?\z/i
          amount = Regexp.last_match(1).to_f
          unit = Regexp.last_match(2)&.downcase || "in"
          to_twips(amount, unit)
        else
          raise ArgumentError, "Invalid margin '#{value}' " \
                               "(use twips, or '1in' / '2.5cm' / '25mm')"
        end
      end

      def to_twips(amount, unit)
        factor = case unit
                 when "in" then TWIPS_PER_INCH
                 when "cm" then TWIPS_PER_CM
                 when "mm" then TWIPS_PER_MM
                 else 1
                 end
        (amount * factor).round
      end

      def each_section_properties(document, &block)
        body = document.body
        return unless body

        yield body.section_properties if body.section_properties
        each_paragraph_section(body, &block)
      end

      def each_paragraph_section(body)
        (body.paragraphs || []).each do |paragraph|
          sect_pr = paragraph.properties&.section_properties
          yield sect_pr if sect_pr
        end
      end

      def apply_page_size(sect_pr)
        width, height = target_dimensions(sect_pr)

        sect_pr.page_size ||= PageSize.new
        sect_pr.page_size.width = width
        sect_pr.page_size.height = height
        sect_pr.page_size.orientation = @orientation if @orientation
      end

      def target_dimensions(sect_pr)
        width, height = current_dimensions(sect_pr)
        width, height = @size if @size
        width, height = orient(width, height) if @orientation
        [width, height]
      end

      def current_dimensions(sect_pr)
        size = sect_pr.page_size
        [size&.width || PageDefaults.default_page_size.width,
         size&.height || PageDefaults.default_page_size.height]
      end

      # Word swaps width/height when flipping orientation.
      def orient(width, height)
        if (@orientation == "landscape" && width < height) ||
            (@orientation == "portrait" && width > height)
          [height, width]
        else
          [width, height]
        end
      end

      def apply_margins(sect_pr)
        return if @margins.values.all?(&:nil?)

        sect_pr.page_margins ||= PageMargins.new
        @margins.each do |side, value|
          next if value.nil?

          sect_pr.page_margins.method(:"#{side}=").call(value)
        end
      end
    end
  end
end
