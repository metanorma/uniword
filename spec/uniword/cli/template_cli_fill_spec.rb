# frozen_string_literal: true

require "spec_helper"
require "open3"
require "tmpdir"

# CLI coverage for `uniword template fill` — mail merge of content
# controls, MERGEFIELD simple fields, and {{var}} text placeholders.
RSpec.describe Uniword::TemplateCLI do
  let(:cli) { described_class.new }
  let(:output_dir) { "tmp/template_cli_fill_spec" }
  let(:input_path) { File.join(output_dir, "letter.docx") }
  let(:filled_path) { File.join(output_dir, "letter.filled.docx") }

  before do
    FileUtils.mkdir_p(output_dir)
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph("Hello {{name}}")
    doc.save(input_path)
    File.write(File.join(output_dir, "data.yml"), "name: World\n")
  end

  after do
    Dir.glob("#{output_dir}/*").each { |f| safe_delete(f) }
  end

  def write_data(name, content)
    path = File.join(output_dir, name)
    File.write(path, content)
    path
  end

  def output_text(path)
    Uniword::DocumentFactory.from_file(path).text
  end

  def run_exe(*args)
    exe = File.expand_path("../../../exe/uniword", __dir__)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  describe "#fill" do
    it "fills placeholders and derives <name>.filled.docx by default" do
      expect do
        cli.invoke(:fill, [input_path],
                   data: File.join(output_dir, "data.yml"))
      end.to output(/Filled document/).to_stdout

      expect(File).to exist(filled_path)
      expect(output_text(filled_path)).to include("Hello World")
    end

    it "writes to -o/--output when given" do
      out_path = File.join(output_dir, "custom.docx")

      cli.invoke(:fill, [input_path],
                 data: File.join(output_dir, "data.yml"), output: out_path)

      expect(output_text(out_path)).to include("Hello World")
    end

    it "accepts JSON data files by extension" do
      json_path = write_data("data.json", JSON.generate("name" => "Monde"))

      cli.invoke(:fill, [input_path], data: json_path)

      expect(output_text(filled_path)).to include("Hello Monde")
    end

    it "prints the JSON report with --json" do
      expect do
        cli.invoke(:fill, [input_path],
                   data: File.join(output_dir, "data.yml"), json: true)
      end.to output(/"total_filled": 1/).to_stdout
    end

    it "reports missing variables but still writes the document" do
      sparse_path = write_data("sparse.yml", "other: x\n")

      expect do
        cli.invoke(:fill, [input_path], data: sparse_path)
      end.to output(/Missing variable\(s\) left untouched: name/).to_stdout

      expect(output_text(filled_path)).to include("{{name}}")
    end

    it "rejects a missing data file" do
      expect do
        cli.invoke(:fill, [input_path],
                   data: File.join(output_dir, "nope.yml"))
      end.to output(/Data file not found/).to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  describe "strict failure (real process)" do
    it "exits 1 through exe/uniword when a variable is missing" do
      sparse_path = write_data("sparse.yml", "other: x\n")

      out, _err, status = run_exe("template", "fill", input_path,
                                  "--data", sparse_path, "--strict")

      expect(status.exitstatus).to eq(1)
      expect(out).to include("Missing template variables")
    end
  end
end
