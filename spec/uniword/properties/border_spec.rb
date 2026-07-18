# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::Border do
  it "accepts common ST_Border styles" do
    %w[nil none single thick double dotted dashed wave threeDEmboss
       custom].each do |style|
      expect(described_class.new(style: style).validate).to be_empty
    end
  end

  it "carries the full 193-value ST_Border enumeration" do
    expect(Uniword::Properties::BorderStyleValue::VALUES.size).to eq(193)
  end

  it "rejects an out-of-enum style via validate" do
    errors = described_class.new(style: "wobbly").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "rejects a non-hex color at assignment" do
    expect { described_class.new(style: "single", color: "red") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end

  it "rejects an out-of-enum theme color via validate" do
    errors = described_class.new(style: "single", theme_color: "bogus").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid style unchanged" do
    expect(described_class.new(style: "single").to_xml)
      .to include('val="single"')
  end

  it "serializes a valid color unchanged" do
    expect(described_class.new(style: "single", color: "auto").to_xml)
      .to include('color="auto"')
  end

  it "serializes a valid theme color unchanged" do
    expect(described_class.new(style: "single", theme_color: "text1").to_xml)
      .to include('themeColor="text1"')
  end
end
