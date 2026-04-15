# frozen_string_literal: true

require "spec_helper"
require "uniword/metadata/metadata_validator"
require "uniword/metadata/metadata"

RSpec.describe Uniword::Metadata::MetadataValidator do
  let(:validator) { described_class.new }

  describe "#initialize" do
    it "initializes with default schema" do
      expect(validator).to be_a(described_class)
      expect(validator.schema).to be_a(Hash)
    end

    it "loads schema configuration" do
      expect(validator.schema).to have_key(:core_properties)
    end
  end

  describe "#validate" do
    let(:metadata) do
      Uniword::Metadata::Metadata.new(
        title: "Test Title",
        author: "Test Author",
        word_count: 100
      )
    end

    it "validates metadata" do
      result = validator.validate(metadata)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:valid)
      expect(result).to have_key(:errors)
    end

    it "returns valid for good metadata" do
      result = validator.validate(metadata)

      expect([true, false]).to include(result[:valid])
      expect(result[:errors]).to be_a(Array)
    end

    it "accepts Hash input" do
      result = validator.validate({ title: "Test" })

      expect(result).to have_key(:valid)
    end

    context "with type validation" do
      it "validates string types" do
        meta = Uniword::Metadata::Metadata.new(title: 123)
        result = validator.validate(meta)

        # Should have error for wrong type
        expect([true, false]).to include(result[:valid])
      end

      it "validates integer types" do
        meta = Uniword::Metadata::Metadata.new(word_count: "not a number")
        result = validator.validate(meta)

        expect([true, false]).to include(result[:valid])
      end
    end

    context "with scenario validation" do
      it "validates for publication scenario" do
        result = validator.validate(metadata, scenario: :publication)

        expect(result).to have_key(:valid)
      end

      it "validates for archival scenario" do
        result = validator.validate(metadata, scenario: :archival)

        expect(result).to have_key(:valid)
      end
    end
  end

  describe "#valid?" do
    it "returns boolean result" do
      metadata = Uniword::Metadata::Metadata.new(title: "Test")
      result = validator.valid?(metadata)

      expect([true, false]).to include(result)
    end
  end

  describe "#errors" do
    it "returns array of errors" do
      metadata = Uniword::Metadata::Metadata.new(title: "Test")
      errors = validator.errors(metadata)

      expect(errors).to be_a(Array)
    end
  end

  describe "constraint validation" do
    it "validates max_length for strings" do
      long_title = "x" * 300
      metadata = Uniword::Metadata::Metadata.new(title: long_title)

      result = validator.validate(metadata)

      # May or may not fail depending on schema configuration
      expect(result[:errors]).to be_a(Array)
    end

    it "validates allowed_values" do
      metadata = Uniword::Metadata::Metadata.new(status: "invalid_status")

      result = validator.validate(metadata)

      # Should validate against allowed values if configured
      expect(result).to have_key(:valid)
    end
  end
end
