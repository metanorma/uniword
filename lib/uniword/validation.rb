# frozen_string_literal: true

module Uniword
  module Validation
    autoload :ValidationResult, "#{__dir__}/validation/validation_result"
    autoload :ValidationReport, "#{__dir__}/validation/validation_report"
    autoload :LinkChecker, "#{__dir__}/validation/link_checker"
    autoload :LinkValidator, "#{__dir__}/validation/link_validator"
    autoload :LayerValidator, "#{__dir__}/validation/layer_validator"
    autoload :LayerValidationResult,
             "#{__dir__}/validation/layer_validation_result"
    autoload :Checkers, "#{__dir__}/validation/checkers"
    autoload :Validators, "#{__dir__}/validation/validators"
    autoload :Engine, "#{__dir__}/validation/engine"
    autoload :OpcValidator, "#{__dir__}/validation/opc_validator"
    autoload :SchemaRegistry, "#{__dir__}/validation/schema_registry"
    autoload :VerifyOrchestrator,
             "#{__dir__}/validation/verify_orchestrator"
    autoload :Rules, "#{__dir__}/validation/rules"
    autoload :Report, "#{__dir__}/validation/report"
  end
end
