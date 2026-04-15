# frozen_string_literal: true

module Uniword
  module Accessibility
    module Rules
      # Descriptive Headings Rule - WCAG 2.4.6 Headings and Labels
      #
      # Responsibility: Check that headings are descriptive
      # Single Responsibility: Heading descriptiveness validation only
      #
      # WCAG 2.4.6 Level AA: Headings and labels describe topic or purpose
      class DescriptiveHeadingsRule < AccessibilityRule
        # Check document headings for descriptiveness
        #
        # @param document [Document] Document to check
        # @return [Array<AccessibilityViolation>] Found violations
        def check(document)
          violations = []

          return violations unless @config[:check_descriptiveness]

          headings = extract_headings(document)

          headings.each_with_index do |heading, index|
            text = extract_heading_text(heading[:paragraph])

            # Check minimum length
            if text && @config[:min_heading_length] && (text.length < @config[:min_heading_length])
              violations << create_violation(
                message: "Heading #{index + 1} is too short to be descriptive: '#{text}'",
                element: heading[:paragraph],
                severity: @config[:severity] || :warning,
                suggestion: @config[:suggestion] ||
                  "Use descriptive headings that clearly describe content"
              )
            end

            # Check for generic headings
            generic_headings = %w[heading section part introduction conclusion]
            next unless text && generic_headings.any? { |g| text.downcase == g }

            violations << create_violation(
              message: "Heading #{index + 1} is too generic: '#{text}'",
              element: heading[:paragraph],
              severity: :warning,
              suggestion: "Make headings specific to the content they describe"
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

        # Extract text from heading paragraph
        #
        # @param paragraph [Paragraph] Paragraph to extract from
        # @return [String, nil] Heading text
        def extract_heading_text(paragraph)
          if paragraph.respond_to?(:text)
            paragraph.text
          elsif paragraph.respond_to?(:runs)
            paragraph.runs.map(&:text).join
          end
        end
      end
    end
  end
end
