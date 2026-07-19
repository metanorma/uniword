# frozen_string_literal: true

module Uniword
  module Validation
    # The single validation engine.
    #
    # Runs the rules registered in Rules::Registry against a validation
    # context and returns Report::ValidationIssue results. One engine, two
    # front-ends:
    #
    # - On-disk (post-save): Rules::DocumentContext wraps the DOCX package;
    #   driven by Validators::DocumentSemanticsValidator (verify layer 3).
    # - In-memory (pre-save): Rules::ModelContext wraps the document model;
    #   driven by Wordprocessingml::DocumentRoot#valid? and CLI `validate`.
    #
    # Rules declare which context they consume via Rules::Base#context_type
    # (:package or :model); only matching rules run.
    module Engine
      # Run every rule matching the context's type.
      #
      # @param context [Rules::DocumentContext, Rules::ModelContext]
      #   validation context; its #context_type selects the rule set
      # @param rules [Array<Rules::Base>] candidate rules
      # @return [Array<Report::ValidationIssue>] issues found
      def self.run(context, rules: Rules::Registry.all)
        rules.each_with_object([]) do |rule, issues|
          next unless rule.context_type == context.context_type
          next unless rule.applicable?(context)

          issues.concat(rule.check(context))
        end
      end
    end
  end
end
