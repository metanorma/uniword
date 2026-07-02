# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::DeterministicId do
  subject(:instance) { test_class.new }

  let(:test_class) do
    Class.new do
      include Uniword::Builder::DeterministicId
    end
  end

  it "returns an integer" do
    expect(instance.deterministic_id("seed")).to be_an(Integer)
  end

  it "is deterministic for the same seed across runs" do
    a = instance.deterministic_id("image", "/path/to/file.png")
    b = instance.deterministic_id("image", "/path/to/file.png")
    expect(a).to eq(b)
  end

  it "is deterministic across instances" do
    a = test_class.new.deterministic_id("x")
    b = test_class.new.deterministic_id("x")
    expect(a).to eq(b)
  end

  it "returns different IDs for different seeds" do
    a = instance.deterministic_id("image", "a.png")
    b = instance.deterministic_id("image", "b.png")
    expect(a).not_to eq(b)
  end

  it "accepts multiple seeds joined by colon" do
    a = instance.deterministic_id("chart", "bar", "rId1")
    b = instance.deterministic_id("chart", "bar", "rId2")
    expect(a).not_to eq(b)
  end

  it "produces a value under 1 billion" do
    expect(instance.deterministic_id("any", "seed")).to be < 1_000_000_000
  end

  it "is included by ImageBuilder and ChartBuilder" do
    expect(Uniword::Builder::ImageBuilder.ancestors)
      .to include(described_class)
    expect(Uniword::Builder::ChartBuilder.ancestors)
      .to include(described_class)
  end
end
