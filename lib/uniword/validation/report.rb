# frozen_string_literal: true

module Uniword
  module Validation
    # Reporting value objects for validation and verification results.
    #
    # Registered here via autoload so any namespace can reference the
    # report classes without load-order coupling.
    module Report
      autoload :ValidationIssue,
               "uniword/validation/report/validation_issue"
      autoload :LayerResult,
               "uniword/validation/report/layer_result"
      autoload :VerificationReport,
               "uniword/validation/report/verification_report"
      autoload :TerminalFormatter,
               "uniword/validation/report/terminal_formatter"
    end
  end
end
