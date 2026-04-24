# frozen_string_literal: true

module Uniword
  module Transformation
    # Transformation rule for Hyperlink elements.
    #
    # Responsibility: Transform Hyperlink objects between DOCX and MHTML formats.
    # Single Responsibility - handles only Hyperlink transformations.
    #
    # Transforms hyperlinks including URL, anchor, tooltip, and contained runs.
    #
    # @example Transform DOCX hyperlink to MHTML
    #   rule = HyperlinkTransformationRule.new(source_format: :docx, target_format: :mhtml)
    #   mhtml_link = rule.transform(docx_link)
    class HyperlinkTransformationRule < TransformationRule
      # Check if this rule matches the transformation request
      #
      # @param element_type [Class] The element class
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @return [Boolean] true if matches
      def matches?(element_type:, source_format:, target_format:)
        element_type == Hyperlink &&
          source_format == @source_format &&
          target_format == @target_format
      end

      # Transform a hyperlink from source format to target format
      #
      # Creates new Hyperlink with same URL/anchor and transformed runs.
      #
      # @param source_link [Hyperlink] Source hyperlink
      # @return [Hyperlink] Transformed hyperlink
      # @raise [ArgumentError] if source_link is not a Hyperlink
      def transform(source_link)
        validate_element_type(source_link, Hyperlink)

        # Create new hyperlink with core properties
        target_link = Hyperlink.new(
          url: source_link.url,
          anchor: source_link.anchor,
          text: source_link.text,
          tooltip: source_link.tooltip,
          relationship_id: source_link.relationship_id,
        )

        # Transform runs within hyperlink
        transform_runs(source_link, target_link)

        target_link
      end

      private

      # Transform runs within hyperlink
      #
      # @param source [Hyperlink] Source hyperlink
      # @param target [Hyperlink] Target hyperlink
      def transform_runs(source, target)
        run_rule = RunTransformationRule.new(
          source_format: @source_format,
          target_format: @target_format,
        )

        source.runs.each do |source_run|
          target_run = run_rule.transform(source_run)
          target.runs << target_run
        end
      end
    end
  end
end
