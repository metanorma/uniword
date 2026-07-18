# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::VerticalAlign do
  it "accepts every ST_VerticalAlignRun value" do
    %w[baseline superscript subscript].each do |value|
      expect(described_class.new(value: value).validate).to be_empty
    end
  end

  it "rejects an out-of-enum value via validate" do
    errors = described_class.new(value: "overline").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid value unchanged" do
    expect(described_class.new(value: "superscript").to_xml)
      .to include('val="superscript"')
  end
end
