# frozen_string_literal: true

require_relative "boolean_element_factory"

module Uniword
  module Properties
    BooleanElementFactory.define("b", "Bold")
    BooleanElementFactory.define("bCs", "BoldCs")
  end
end
