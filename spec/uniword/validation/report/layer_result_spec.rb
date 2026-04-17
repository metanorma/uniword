# frozen_string_literal: true

require "spec_helper"
require "uniword/validation/report/layer_result"
require "uniword/validation/report/validation_issue"

RSpec.describe Uniword::Validation::Report::LayerResult do
  let(:error_issue) do
    Uniword::Validation::Report::ValidationIssue.new(
      severity: "error", code: "OPC-001", message: "ZIP error"
    )
  end

  let(:warning_issue) do
    Uniword::Validation::Report::ValidationIssue.new(
      severity: "warning", code: "OPC-005", message: "Missing content type"
    )
  end

  let(:info_issue) do
    Uniword::Validation::Report::ValidationIssue.new(
      severity: "info", code: "XSD-003", message: "Unknown namespace"
    )
  end

  describe "pass/fail predicates" do
    it "passes when status is pass" do
      layer = described_class.new(
        name: "OPC Package", status: "pass", duration_ms: 10, issues: []
      )

      expect(layer).to be_pass
      expect(layer).not_to be_fail
    end

    it "fails when status is fail" do
      layer = described_class.new(
        name: "OPC Package", status: "fail", duration_ms: 10, issues: [error_issue]
      )

      expect(layer).to be_fail
      expect(layer).not_to be_pass
    end

    it "is skipped when status is skipped" do
      layer = described_class.new(
        name: "XSD Schema", status: "skipped", duration_ms: 0, issues: []
      )

      expect(layer).not_to be_pass
      expect(layer).not_to be_fail
    end
  end

  describe "issue filtering" do
    let(:layer) do
      described_class.new(
        name: "Test Layer",
        status: "fail",
        duration_ms: 50,
        issues: [error_issue, warning_issue, info_issue]
      )
    end

    it "filters errors" do
      expect(layer.errors.size).to eq(1)
      expect(layer.errors.first.code).to eq("OPC-001")
    end

    it "filters warnings" do
      expect(layer.warnings.size).to eq(1)
      expect(layer.warnings.first.code).to eq("OPC-005")
    end

    it "filters infos" do
      expect(layer.infos.size).to eq(1)
      expect(layer.infos.first.code).to eq("XSD-003")
    end
  end

  describe "JSON serialization" do
    it "serializes to JSON" do
      layer = described_class.new(
        name: "OPC Package",
        status: "pass",
        duration_ms: 15,
        issues: []
      )

      parsed = JSON.parse(layer.to_json)
      expect(parsed["name"]).to eq("OPC Package")
      expect(parsed["status"]).to eq("pass")
      expect(parsed["duration_ms"]).to eq(15)
      # lutaml-model omits empty collections from JSON
      expect(parsed["issues"]).to be_nil
    end
  end
end
