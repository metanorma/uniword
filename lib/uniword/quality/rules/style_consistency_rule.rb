# frozen_string_literal: true


module Uniword
  module Quality
    # Checks for direct formatting instead of styles.
    #
    # Responsibility: Validate consistent use of styles.
    # Single Responsibility - only checks style consistency.
    #
    # Validates:
    # - Paragraphs use standard styles instead of direct formatting
    # - Direct formatting is used appropriately (if allowed)
    # - Document maintains consistent appearance
    #
    # @example Configuration
    #   style_consistency:
    #     enabled: true
    #     allow_direct_formatting: false
    #     require_standard_styles: true
    class StyleConsistencyRule < QualityRule
      def initialize(config = {})
        super
        @allow_direct_formatting = @config.fetch(:allow_direct_formatting, false)
        @require_standard_styles = @config.fetch(:require_standard_styles, true)
      end

      # Check document for style consistency violations
      #
      # @param document [Document] The document to check
      # @return [Array<QualityViolation>] List of violations found
      def check(document)
        violations = []

        document.paragraphs.each_with_index do |para, index|
          # Skip empty paragraphs
          next if para.empty?

          # Check if paragraph has no style but has formatting
          if @require_standard_styles && !has_style?(para) && has_formatting?(para)
            violations << create_violation(
              severity: :warning,
              message: "Paragraph #{index + 1} uses direct formatting instead of a style. " \
                       'Consider applying a standard paragraph style.',
              location: "Paragraph #{index + 1}",
              element: para
            )
          end

          # Check runs for direct formatting
          next if @allow_direct_formatting

          para.runs.each_with_index do |run, run_index|
            next unless run.respond_to?(:properties)
            next unless run.properties

            next unless has_direct_run_formatting?(run)

            violations << create_violation(
              severity: :info,
              message: "Direct text formatting detected in paragraph #{index + 1}, run #{run_index + 1}. " \
                       'Consider using character styles for consistency.',
              location: "Paragraph #{index + 1}, Run #{run_index + 1}",
              element: run
            )
          end
        end

        violations
      end

      private

      # Check if paragraph has a style applied
      #
      # @param paragraph [Paragraph] The paragraph to check
      # @return [Boolean] true if has style
      def has_style?(paragraph)
        paragraph.style_id && !paragraph.style_id.empty?
      end

      # Check if paragraph has formatting properties
      #
      # @param paragraph [Paragraph] The paragraph to check
      # @return [Boolean] true if has formatting
      def has_formatting?(paragraph)
        return false unless paragraph.properties

        # Check for common formatting properties
        paragraph.properties.alignment ||
          paragraph.properties.spacing_before ||
          paragraph.properties.spacing_after ||
          paragraph.properties.line_spacing ||
          paragraph.properties.indent_left ||
          paragraph.properties.indent_right
      end

      # Check if run has direct formatting
      #
      # @param run [Run] The run to check
      # @return [Boolean] true if has direct formatting
      def has_direct_run_formatting?(run)
        props = run.properties
        return false unless props

        # Check for common direct formatting
        props.bold ||
          props.italic ||
          props.underline ||
          props.font ||
          props.size ||
          props.color
      end
    end
  end
end
