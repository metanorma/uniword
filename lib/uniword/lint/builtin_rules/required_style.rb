# frozen_string_literal: true

module Uniword
  module Lint
    module BuiltinRules
      # Rule: required style presence. Triggers when the named style
      # is missing from the document.
      class RequiredStyle < Rule
        register :required_style, self

        # @param style_id [String, Array<String>] required styleId(s)
        def initialize(style_id:, **rest)
          super(**rest)
          @required = Array(style_id)
        end

        def check(document)
          present = document.styles_configuration&.styles&.map(&:styleId) || []
          @required.each do |id|
            next if present.include?(id)

            yield finding(
              message: "Required style '#{id}' is missing",
              path: "styles.xml",
            )
          end
        end
      end
    end
  end
end
