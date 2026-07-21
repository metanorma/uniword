# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::StrippedPart do
  describe "construction" do
    it "exposes path and reason readers" do
      part = described_class.new(
        path: "[trash]/0000.dat",
        reason: "No content type declaration and no referencing relationship",
      )

      expect(part.path).to eq("[trash]/0000.dat")
      expect(part.reason)
        .to eq("No content type declaration and no referencing relationship")
    end
  end

  describe "value-object equality" do
    it "is equal to another StrippedPart with the same path and reason" do
      a = described_class.new(path: "foo.dat", reason: "junk")
      b = described_class.new(path: "foo.dat", reason: "junk")

      expect(a).to eq(b)
      expect(a.eql?(b)).to be(true)
      expect(a.hash).to eq(b.hash)
    end

    it "is not equal when the path differs" do
      a = described_class.new(path: "foo.dat", reason: "junk")
      b = described_class.new(path: "bar.dat", reason: "junk")

      expect(a).not_to eq(b)
    end

    it "is not equal when the reason differs" do
      a = described_class.new(path: "foo.dat", reason: "junk")
      b = described_class.new(path: "foo.dat", reason: "different")

      expect(a).not_to eq(b)
    end

    it "is not equal to non-StrippedPart objects" do
      part = described_class.new(path: "foo.dat", reason: "junk")

      expect(part).not_to eq("foo.dat")
      expect(part).not_to eq(path: "foo.dat", reason: "junk")
    end
  end
end
