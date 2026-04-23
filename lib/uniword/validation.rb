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
    autoload :DocumentValidator, "#{__dir__}/validation/document_validator"
    autoload :Checkers, "#{__dir__}/validation/checkers"
    autoload :Validators, "#{__dir__}/validation/validators"
    autoload :StructuralValidator, "#{__dir__}/validation/structural_validator"
  end
end
