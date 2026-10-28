# frozen_string_literal: true

require "spec_helper"

# POSIX NO_COLOR convention (TODO.fix/07).
RSpec.describe Uniword::Cli::NoColor do
  around do |example|
    old = ENV.fetch("NO_COLOR", nil)
    ENV["NO_COLOR"] = "1"
    # Re-apply the prepend with the variable set (idempotent).
    Thor::Shell::Basic.prepend(described_class) unless
      described_class >= Thor::Shell::Basic
    example.run
  ensure
    ENV["NO_COLOR"] = old
  end

  it "forces Thor's shell color? to false" do
    expect(Thor::Shell::Basic.new.color?).to be(false)
  end

  it "answers color requests made through a script" do
    shell = Thor::Shell::Basic.new
    expect(shell.set_color("x", :red)).to eq("x")
  end
end
