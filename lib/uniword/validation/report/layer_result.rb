# frozen_string_literal: true

require "lutaml/model"
require_relative "validation_issue"

module Uniword
  module Validation
    module Report
      # Result from a single validation layer.
      #
      # Contains the layer name, pass/fail status, timing, and all issues found.
      #
      # @example Create a passing layer result
      #   LayerResult.new(
      #     name: "OPC Package",
      #     status: "pass",
      #     duration_ms: 12,
      #     issues: []
      #   )
      class LayerResult < Lutaml::Model::Serializable
        attribute :name, :string
        attribute :status, :string
        attribute :duration_ms, :integer
        attribute :issues, ValidationIssue, collection: true

        json do
          map "name", to: :name
          map "status", to: :status
          map "duration_ms", to: :duration_ms
          map "issues", to: :issues
        end

        def pass?
          status == "pass"
        end

        def fail?
          status == "fail"
        end

        def errors
          issues.select(&:error?)
        end

        def warnings
          issues.select(&:warning?)
        end

        def infos
          issues.select(&:info?)
        end

        def notices
          issues.select(&:notice?)
        end
      end
    end
  end
end
