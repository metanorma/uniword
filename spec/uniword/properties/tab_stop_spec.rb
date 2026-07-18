# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::TabStop do
  it "accepts every ST_TabJc value for alignment" do
    %w[clear start center end decimal bar num left right].each do |value|
      expect(described_class.new(alignment: value).validate).to be_empty
    end
  end

  it "rejects an out-of-enum alignment via validate" do
    errors = described_class.new(alignment: "justified").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid alignment unchanged" do
    expect(described_class.new(alignment: "decimal", position: 720).to_xml)
      .to include('val="decimal"')
  end
end
