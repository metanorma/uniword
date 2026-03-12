# frozen_string_literal: true

module Uniword
  module Validators
    autoload :ElementValidator, "#{__dir__}/validators/element_validator"
    autoload :ParagraphValidator, "#{__dir__}/validators/paragraph_validator"
    autoload :TableValidator, "#{__dir__}/validators/table_validator"
  end
end
