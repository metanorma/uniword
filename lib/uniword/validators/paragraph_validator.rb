# frozen_string_literal: true

# NOTE: element_validator is already loaded by uniword.rb
# No need to require it here to avoid circular dependencies

module Uniword
  module Validators
    # Validator for Paragraph elements
    # Responsibility: Validate paragraph-specific constraints
    #
    # A valid paragraph:
    # - Must be a Paragraph instance
    # - Can have zero or more runs (empty paragraphs are valid)
    # - All runs must be valid Run instances
    # - Properties, if present, must be valid ParagraphProperties
    #
    # @example Using the paragraph validator
    #   validator = Uniword::Validators::ParagraphValidator.new
    #   validator.valid?(paragraph) # => true or false
    #   validator.errors(paragraph) # => ["error message", ...]
    class ParagraphValidator < ElementValidator
      # Validate a paragraph element
      #
      # @param element [Paragraph] The paragraph to validate
      # @return [Boolean] true if valid, false otherwise
      def valid?(element)
        return false unless super
        return false unless element.is_a?(Uniword::Wordprocessingml::Paragraph)

        validate_runs(element) &&
          validate_properties(element)
      end

      # Get validation errors for a paragraph
      #
      # @param element [Paragraph] The paragraph to validate
      # @return [Array<String>] Array of error messages
      def errors(element)
        errors = []

        # Check if element is nil
        return ['Element is nil'] if element.nil?

        # Check paragraph type first (more specific than base check)
        unless element.is_a?(Uniword::Wordprocessingml::Paragraph)
          return ['Element must be a Paragraph']
        end

        # Validate runs - collect all specific errors
        errors.concat(run_errors(element))

        # Validate properties - collect all specific errors
        errors.concat(property_errors(element))

        errors
      end

      private

      # Validate that all runs are valid Run instances
      #
      # @param paragraph [Paragraph] The paragraph to validate
      # @return [Boolean] true if all runs are valid
      def validate_runs(paragraph)
        return true if paragraph.runs.nil? || paragraph.runs.empty?

        paragraph.runs.all?(Uniword::Wordprocessingml::Run)
      end

      # Get errors related to runs
      #
      # @param paragraph [Paragraph] The paragraph to validate
      # @return [Array<String>] Array of error messages
      def run_errors(paragraph)
        errors = []

        return errors if paragraph.runs.nil? || paragraph.runs.empty?

        paragraph.runs.each_with_index do |run, index|
          unless run.is_a?(Uniword::Wordprocessingml::Run)
            errors << "Run at index #{index} must be a Run instance"
          end
        end

        errors
      end

      # Validate properties if present
      #
      # @param paragraph [Paragraph] The paragraph to validate
      # @return [Boolean] true if properties are valid or nil
      def validate_properties(paragraph)
        return true if paragraph.properties.nil?

        paragraph.properties.is_a?(Uniword::Wordprocessingml::ParagraphProperties)
      end

      # Get errors related to properties
      #
      # @param paragraph [Paragraph] The paragraph to validate
      # @return [Array<String>] Array of error messages
      def property_errors(paragraph)
        return [] if paragraph.properties.nil?

        unless paragraph.properties.is_a?(Uniword::Wordprocessingml::ParagraphProperties)
          return ['Properties must be a ParagraphProperties instance']
        end

        []
      end
    end
  end
end

# Register this validator when the file is loaded
# This ensures the validator is available regardless of load order
if defined?(Uniword::Validators::ElementValidator)
  Uniword::Validators::ElementValidator.register(
    Uniword::Wordprocessingml::Paragraph,
    Uniword::Validators::ParagraphValidator
  )
end
