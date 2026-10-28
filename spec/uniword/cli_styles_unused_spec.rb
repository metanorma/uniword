# frozen_string_literal: true

require "spec_helper"
require "open3"
require "tmpdir"

# StyleCleanup walker fix (TODO.fix/13): --unused must survive
# documents whose package carries footnotes (the probing walker
# crashed on note containers).
RSpec.describe Uniword::CLI do
  let(:exe) { File.expand_path("../../exe/uniword", __dir__) }
  let(:dir) { Dir.mktmpdir }
  let(:fixture) do
    File.expand_path("../fixtures/docx_gem/styles.docx", __dir__)
  end

  it "removes unused styles from a footnote-bearing document" do
    output = File.join(dir, "cleaned.docx")
    out, _err, status = Open3.capture3(
      RbConfig.ruby, exe, "styles", "remove", fixture, output, "--unused"
    )
    expect(status.exitstatus).to eq(0)
    expect(out).to match(/Removed \d+ style\(s\)/)
    expect(File.exist?(output)).to be(true)
  end
end
