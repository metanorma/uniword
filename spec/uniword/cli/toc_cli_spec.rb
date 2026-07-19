# frozen_string_literal: true

require "spec_helper"
require "zip"

# CLI coverage for `uniword toc insert/update --update-fields` —
# w:updateFields makes Word refresh fields (TOC, page numbers) when the
# document is opened, no manual F9 needed.
RSpec.describe Uniword::TocCLI do
  let(:cli) { described_class.new }
  let(:output_dir) { "tmp/toc_cli_spec" }
  let(:input_path) { File.join(output_dir, "input.docx") }

  before do
    FileUtils.mkdir_p(output_dir)
    doc = Uniword::Builder::DocumentBuilder.new
    doc.heading("Chapter One", level: 1)
    doc.paragraph { |p| p << "Body one" }
    doc.heading("Chapter Two", level: 1)
    doc.paragraph { |p| p << "Body two" }
    doc.save(input_path)
  end

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  def settings_xml(path)
    Zip::File.open(path) { |z| z.read("word/settings.xml") }
  end

  describe "#insert" do
    it "inserts a TOC and sets w:updateFields by default" do
      output_path = File.join(output_dir, "toc.docx")

      expect do
        cli.invoke(:insert, [input_path], output: output_path)
      end.to output(/TOC inserted with 2 entries/).to_stdout

      xml = settings_xml(output_path)
      expect(xml).to include("<w:updateFields/>")
    end

    it "omits w:updateFields with --no-update-fields" do
      output_path = File.join(output_dir, "toc_no_uf.docx")

      cli.invoke(:insert, [input_path],
                 output: output_path, update_fields: false)

      expect(settings_xml(output_path)).not_to include("updateFields")
    end
  end
end
