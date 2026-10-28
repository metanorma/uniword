# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::Insertion do
  let(:xml) do
    '<w:ins xmlns:w="http://schemas.openxmlformats.org/' \
      'wordprocessingml/2006/main" w:id="7" w:author="Alice" ' \
      'w:date="2026-01-01T00:00:00Z">' \
      "<w:r><w:t>INSERTED</w:t></w:r></w:ins>"
  end

  it "parses attributes and wrapped-run text" do
    insertion = described_class.from_xml(xml)

    expect(insertion.id).to eq("7")
    expect(insertion.author).to eq("Alice")
    expect(insertion.text).to eq("INSERTED")
  end

  it "round-trips through serialization" do
    round_tripped = described_class.from_xml(
      described_class.from_xml(xml).to_xml,
    )

    expect(round_tripped.author).to eq("Alice")
    expect(round_tripped.text).to eq("INSERTED")
  end
end
