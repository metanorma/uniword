# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::TableJustification do
  it "accepts every ST_JcTable value" do
    %w[center end left right start].each do |value|
      expect(described_class.new(value: value).validate).to be_empty
    end
  end

  it "rejects an ST_Jc-only value via validate" do
    errors = described_class.new(value: "both").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid value unchanged" do
    expect(described_class.new(value: "center").to_xml)
      .to include('val="center"')
  end
end
