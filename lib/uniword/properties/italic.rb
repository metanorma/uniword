# frozen_string_literal: true

require_relative "boolean_element_factory"

module Uniword
  module Properties
    BooleanElementFactory.define("i", "Italic")
    BooleanElementFactory.define("iCs", "ItalicCs")
  end
end
