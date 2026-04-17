# frozen_string_literal: true

require "spec_helper"
require "uniword/validation/report/verification_report"
require "uniword/validation/report/layer_result"
require "uniword/validation/report/validation_issue"

RSpec.describe Uniword::Validation::Report::VerificationReport do
  let(:error_issue) do
    Uniword::Validation::Report::ValidationIssue.new(
      severity: "error", code: "DOC-020", message: "footnotes.xml missing"
    )
  end

  let(:warning_issue) do
    Uniword::Validation::Report::ValidationIssue.new(
      severity: "warning", code: "DOC-070", message: "Font not in fontTable"
    )
  end

  describe "valid report" do
    let(:report) do
      described_class.new(
        file_path: "test.docx",
        timestamp: "2026-04-16T12:00:00Z",
        valid: true,
        duration_ms: 50,
        layers: [
          Uniword::Validation::Report::LayerResult.new(
            name: "OPC Package", status: "pass", duration_ms: 10, issues: []
          ),
          Uniword::Validation::Report::LayerResult.new(
            name: "XSD Schema", status: "pass", duration_ms: 20, issues: []
          ),
          Uniword::Validation::Report::LayerResult.new(
            name: "Word Document", status: "pass", duration_ms: 15, issues: []
          )
        ]
      )
    end

    it "reports valid" do
      expect(report.valid).to be true
    end

    it "has three layers" do
      expect(report.layers.size).to eq(3)
    end

    it "has no errors" do
      expect(report.all_errors).to be_empty
    end

    it "has no warnings" do
      expect(report.all_warnings).to be_empty
    end

    it "serializes to JSON" do
      parsed = JSON.parse(report.to_json)
      expect(parsed["valid"]).to be true
      expect(parsed["file_path"]).to eq("test.docx")
      expect(parsed["layers"].size).to eq(3)
    end
  end

  describe "invalid report" do
    let(:report) do
      described_class.new(
        file_path: "bad.docx",
        timestamp: "2026-04-16T12:00:00Z",
        valid: false,
        duration_ms: 100,
        layers: [
          Uniword::Validation::Report::LayerResult.new(
            name: "OPC Package", status: "fail", duration_ms: 10,
            issues: [error_issue]
          ),
          Uniword::Validation::Report::LayerResult.new(
            name: "Word Document", status: "fail", duration_ms: 15,
            issues: [warning_issue]
          )
        ]
      )
    end

    it "reports invalid" do
      expect(report.valid).to be false
    end

    it "collects all errors across layers" do
      expect(report.all_errors.size).to eq(1)
      expect(report.all_errors.first.code).to eq("DOC-020")
    end

    it "collects all warnings across layers" do
      expect(report.all_warnings.size).to eq(1)
      expect(report.all_warnings.first.code).to eq("DOC-070")
    end

    it "counts total issues" do
      expect(report.all_issues.size).to eq(2)
    end
  end
end
