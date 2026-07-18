# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::SharedTypes::PixelMeasure do
  it "accepts a non-negative value and serializes it unchanged" do
    measure = described_class.new(val: 96)
    expect(measure.to_xml).to include('val="96"')
  end

  it "rejects a negative value at assignment" do
    expect { described_class.new(val: -1) }
      .to raise_error(Lutaml::Model::Type::MinBoundError)
  end
end
