# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::CellVerticalAlign do
  it "accepts every ST_VerticalJc value" do
    %w[top center both bottom].each do |value|
      expect(described_class.new(value: value).validate).to be_empty
    end
  end

  it "rejects an out-of-enum value via validate" do
    errors = described_class.new(value: "middle").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid value unchanged" do
    expect(described_class.new(value: "center").to_xml)
      .to include('val="center"')
  end
end
