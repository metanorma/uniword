# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::Types::UnsignedDecimalNumber do
  describe ".cast" do
    it "accepts zero" do
      expect(described_class.cast(0)).to eq(0)
    end

    it "accepts a positive integer" do
      expect(described_class.cast(240)).to eq(240)
    end

    it "casts a numeric string to an integer" do
      expect(described_class.cast("240")).to eq(240)
    end

    it "casts nil to nil" do
      expect(described_class.cast(nil)).to be_nil
    end

    it "raises on a negative integer" do
      expect { described_class.cast(-9999) }
        .to raise_error(Lutaml::Model::Type::MinBoundError)
    end
  end
end
