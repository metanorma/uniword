# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::Types::OoxmlBooleanOptional do
  describe ".cast" do
    it "casts true spellings to true" do
      values = [true, 1, "1", "true", "on"].map { |v| described_class.cast(v) }
      expect(values).to all(be(true))
    end

    it "casts false spellings to false" do
      values = [false, 0, "0", "false", "off"]
      expect(values.map { |v| described_class.cast(v) }).to all(be(false))
    end

    it "casts nil to nil" do
      expect(described_class.cast(nil)).to be_nil
    end

    it "raises on an unknown value instead of passing it through" do
      expect { described_class.cast("yes") }
        .to raise_error(Lutaml::Model::Type::InvalidValueError)
    end
  end

  describe ".serialize" do
    it "serializes true as 1" do
      expect(described_class.serialize(true)).to eq("1")
    end

    it "serializes false as 0" do
      expect(described_class.serialize(false)).to eq("0")
    end

    it "serializes nil as nil" do
      expect(described_class.serialize(nil)).to be_nil
    end
  end
end
