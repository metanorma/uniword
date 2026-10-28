# frozen_string_literal: true

module Uniword
  module Batch
    module Operation
      # Parallel runner for a Task across many files.
      #
      class Runner
        # @param task [Task]
        # @param paths [Array<String>]
        def initialize(task:, paths:)
          @task = task
          @paths = paths
        end

        # Run the task on every path. Files are processed serially
        # in v1 (parallelism deferred — see TODO.tier-2/10).
        #
        # @return [Report]
        def run
          report = Report.new(operation_name: @task.name)
          @paths.each do |path|
            report.add(@task.run(path))
          end
          report
        end
      end
    end
  end
end
