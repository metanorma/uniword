# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Hyperlink, "#to_model" do
  it "creates a run with Text.cast for whitespace-prefixed text" do
    link = described_class.new(url: "https://example.com", text: " click here ")
    model = link.to_model
    run = model.runs.first
    expect(run.text.first.xml_space).to eq("preserve")
  end

  it "creates a run with plain text" do
    link = described_class.new(url: "https://example.com", text: "click")
    model = link.to_model
    run = model.runs.first
    expect(run.text.first.content).to eq("click")
    expect(run.text.first.xml_space).to be_nil
  end

  it "creates a run with newline-containing text" do
    link = described_class.new(anchor: "section1", text: "go to\nsection")
    model = link.to_model
    run = model.runs.first
    expect(run.text.first.xml_space).to eq("preserve")
  end
end
