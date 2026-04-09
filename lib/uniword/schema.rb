# frozen_string_literal: true

module Uniword
  module Schema
    autoload :SchemaLoader, "#{__dir__}/schema/schema_loader"
    autoload :ModelGenerator, "#{__dir__}/schema/model_generator"
  end
end
