# frozen_string_literal: true

require "lutaml/model"
require "time"
require_relative "validation_issue"
require_relative "layer_result"

module Uniword
  module Validation
    module Report
      # Full verification report for a DOCX file.
      #
      # Aggregates results from all validation layers (OPC, XSD, Word Document).
      # Serializable to JSON and YAML via lutaml-model.
      #
      # @example Create a report
      #   report = VerificationReport.new(
      #     file_path: "document.docx",
      #     valid: true,
      #     duration_ms: 80,
      #     layers: [layer1, layer2, layer3]
      #   )
      #   puts report.to_json
      class VerificationReport < Lutaml::Model::Serializable
        attribute :file_path, :string
        attribute :timestamp, :string
        attribute :valid, :boolean
        attribute :duration_ms, :integer
        attribute :layers, LayerResult, collection: true

        json do
          map "file_path", to: :file_path
          map "timestamp", to: :timestamp
          map "valid", to: :valid
          map "duration_ms", to: :duration_ms
          map "layers", to: :layers
        end

        def initialize(attributes = {})
          super
          self.timestamp ||= Time.now.utc.iso8601
        end

        def all_issues
          layers.flat_map(&:issues)
        end

        def all_errors
          all_issues.select(&:error?)
        end

        def all_warnings
          all_issues.select(&:warning?)
        end

        def all_infos
          all_issues.select(&:info?)
        end

        def all_notices
          all_issues.select(&:notice?)
        end
      end
    end
  end
end
