# frozen_string_literal: true

module Uniword
  module Styles
    module DSL
      autoload :ParagraphContext, "#{__dir__}/dsl/paragraph_context"
      autoload :TableContext, "#{__dir__}/dsl/table_context"
      autoload :ListContext, "#{__dir__}/dsl/list_context"
    end
  end
end
