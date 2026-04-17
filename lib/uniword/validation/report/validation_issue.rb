# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Validation
    module Report
      # A single validation issue (error, warning, info, or notice).
      #
      # Represents one finding from a validation rule, including
      # an actionable suggestion for resolution.
      #
      # @example Create an error issue
      #   ValidationIssue.new(
      #     severity: "error",
      #     code: "DOC-020",
      #     message: "settings.xml declares footnotePr but footnotes.xml is missing",
      #     part: "word/settings.xml",
      #     suggestion: "Add a minimal footnotes.xml with separator entries..."
      #   )
      class ValidationIssue < Lutaml::Model::Serializable
        attribute :severity, :string
        attribute :code, :string
        attribute :message, :string
        attribute :part, :string
        attribute :line, :integer
        attribute :suggestion, :string

        json do
          map "severity", to: :severity
          map "code", to: :code
          map "message", to: :message
          map "part", to: :part
          map "line", to: :line
          map "suggestion", to: :suggestion
        end

        def error?
          severity == "error"
        end

        def warning?
          severity == "warning"
        end

        def info?
          severity == "info"
        end

        def notice?
          severity == "notice"
        end
      end
    end
  end
end
