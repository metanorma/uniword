# frozen_string_literal: true

module Uniword
  module Visitor
    autoload :BaseVisitor, "#{__dir__}/visitor/base_visitor"
    autoload :TextExtractor, "#{__dir__}/visitor/text_extractor"
  end
end
