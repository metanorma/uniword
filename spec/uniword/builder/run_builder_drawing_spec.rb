# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::RunBuilder, "#drawing" do
  it "appends a drawing without instance_variable_get/set" do
    run = described_class.new
    drawing = Uniword::Wordprocessingml::Drawing.new

    run.drawing(drawing)

    expect(run.model.drawings).to include(drawing)
    expect(run.model.drawings.size).to eq(1)
  end

  it "supports multiple drawings" do
    run = described_class.new
    d1 = Uniword::Wordprocessingml::Drawing.new
    d2 = Uniword::Wordprocessingml::Drawing.new

    run.drawing(d1)
    run.drawing(d2)

    expect(run.model.drawings).to eq([d1, d2])
  end

  it "returns self for chaining" do
    run = described_class.new
    result = run.drawing(Uniword::Wordprocessingml::Drawing.new)
    expect(result).to eq(run)
  end
end
