# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Resource::FontSubstitutor do
  after { described_class.reset_registry! }

  describe ".substitute" do
    it "returns OFL alternative for known MS fonts" do
      expect(described_class.substitute("Calibri")).to eq("Carlito")
    end

    it "returns OFL alternative for Arial" do
      expect(described_class.substitute("Arial")).to eq("Liberation Sans")
    end

    it "returns OFL alternative for Times New Roman" do
      expect(described_class.substitute("Times New Roman"))
        .to eq("Liberation Serif")
    end

    it "returns OFL alternative for Courier New" do
      expect(described_class.substitute("Courier New"))
        .to eq("Liberation Mono")
    end

    it "returns OFL alternative for Cambria" do
      expect(described_class.substitute("Cambria")).to eq("Caladea")
    end

    it "returns original font when no substitution exists" do
      expect(described_class.substitute("OpenSans")).to eq("OpenSans")
    end

    it "returns original for empty string" do
      expect(described_class.substitute("")).to eq("")
    end
  end

  describe ".substitute_script" do
    it "returns registry entry for known script code" do
      result = described_class.substitute_script("Hans", "SimSun")
      expect(result).to be_a(String)
    end

    it "falls back to generic substitution for unknown script" do
      result = described_class.substitute_script("Unknown", "Arial")
      expect(result).to eq("Liberation Sans")
    end
  end

  describe ".check_availability" do
    it "returns true or false without raising" do
      result = described_class.check_availability("SomeRandomFont12345")
      expect(result).to(satisfy { |v| [true, false].include?(v) })
    end

    it "returns boolean for common fonts" do
      result = described_class.check_availability("Arial")
      expect(result).to(satisfy { |v| [true, false].include?(v) })
    end
  end

  describe ".registry" do
    it "returns a hash" do
      expect(described_class.registry).to be_a(Hash)
    end

    it "caches the result" do
      first = described_class.registry
      second = described_class.registry
      expect(first).to equal(second)
    end
  end

  describe ".reset_registry!" do
    it "clears the cached registry" do
      first = described_class.registry
      described_class.reset_registry!
      second = described_class.registry
      expect(first).not_to equal(second)
    end
  end

  describe "SUBSTITUTIONS" do
    it "is frozen" do
      expect(described_class::SUBSTITUTIONS).to be_frozen
    end

    it "contains Calibri mapping" do
      expect(described_class::SUBSTITUTIONS["Calibri"]).to eq("Carlito")
    end

    it "contains all 10 standard mappings" do
      expect(described_class::SUBSTITUTIONS.size).to eq(10)
    end
  end
end
