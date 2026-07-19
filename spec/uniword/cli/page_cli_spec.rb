# frozen_string_literal: true

require "spec_helper"
require "zip"

# CLI coverage for `uniword page setup` — Word's Layout dialog as a
# one-shot command across all sections.
RSpec.describe Uniword::PageCLI do
  let(:cli) { described_class.new }
  let(:output_dir) { "tmp/page_cli_spec" }
  let(:input_path) { File.join(output_dir, "input.docx") }

  before do
    FileUtils.mkdir_p(output_dir)
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph { |p| p << "page cli spec" }
    doc.save(input_path)
  end

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  describe "#setup" do
    it "applies size, orientation and margins through the gate" do
      output_path = File.join(output_dir, "a4.docx")

      expect do
        cli.invoke(:setup, [input_path, output_path],
                   size: "a4", orientation: "landscape", margins: "2cm")
      end.to output(/Page setup applied to 1 section/).to_stdout

      document_xml = Zip::File.open(output_path) do |z|
        z.read("word/document.xml")
      end
      expect(document_xml).to include('w:w="16838"')
      expect(document_xml).to include('w:orient="landscape"')
      expect(document_xml).to include('w:top="1134"')
    end

    it "exits with error when no option is given" do
      expect do
        cli.invoke(:setup, [input_path, File.join(output_dir, "x.docx")])
      end.to raise_error(SystemExit)
    end
  end
end
