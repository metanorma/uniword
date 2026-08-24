# frozen_string_literal: true

module Uniword
  module Batch
    # Operation-style batching: run a top-level CLI operation
    # (repair, verify, find-replace, diff) across many files in
    # parallel with structured per-file reports. Distinct from
    # `Batch::DocumentProcessor` (staged pipeline processing) and
    # from `Batch::ProcessingStage`.
    #
    # Open/closed: a new operation = new subclass of `Operation::Task`
    # + registration in `Operation::Runner::TASKS`.
    module Operation
      autoload :Task, "#{__dir__}/operation/task"
      autoload :FileResult, "#{__dir__}/operation/file_result"
      autoload :Report, "#{__dir__}/operation/report"
      autoload :Runner, "#{__dir__}/operation/runner"
      autoload :RepairTask, "#{__dir__}/operation/repair_task"
      autoload :VerifyTask, "#{__dir__}/operation/verify_task"
    end
  end
end
