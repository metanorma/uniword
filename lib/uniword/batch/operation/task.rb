# frozen_string_literal: true

module Uniword
  module Batch
    module Operation
      # Abstract base class for one batchable operation on one file.
      # Subclasses implement `run(path) -> FileResult`.
      class Task
        # @return [Symbol] task name shown in reports
        def name
          raise NotImplementedError
        end

        # Run the operation on one file. Returns a FileResult.
        #
        # @param path [String] input file path
        # @return [FileResult]
        def run(path)
          raise NotImplementedError
        end

        protected

        def success(path:, metric: 0)
          FileResult.new(path: path, status: :success, metric: metric)
        end

        def failure(path:, error:, metric: 0)
          FileResult.new(path: path, status: :failure,
                         metric: metric, error: error)
        end

        # Render an exception's message (stripping noisy backtrace).
        def message_of(error)
          "#{error.class}: #{error.message}"
        end
      end
    end
  end
end
