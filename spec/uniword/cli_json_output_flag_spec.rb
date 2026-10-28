# frozen_string_literal: true

require "spec_helper"
require "json"
require "open3"

# Machine-readable output (TODO.fix/06).
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:fixture) do
    File.expand_path("../fixtures/blank/blank.docx", __dir__)
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  def assert_info_json_shape(stats)
    expect(stats["format"]).to eq("DOCX")
    expect(stats["paragraphs"]).to be_a(Integer)
    expect(stats["text_length"]).to be_a(Integer)
  end

  it "emits valid JSON from `info --json`" do
    out, _err, status = run_cli("info", fixture, "--json")
    expect(status.exitstatus).to eq(0)

    assert_info_json_shape(JSON.parse(out))
  end

  it "emits a valid JSON report from `validate --json`" do
    out, _err, status = run_cli("validate", fixture, "--json")
    expect(status.exitstatus).to eq(0)

    report = JSON.parse(out)
    expect(report["path"]).to eq(fixture)
    expect(report["issues"]).to be_an(Array)
  end

  it "keeps plain `info` textual without --json" do
    out, _err, status = run_cli("info", fixture)
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Document Statistics:")
    expect { JSON.parse(out) }.to raise_error(JSON::ParserError)
  end
end
