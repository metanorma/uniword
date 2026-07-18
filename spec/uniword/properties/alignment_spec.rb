# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::Alignment do
  it "accepts every ST_Jc value" do
    %w[start center end both mediumKashida distribute numTab
       highKashida lowKashida thaiDistribute left right].each do |value|
      expect(described_class.new(value: value).validate).to be_empty
    end
  end

  it "rejects an out-of-enum value via validate" do
    errors = described_class.new(value: "diagonal-garbage").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid value unchanged" do
    expect(described_class.new(value: "both").to_xml)
      .to include('val="both"')
  end

  it "parses an out-of-enum value without raising" do
    xml = '<w:jc xmlns:w="http://schemas.openxmlformats.org/' \
          'wordprocessingml/2006/main" w:val="wobbly"/>'
    alignment = described_class.from_xml(xml)
    expect(alignment.value).to eq("wobbly")
  end
end
