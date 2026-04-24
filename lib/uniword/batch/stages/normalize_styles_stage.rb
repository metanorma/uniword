# frozen_string_literal: true

module Uniword
  module Batch
    # Processing stage that normalizes document styles.
    #
    # Responsibility: Remove direct formatting and apply standard styles.
    # Single Responsibility - only handles style normalization.
    #
    # @example Use in pipeline
    #   stage = NormalizeStylesStage.new(
    #     remove_direct_formatting: true,
    #     apply_standard_styles: true
    #   )
    #   document = stage.process(document, context)
    class NormalizeStylesStage < ProcessingStage
      # Initialize normalize styles stage
      #
      # @param options [Hash] Stage options
      # @option options [Boolean] :remove_direct_formatting Remove direct formatting
      # @option options [Boolean] :apply_standard_styles Apply standard styles
      # @option options [Boolean] :preserve_semantic_styles Preserve semantic styles
      # @option options [Hash] :target_styles Target style mappings
      def initialize(options = {})
        super
        @remove_direct_formatting = options.fetch(:remove_direct_formatting,
                                                  true)
        @apply_standard_styles = options.fetch(:apply_standard_styles, true)
        @preserve_semantic_styles = options.fetch(:preserve_semantic_styles,
                                                  true)
        @target_styles = options.fetch(:target_styles, default_target_styles)
      end

      # Process document to normalize styles
      #
      # @param document [Document] Document to process
      # @param context [Hash] Processing context
      # @return [Document] Processed document
      def process(document, context = {})
        log "Normalizing styles in #{context[:filename]}"

        normalize_paragraph_styles(document) if @apply_standard_styles
        remove_direct_formatting_from_runs(document) if @remove_direct_formatting

        log "Style normalization complete"
        document
      end

      # Get stage description
      #
      # @return [String] Description
      def description
        "Normalize document styles"
      end

      private

      # Default target style mappings
      #
      # @return [Hash] Style mappings
      def default_target_styles
        {
          heading1: "Heading 1",
          heading2: "Heading 2",
          heading3: "Heading 3",
          normal: "Normal",
        }
      end

      # Normalize paragraph styles
      #
      # @param document [Document] Document to process
      def normalize_paragraph_styles(document)
        document.paragraphs.each do |paragraph|
          next unless paragraph.properties

          # Detect style based on properties
          detected_style = detect_paragraph_style(paragraph)

          paragraph.properties.style = @target_styles[detected_style] if detected_style && @target_styles[detected_style]
        end
      end

      # Detect paragraph style based on properties
      #
      # @param paragraph [Paragraph] Paragraph to analyze
      # @return [Symbol, nil] Detected style or nil
      def detect_paragraph_style(paragraph)
        props = paragraph.properties

        # Check outline level for headings
        if props.respond_to?(:outline_level)
          case props.outline_level
          when 0, 1
            return :heading1
          when 2
            return :heading2
          when 3
            return :heading3
          end
        end

        # Check style name
        if paragraph.style
          style_name = paragraph.style.downcase
          return :heading1 if style_name.include?("heading 1")
          return :heading2 if style_name.include?("heading 2")
          return :heading3 if style_name.include?("heading 3")
        end

        # Default to normal
        :normal
      end

      # Remove direct formatting from runs
      #
      # @param document [Document] Document to process
      def remove_direct_formatting_from_runs(document)
        document.paragraphs.each do |paragraph|
          paragraph.runs.each do |run|
            next unless run.properties

            # Preserve semantic formatting if configured
            if @preserve_semantic_styles
              preserve_semantic_run_properties(run)
            else
              clear_all_run_properties(run)
            end
          end
        end
      end

      # Preserve only semantic run properties
      #
      # @param run [Run] Run to process
      def preserve_semantic_run_properties(run)
        props = run.properties

        # Preserve bold for emphasis
        bold = props.respond_to?(:bold) ? props.bold : nil
        # Preserve italic for emphasis
        italic = props.respond_to?(:italic) ? props.italic : nil

        # Clear all properties
        clear_all_run_properties(run)

        # Restore semantic properties
        props.bold = bold if props.respond_to?(:bold=) && bold
        return unless props.respond_to?(:italic=) && italic

        props.italic = italic
      end

      # Clear all run properties
      #
      # @param run [Run] Run to process
      def clear_all_run_properties(run)
        props = run.properties
        return unless props

        # Reset font properties
        props.font_size = nil if props.respond_to?(:font_size=)
        props.font_name = nil if props.respond_to?(:font_name=)
        props.color = nil if props.respond_to?(:color=)

        # Reset text effects (keep if you want to preserve semantic formatting)
        # props.bold = nil if props.respond_to?(:bold=)
        # props.italic = nil if props.respond_to?(:italic=)
        props.underline = nil if props.respond_to?(:underline=)
        props.strike = nil if props.respond_to?(:strike=)
      end
    end
  end
end
