# frozen_string_literal: true

require "spec_helper"
require "uniword/validation/report/validation_issue"

RSpec.describe Uniword::Validation::Report::ValidationIssue do
  describe "attributes" do
    it "creates an issue with all attributes" do
      issue = described_class.new(
        severity: "error",
        code: "OPC-001",
        message: "Cannot open ZIP file",
        part: "document.docx",
        line: 42,
        suggestion: "Ensure the file is a valid .docx archive."
      )

      expect(issue.severity).to eq("error")
      expect(issue.code).to eq("OPC-001")
      expect(issue.message).to eq("Cannot open ZIP file")
      expect(issue.part).to eq("document.docx")
      expect(issue.line).to eq(42)
      expect(issue.suggestion).to eq("Ensure the file is a valid .docx archive.")
    end

    it "defaults optional attributes to nil" do
      issue = described_class.new(
        severity: "warning",
        code: "DOC-070",
        message: "Font not found"
      )

      expect(issue.part).to be_nil
      expect(issue.line).to be_nil
      expect(issue.suggestion).to be_nil
    end
  end

  describe "severity predicates" do
    it "identifies errors" do
      issue = described_class.new(severity: "error", code: "T", message: "t")
      expect(issue).to be_error
      expect(issue).not_to be_warning
    end

    it "identifies warnings" do
      issue = described_class.new(severity: "warning", code: "T", message: "t")
      expect(issue).to be_warning
      expect(issue).not_to be_error
    end

    it "identifies info" do
      issue = described_class.new(severity: "info", code: "T", message: "t")
      expect(issue).to be_info
    end

    it "identifies notices" do
      issue = described_class.new(severity: "notice", code: "T", message: "t")
      expect(issue).to be_notice
    end
  end

  describe "JSON serialization" do
    it "serializes to JSON" do
      issue = described_class.new(
        severity: "error",
        code: "DOC-020",
        message: "footnotes.xml is missing",
        part: "word/settings.xml",
        suggestion: "Add footnotes.xml"
      )

      json = issue.to_json
      parsed = JSON.parse(json)

      expect(parsed["severity"]).to eq("error")
      expect(parsed["code"]).to eq("DOC-020")
      expect(parsed["message"]).to eq("footnotes.xml is missing")
      expect(parsed["part"]).to eq("word/settings.xml")
      expect(parsed["suggestion"]).to eq("Add footnotes.xml")
    end
  end
end
