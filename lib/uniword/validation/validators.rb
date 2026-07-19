# frozen_string_literal: true

module Uniword
  module Validation
    module Validators
      autoload :XmlSchemaValidator, "#{__dir__}/validators/xml_schema_validator"
      autoload :DocumentSemanticsValidator,
               "#{__dir__}/validators/document_semantics_validator"
    end
  end
end
