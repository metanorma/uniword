# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::ColorValue do
  it "accepts a valid hex color and serializes it unchanged" do
    color = described_class.new(value: "2E74B5")
    expect(color.to_xml).to include('val="2E74B5"')
  end

  it "accepts auto" do
    expect(described_class.new(value: "auto").to_xml)
      .to include('val="auto"')
  end

  it "rejects a non-hex value at assignment" do
    expect { described_class.new(value: "red") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end

  it "accepts a valid theme color" do
    color = described_class.new(value: "FF0000", theme_color: "accent1")
    expect(color.validate).to be_empty
  end

  it "serializes a valid theme color unchanged" do
    color = described_class.new(value: "FF0000", theme_color: "accent1")
    expect(color.to_xml).to include('themeColor="accent1"')
  end

  it "rejects an out-of-enum theme color via validate" do
    errors = described_class.new(value: "FF0000", theme_color: "bogus").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end
end
