# frozen_string_literal: true

# All classes autoloaded via lib/uniword.rb
# Transformation::Transformer, DocumentFactory, DocumentWriter

module Uniword
  # Explicit format converter with declarative API.
  #
  # Responsibility: Coordinate format conversion using model transformation.
  # Single Responsibility - orchestrates conversion, delegates implementation.
  #
  # Architecture follows separation of concerns:
  # 1. Reading (DocumentFactory) - separate from transformation
  # 2. Transformation (Transformer) - separate from I/O
  # 3. Writing (DocumentWriter) - separate from transformation
  #
  # Provides explicit, declarative API with no magic or automatic detection.
  #
  # @example Explicit DOCX to MHTML conversion
  #   converter = Uniword::FormatConverter.new
  #   result = converter.convert(
  #     source: "input.docx",
  #     source_format: :docx,
  #     target: "output.mhtml",
  #     target_format: :mhtml
  #   )
  #
  # @example Named conversion method
  #   result = converter.docx_to_mhtml(
  #     source: "document.docx",
  #     target: "document.mhtml"
  #   )
  class FormatConverter
    # Initialize a new format converter
    #
    # @param options [Hash] Converter options
    # @option options [Logger] :logger (nil) Logger for conversion progress
    # @option options [Boolean] :preserve_metadata (true) Preserve styles/theme
    # @option options [Transformation::Transformer] :transformer (nil) Custom transformer
    def initialize(options = {})
      @logger = options[:logger]
      @preserve_metadata = options.fetch(:preserve_metadata, true)
      @transformer = options[:transformer] || Transformation::Transformer.new
    end

    # Convert between formats with explicit specification.
    #
    # All parameters must be explicitly specified - no automatic detection.
    #
    # @param source [String, IO] Source file path or stream
    # @param source_format [Symbol] Source format (:docx or :mhtml)
    # @param target [String, IO] Target file path or stream
    # @param target_format [Symbol] Target format (:docx or :mhtml)
    # @param options [Hash] Conversion options
    # @option options [Boolean] :preserve_images (true) Preserve images
    # @option options [Boolean] :preserve_formatting (true) Preserve formatting
    # @return [ConversionResult] Result object with statistics
    # @raise [ArgumentError] if parameters are invalid
    #
    # @example Explicit conversion
    #   result = converter.convert(
    #     source: "input.mhtml",
    #     source_format: :mhtml,
    #     target: "output.docx",
    #     target_format: :docx
    #   )
    #   puts result  # "Conversion: mhtml → docx (SUCCESS)"
    def convert(source:, source_format:, target:, target_format:, **_options)
      validate_conversion_params(source, source_format, target, target_format)

      log_conversion_start(source, source_format, target, target_format)

      begin
        # Step 1: Read source file to model (deserialization)
        source_document = read_document(source, source_format)

        # Step 2: Transform model (model-to-model transformation)
        target_document = @transformer.transform(
          source: source_document,
          source_format: source_format,
          target_format: target_format
        )

        # Step 3: Write target model to file (serialization)
        write_document(target_document, target, target_format)

        # Create success result
        ConversionResult.new(
          source: source,
          source_format: source_format,
          target: target,
          target_format: target_format,
          success: true,
          paragraphs_count: target_document.paragraphs.count,
          tables_count: target_document.tables.count,
          images_count: target_document.images.count
        )
      rescue StandardError => e
        # Create failure result
        ConversionResult.new(
          source: source,
          source_format: source_format,
          target: target,
          target_format: target_format,
          success: false,
          error: e.message
        )
      end
    end

    # Convert MHTML to DOCX with explicit declaration.
    #
    # Declarative method that clearly states the conversion operation.
    #
    # @param source [String, IO] MHTML source file or stream
    # @param target [String] DOCX target file path
    # @param options [Hash] Conversion options
    # @return [ConversionResult] Result object
    #
    # @example Declarative MHTML to DOCX
    #   result = converter.mhtml_to_docx(
    #     source: "document.mhtml",
    #     target: "document.docx"
    #   )
    def mhtml_to_docx(source:, target:, **options)
      convert(
        source: source,
        source_format: :mhtml,
        target: target,
        target_format: :docx,
        **options
      )
    end

    # Convert DOCX to MHTML with explicit declaration.
    #
    # Declarative method that clearly states the conversion operation.
    #
    # @param source [String, IO] DOCX source file or stream
    # @param target [String] MHTML target file path
    # @param options [Hash] Conversion options
    # @return [ConversionResult] Result object
    #
    # @example Declarative DOCX to MHTML
    #   result = converter.docx_to_mhtml(
    #     source: "document.docx",
    #     target: "document.mhtml"
    #   )
    def docx_to_mhtml(source:, target:, **options)
      convert(
        source: source,
        source_format: :docx,
        target: target,
        target_format: :mhtml,
        **options
      )
    end

    # Batch convert multiple files explicitly.
    #
    # @param sources [Array<String>] Array of source file paths
    # @param source_format [Symbol] Source format for all files
    # @param target_format [Symbol] Target format for all files
    # @param target_dir [String] Directory for output files
    # @return [Array<ConversionResult>] Array of results
    #
    # @example Batch conversion
    #   results = converter.batch_convert(
    #     sources: Dir.glob("*.mhtml"),
    #     source_format: :mhtml,
    #     target_format: :docx,
    #     target_dir: "converted/"
    #   )
    #   results.each { |r| puts r }
    def batch_convert(sources:, source_format:, target_format:, target_dir:)
      # Ensure target directory exists
      FileUtils.mkdir_p(target_dir)

      sources.map do |source|
        basename = File.basename(source, File.extname(source))
        target = File.join(target_dir, "#{basename}.#{target_format}")

        convert(
          source: source,
          source_format: source_format,
          target: target,
          target_format: target_format
        )
      end
    end

    # Result object for conversion operations.
    #
    # Explicitly reports what happened during conversion.
    # No hidden state - all information is accessible.
    class ConversionResult
      attr_reader :source, :source_format, :target, :target_format,
                  :success, :paragraphs_count, :tables_count, :images_count,
                  :error

      # Initialize conversion result
      #
      # @param attributes [Hash] Result attributes
      def initialize(attributes)
        @source = attributes[:source]
        @source_format = attributes[:source_format]
        @target = attributes[:target]
        @target_format = attributes[:target_format]
        @success = attributes[:success]
        @paragraphs_count = attributes[:paragraphs_count] || 0
        @tables_count = attributes[:tables_count] || 0
        @images_count = attributes[:images_count] || 0
        @error = attributes[:error]
      end

      # Check if conversion succeeded
      #
      # @return [Boolean] true if successful
      def success?
        @success
      end

      # Get human-readable result summary
      #
      # @return [String] Conversion summary
      def to_s
        if success?
          "Conversion: #{source_format} → #{target_format} " \
            "(#{paragraphs_count} paragraphs, #{tables_count} tables, " \
            "#{images_count} images) - SUCCESS"
        else
          "Conversion: #{source_format} → #{target_format} - FAILED: #{error}"
        end
      end

      # Get detailed result as hash
      #
      # @return [Hash] Result details
      def to_h
        {
          source: source,
          source_format: source_format,
          target: target,
          target_format: target_format,
          success: success,
          paragraphs_count: paragraphs_count,
          tables_count: tables_count,
          images_count: images_count,
          error: error
        }
      end
    end

    private

    # Read document from file using format-specific handler
    #
    # @param source [String, IO] Source file or stream
    # @param format [Symbol] Format to read
    # @return [Document] Loaded document
    def read_document(source, format)
      DocumentFactory.from_file(source, format: format)
    end

    # Write document to file using format-specific handler
    #
    # @param document [Document] Document to write
    # @param target [String, IO] Target file or stream
    # @param format [Symbol] Format to write
    def write_document(document, target, format)
      writer = DocumentWriter.new(document)
      writer.save(target, format: format)
    end

    # Validate conversion parameters
    #
    # @param source [Object] Source parameter
    # @param source_format [Symbol] Source format
    # @param target [Object] Target parameter
    # @param target_format [Symbol] Target format
    # @raise [ArgumentError] if parameters are invalid
    def validate_conversion_params(source, source_format, target, target_format)
      raise ArgumentError, 'Source cannot be nil' if source.nil?
      raise ArgumentError, 'Source format must be specified' if source_format.nil?
      raise ArgumentError, 'Target cannot be nil' if target.nil?
      raise ArgumentError, 'Target format must be specified' if target_format.nil?

      # Validate formats are supported
      supported = %i[docx mhtml]
      unless supported.include?(source_format)
        raise ArgumentError,
              "Unsupported source format: #{source_format}. " \
              "Supported: #{supported.join(', ')}"
      end
      return if supported.include?(target_format)

      raise ArgumentError,
            "Unsupported target format: #{target_format}. " \
            "Supported: #{supported.join(', ')}"
    end

    # Log conversion start
    #
    # @param source [String, IO] Source file
    # @param source_format [Symbol] Source format
    # @param target [String, IO] Target file
    # @param target_format [Symbol] Target format
    def log_conversion_start(source, source_format, target, target_format)
      return unless @logger

      source_name = source.respond_to?(:path) ? source.path : source.to_s
      target_name = target.respond_to?(:path) ? target.path : target.to_s

      @logger.info(
        "Converting #{source_name} (#{source_format}) → #{target_name} (#{target_format})"
      )
    end
  end
end
