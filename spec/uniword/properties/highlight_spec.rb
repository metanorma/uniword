# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Properties::Highlight do
  it "accepts every ST_HighlightColor value" do
    %w[black blue cyan green magenta red yellow white darkBlue darkCyan
       darkGreen darkMagenta darkRed darkYellow darkGray lightGray
       none].each do |value|
      expect(described_class.new(value: value).validate).to be_empty
    end
  end

  it "rejects an out-of-enum value via validate" do
    errors = described_class.new(value: "pink").validate
    expect(errors).to include(an_instance_of(Lutaml::Model::InvalidValueError))
  end

  it "serializes a valid value unchanged" do
    expect(described_class.new(value: "darkYellow").to_xml)
      .to include('val="darkYellow"')
  end
end
