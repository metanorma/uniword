# frozen_string_literal: true

module Uniword
  module Template
    module Helpers
      autoload :ConditionalHelper, "#{__dir__}/helpers/conditional_helper"
      autoload :LoopHelper, "#{__dir__}/helpers/loop_helper"
      autoload :VariableHelper, "#{__dir__}/helpers/variable_helper"
      autoload :FilterHelper, "#{__dir__}/helpers/filter_helper"
    end
  end
end
