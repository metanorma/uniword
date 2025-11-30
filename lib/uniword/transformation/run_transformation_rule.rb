# frozen_string_literal: true

require_relative 'transformation_rule'

module Uniword
  module Transformation
    # Transformation rule for Run elements.
    #
    # Responsibility: Transform Run objects between DOCX and MHTML formats.
    # Single Responsibility - handles only Run transformations.
    #
    # Transformations preserve text content and formatting properties.
    # Format-specific properties are adapted as needed.
    #
    # @example Transform DOCX run to MHTML
    #   rule = RunTransformationRule.new(source_format: :docx, target_format: :mhtml)
    #   mhtml_run = rule.transform(docx_run)
    class RunTransformationRule < TransformationRule
      # Check if this rule matches the transformation request
      #
      # @param element_type [Class] The element class
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @return [Boolean] true if matches
      def matches?(element_type:, source_format:, target_format:)
        element_type == Run &&
          source_format == @source_format &&
          target_format == @target_format
      end

      # Transform a run from source format to target format
      #
      # Creates new Run with same text and adapted properties.
      #
      # @param source_run [Run] Source run
      # @return [Run] Transformed run
      # @raise [ArgumentError] if source_run is not a Run
      def transform(source_run)
        validate_element_type(source_run, Run)

        # Create new run with same text
        target_run = Run.new(text: source_run.text)

        # Transform properties if they exist
        transform_properties(source_run, target_run) if source_run.properties

        target_run
      end

      private

      # Transform run properties
      #
      # @param source [Run] Source run
      # @param target [Run] Target run
      def transform_properties(source, target)
        source_props = source.properties

        # Create new properties object
        target.properties = Properties::RunProperties.new(
          bold: source_props.bold,
          italic: source_props.italic,
          underline: source_props.underline,
          strike: source_props.strike,
          double_strike: source_props.double_strike,
          size: source_props.size,
          font: source_props.font,
          color: source_props.color,
          highlight: source_props.highlight,
          vertical_align: source_props.vertical_align,
          small_caps: source_props.small_caps,
          all_caps: source_props.all_caps,
          style: source_props.style
        )
      end
    end
  end
end
