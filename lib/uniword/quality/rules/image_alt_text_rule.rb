# frozen_string_literal: true

require_relative '../quality_rule'

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

        image_count = 0
        document.paragraphs.each_with_index do |para, para_index|
          para.images.each do |image|
            image_count += 1

            alt_text = extract_alt_text(image)

            if alt_text.nil? || alt_text.empty?
              violations << create_violation(
                severity: :error,
                message: "Image #{image_count} is missing alt text. " \
                         "Alt text is required for accessibility.",
                location: "Paragraph #{para_index + 1}, Image #{image_count}",
                element: image
              )
            elsif alt_text.length < @min_length
              violations << create_violation(
                severity: :warning,
                message: "Image #{image_count} has alt text that is too short " \
                         "(#{alt_text.length} characters, minimum: #{@min_length}). " \
                         "Provide more descriptive alt text.",
                location: "Paragraph #{para_index + 1}, Image #{image_count}",
                element: image
              )
            end
          end
        end

        violations
      end

      private

      # Extract alt text from image
      #
      # @param image [Image] The image to extract alt text from
      # @return [String, nil] Alt text or nil if not present
      def extract_alt_text(image)
        # Images may have alt_text or title properties
        image.respond_to?(:alt_text) ? image.alt_text : nil
      end
    end
  end
end