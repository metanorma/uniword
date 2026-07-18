# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::Types::HexColorValue do
  describe ".cast" do
    it "accepts six uppercase hex digits" do
      expect(described_class.cast("FF0000")).to eq("FF0000")
    end

    it "accepts six lowercase hex digits" do
      expect(described_class.cast("ff0000")).to eq("ff0000")
    end

    it "accepts auto" do
      expect(described_class.cast("auto")).to eq("auto")
    end

    it "casts nil to nil" do
      expect(described_class.cast(nil)).to be_nil
    end

    it "raises on a non-hex string" do
      expect { described_class.cast("not-a-color") }
        .to raise_error(Lutaml::Model::Type::InvalidValueError)
    end

    it "raises on a named color" do
      expect { described_class.cast("red") }
        .to raise_error(Lutaml::Model::Type::InvalidValueError)
    end

    it "raises on a three-digit hex string" do
      expect { described_class.cast("F00") }
        .to raise_error(Lutaml::Model::Type::InvalidValueError)
    end
  end
end
