# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::Deletion do
  let(:xml) do
    '<w:del xmlns:w="http://schemas.openxmlformats.org/' \
      'wordprocessingml/2006/main" w:id="8" w:author="Bob">' \
      "<w:r><w:delText>GONE</w:delText></w:r></w:del>"
  end

  it "parses attributes and deleted text" do
    deletion = described_class.from_xml(xml)

    expect(deletion.id).to eq("8")
    expect(deletion.author).to eq("Bob")
    expect(deletion.text).to eq("GONE")
  end

  it "round-trips through serialization" do
    round_tripped = described_class.from_xml(
      described_class.from_xml(xml).to_xml,
    )

    expect(round_tripped.author).to eq("Bob")
    expect(round_tripped.text).to eq("GONE")
  end
end
