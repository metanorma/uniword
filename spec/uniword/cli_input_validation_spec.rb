# frozen_string_literal: true

require "spec_helper"
require "open3"
require "tmpdir"

# Input validation (TODO.fix/14): typos in option values must fail
# loudly with the list of valid values instead of silently no-oping.
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:dir) { Dir.mktmpdir }
  let(:fixture) do
    path = File.join(dir, "doc.docx")
    Uniword::Builder::DocumentBuilder.new
      .tap { |b| b.paragraph("Body text") }.save(path)
    path
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  it "rejects unknown find-replace scopes" do
    out, _err, status = run_cli(
      "find-replace", fixture, File.join(dir, "o.docx"), "x", "y",
      "--scope", "bogus"
    )
    expect(status.exitstatus).to eq(1)
    expect(out).to include("Unknown scope: bogus")
    expect(out).to include("valid: all, body, headers")
  end

  it "rejects invalid regex patterns" do
    out, _err, status = run_cli(
      "find-replace", fixture, File.join(dir, "o.docx"), "[", "y",
      "--regex"
    )
    expect(status.exitstatus).to eq(1)
    expect(out).to include("Invalid regular expression")
  end

  it "rejects unknown check types" do
    out, _err, status = run_cli("check", fixture, "--type", "bogus")
    expect(status.exitstatus).to eq(1)
    expect(out).to include("Unknown check type: bogus")
    expect(out).to include("valid: all, quality, accessibility")
  end

  it "rejects unknown redact patterns" do
    out, _err, status = run_cli(
      "redact", fixture, File.join(dir, "o.docx"), "--pattern", "bogus"
    )
    expect(status.exitstatus).to eq(1)
    expect(out).to include("Unknown pattern: bogus")
    expect(out).to include("valid: pii, ssn, email")
  end

  it "still accepts valid scopes" do
    out, _err, status = run_cli(
      "find-replace", fixture, File.join(dir, "o.docx"), "text", "body",
      "--scope", "body"
    )
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Replaced 1 match(es)")
  end
end
