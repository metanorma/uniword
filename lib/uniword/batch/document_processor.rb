# frozen_string_literal: true

# All classes autoloaded via lib/uniword.rb and lib/uniword/batch.rb
# ProcessingStage, BatchResult, Configuration::ConfigurationLoader, DocumentFactory

module Uniword
  module Batch
    # Orchestrates batch document processing through configurable pipeline stages.
    #
    # Responsibility: Load pipeline configuration and coordinate stage execution.
    # Single Responsibility - only orchestrates processing, delegates work to stages.
    #
    # Follows Open/Closed Principle - new stages can be added via configuration
    # without modifying this class.
    #
    # @example Process batch of documents
    #   processor = DocumentProcessor.new(pipeline_config: 'config/pipeline.yml')
    #   results = processor.process_batch(
    #     input_dir: 'documents/input/',
    #     output_dir: 'documents/output/'
    #   )
    #   puts results.summary_text
    #
    # @example Process with custom stages
    #   processor = DocumentProcessor.new
    #   processor.add_stage(CustomStage.new(enabled: true))
    #   results = processor.process_file('document.docx', 'output.docx')
    class DocumentProcessor
      attr_reader :stages, :config

      # Stage class registry
      # Maps stage names to their class implementations
      STAGE_CLASSES = {
        normalize_styles: 'NormalizeStylesStage',
        update_metadata: 'UpdateMetadataStage',
        validate_links: 'ValidateLinksStage',
        quality_check: 'QualityCheckStage',
        convert_format: 'ConvertFormatStage',
        compress_images: 'CompressImagesStage'
      }.freeze

      # Initialize document processor
      #
      # @param pipeline_config [String, nil] Path to pipeline configuration file
      # @param config [Hash, nil] Direct configuration hash (overrides pipeline_config)
      # @param parallel [Boolean] Enable parallel processing
      # @param max_workers [Integer] Maximum number of parallel workers
      def initialize(pipeline_config: nil, config: nil, parallel: false, max_workers: 4)
        @config = load_configuration(pipeline_config, config)
        @parallel = parallel || @config.dig(:pipeline, :parallel, :enabled) || false
        @max_workers = max_workers || @config.dig(:pipeline, :parallel, :max_workers) || 4
        @stages = load_stages
        @custom_stages = []
      end

      # Process a batch of documents from input directory
      #
      # @param input_dir [String] Input directory path
      # @param output_dir [String] Output directory path
      # @param pattern [String] File pattern to match (default: '*.{docx,doc}')
      # @return [BatchResult] Processing results
      def process_batch(input_dir:, output_dir:, pattern: '*.{docx,doc}')
        validate_directories!(input_dir, output_dir)

        # Create output directory if it doesn't exist
        FileUtils.mkdir_p(output_dir)

        # Find all matching files
        files = Dir.glob(File.join(input_dir, pattern))

        result = BatchResult.new

        if @parallel && files.size > 1
          process_parallel(files, input_dir, output_dir, result)
        else
          process_sequential(files, input_dir, output_dir, result)
        end

        result.complete!
      end

      # Process a single document file
      #
      # @param input_path [String] Input file path
      # @param output_path [String] Output file path
      # @return [BatchResult] Processing result
      def process_file(input_path, output_path)
        result = BatchResult.new
        start_time = Time.now

        begin
          # Load document
          document = DocumentFactory.from_file(input_path)

          # Create context
          context = {
            input_path: input_path,
            output_path: output_path,
            filename: File.basename(input_path)
          }

          # Execute pipeline
          executed_stages = []
          all_stages = @stages + @custom_stages

          all_stages.each do |stage|
            next unless stage.enabled?

            stage.process(document, context)
            executed_stages << stage.name
          end

          # Save output
          output_dir = File.dirname(output_path)
          FileUtils.mkdir_p(output_dir)
          document.save(output_path)

          duration = Time.now - start_time
          result.add_success(
            file: input_path,
            duration: duration,
            stages: executed_stages
          )
        rescue StandardError => e
          handle_error(e, input_path, result)
        end

        result.complete!
      end

      # Add a custom processing stage
      #
      # @param stage [ProcessingStage] Stage to add
      # @return [self]
      def add_stage(stage)
        unless stage.is_a?(ProcessingStage)
          raise ArgumentError,
                'Stage must inherit from ProcessingStage'
        end

        @custom_stages << stage
        self
      end

      # Get list of enabled stage names
      #
      # @return [Array<String>] Names of enabled stages
      def enabled_stages
        all_stages = @stages + @custom_stages
        all_stages.select(&:enabled?).map(&:name)
      end

      # Get list of disabled stage names
      #
      # @return [Array<String>] Names of disabled stages
      def disabled_stages
        all_stages = @stages + @custom_stages
        all_stages.reject(&:enabled?).map(&:name)
      end

      private

      # Load configuration from file or use provided config
      #
      # @param pipeline_config [String, nil] Path to pipeline file
      # @param config [Hash, nil] Direct configuration
      # @return [Hash] Loaded configuration
      def load_configuration(pipeline_config, config)
        if config
          config
        elsif pipeline_config
          Configuration::ConfigurationLoader.load_file(pipeline_config)
        else
          Configuration::ConfigurationLoader.load('pipeline')
        end
      rescue Configuration::ConfigurationError => e
        # Use default configuration if file not found
        warn "Warning: Could not load pipeline configuration: #{e.message}"
        warn 'Using default configuration'
        default_configuration
      end

      # Default configuration
      #
      # @return [Hash] Default pipeline configuration
      def default_configuration
        {
          pipeline: {
            default: {
              stages: []
            },
            parallel: {
              enabled: false,
              max_workers: 4
            },
            error_handling: {
              continue_on_error: true,
              log_errors: true
            }
          }
        }
      end

      # Load and instantiate all configured stages
      #
      # @return [Array<ProcessingStage>] Array of stage instances
      def load_stages
        stages_config = @config.dig(:pipeline, :default, :stages) || []

        stages_config.map do |stage_config|
          stage_name = stage_config[:name]&.to_sym
          class_name = STAGE_CLASSES[stage_name]

          next unless class_name

          instantiate_stage(class_name, stage_config[:options] || {})
        end.compact
      end

      # Instantiate a stage class with configuration
      #
      # @param class_name [String] Name of the stage class
      # @param options [Hash] Stage options
      # @return [ProcessingStage, nil] Stage instance or nil if class not found
      def instantiate_stage(class_name, options)
        # Stage classes are autoloaded via lib/uniword/batch.rb
        stage_class = Batch.const_get(class_name)
        stage_class.new(options)
      rescue NameError => e
        warn "Warning: Stage class not found: #{class_name} (#{e.message})"
        nil
      end

      # Process files sequentially
      #
      # @param files [Array<String>] List of file paths
      # @param input_dir [String] Input directory
      # @param output_dir [String] Output directory
      # @param result [BatchResult] Result tracker
      def process_sequential(files, input_dir, output_dir, result)
        files.each do |input_path|
          relative_path = input_path.sub(input_dir, '').sub(%r{^/}, '')
          output_path = File.join(output_dir, relative_path)

          process_single_file(input_path, output_path, result)
        end
      end

      # Process files in parallel
      #
      # @param files [Array<String>] List of file paths
      # @param input_dir [String] Input directory
      # @param output_dir [String] Output directory
      # @param result [BatchResult] Result tracker
      def process_parallel(files, input_dir, output_dir, result)
        # NOTE: Actual parallel implementation would require thread-safe operations
        # For now, fall back to sequential processing
        warn 'Warning: Parallel processing not yet implemented, using sequential'
        process_sequential(files, input_dir, output_dir, result)
      end

      # Process a single file and update result
      #
      # @param input_path [String] Input file path
      # @param output_path [String] Output file path
      # @param result [BatchResult] Result tracker
      def process_single_file(input_path, output_path, result)
        start_time = Time.now

        begin
          # Load document
          document = DocumentFactory.from_file(input_path)

          # Create context
          context = {
            input_path: input_path,
            output_path: output_path,
            filename: File.basename(input_path)
          }

          # Execute pipeline
          executed_stages = []
          all_stages = @stages + @custom_stages

          all_stages.each do |stage|
            next unless stage.enabled?

            document = stage.process(document, context)
            executed_stages << stage.name
          end

          # Save output
          output_dir = File.dirname(output_path)
          FileUtils.mkdir_p(output_dir)
          document.save(output_path)

          duration = Time.now - start_time
          result.add_success(
            file: input_path,
            duration: duration,
            stages: executed_stages
          )
        rescue StandardError => e
          handle_error(e, input_path, result)
        end
      end

      # Handle processing error
      #
      # @param error [Exception] The error that occurred
      # @param file_path [String] File being processed
      # @param result [BatchResult] Result tracker
      def handle_error(error, file_path, result)
        continue_on_error = @config.dig(:pipeline, :error_handling, :continue_on_error)
        log_errors = @config.dig(:pipeline, :error_handling, :log_errors)

        result.add_failure(file: file_path, error: error)

        if log_errors
          warn "Error processing #{file_path}: #{error.message}"
          warn error.backtrace.first(5).join("\n") if ENV['UNIWORD_VERBOSE']
        end

        raise error unless continue_on_error
      end

      # Validate directories exist
      #
      # @param input_dir [String] Input directory
      # @param output_dir [String] Output directory
      # @raise [ArgumentError] if input directory doesn't exist
      def validate_directories!(input_dir, _output_dir)
        return if Dir.exist?(input_dir)

        raise ArgumentError, "Input directory does not exist: #{input_dir}"
      end
    end
  end
end
