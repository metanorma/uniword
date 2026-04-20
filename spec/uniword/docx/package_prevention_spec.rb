# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"
require "uniword/validation/verify_orchestrator"
require "zip"

RSpec.describe "DOCX prevention layer" do
  let(:valid_docx) { "spec/fixtures/blank/blank.docx" }

  describe "footnote_pr without footnotes" do
    it "adds footnotes.xml to the output ZIP" do
      skip "blank.docx not available" unless File.exist?(valid_docx)

      package = Uniword::Docx::Package.from_file(valid_docx)
      package.settings ||= Uniword::Wordprocessingml::Settings.new
      package.settings.footnote_pr = Uniword::Wordprocessingml::FootnotePr.new
      package.footnotes = nil

      output_path = "test_output/prevention_footnote_test.docx"
      FileUtils.mkdir_p(File.dirname(output_path))
      package.to_file(output_path)

      # Verify footnotes.xml exists in the ZIP
      has_footnotes = false
      Zip::File.open(output_path) do |zip|
        has_footnotes = zip.find_entry("word/footnotes.xml").nil?
      end

      expect(has_footnotes).to be false

      FileUtils.rm_f(output_path)
    end
  end

  describe "round-trip with footnote-err fixture" do
    it "produces a valid DOCX without DOC-020 errors" do
      sample = "spec/fixtures/hello-world-footnote-err.docx"

      package = Uniword::Docx::Package.from_file(sample)
      output_path = "test_output/prevention_roundtrip.docx"
      FileUtils.mkdir_p(File.dirname(output_path))
      package.to_file(output_path)

      # Verify with the validator
      orchestrator = Uniword::Validation::VerifyOrchestrator.new
      report = orchestrator.verify(output_path)

      doc020_issues = report.layers.flat_map(&:issues).select { |i| i.code == "DOC-020" }
      expect(doc020_issues).to be_empty

      FileUtils.rm_f(output_path)
    end
  end

  describe "footnotes without footnote_pr" do
    it "adds footnotePr to settings in the output" do
      skip "blank.docx not available" unless File.exist?(valid_docx)

      package = Uniword::Docx::Package.from_file(valid_docx)
      package.settings ||= Uniword::Wordprocessingml::Settings.new
      package.settings.footnote_pr = nil
      package.footnotes = Uniword::Wordprocessingml::Footnotes.new(
        footnote_entries: [
          Uniword::Wordprocessingml::Footnote.new(
            id: "1", paragraphs: [Uniword::Wordprocessingml::Paragraph.new]
          )
        ]
      )

      output_path = "test_output/prevention_fn_reverse.docx"
      FileUtils.mkdir_p(File.dirname(output_path))
      package.to_file(output_path)

      expect(package.settings.footnote_pr).not_to be_nil

      FileUtils.rm_f(output_path)
    end
  end
end
