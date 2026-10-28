# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Cli::Completions do
  subject(:script) { described_class.script(shell, root: Uniword::CLI) }

  let(:expected_commands) do
    %w[convert info validate tree version]
  end

  context "with bash" do
    let(:shell) { "bash" }

    it "lists the top-level commands" do
      expected_commands.each { |c| expect(script).to include(c) }
    end

    it "registers the completion function" do
      expect(script).to include("complete -F _uniword uniword")
    end

    it "includes nested subcommand words for images" do
      %w[tree list extract insert remove].each do |w|
        expect(script).to include(w)
      end
    end
  end

  context "with zsh" do
    let(:shell) { "zsh" }

    it "starts with a #compdef directive" do
      expect(script).to start_with("#compdef uniword")
    end

    it "lists the top-level commands" do
      expect(script).to include("'convert'")
    end
  end

  context "with fish" do
    let(:shell) { "fish" }

    it "emits one complete call per command" do
      expect(script).to include("complete -c uniword")
      expect(script).to include("-a 'convert'")
    end
  end

  context "with an unsupported shell" do
    let(:shell) { "tcsh" }

    it "raises ArgumentError" do
      expect { script }.to raise_error(ArgumentError, /unsupported shell/)
    end
  end

  it "includes newly registered commands automatically" do
    expect(script_for_root_commands).to be true
  end

  private

  def script_for_root_commands
    Uniword::CLI.all_commands.keys.all? do |cmd|
      described_class.script("bash", root: Uniword::CLI).include?(cmd) ||
        described_class::BUILTINS.include?(cmd)
    end
  end
end
