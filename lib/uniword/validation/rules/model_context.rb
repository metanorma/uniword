# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # In-memory validation context: wraps a document model.
      #
      # Counterpart to DocumentContext (which wraps an on-disk DOCX
      # package). Model-level rules consume this context via the Engine.
      #
      # @example Validate a built document
      #   context = ModelContext.new(document)
      #   issues = Validation::Engine.run(context)
      class ModelContext
        # @return [Wordprocessingml::DocumentRoot] the document model
        attr_reader :document

        # @param document [Wordprocessingml::DocumentRoot] in-memory model
        def initialize(document)
          @document = document
        end

        # Context type used by the Engine to select rules.
        #
        # @return [Symbol] :model — this context wraps an in-memory model
        def context_type
          :model
        end
      end
    end
  end
end
