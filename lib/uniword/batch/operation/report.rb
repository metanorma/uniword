# frozen_string_literal: true

module Uniword
  module Batch
    module Operation
      # Aggregated report for a batch run.
      class Report
        attr_reader :results, :operation_name

        # @param operation_name [Symbol]
        def initialize(operation_name:)
          @operation_name = operation_name
          @results = []
        end

        # @param result [FileResult]
        # @return [void]
        def add(result)
          @results << result
        end

        # Total file count processed.
        #
        # @return [Integer]
        def count
          @results.length
        end

        # Count of successful files.
        #
        # @return [Integer]
        def success_count
          @results.count(&:success?)
        end

        # Count of failed files.
        #
        # @return [Integer]
        def failure_count
          @results.count { |r| !r.success? }
        end

        # Sum of per-file metrics (e.g. total repairs applied).
        #
        # @return [Integer]
        def total_metric
          @results.sum(&:metric)
        end

        # True when every file succeeded.
        #
        # @return [Boolean]
        def all_success?
          @results.all?(&:success?)
        end

        # List of failed file paths.
        #
        # @return [Array<String>]
        def failed_paths
          @results.reject(&:success?).map(&:path)
        end
      end
    end
  end
end
