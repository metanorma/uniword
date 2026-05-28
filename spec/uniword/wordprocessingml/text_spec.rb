# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::Text, "xml:space handling" do
  describe ".cast" do
    it "sets xml_space=preserve for text starting with space" do
      text = described_class.cast(" hello")
      expect(text.xml_space).to eq("preserve")
    end

    it "sets xml_space=preserve for text ending with space" do
      text = described_class.cast("hello ")
      expect(text.xml_space).to eq("preserve")
    end

    it "sets xml_space=preserve for text containing tab" do
      text = described_class.cast("hel\tlo")
      expect(text.xml_space).to eq("preserve")
    end

    it "sets xml_space=preserve for text containing newline" do
      text = described_class.cast("hel\nlo")
      expect(text.xml_space).to eq("preserve")
    end

    it "sets xml_space=preserve for text starting with newline" do
      text = described_class.cast("\nhello")
      expect(text.xml_space).to eq("preserve")
    end

    it "sets xml_space=preserve for text ending with newline" do
      text = described_class.cast("hello\n")
      expect(text.xml_space).to eq("preserve")
    end

    it "does not set xml_space for plain text" do
      text = described_class.cast("hello")
      expect(text.xml_space).to be_nil
    end

    it "returns the same object when given a Text instance" do
      original = described_class.new(content: "hello")
      result = described_class.cast(original)
      expect(result).to equal(original)
    end

    it "returns nil when given nil" do
      expect(described_class.cast(nil)).to be_nil
    end
  end

  describe ".preserve_whitespace?" do
    it "returns true for leading space" do
      expect(described_class.preserve_whitespace?(" hello")).to be true
    end

    it "returns true for trailing space" do
      expect(described_class.preserve_whitespace?("hello ")).to be true
    end

    it "returns true for tab" do
      expect(described_class.preserve_whitespace?("hel\tlo")).to be true
    end

    it "returns true for newline" do
      expect(described_class.preserve_whitespace?("hel\nlo")).to be true
    end

    it "returns false for plain text" do
      expect(described_class.preserve_whitespace?("hello")).to be false
    end

    it "returns false for empty string" do
      expect(described_class.preserve_whitespace?("")).to be false
    end
  end

  describe "XML serialization" do
    it "serializes xml:space attribute when set" do
      text = described_class.new(content: " hello ", xml_space: "preserve")
      xml = text.to_xml(encoding: "UTF-8", prefix: true, standalone: true)
      expect(xml).to include('xml:space="preserve"')
    end
  end
end
