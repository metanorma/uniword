# frozen_string_literal: true

require "spec_helper"
require "uniword/validation/verify_orchestrator"

RSpec.describe Uniword::Validation::VerifyOrchestrator do
  let(:valid_docx) { "spec/fixtures/blank/blank.docx" }

  describe "valid DOCX" do
    it "returns a valid report" do
      orchestrator = described_class.new
      report = orchestrator.verify(valid_docx)

      expect(report.valid).to be true
      expect(report.file_path).to eq(valid_docx)
      expect(report.layers.size).to eq(3)
    end

    it "all layers pass" do
      orchestrator = described_class.new
      report = orchestrator.verify(valid_docx)

      report.layers.each do |layer|
        expect(layer).to be_pass,
                         "Expected #{layer.name} to pass, got #{layer.status}"
      end
    end

    it "tracks timing" do
      orchestrator = described_class.new
      report = orchestrator.verify(valid_docx)

      expect(report.duration_ms).to be >= 0
      report.layers.each do |layer|
        expect(layer.duration_ms).to be >= 0
      end
    end
  end

  describe "invalid DOCX" do
    it "reports errors for non-ZIP files" do
      tmp = Tempfile.new(["test", ".docx"])
      tmp.write("not a zip file")
      tmp.close

      orchestrator = described_class.new
      report = orchestrator.verify(tmp.path)

      expect(report.valid).to be false
      opc_layer = report.layers.first
      expect(opc_layer.name).to eq("OPC Package")
      expect(opc_layer.fail?).to be true

      # Downstream layers should be skipped
      expect(report.layers[1].status).to eq("skipped")
      expect(report.layers[2].status).to eq("skipped")

      tmp.unlink
    end

    it "detects DOC-020 for hello-world-footnote-err.docx" do
      fixture = "spec/fixtures/hello-world-footnote-err.docx"
      orchestrator = described_class.new
      report = orchestrator.verify(fixture)

      expect(report.valid).to be false
      doc_issues = report.layers.flat_map(&:issues)
      doc020 = doc_issues.select { |i| i.code == "DOC-020" }
      expect(doc020).not_to be_empty
    end
  end

  describe "JSON output" do
    it "produces valid JSON" do
      orchestrator = described_class.new
      report = orchestrator.verify(valid_docx)

      json = report.to_json
      parsed = JSON.parse(json)

      expect(parsed["file_path"]).to eq(valid_docx)
      expect(parsed["valid"]).to be true
      expect(parsed["layers"]).to be_an(Array)
    end
  end
end
