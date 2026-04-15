# frozen_string_literal: true

module Uniword
  module Accessibility
    module Rules
      # Heading Structure Rule - WCAG 1.3.1 Info and Relationships
      #
      # Responsibility: Check proper heading hierarchy
      # Single Responsibility: Heading structure validation only
      #
      # WCAG 1.3.1 Level A: Headings must follow proper hierarchy
      class HeadingStructureRule < AccessibilityRule
        # Check document heading structure
        #
        # @param document [Document] Document to check
        # @return [Array<AccessibilityViolation>] Found violations
        def check(document)
          violations = []
          headings = extract_headings(document)

          # Check if document needs headings but has none
          if headings.empty? && requires_headings?(document)
            violations << create_violation(
              message: "Document lacks heading structure (#{document.paragraphs.count} paragraphs without headings)",
              element: document,
              severity: :warning,
              suggestion: @config[:suggestion] ||
                "Add headings to structure the content for screen readers"
            )
            return violations
          end

          # Check heading hierarchy
          violations.concat(check_hierarchy(headings)) if @config[:check_hierarchy]

          # Check for H1 requirement
          if @config[:require_h1] && !has_h1?(headings)
            violations << create_violation(
              message: "Document missing top-level heading (H1)",
              element: document,
              severity: :error,
              suggestion: "Start document with a level 1 heading (H1)"
            )
          end

          violations
        end

        private

        # Extract headings from document
        #
        # @param document [Document] Document to extract from
        # @return [Array<Hash>] Headings with level and paragraph
        def extract_headings(document)
          document.paragraphs
                  .select { |p| heading_paragraph?(p) }
                  .map { |p| { level: extract_heading_level(p), paragraph: p } }
        end

        # Check if paragraph is a heading
        #
        # @param paragraph [Paragraph] Paragraph to check
        # @return [Boolean] True if heading
        def heading_paragraph?(paragraph)
          return false unless paragraph.style

          paragraph.style.match?(/^Heading\s*\d+$/i) ||
            paragraph.style.match?(/^h\d+$/i)
        end

        # Extract heading level from paragraph
        #
        # @param paragraph [Paragraph] Paragraph to extract from
        # @return [Integer] Heading level
        def extract_heading_level(paragraph)
          match = paragraph.style.match(/(\d+)/)
          match ? match[1].to_i : 1
        end

        # Check if document requires headings
        #
        # @param document [Document] Document to check
        # @return [Boolean] True if headings required
        def requires_headings?(document)
          min = @config[:min_paragraphs_for_heading] || 5
          document.paragraphs.count >= min
        end

        # Check heading hierarchy
        #
        # @param headings [Array<Hash>] Extracted headings
        # @return [Array<AccessibilityViolation>] Hierarchy violations
        def check_hierarchy(headings)
          violations = []
          previous_level = 0

          headings.each_with_index do |heading, index|
            level = heading[:level]

            # Headings should not skip levels
            if @config[:no_level_skipping] && level > previous_level + 1
              violations << create_violation(
                message: "Heading hierarchy skip: Level #{previous_level} to #{level} (heading #{index + 1})",
                element: heading[:paragraph],
                severity: @config[:severity] || :error,
                suggestion: "Headings should increase by one level at a time (e.g., H1 → H2, not H1 → H3)"
              )
            end

            previous_level = level
          end

          violations
        end

        # Check if document has H1
        #
        # @param headings [Array<Hash>] Extracted headings
        # @return [Boolean] True if H1 exists
        def has_h1?(headings)
          headings.any? { |h| h[:level] == 1 }
        end
      end
    end
  end
end
