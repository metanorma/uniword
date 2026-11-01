# frozen_string_literal: true

require "spec_helper"
require "open3"
require "tmpdir"

# CLI coverage for the top-level `to` / `from` verbs (issue #80):
# plain-text editing round trip through the Coradoc bridge.
RSpec.describe Uniword::CLI do
  let(:cli) { described_class.new }
  let(:output_dir) { "tmp/plain_text_cli_spec" }
  let(:input_path) { File.join(output_dir, "report.docx") }
  let(:md_path) { File.join(output_dir, "report.md") }
  let(:adoc_path) { File.join(output_dir, "report.adoc") }
  let(:back_path) { File.join(output_dir, "back.docx") }

  before do
    FileUtils.mkdir_p(output_dir)
    doc = Uniword::Builder::DocumentBuilder.new
    doc.heading("Report", level: 1)
    doc.paragraph("Body paragraph")
    doc.save(input_path)
  end

  after do
    Dir.glob("#{output_dir}/*").each { |f| safe_delete(f) }
  end

  def write_file(name, content)
    path = File.join(output_dir, name)
    File.write(path, content)
    path
  end

  def run_exe(*args)
    exe = File.expand_path("../../../exe/uniword", __dir__)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  describe "#to" do
    it "derives the .md output path from the input" do
      expect do
        cli.invoke(:to, ["md", input_path])
      end.to output(/Converted/).to_stdout

      expect(File).to exist(md_path)
      expect(File.read(md_path)).to include("# Report")
    end

    it "converts to AsciiDoc on request" do
      cli.invoke(:to, ["adoc", input_path])

      expect(File).to exist(adoc_path)
      expect(File.read(adoc_path)).to include("= Report")
    end

    it "writes to stdout with -o -" do
      expect { cli.invoke(:to, ["md", input_path], output: "-") }
        .to output(/^# Report/).to_stdout
    end

    it "prints the JSON report with --json" do
      out_path = File.join(output_dir, "report.json.md")

      expect do
        cli.invoke(:to, ["md", input_path], output: out_path, json: true)
      end.to output(/"direction": "docx_to_markdown"/).to_stdout

      expect(File).to exist(out_path)
    end

    it "rejects --json with -o -" do
      expect do
        cli.invoke(:to, ["md", input_path], output: "-", json: true)
      end.to output(/--json cannot be combined/).to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it "rejects unknown formats" do
      expect do
        cli.invoke(:to, ["rtf", input_path])
      end.to output(/Unsupported operation/).to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it "reports a missing input file" do
      expect do
        cli.invoke(:to, ["md", File.join(output_dir, "nope.docx")])
      end.to output(/File not found/).to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it "exits 1 through exe/uniword on strict fidelity loss" do
      commented = Uniword::Builder::DocumentBuilder.new
      commented.paragraph("Anchored")
      commented.comment(author: "Reviewer", text: "Fix this")
      commented_path = File.join(output_dir, "commented.docx")
      commented.save(commented_path)

      out, _err, status = run_exe("to", "md", commented_path,
                                  "-o", md_path, "--strict")

      expect(status.exitstatus).to eq(1)
      expect(out).to include("Strict markdown conversion would drop")
    end
  end

  describe "#from" do
    it "derives the .docx output path from the input" do
      md = write_file("notes.md", "# Notes\n\n- one\n- two\n")

      expect do
        cli.invoke(:from, ["md", md])
      end.to output(/Converted/).to_stdout

      docx_path = File.join(output_dir, "notes.docx")
      expect(File).to exist(docx_path)
      loaded = Uniword::DocumentFactory.from_file(docx_path)
      expect(loaded.body.paragraphs.first.text).to eq("Notes")
    end

    it "writes to -o when given" do
      adoc = write_file("notes.adoc", "== Notes\n\nA paragraph.\n")

      cli.invoke(:from, ["adoc", adoc], output: back_path)

      loaded = Uniword::DocumentFactory.from_file(back_path)
      expect(loaded.body.paragraphs.first.text).to eq("Notes")
    end

    it "prints the JSON report with --json" do
      md = write_file("json.md", "# T\n\nText.\n")

      expect do
        cli.invoke(:from, ["md", md], json: true)
      end.to output(/"direction": "markdown_to_docx"/).to_stdout
    end

    it "reports a missing input file" do
      expect do
        cli.invoke(:from, ["md", File.join(output_dir, "nope.md")])
      end.to output(/File not found/).to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end
end
