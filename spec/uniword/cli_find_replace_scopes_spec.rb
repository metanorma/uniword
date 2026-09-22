# frozen_string_literal: true

require "spec_helper"
require "open3"
require "tmpdir"

# Walker fix (TODO.fix/10): find-replace and redact must survive
# documents with tables, and replace inside headers/footers.
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:dir) { Dir.mktmpdir }
  let(:output) { File.join(dir, "output.docx") }

  let(:table_doc) do
    path = File.join(dir, "tables.docx")
    builder = Uniword::Builder::DocumentBuilder.new
    builder.paragraph("Body text with target word")
    builder.table do |table|
      table.row do |row|
        row.cell(text: "Cell contains target word")
        row.cell(text: "No match here")
      end
    end
    builder.save(path)
    path
  end

  let(:header_doc) do
    path = File.join(dir, "headers.docx")
    builder = Uniword::Builder::DocumentBuilder.new
    builder.paragraph("Body text")
    builder.header { |header| header.paragraph("Confidential header") }
    builder.save(path)
    path
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  it "find-replace walks table cell text" do
    out, _err, status = run_cli("find-replace", table_doc, output,
                                "target", "replaced")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Replaced 2 match(es)")
    expect(File.exist?(output)).to be(true)
  end

  it "find-replace replaces header text when scoped to headers" do
    out, _err, status = run_cli(
      "find-replace", header_doc, output, "Confidential", "Secret",
      "--scope", "headers"
    )
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Replaced 1 match(es)")
  end

  it "find-replace header result contains the replaced text" do
    _out, _err, _status = run_cli(
      "find-replace", header_doc, output, "Confidential", "Secret",
      "--scope", "headers"
    )
    listed, = run_cli("headers", "list", output)
    expect(listed).to include("Secret header")
  end

  it "redact runs on documents with tables" do
    out, _err, status = run_cli("redact", table_doc, output)
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Redacted")
    expect(File.exist?(output)).to be(true)
  end
end
