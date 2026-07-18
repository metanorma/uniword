# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::SharedTypes::TextAlignment do
  it "accepts every ST_TextAlignment value" do
    %w[top center baseline bottom auto].each do |value|
      expect(described_class.new(val: value).validate).to be_empty
    end
  end

  it "rejects an out-of-enum value via validate" do
    errors = described_class.new(val: "justify").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid value unchanged" do
    expect(described_class.new(val: "baseline").to_xml)
      .to include('val="baseline"')
  end
end
