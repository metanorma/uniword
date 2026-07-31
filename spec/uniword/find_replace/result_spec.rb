# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::FindReplace::Result do
  it "starts at zero count" do
    expect(described_class.new.count).to eq(0)
    expect(described_class.new.empty?).to be(true)
  end

  it "aggregates counts by scope" do
    result = described_class.new
    result.add(:body, 5)
    result.add(:headers, 2)
    result.add(:body, 1)

    expect(result.count).to eq(8)
    expect(result.by_scope).to eq(body: 6, headers: 2)
  end

  it "lists scopes with positive counts" do
    result = described_class.new
    result.add(:body, 5)
    result.add(:headers, 0)
    result.add(:footnotes, 3)

    expect(result.scopes_touched).to contain_exactly(:body, :footnotes)
  end
end
