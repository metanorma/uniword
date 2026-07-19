# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # Base class for in-memory (model-level) validation rules.
      #
      # Model rules run against a Rules::ModelContext — the pre-save
      # front-end of the validation engine — and inspect the document
      # model directly instead of parsing package XML.
      #
      # @example Implement a model rule
      #   class MyModelRule < ModelRule
      #     def code = "DOC-900"
      #
      #     def check(context)
      #       return [] if context.document.body
      #
      #       [issue("Document body is missing")]
      #     end
      #   end
      #
      #   Rules::Registry.register(MyModelRule)
      class ModelRule < Base
        # Model rules consume the in-memory ModelContext.
        #
        # @return [Symbol] :model
        def context_type
          :model
        end
      end
    end
  end
end
