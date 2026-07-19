# frozen_string_literal: true

require "spec_helper"
require "zip"

# CLI coverage for `uniword theme fonts|colors` (Design → Fonts/Colors
# style scheme switching on an existing document).
RSpec.describe Uniword::ThemeCLI do
  let(:cli) { described_class.new }
  let(:output_dir) { "tmp/theme_cli_spec" }
  let(:input_path) { File.join(output_dir, "input.docx") }

  before do
    FileUtils.mkdir_p(output_dir)
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph { |p| p << "scheme cli spec" }
    doc.save(input_path)
  end

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  describe "#fonts" do
    it "applies a bundled font scheme and saves" do
      output_path = File.join(output_dir, "fonts.docx")

      expect do
        cli.invoke(:fonts, [input_path, output_path], name: "carlito_sans")
      end.to output(/Font scheme 'carlito_sans' applied/).to_stdout

      theme_xml = Zip::File.open(output_path) do |z|
        z.read("word/theme/theme1.xml")
      end
      expect(theme_xml).to include('typeface="Carlito"')
    end

    it "lists available font schemes with --list" do
      expect { cli.invoke(:fonts, [], list: true) }
        .to output(/carlito_sans/).to_stdout
    end
  end

  describe "#colors" do
    it "applies a bundled color scheme and saves" do
      output_path = File.join(output_dir, "colors.docx")

      expect do
        cli.invoke(:colors, [input_path, output_path], name: "emerald")
      end.to output(/Color scheme 'emerald' applied/).to_stdout

      theme_xml = Zip::File.open(output_path) do |z|
        z.read("word/theme/theme1.xml")
      end
      expect(theme_xml).to include('val="2D6A4F"')
    end

    it "exits with error when --name is missing" do
      expect do
        cli.invoke(:colors, [input_path, File.join(output_dir, "x.docx")])
      end.to raise_error(SystemExit)
    end
  end
end
