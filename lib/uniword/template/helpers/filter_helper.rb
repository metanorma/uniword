# frozen_string_literal: true

module Uniword
  module Template
    module Helpers
      # Helper for applying filters to template values.
      #
      # Supports value transformations:
      # - format: Date/time formatting
      # - upcase: Uppercase text
      # - downcase: Lowercase text
      # - titleize: Title case text
      # - capitalize: Capitalize first letter
      # - currency: Format as currency
      #
      # Syntax: {{variable | filter}} or {{variable | filter: arg}}
      #
      # Responsibility: Filter application only
      # Single Responsibility Principle: Does NOT parse or render
      #
      # @example Apply filters
      #   helper = FilterHelper.new
      #   result = helper.apply("hello", "upcase") # => "HELLO"
      #   result = helper.apply(date, "format", "%Y-%m-%d")
      class FilterHelper
        # Apply filter to value
        #
        # @param value [Object] Value to filter
        # @param filter_name [String] Filter name
        # @param args [Array] Filter arguments
        # @return [Object] Filtered value
        def apply(value, filter_name, *args)
          case filter_name.to_s
          when 'format'
            apply_format(value, args.first || '%Y-%m-%d')
          when 'upcase'
            value.to_s.upcase
          when 'downcase'
            value.to_s.downcase
          when 'titleize'
            titleize(value.to_s)
          when 'capitalize'
            value.to_s.capitalize
          when 'currency'
            apply_currency(value, args.first || 'USD')
          when 'number'
            apply_number_format(value, args.first)
          when 'truncate'
            truncate(value.to_s, args.first&.to_i || 30)
          when 'strip'
            value.to_s.strip
          when 'reverse'
            value.to_s.reverse
          else
            # Unknown filter - return value unchanged
            value
          end
        end

        private

        # Apply date/time formatting
        #
        # @param value [Object] Value to format
        # @param format_string [String] Format string
        # @return [String] Formatted value
        def apply_format(value, format_string)
          if value.respond_to?(:strftime)
            value.strftime(format_string)
          else
            value.to_s
          end
        rescue StandardError
          value.to_s
        end

        # Apply currency formatting
        #
        # @param value [Object] Numeric value
        # @param currency [String] Currency code
        # @return [String] Formatted currency
        def apply_currency(value, currency)
          num = value.to_f
          formatted = format('%.2f', num)
          "#{currency} #{formatted}"
        rescue StandardError
          value.to_s
        end

        # Apply number formatting
        #
        # @param value [Object] Numeric value
        # @param precision [String, Integer] Decimal precision
        # @return [String] Formatted number
        def apply_number_format(value, precision)
          num = value.to_f
          prec = precision ? precision.to_i : 2
          format("%.#{prec}f", num)
        rescue StandardError
          value.to_s
        end

        # Convert to title case
        #
        # @param text [String] Text to convert
        # @return [String] Title case text
        def titleize(text)
          text.split(/\s+/).map(&:capitalize).join(' ')
        end

        # Truncate text to length
        #
        # @param text [String] Text to truncate
        # @param length [Integer] Maximum length
        # @return [String] Truncated text
        def truncate(text, length)
          return text if text.length <= length

          "#{text[0...length]}..."
        end
      end
    end
  end
end
