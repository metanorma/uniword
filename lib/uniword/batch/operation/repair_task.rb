# frozen_string_literal: true

module Uniword
  module Batch
    module Operation
      # `uniword repair` for one file. Saves the repaired copy to
      # `output_path`, returns the count of applied fixes as the
      # metric.
      class RepairTask < Task
        # @param output_dir [String] directory to write repaired copies
        def initialize(output_dir:)
          @output_dir = output_dir
        end

        # @return [Symbol]
        def name
          :repair
        end

        # @param path [String]
        # @return [FileResult]
        def run(path)
          doc = Uniword::DocumentFactory.from_file(path)
          output_path = File.join(@output_dir, File.basename(path))

          doc.save(output_path)
          success(path: path)
        rescue StandardError => e
          failure(path: path, error: message_of(e))
        end
      end
    end
  end
end
