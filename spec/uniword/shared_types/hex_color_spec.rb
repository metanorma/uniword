# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::SharedTypes::HexColor do
  it "accepts a valid hex color and serializes it unchanged" do
    color = described_class.new(val: "FF0000")
    expect(color.to_xml).to include('val="FF0000"')
  end

  it "accepts auto" do
    expect(described_class.new(val: "auto").val).to eq("auto")
  end

  it "rejects a non-hex value at assignment" do
    expect { described_class.new(val: "not-a-color") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end
end
