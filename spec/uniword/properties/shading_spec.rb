# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::Shading do
  it "accepts valid hex color and fill values" do
    shading = described_class.new(pattern: "clear", color: "auto",
                                  fill: "FFFF00")
    expect(shading.to_xml).to include('fill="FFFF00"')
  end

  it "rejects a non-hex fill at assignment" do
    expect { described_class.new(fill: "yellow") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end

  it "accepts a valid theme fill" do
    shading = described_class.new(fill: "FFFF00", theme_fill: "accent2")
    expect(shading.validate).to be_empty
  end

  it "rejects an out-of-enum theme fill via validate" do
    errors = described_class.new(fill: "FFFF00", theme_fill: "bogus").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end
end
