# frozen_string_literal: true

require "spec_helper"

# CLI coverage for `uniword styles list` — Word's Styles pane as a
# terminal listing.
RSpec.describe Uniword::StylesCLI do
  let(:cli) { described_class.new }
  let(:fixture) { "spec/fixtures/docx_gem/test_with_style.docx" }

  describe "#list" do
    it "lists styles with id, type and base" do
      expect { cli.invoke(:list, [fixture]) }
        .to output(/Styles in test_with_style\.docx \(\d+\):/).to_stdout
    end

    it "filters by type" do
      expect { cli.invoke(:list, [fixture], type: "table") }
        .to output(/table/).to_stdout
    end

    it "shows formatting details with --verbose" do
      expect { cli.invoke(:list, [fixture], verbose: true) }
        .to output(/name=/).to_stdout
    end
  end

  describe "#remove" do
    let(:output_dir) { "tmp/styles_remove_spec" }
    let(:input_path) { File.join(output_dir, "input.docx") }
    let(:output_path) { File.join(output_dir, "out.docx") }

    before do
      FileUtils.mkdir_p(output_dir)
      doc = Uniword::Builder::DocumentBuilder.new
      doc.define_style("KeepMe", base_on: "Normal") { |s| s.italic(true) }
      doc.paragraph { |p| p << Uniword::Builder.text("x", style: "KeepMe") }
      doc.save(input_path)
    end

    after do
      Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
    end

    it "exits with error without --id or --unused" do
      expect do
        cli.invoke(:remove, [input_path, output_path])
      end.to raise_error(SystemExit)
    end

    it "--unused reports styles to remove and saves" do
      expect do
        cli.invoke(:remove, [input_path, output_path], unused: true)
      end.to output(/Removed \d+ style/).to_stdout

      expect(File.exist?(output_path)).to be(true)
    end

    it "--unused --dry-run lists without saving" do
      expect do
        cli.invoke(:remove, [input_path, output_path],
                   unused: true, dry_run: true)
      end.to output(/Would remove \d+ style/).to_stdout

      expect(File.exist?(output_path)).to be(false)
    end
  end
end
