# frozen_string_literal: true

module Uniword
  module Batch
    module Operation
      # Aggregated result for one file in a batch run.
      class FileResult
        # @return [String] absolute or relative path of the input file
        attr_reader :path

        # @return [Symbol] :success, :failure
        attr_reader :status

        # @return [Integer] operation-specific metric (e.g. repair
        #   count, verify issue count)
        attr_reader :metric

        # @return [String, nil] error message when status is :failure
        attr_reader :error

        # @param path [String]
        # @param status [Symbol]
        # @param metric [Integer]
        # @param error [String, nil]
        def initialize(path:, status:, metric: 0, error: nil)
          @path = path
          @status = status
          @metric = metric
          @error = error
        end

        # @return [Boolean]
        def success?
          @status == :success
        end
      end
    end
  end
end
