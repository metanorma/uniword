# frozen_string_literal: true

require_relative '../quality_rule'

module Uniword
  module Quality
    # Checks that headings follow proper hierarchical structure.
    #
    # Responsibility: Validate heading level sequence and hierarchy.
    # Single Responsibility - only checks heading hierarchy.
    #
    # Validates:
    # - Headings don't skip levels (e.g., H1 -> H3)
    # - Heading levels don't exceed maximum
    # - Document structure follows logical hierarchy
    #
    # @example Configuration
    #   heading_hierarchy:
    #     enabled: true
    #     max_level: 6
    #     require_sequential: true
    class HeadingHierarchyRule < QualityRule
      HEADING_PATTERN = /^heading\s*(\d+)$/i

      def initialize(config = {})
        super
        @max_level = @config[:max_level] || 6
        @require_sequential = @config.fetch(:require_sequential, true)
      end

      # Check document for heading hierarchy violations
      #
      # @param document [Document] The document to check
      # @return [Array<QualityViolation>] List of violations found
      def check(document)
        violations = []
        previous_level = 0

        document.paragraphs.each_with_index do |para, index|
          heading_level = extract_heading_level(para)
          next unless heading_level

          # Check max level
          if heading_level > @max_level
            violations << create_violation(
              severity: :error,
              message: "Heading level #{heading_level} exceeds maximum allowed level #{@max_level}",
              location: "Paragraph #{index + 1}",
              element: para
            )
          end

          # Check sequential hierarchy
          if @require_sequential && previous_level > 0
            if heading_level > previous_level + 1
              violations << create_violation(
                severity: :warning,
                message: "Heading level skips from #{previous_level} to #{heading_level} " \
                         "(expected #{previous_level + 1} or less)",
                location: "Paragraph #{index + 1}",
                element: para
              )
            end
          end

          previous_level = heading_level
        end

        violations
      end

      private

      # Extract heading level from paragraph style
      #
      # @param paragraph [Paragraph] The paragraph to check
      # @return [Integer, nil] Heading level (1-9) or nil if not a heading
      def extract_heading_level(paragraph)
        return nil unless paragraph.style

        style_name = paragraph.style.to_s
        match = style_name.match(HEADING_PATTERN)
        match ? match[1].to_i : nil
      end
    end
  end
end