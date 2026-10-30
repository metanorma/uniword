# frozen_string_literal: true

module Uniword
  module Accessibility
    module Rules
      # Image Alt Text Rule - WCAG 1.1.1 Non-text Content
      #
      # Responsibility: Check that images have alternative text
      # Single Responsibility: Image alt text validation only
      #
      # WCAG 1.1.1 Level A: All non-text content must have text alternative
      class ImageAltTextRule < AccessibilityRule
        # Check document images for alt text
        #
        # @param document [Document] Document to check
        # @return [Array<AccessibilityViolation>] Found violations
        def check(document)
          violations = []

          document.images.each_with_index do |image, index|
            alt_text = image.alt_text

            # Drawing#alt_text already treats a blank descr as absent.
            if alt_text.nil?
              violations << create_violation(
                message: "Image #{index + 1} missing alternative text",
                element: image,
                severity: @config[:severity] || :error,
                suggestion: missing_alt_text_suggestion(image),
              )
              next # Skip quality checks if no alt text
            end

            # Check alt text quality if enabled
            next unless @config[:check_quality]

            violations.concat(check_alt_text_quality(image, alt_text, index))
          end

          violations
        end

        private

        # Word's older Alt Text dialog had both a Title and a Description
        # field, and templates from that era put the description in Title.
        # Title is a caption, not a text alternative, so the image still
        # counts as undescribed — but say where the text already is.
        #
        # @param drawing [Wordprocessingml::Drawing] Drawing being reported
        # @return [String] Suggestion text
        def missing_alt_text_suggestion(drawing)
          title = drawing.alt_title
          if title
            return "Move the drawing's docPr title (#{title.inspect}) into " \
                   "its descr attribute; title is a caption, not alt text"
          end

          @config[:suggestion] ||
            "Add descriptive alternative text via the drawing's " \
            "docPr descr attribute"
        end

        # Check quality of alt text
        #
        # @param image [Wordprocessingml::Drawing] Drawing to check
        # @param alt_text [String] Alternative text read from the drawing
        # @param index [Integer] Image index
        # @return [Array<AccessibilityViolation>] Quality violations
        def check_alt_text_quality(image, alt_text, index)
          violations = []

          # Check minimum length
          if @config[:min_length] && alt_text.length < @config[:min_length]
            violations << create_violation(
              message: "Image #{index + 1} has insufficient alt text " \
                       "(too short: #{alt_text.length} chars)",
              element: image,
              severity: :warning,
              suggestion: "Alternative text should describe the image content meaningfully (min #{@config[:min_length]} chars)",
            )
          end

          # Check maximum length
          if @config[:max_length] && alt_text.length > @config[:max_length]
            violations << create_violation(
              message: "Image #{index + 1} has excessive alt text " \
                       "(too long: #{alt_text.length} chars)",
              element: image,
              severity: :warning,
              suggestion: "Keep alternative text concise (max #{@config[:max_length]} chars)",
            )
          end

          # Check for unhelpful generic text
          unhelpful = %w[image picture photo img graphic icon]
          alt_lower = alt_text.downcase
          if unhelpful.any? do |word|
            alt_lower == word || alt_lower.start_with?("#{word} of")
          end
            violations << create_violation(
              message: "Image #{index + 1} has generic alt text: '#{alt_text}'",
              element: image,
              severity: :warning,
              suggestion: "Describe what the image shows, not that it's an image",
            )
          end

          violations
        end
      end
    end
  end
end
