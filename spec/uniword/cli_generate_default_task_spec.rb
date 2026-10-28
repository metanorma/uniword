# frozen_string_literal: true

require "spec_helper"
require "open3"
require "tmpdir"

# Default-task dispatch (TODO.fix/11): `uniword generate IN OUT`
# works without repeating the verb; the doubled form stays valid.
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:dir) { Dir.mktmpdir }

  let(:style_source) do
    path = File.join(dir, "template.docx")
    Uniword::Builder::DocumentBuilder.new.tap do |builder|
      builder.paragraph("Template body")
    end.save(path)
    path
  end

  let(:input) do
    path = File.join(dir, "input.md")
    File.write(path, "# Title\n\nBody text.\n")
    path
  end

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, exe, *args)
  end

  it "dispatches `uniword generate INPUT OUTPUT` to the generate task" do
    output = File.join(dir, "out.docx")
    out, _err, status = run_cli(
      "generate", input, output, "--style-source", style_source
    )
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Generated: #{output}")
    expect(File.exist?(output)).to be(true)
  end

  it "keeps the explicit `generate generate` form working" do
    output = File.join(dir, "out_explicit.docx")
    out, _err, status = run_cli(
      "generate", "generate", input, output, "--style-source", style_source
    )
    expect(status.exitstatus).to eq(0)
    expect(out).to include("Generated: #{output}")
    expect(File.exist?(output)).to be(true)
  end
end
