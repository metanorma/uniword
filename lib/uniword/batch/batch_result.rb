# frozen_string_literal: true

require 'json'
require 'yaml'
require 'csv'

module Uniword
  module Batch
    # Aggregates and reports results from batch document processing.
    #
    # Responsibility: Track processing results, statistics, and failures.
    # Single Responsibility - only manages result aggregation and reporting.
    #
    # @example Tracking batch results
    #   result = BatchResult.new
    #   result.add_success(file: 'doc1.docx', duration: 1.5)
    #   result.add_failure(file: 'doc2.docx', error: 'Invalid format')
    #   puts result.summary
    #
    # @example Export results
    #   result.export_json('results.json')
    #   result.export_csv('results.csv')
    class BatchResult
      attr_reader :successes, :failures, :start_time, :end_time

      # Initialize batch result tracker
      def initialize
        @successes = []
        @failures = []
        @start_time = Time.now
        @end_time = nil
      end

      # Mark processing as completed
      #
      # @return [self]
      def complete!
        @end_time = Time.now
        self
      end

      # Add a successful processing result
      #
      # @param file [String] File path that was processed
      # @param duration [Float] Processing duration in seconds
      # @param stages [Array<String>] List of stages executed
      # @param metadata [Hash] Additional metadata
      # @return [self]
      def add_success(file:, duration: 0.0, stages: [], metadata: {})
        @successes << {
          file: file,
          duration: duration,
          stages: stages,
          metadata: metadata,
          timestamp: Time.now
        }
        self
      end

      # Add a failed processing result
      #
      # @param file [String] File path that failed
      # @param error [String, Exception] Error message or exception
      # @param stage [String, nil] Stage where failure occurred
      # @param metadata [Hash] Additional metadata
      # @return [self]
      def add_failure(file:, error:, stage: nil, metadata: {})
        error_message = error.is_a?(Exception) ? error.message : error.to_s
        error_class = error.is_a?(Exception) ? error.class.name : 'Error'

        @failures << {
          file: file,
          error: error_message,
          error_class: error_class,
          stage: stage,
          metadata: metadata,
          timestamp: Time.now
        }
        self
      end

      # Get total number of files processed
      #
      # @return [Integer] Total count
      def total_count
        successes.size + failures.size
      end

      # Get number of successful files
      #
      # @return [Integer] Success count
      def success_count
        successes.size
      end

      # Get number of failed files
      #
      # @return [Integer] Failure count
      def failure_count
        failures.size
      end

      # Get success rate as percentage
      #
      # @return [Float] Success rate (0.0 to 100.0)
      def success_rate
        return 0.0 if total_count.zero?

        (success_count.to_f / total_count * 100).round(2)
      end

      # Get elapsed processing time in seconds
      #
      # @return [Float] Elapsed time
      def elapsed_time
        end_time = @end_time || Time.now
        (end_time - @start_time).round(2)
      end

      # Get average processing time per successful document
      #
      # @return [Float] Average time in seconds
      def average_duration
        return 0.0 if successes.empty?

        total = successes.sum { |s| s[:duration] }
        (total / successes.size).round(2)
      end

      # Check if batch processing was successful (no failures)
      #
      # @return [Boolean] true if all files processed successfully
      def success?
        failures.empty?
      end

      # Get summary statistics
      #
      # @return [Hash] Summary statistics
      def summary
        {
          total: total_count,
          successes: success_count,
          failures: failure_count,
          success_rate: success_rate,
          elapsed_time: elapsed_time,
          average_duration: average_duration
        }
      end

      # Get formatted summary text
      #
      # @return [String] Summary text
      def summary_text
        lines = []
        lines << "Batch Processing Results"
        lines << "=" * 40
        lines << "Total files:      #{total_count}"
        lines << "Successful:       #{success_count}"
        lines << "Failed:           #{failure_count}"
        lines << "Success rate:     #{success_rate}%"
        lines << "Elapsed time:     #{elapsed_time}s"
        lines << "Average duration: #{average_duration}s" if success_count > 0
        lines.join("\n")
      end

      # Export results to JSON file
      #
      # @param path [String] Output file path
      # @return [self]
      def export_json(path)
        data = {
          summary: summary,
          successes: successes,
          failures: failures
        }

        File.write(path, JSON.pretty_generate(data))
        self
      end

      # Export results to YAML file
      #
      # @param path [String] Output file path
      # @return [self]
      def export_yaml(path)
        data = {
          'summary' => summary,
          'successes' => successes.map { |s| stringify_keys(s) },
          'failures' => failures.map { |f| stringify_keys(f) }
        }

        File.write(path, YAML.dump(data))
        self
      end

      # Export results to CSV file
      #
      # @param path [String] Output file path
      # @return [self]
      def export_csv(path)
        CSV.open(path, 'wb') do |csv|
          # Header row
          csv << ['File', 'Status', 'Duration', 'Error', 'Stage']

          # Success rows
          successes.each do |success|
            csv << [
              success[:file],
              'SUCCESS',
              success[:duration],
              '',
              success[:stages].join(', ')
            ]
          end

          # Failure rows
          failures.each do |failure|
            csv << [
              failure[:file],
              'FAILURE',
              '',
              failure[:error],
              failure[:stage] || ''
            ]
          end
        end
        self
      end

      private

      # Convert hash keys to strings
      #
      # @param hash [Hash] Hash with symbol keys
      # @return [Hash] Hash with string keys
      def stringify_keys(hash)
        hash.transform_keys(&:to_s).transform_values do |value|
          value.is_a?(Hash) ? stringify_keys(value) : value
        end
      end
    end
  end
end