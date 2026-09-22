# frozen_string_literal: true

require "spec_helper"
require "open3"
require "json"

# stdout piping (TODO.fix/05) and HTML output (TODO.fix/04) through the
# real CLI.
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:fixture) do
    File.expand_path("../fixtures/blank/blank.docx", __dir__)
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  it "writes DOCX bytes to stdout for `-`" do
    out, _err, status = run_cli("convert", fixture, "-")
    expect(status.exitstatus).to eq(0)
    expect(out.byteslice(0, 2)).to eq("PK")
  end

  it "writes MHTML to stdout for `-`" do
    out, _err, status = run_cli("convert", fixture, "-", "--to", "mhtml")
    expect(status.exitstatus).to eq(0)
    expect(out).to include("MIME-Version")
  end

  it "converts docx to html via file output" do
    Dir.mktmpdir do |dir|
      out_path = File.join(dir, "converted.html")
      _out, _err, status = run_cli("convert", fixture, out_path)
      expect(status.exitstatus).to eq(0)
      expect(File.read(out_path)).to match(/<html|<!DOCTYPE/i)
    end
  end

  it "writes HTML to stdout for `-`" do
    out, _err, status = run_cli("convert", fixture, "-", "--to", "html")
    expect(status.exitstatus).to eq(0)
    expect(out).to match(/<html|<!DOCTYPE/i)
  end
end
