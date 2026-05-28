# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::InstrText, "xml:space handling" do
  it "sets xml_space=preserve for text ending with space" do
    instr = described_class.new(text: " TOC \\o ")
    expect(instr.xml_space).to eq("preserve")
  end

  it "sets xml_space=preserve for text containing newline" do
    instr = described_class.new(text: " TOC\n\\o ")
    expect(instr.xml_space).to eq("preserve")
  end

  it "does not set xml_space for text without whitespace edges" do
    instr = described_class.new(text: "PAGE")
    expect(instr.xml_space).to be_nil
  end
end
