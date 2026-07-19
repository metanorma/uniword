# frozen_string_literal: true

require "spec_helper"
require "zip"

# CLI coverage for `uniword fonts replace` (Word's Replace Fonts dialog
# as a one-shot command).
RSpec.describe Uniword::FontsCLI do
  let(:cli) { described_class.new }
  let(:output_dir) { "tmp/fonts_cli_spec" }
  let(:input_path) { File.join(output_dir, "input.docx") }

  before do
    FileUtils.mkdir_p(output_dir)
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph do |p|
      p << Uniword::Builder.text("calibri run", font: "Calibri")
    end
    doc.save(input_path)
  end

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  describe "#replace" do
    it "replaces the font and saves through the gate" do
      output_path = File.join(output_dir, "out.docx")

      expect do
        cli.invoke(:replace, [input_path, output_path],
                   from: "Calibri", to: "Carlito")
      end.to output(/Replaced \d+ font reference/).to_stdout

      document_xml = Zip::File.open(output_path) do |z|
        z.read("word/document.xml")
      end
      expect(document_xml).to include('w:ascii="Carlito"')
      expect(document_xml).not_to include('w:ascii="Calibri"')
    end

    it "reports zero replacements when the font is absent" do
      output_path = File.join(output_dir, "out.docx")

      expect do
        cli.invoke(:replace, [input_path, output_path],
                   from: "NoSuchFont", to: "Carlito")
      end.to output(/Replaced 0 font reference/).to_stdout
    end
  end
end
