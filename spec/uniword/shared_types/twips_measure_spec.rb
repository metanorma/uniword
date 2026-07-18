# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::SharedTypes::TwipsMeasure do
  it "accepts a non-negative value and serializes it unchanged" do
    measure = described_class.new(val: 240)
    expect(measure.to_xml).to include('val="240"')
  end

  it "rejects a negative value at assignment" do
    expect { described_class.new(val: -9999) }
      .to raise_error(Lutaml::Model::Type::MinBoundError)
  end
end
