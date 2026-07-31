# frozen_string_literal: true

module Uniword
  module Lint
    module BuiltinRules
      # Rule: documents must have a non-empty body.
      class RequireBody < Rule
        register :require_body, self

        def check(document)
          body = document.body
          paragraphs = body&.paragraphs || []
          return if paragraphs.any?

          yield finding(
            message: "Document body is empty",
            path: "word/document.xml",
          )
        end
      end
    end
  end
end
