# frozen_string_literal: true


module Uniword
  module Transformation
    # Transformation rule for Paragraph elements.
    #
    # Responsibility: Transform Paragraph objects between DOCX and MHTML formats.
    # Single Responsibility - handles only Paragraph transformations.
    #
    # Transformations handle format-specific property conversions:
    # - DOCX → MHTML: Convert OOXML properties to CSS-compatible properties
    # - MHTML → DOCX: Convert CSS properties to OOXML properties
    #
    # @example Transform DOCX paragraph to MHTML
    #   rule = ParagraphTransformationRule.new(source_format: :docx, target_format: :mhtml)
    #   mhtml_para = rule.transform(docx_para)
    class ParagraphTransformationRule < TransformationRule
      # Check if this rule matches the transformation request
      #
      # @param element_type [Class] The element class
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @return [Boolean] true if matches
      def matches?(element_type:, source_format:, target_format:)
        element_type == Paragraph &&
          source_format == @source_format &&
          target_format == @target_format
      end

      # Transform a paragraph from source format to target format
      #
      # Creates new Paragraph with adapted properties and transformed runs.
      #
      # @param source_para [Paragraph] Source paragraph
      # @return [Paragraph] Transformed paragraph
      # @raise [ArgumentError] if source_para is not a Paragraph
      def transform(source_para)
        validate_element_type(source_para, Paragraph)

        target_para = Paragraph.new

        # Transform properties based on format direction
        transform_properties(source_para, target_para)

        # Transform runs (delegate to RunTransformationRule)
        transform_runs(source_para, target_para)

        target_para
      end

      private

      # Transform paragraph properties
      #
      # @param source [Paragraph] Source paragraph
      # @param target [Paragraph] Target paragraph
      def transform_properties(source, target)
        return unless source.properties

        if @source_format == :docx && @target_format == :mhtml
          transform_properties_docx_to_mhtml(source.properties, target)
        elsif @source_format == :mhtml && @target_format == :docx
          transform_properties_mhtml_to_docx(source.properties, target)
        else
          # Same format - direct copy
          copy_properties(source.properties, target)
        end
      end

      # Transform DOCX paragraph properties to MHTML format
      #
      # @param source_props [Wordprocessingml::ParagraphProperties] Source properties
      # @param target_para [Paragraph] Target paragraph
      def transform_properties_docx_to_mhtml(source_props, target_para)
        target_props = Wordprocessingml::ParagraphProperties.new

        # Direct mappings (format-agnostic)
        target_props.alignment = source_props.alignment
        target_props.spacing_before = source_props.spacing_before
        target_props.spacing_after = source_props.spacing_after
        target_props.line_spacing = source_props.line_spacing
        target_props.line_rule = source_props.line_rule
        target_props.indent_left = source_props.indent_left
        target_props.indent_right = source_props.indent_right
        target_props.indent_first_line = source_props.indent_first_line

        # DOCX-specific properties to preserve
        target_props.style = source_props.style
        target_props.num_id = source_props.num_id
        target_props.ilvl = source_props.ilvl
        target_props.keep_next = source_props.keep_next
        target_props.keep_lines = source_props.keep_lines
        target_props.page_break_before = source_props.page_break_before
        target_props.outline_level = source_props.outline_level

        target_para.properties = target_props
      end

      # Transform MHTML paragraph properties to DOCX format
      #
      # @param source_props [Wordprocessingml::ParagraphProperties] Source properties
      # @param target_para [Paragraph] Target paragraph
      def transform_properties_mhtml_to_docx(source_props, target_para)
        # Same transformation as docx_to_mhtml since both use same model
        # In future, could handle CSS-specific transformations here
        transform_properties_docx_to_mhtml(source_props, target_para)
      end

      # Copy properties directly (same format)
      #
      # @param source_props [Wordprocessingml::ParagraphProperties] Source properties
      # @param target_para [Paragraph] Target paragraph
      def copy_properties(source_props, target_para)
        target_para.properties = Wordprocessingml::ParagraphProperties.new(
          alignment: source_props.alignment,
          spacing_before: source_props.spacing_before,
          spacing_after: source_props.spacing_after,
          line_spacing: source_props.line_spacing,
          line_rule: source_props.line_rule,
          indent_left: source_props.indent_left,
          indent_right: source_props.indent_right,
          indent_first_line: source_props.indent_first_line,
          style: source_props.style,
          num_id: source_props.num_id,
          ilvl: source_props.ilvl,
          keep_next: source_props.keep_next,
          keep_lines: source_props.keep_lines,
          page_break_before: source_props.page_break_before,
          outline_level: source_props.outline_level
        )
      end

      # Transform runs from source to target paragraph
      #
      # @param source [Paragraph] Source paragraph
      # @param target [Paragraph] Target paragraph
      def transform_runs(source, target)

        run_rule = RunTransformationRule.new(
          source_format: @source_format,
          target_format: @target_format
        )

        source.runs.each do |source_run|
          # Handle different run types (Run, Image, Hyperlink)
          transformed = if source_run.is_a?(Image)
                          image_rule = ImageTransformationRule.new(
                            source_format: @source_format,
                            target_format: @target_format
                          )
                          image_rule.transform(source_run)
                        elsif source_run.is_a?(Hyperlink)
                          link_rule = HyperlinkTransformationRule.new(
                            source_format: @source_format,
                            target_format: @target_format
                          )
                          link_rule.transform(source_run)
                        else
                          run_rule.transform(source_run)
                        end

          target.add_run(transformed)
        end
      end
    end
  end
end
