# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::Underline do
  it "accepts a valid hex color and serializes it unchanged" do
    underline = described_class.new(value: "single", color: "auto")
    expect(underline.to_xml).to include('color="auto"')
  end

  it "rejects a non-hex color at assignment" do
    expect { described_class.new(value: "single", color: "blue") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end

  it "rejects an out-of-enum theme color via validate" do
    errors = described_class.new(value: "single", theme_color: "bogus").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "accepts a valid theme color" do
    underline = described_class.new(value: "single", theme_color: "hyperlink")
    expect(underline.validate).to be_empty
  end
end
