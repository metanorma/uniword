# frozen_string_literal: true

module Uniword
  module Quality
    # Checks that images have accessibility text.
    #
    # Responsibility: Validate image accessibility.
    # Single Responsibility - only checks image alt text.
    #
    # Validates:
    # - Images have alt text
    # - Alt text meets minimum length requirements
    # - Document is accessible for screen readers
    #
    # @example Configuration
    #   image_alt_text:
    #     enabled: true
    #     require_alt_text: true
    #     min_length: 10
    class ImageAltTextRule < QualityRule
      def initialize(config = {})
        super
        @require_alt_text = @config.fetch(:require_alt_text, true)
        @min_length = @config[:min_length] || 10
      end

      # Check document for image alt text violations
      #
      # @param document [Document] The document to check
      # @return [Array<QualityViolation>] List of violations found
      def check(document)
        violations = []

        return violations unless @require_alt_text

        # Same drawings the accessibility rule and the renderer see, table
        # cells included, read through the same Drawing#alt_text.
        document.images.each_with_index do |drawing, index|
          image_count = index + 1
          alt_text = drawing.alt_text

          if alt_text.nil?
            violations << create_violation(
              severity: :error,
              message: "Image #{image_count} is missing alt text. " \
                       "Alt text is required for accessibility.",
              location: "Image #{image_count}",
              element: drawing,
            )
          elsif alt_text.length < @min_length
            violations << create_violation(
              severity: :warning,
              message: "Image #{image_count} has alt text that is too short " \
                       "(#{alt_text.length} characters, minimum: #{@min_length}). " \
                       "Provide more descriptive alt text.",
              location: "Image #{image_count}",
              element: drawing,
            )
          end
        end

        violations
      end
    end
  end
end
