# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::NumberingBuilder do
  it "inherits from BaseBuilder" do
    expect(described_class).to be < Uniword::Builder::BaseBuilder
  end

  it "creates a NumberingConfiguration by default" do
    nb = described_class.new
    expect(nb.model).to be_a(Uniword::Wordprocessingml::NumberingConfiguration)
  end

  describe "#build" do
    it "returns the underlying model" do
      nb = described_class.new
      expect(nb.build).to eq(nb.model)
    end
  end

  describe ".from_model" do
    it "wraps an existing model" do
      model = Uniword::Wordprocessingml::NumberingConfiguration.new
      nb = described_class.from_model(model)
      expect(nb.model).to eq(model)
    end
  end
end
