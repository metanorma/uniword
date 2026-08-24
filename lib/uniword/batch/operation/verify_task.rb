# frozen_string_literal: true

module Uniword
  module Batch
    module Operation
      # `uniword verify` for one file. Returns the issue count as the
      # metric (0 means clean).
      class VerifyTask < Task
        # @return [Symbol]
        def name
          :verify
        end

        # @param path [String]
        # @return [FileResult]
        def run(path)
          report = Uniword::Verification.verify(path)
          issue_count = report.issues.length
          status = report.valid? ? :success : :failure
          FileResult.new(path: path, status: status, metric: issue_count)
        rescue StandardError => e
          failure(path: path, error: message_of(e))
        end
      end
    end
  end
end
