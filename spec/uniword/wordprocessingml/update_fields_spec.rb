# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::UpdateFields do
  it "defaults val to true" do
    expect(described_class.new.value).to be(true)
  end

  it "serializes as w:updateFields (val omitted for true, ST_OnOff)" do
    settings = Uniword::Wordprocessingml::Settings.new
    settings.update_fields = described_class.new

    xml = settings.to_xml
    expect(xml).to include("updateFields")
  end

  # w:updateFields now goes through the same ST_OnOff element machinery as
  # every other toggle, which spells off as w:val="false". The assertion is
  # about the meaning, not the spelling: both are ST_OnOff off.
  it "serializes w:val when false" do
    xml = described_class.new(value: false).to_xml

    aggregate_failures do
      expect(xml).to match(/w:val="(0|false|off)"/)
      expect(described_class.from_xml(xml).on?).to be(false)
    end
  end

  it "parses w:updateFields from settings XML" do
    xml = <<~XML
      <w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:updateFields w:val="true"/></w:settings>
    XML

    settings = Uniword::Wordprocessingml::Settings.from_xml(xml)
    expect(settings.update_fields).not_to be_nil
    expect(settings.update_fields.value).to be(true)
  end
end
