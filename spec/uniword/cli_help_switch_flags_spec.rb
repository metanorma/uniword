# frozen_string_literal: true

require "spec_helper"
require "open3"

# Help/version flag rewrites (TODO.fix/02, /03): `<task> --help` must
# never collide with required-argument validation.
RSpec.describe Uniword::CLI do
  # Help/version flag rewrites: `<task> --help` must never collide
  # with required-argument validation.
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  it "prints help for `convert --help` (required-arg task)" do
    out, _err, status = run_cli("convert", "--help")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("convert INPUT OUTPUT")
    expect(out).to include("--from")
  end

  it "prints class help for a nested subcommand with --help" do
    out, _err, status = run_cli("images", "add", "--help")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("images")
  end

  it "prints help for -h" do
    _out, _err, status = run_cli("validate", "-h")
    expect(status.exitstatus).to eq(0)
  end

  it "maps --version to the version task" do
    out, _err, status = run_cli("--version")
    expect(status.exitstatus).to eq(0)
    expect(out).to match(/Uniword version \d+\.\d+\.\d+/)
  end

  it "still exits 1 when required args are missing (no help flag)" do
    _out, _err, status = run_cli("convert")
    expect(status.exitstatus).to eq(1)
  end
end
