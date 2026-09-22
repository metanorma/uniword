# frozen_string_literal: true

require "spec_helper"
require "json"
require "open3"

# Report-contract fix (TODO.fix/09): `check` must run both checkers,
# report real counts, honor --verbose for both, and exit 1 only when
# error-level findings exist.
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:fixture) do
    File.expand_path("../fixtures/blank/blank.docx", __dir__)
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  it "runs both checkers on a document with findings" do
    out, _err, status = run_cli("check", fixture)
    expect(status.exitstatus).to eq(1)
    expect(out).to include("Quality:").and include("Accessibility:")
    expect(out).not_to include("Unexpected error")
  end

  it "exits 0 when the requested checker has no error-level findings" do
    out, _err, status = run_cli("check", fixture, "--type", "quality")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Quality: No issues found")
  end

  it "emits JSON with valid/issues for every requested report" do
    out, _err, status = run_cli("check", fixture, "--json")
    expect(status.exitstatus).to eq(1)
    report = JSON.parse(out)
    expect(report.keys).to contain_exactly("quality", "accessibility")
    expect(report["quality"]).to eq("valid" => true, "issues" => 0)
  end

  it "marks failing reports invalid in JSON" do
    out, _err, _status = run_cli("check", fixture, "--json")
    report = JSON.parse(out)
    expect(report["accessibility"]["valid"]).to be(false)
    expect(report["accessibility"]["issues"]).to be_a(Integer)
  end

  it "lists individual findings with --verbose" do
    out, _err, status = run_cli("check", fixture, "--verbose")
    expect(status.exitstatus).to eq(1)
    expect(out).to match(/^  - \S+/)
    expect(out).not_to include("Unexpected error")
  end
end
