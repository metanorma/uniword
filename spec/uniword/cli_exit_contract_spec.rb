# frozen_string_literal: true

require "spec_helper"
require "open3"

# End-to-end CLI contract: real process exit codes through `exe/uniword`.
# Exit statuses cannot be asserted in-process (SystemExit from nested
# starts), so these spawn the real executable.
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:fixture) do
    File.expand_path("../fixtures/blank/blank.docx", __dir__)
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  it "exits 0 on successful conversion" do
    out_path = File.join(Dir.mktmpdir, "contract_out.html")
    _out, _err, status = run_cli("convert", fixture, out_path)
    expect(status.exitstatus).to eq(0)
    expect(File).to exist(out_path)
  end

  it "exits 1 when the input file is missing" do
    _out, _err, status = run_cli("convert", "/nonexistent.docx",
                                 "/tmp/leptris-eval/contract_x.html")
    expect(status.exitstatus).to eq(1)
  end

  it "exits 1 when the output extension is unsupported" do
    _out, _err, status = run_cli("convert", fixture,
                                 "/tmp/leptris-eval/contract_x.xyz")
    expect(status.exitstatus).to eq(1)
  end

  it "exits 0 for --version and uniword version" do
    _out, _err, status = run_cli("--version")
    expect(status.exitstatus).to eq(0)
    _out, _err, status = run_cli("version")
    expect(status.exitstatus).to eq(0)
  end

  it "exits 1 on unknown commands" do
    _out, _err, status = run_cli("definitely-not-a-command")
    expect(status.exitstatus).to eq(1)
  end
end
