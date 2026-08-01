# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Diff::Semantic::Engine do
  let(:old_doc) do
    b = Uniword::Builder::DocumentBuilder.new
    b.paragraph("First")
    b.paragraph("Second")
    b.paragraph("Third")
    b.model
  end

  it "returns empty result for identical documents" do
    result = described_class.new(old_doc, old_doc).diff
    expect(result.empty?).to be(true)
  end

  it "detects added paragraph" do
    new_doc = Uniword::Builder::DocumentBuilder.new
    new_doc.paragraph("First")
    new_doc.paragraph("Second")
    new_doc.paragraph("Third")
    new_doc.paragraph("Fourth")
    result = described_class.new(old_doc, new_doc.model).diff
    expect(result.by_kind[:added]).to eq(1)
  end

  it "detects removed paragraph" do
    new_doc = Uniword::Builder::DocumentBuilder.new
    new_doc.paragraph("First")
    new_doc.paragraph("Third")
    result = described_class.new(old_doc, new_doc.model).diff
    expect(result.by_kind[:removed]).to eq(1)
  end

  it "detects modified text" do
    new_doc = Uniword::Builder::DocumentBuilder.new
    new_doc.paragraph("First")
    new_doc.paragraph("CHANGED")
    new_doc.paragraph("Third")
    result = described_class.new(old_doc, new_doc.model).diff
    expect(result.by_kind[:modified]).to eq(1)
    expect(result.by_modifier[:text]).to eq(1)
  end
end

RSpec.describe Uniword::Diff::Semantic::Change do
  it "rejects unknown kinds" do
    expect do
      described_class.new(kind: :bogus)
    end.to raise_error(ArgumentError)
  end

  it "rejects unknown modifiers" do
    expect do
      described_class.new(kind: :modified, modifier: :bogus)
    end.to raise_error(ArgumentError)
  end

  it "equals by to_h" do
    a = described_class.new(kind: :added, new_index: 0)
    b = described_class.new(kind: :added, new_index: 0)
    expect(a).to eq(b)
  end
end
