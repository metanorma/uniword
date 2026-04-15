# frozen_string_literal: true

module Uniword
  module Batch
    # Processing stage that converts document format.
    #
    # Responsibility: Convert documents between DOCX and MHTML formats.
    # Single Responsibility - only handles format conversion.
    #
    # @example Use in pipeline
    #   stage = ConvertFormatStage.new(
    #     target_format: :docx,
    #     preserve_original: true
    #   )
    #   document = stage.process(document, context)
    class ConvertFormatStage < ProcessingStage
      # Initialize convert format stage
      #
      # @param options [Hash] Stage options
      # @option options [Symbol] :target_format Target format (:docx or :mhtml)
      # @option options [Boolean] :preserve_original Keep original format file
      def initialize(options = {})
        super
        @target_format = options.fetch(:target_format, :docx)
        @preserve_original = options.fetch(:preserve_original, true)

        validate_target_format!
      end

      # Process document to convert format
      #
      # @param document [Document] Document to process
      # @param context [Hash] Processing context
      # @return [Document] Processed document
      def process(document, context = {})
        log "Converting to #{@target_format} format: #{context[:filename]}"

        # Detect current format from file extension
        current_format = detect_format(context[:input_path])

        # Skip if already in target format
        if current_format == @target_format
          log "Document already in #{@target_format} format, skipping conversion"
          return document
        end

        # Update output path extension if needed
        if context[:output_path]
          context[:output_path] = update_output_extension(
            context[:output_path],
            @target_format
          )
        end

        log "Format conversion complete"
        document
      end

      # Get stage description
      #
      # @return [String] Description
      def description
        "Convert document format to #{@target_format}"
      end

      private

      # Validate target format
      #
      # @raise [ArgumentError] if target format is invalid
      def validate_target_format!
        valid_formats = %i[docx mhtml]
        return if valid_formats.include?(@target_format)

        raise ArgumentError,
              "Invalid target_format: #{@target_format}. " \
              "Must be one of: #{valid_formats.join(", ")}"
      end

      # Detect format from file path
      #
      # @param file_path [String] File path
      # @return [Symbol] Format (:docx or :mhtml)
      def detect_format(file_path)
        return :docx unless file_path

        ext = File.extname(file_path).downcase
        case ext
        when ".docx"
          :docx
        when ".doc", ".mht", ".mhtml"
          :mhtml
        else
          :docx # Default
        end
      end

      # Update output file extension
      #
      # @param output_path [String] Original output path
      # @param format [Symbol] Target format
      # @return [String] Updated output path
      def update_output_extension(output_path, format)
        ext = case format
              when :docx
                ".docx"
              when :mhtml
                ".doc"
              else
                ".docx"
              end

        output_path.sub(/\.[^.]+$/, ext)
      end
    end
  end
end
