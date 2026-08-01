# frozen_string_literal: true

require "spec_helper"
require "thor"

RSpec.describe Uniword::Plugin::Registry do
  before { described_class.clear }

  it "registers validators by name" do
    validator = MyValidator.new(name: :no_contractions)
    described_class.register_validator(:no_contractions, validator)
    expect(described_class.validators[:no_contractions]).to equal(validator)
  end

  it "rejects non-Validator objects" do
    expect do
      described_class.register_validator(:bad, Object.new)
    end.to raise_error(ArgumentError)
  end

  it "registers transformers" do
    transformer = MyTransformer.new(name: :strip_rsids)
    described_class.register_transformer(:strip_rsids, transformer)
    expect(described_class.transformers[:strip_rsids]).to equal(transformer)
  end

  it "registers CLI commands" do
    described_class.register_cli_command(:my_cmd, MyCli)
    expect(described_class.cli_commands[:my_cmd]).to eq(MyCli)
  end

  it "clear resets all registries" do
    described_class.register_validator(:x, MyValidator.new(name: :x))
    described_class.clear
    expect(described_class.validators).to be_empty
  end
end

RSpec.describe Uniword::Plugin::Transformer do
  it "validates stage names" do
    expect do
      Class.new(described_class).new(name: :bad, stages: :bogus)
    end.to raise_error(ArgumentError)
  end

  it "accepts multiple stages" do
    t = MyTransformer.new(name: :multi,
                          stages: %i[after_load before_save])
    expect(t.applies_to?(:after_load)).to be(true)
    expect(t.applies_to?(:before_save)).to be(true)
    expect(t.applies_to?(:after_reconcile)).to be(false)
  end
end

RSpec.describe Uniword::Plugin::Loader do
  before { Uniword::Plugin::Registry.clear }

  it "runs only transformers matching the stage" do
    transformer = MyTransformer.new(name: :only_save, stages: :before_save)
    Uniword::Plugin::Registry.register_transformer(:only_save, transformer)
    expect(transformer).to receive(:transform).with(:doc).once
    described_class.run_transformers(document: :doc, stage: :before_save)
  end

  it "skips transformers not matching the stage" do
    transformer = MyTransformer.new(name: :only_load, stages: :after_load)
    Uniword::Plugin::Registry.register_transformer(:only_load, transformer)
    expect(transformer).not_to receive(:transform)
    described_class.run_transformers(document: :doc, stage: :before_save)
  end

  it "yields validators via each_validator" do
    validator = MyValidator.new(name: :v)
    Uniword::Plugin::Registry.register_validator(:v, validator)
    yielded = []
    described_class.each_validator { |v| yielded << v }
    expect(yielded).to eq([validator])
  end
end

# Test fixtures
class MyValidator < Uniword::Plugin::Validator
  def check(_document); end
end

class MyTransformer < Uniword::Plugin::Transformer
  def transform(_document); end
end

class MyCli < Thor; end
