# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Uniword::Quality::QualityReport do
  let(:report) { described_class.new }
  let(:error_violation) do
    Uniword::Quality::QualityViolation.new(
      rule: "test_rule",
      severity: :error,
      message: "Error message",
      location: "Line 1",
    )
  end
  let(:warning_violation) do
    Uniword::Quality::QualityViolation.new(
      rule: "test_rule",
      severity: :warning,
      message: "Warning message",
      location: "Line 2",
    )
  end
  let(:info_violation) do
    Uniword::Quality::QualityViolation.new(
      rule: "test_rule",
      severity: :info,
      message: "Info message",
      location: "Line 3",
    )
  end

  describe "#initialize" do
    it "creates empty report with timestamp" do
      expect(report.violations).to be_empty
      expect(report.checked_at).to be_a(Time)
    end
  end

  describe "#add_violation" do
    it "adds violation to report" do
      report.add_violation(error_violation)
      expect(report.violations).to include(error_violation)
    end
  end

  describe "#add_violations" do
    it "adds multiple violations" do
      violations = [error_violation, warning_violation]
      report.add_violations(violations)
      expect(report.violations.size).to eq(2)
    end
  end

  describe "#valid?" do
    it "returns true when no errors" do
      expect(report.valid?).to be true
    end

    it "returns true with warnings but no errors" do
      report.add_violation(warning_violation)
      expect(report.valid?).to be true
    end

    it "returns false when errors present" do
      report.add_violation(error_violation)
      expect(report.valid?).to be false
    end
  end

  describe "violation counts" do
    before do
      report.add_violations([error_violation, warning_violation,
                             info_violation])
    end

    it "counts errors" do
      expect(report.error_count).to eq(1)
    end

    it "counts warnings" do
      expect(report.warning_count).to eq(1)
    end

    it "counts info" do
      expect(report.info_count).to eq(1)
    end

    it "counts total" do
      expect(report.total_count).to eq(3)
    end
  end

  describe "#by_severity" do
    before do
      report.add_violations([error_violation, warning_violation,
                             info_violation])
    end

    it "groups violations by severity" do
      grouped = report.by_severity
      expect(grouped[:error]).to include(error_violation)
      expect(grouped[:warning]).to include(warning_violation)
      expect(grouped[:info]).to include(info_violation)
    end
  end

  describe "#by_rule" do
    let(:another_violation) do
      Uniword::Quality::QualityViolation.new(
        rule: "other_rule",
        severity: :error,
        message: "Test",
        location: "Test",
      )
    end

    before do
      report.add_violations([error_violation, warning_violation,
                             another_violation])
    end

    it "groups violations by rule" do
      grouped = report.by_rule
      expect(grouped["test_rule"].size).to eq(2)
      expect(grouped["other_rule"].size).to eq(1)
    end
  end

  describe "#to_json" do
    before do
      report.add_violation(error_violation)
    end

    it "generates JSON string" do
      json = report.to_json
      expect(json).to be_a(String)
      parsed = JSON.parse(json)
      expect(parsed["summary"]["total"]).to eq(1)
      expect(parsed["summary"]["errors"]).to eq(1)
      expect(parsed["violations"]).to be_an(Array)
    end

    it "writes JSON to file" do
      Tempfile.create(["report", ".json"]) do |file|
        report.to_json(file.path)
        content = File.read(file.path)
        parsed = JSON.parse(content)
        expect(parsed["summary"]["total"]).to eq(1)
      end
    end
  end

  describe "#to_yaml" do
    before do
      report.add_violation(error_violation)
    end

    it "generates YAML string" do
      yaml = report.to_yaml
      expect(yaml).to be_a(String)
      parsed = YAML.safe_load(yaml, permitted_classes: [Symbol])
      expect(parsed["summary"]["total"]).to eq(1)
    end

    it "writes YAML to file" do
      Tempfile.create(["report", ".yml"]) do |file|
        report.to_yaml(file.path)
        content = File.read(file.path)
        parsed = YAML.safe_load(content, permitted_classes: [Symbol])
        expect(parsed["summary"]["total"]).to eq(1)
      end
    end
  end

  describe "#export_html" do
    before do
      report.add_violations([error_violation, warning_violation])
    end

    it "generates HTML report" do
      Tempfile.create(["report", ".html"]) do |file|
        html = report.export_html(file.path)
        expect(html).to include("<!DOCTYPE html>")
        expect(html).to include("Document Quality Report")
        expect(html).to include("Error message")
        expect(html).to include("Warning message")
        expect(File.read(file.path)).to eq(html)
      end
    end
  end

  describe "#summary" do
    before do
      report.add_violations([error_violation, warning_violation])
    end

    it "generates text summary" do
      summary = report.summary
      expect(summary).to include("Document Quality Report")
      expect(summary).to include("Total violations: 2")
      expect(summary).to include("Errors: 1")
      expect(summary).to include("Warnings: 1")
      expect(summary).to include("INVALID")
    end
  end
end
