# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::Types::OoxmlBoolean do
  describe ".cast" do
    it "casts true spellings to true" do
      values = [true, 1, "1", "true", "on"].map { |v| described_class.cast(v) }
      expect(values).to all(be(true))
    end

    it "casts false spellings to false" do
      values = [false, 0, "0", "false", "off"]
      expect(values.map { |v| described_class.cast(v) }).to all(be(false))
    end

    it "casts nil to false" do
      expect(described_class.cast(nil)).to be false
    end

    # A reader must not raise on a malformed document. One bad token in
    # styles.xml used to kill the whole parse.
    it "reads an unknown token as on instead of raising" do
      expect(described_class.cast("diagonal-garbage")).to be(true)
    end

    it "reads the same way Properties::BooleanElement does" do
      %w[1 0 true false on off banana].each do |token|
        expect(described_class.cast(token))
          .to be(Uniword::Properties::Bold.new(val: token).on?)
      end
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

    it "raises on an unknown value instead of passing it through" do
      expect { described_class.serialize("maybe") }
        .to raise_error(Lutaml::Model::Type::InvalidValueError)
    end
  end
end
