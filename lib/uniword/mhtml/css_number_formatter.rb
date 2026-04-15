# frozen_string_literal: true

module Uniword
  module Mhtml
    # Formats CSS numeric values for Word-compatible MHTML.
    #
    # Responsibility: Provide consistent CSS number formatting with proper
    # units, precision, and handling of edge cases like zero values.
    #
    # @example Format a font size
    #   CssNumberFormatter.format(16, 'pt')  # => "16pt"
    #
    # @example Format a margin with precision
    #   CssNumberFormatter.format(1.5, 'pt')  # => "1.5pt"
    #
    # @example Format zero value
    #   CssNumberFormatter.format(0, 'px')  # => "0"
    class CssNumberFormatter
      # Default decimal precision for CSS values
      DEFAULT_PRECISION = 2

      # Units that should be omitted for zero values
      OMIT_UNIT_FOR_ZERO = %w[px pt em rem % cm mm in].freeze

      # Convert twips to points (1pt = 20 twips)
      TWIPS_PER_POINT = 20

      # Format a CSS number value with appropriate unit and precision.
      #
      # @param value [Numeric, nil] The numeric value
      # @param unit [String] The CSS unit (pt, px, em, %, in, cm, mm)
      # @param precision [Integer] Decimal places (default: 2)
      # @return [String, nil] Formatted CSS value or nil if value is nil
      #
      # @example Format with default precision
      #   format(12.5, 'pt')  # => "12.5pt"
      #
      # @example Format zero value
      #   format(0, 'px')  # => "0"
      #
      # @example Format with custom precision
      #   format(1.23456, 'em', 3)  # => "1.235em"
      def self.format(value, unit, precision: DEFAULT_PRECISION)
        return nil if value.nil?

        # Convert to float
        numeric_value = value.to_f

        # Handle zero specially - omit unit
        return "0" if numeric_value.zero? && OMIT_UNIT_FOR_ZERO.include?(unit)

        # Round to specified precision
        rounded = numeric_value.round(precision)

        # Format and remove unnecessary trailing zeros
        formatted = if rounded == rounded.to_i
                      rounded.to_i.to_s
                    else
                      # Format with precision, then remove trailing zeros
                      Kernel.format("%.#{precision}f", rounded).sub(/\.?0+$/, "")
                    end

        "#{formatted}#{unit}"
      end

      # Convert twips to points and format.
      #
      # @param twips [Numeric, nil] Value in twips
      # @param precision [Integer] Decimal places (default: 2)
      # @return [String, nil] Formatted value in points
      #
      # @example Convert 1440 twips to inches
      #   twips_to_pt(1440)  # => "72pt"
      def self.twips_to_pt(twips, precision: DEFAULT_PRECISION)
        return nil if twips.nil?

        points = twips.to_f / TWIPS_PER_POINT
        format(points, "pt", precision: precision)
      end

      # Convert twips to inches and format.
      #
      # @param twips [Numeric, nil] Value in twips
      # @param precision [Integer] Decimal places (default: 2)
      # @return [String, nil] Formatted value in inches
      #
      # @example Convert 1440 twips to inches
      #   twips_to_in(1440)  # => "1in"
      def self.twips_to_in(twips, precision: DEFAULT_PRECISION)
        return nil if twips.nil?

        # 1 inch = 1440 twips
        inches = twips.to_f / 1440.0
        format(inches, "in", precision: precision)
      end

      # Format a font size value (typically in half-points).
      #
      # @param half_points [Numeric, nil] Font size in half-points
      # @param precision [Integer] Decimal places (default: 1)
      # @return [String, nil] Formatted font size
      #
      # @example Format font size
      #   format_font_size(24)  # => "12pt"
      def self.format_font_size(half_points, precision: 1)
        return nil if half_points.nil?

        points = half_points.to_f / 2.0
        format(points, "pt", precision: precision)
      end

      # Format percentage value.
      #
      # @param value [Numeric, nil] Percentage value (0-100)
      # @param precision [Integer] Decimal places (default: 0)
      # @return [String, nil] Formatted percentage
      #
      # @example Format percentage
      #   format_percentage(50)  # => "50%"
      def self.format_percentage(value, precision: 0)
        return nil if value.nil?

        format(value, "%", precision: precision)
      end
    end
  end
end
