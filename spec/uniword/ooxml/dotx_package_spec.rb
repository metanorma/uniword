# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::DotxPackage do
  let(:output_dir) { File.expand_path("../../tmp", __dir__) }
  let(:output_path) { File.join(output_dir, "dotx_gate_spec_output.dotx") }

  let(:document) do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.body = Uniword::Wordprocessingml::Body.new
    doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
      runs: [Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(content: "Template")
      )],
    )
    doc
  end

  before { FileUtils.mkdir_p(output_dir) }

  after do
    safe_delete(output_path)
    Uniword.configuration.reset!
  end

  describe ".to_file integrity gate" do
    it "saves a normal document through DocumentWriter" do
      Uniword::DocumentWriter.new(document).save(output_path)
      expect(File.exist?(output_path)).to be(true)
    end
  end

  describe "#to_file integrity gate" do
    it "raises ValidationError for malformed part content" do
      package = described_class.new
      package.raw_document_xml = "<broken<xml"

      expect { package.to_file(output_path) }
        .to raise_error(Uniword::ValidationError) do |error|
          expect(error.issues.map(&:code)).to include("OPC-008")
        end
    end

    it "writes the file with validate: false" do
      package = described_class.new
      package.raw_document_xml = "<broken<xml"
      package.to_file(output_path, validate: false)

      expect(File.exist?(output_path)).to be(true)
    end
  end
end
