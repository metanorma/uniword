# frozen_string_literal: true

require "spec_helper"
require "uniword/diff"

RSpec.describe Uniword::Diff::DiffResult do
  describe "#empty?" do
    it "is empty when no changes" do
      result = described_class.new
      expect(result).to be_empty
    end

    it "is not empty when text changes exist" do
      result = described_class.new(
        text_changes: [{ type: :text, change: :added }],
      )
      expect(result).not_to be_empty
    end

    it "is not empty when format changes exist" do
      result = described_class.new(
        format_changes: [{ type: :format, change: :modified }],
      )
      expect(result).not_to be_empty
    end

    it "is not empty when structure changes exist" do
      result = described_class.new(
        structure_changes: [{ type: :structure, change: :paragraph_count }],
      )
      expect(result).not_to be_empty
    end

    it "is not empty when metadata changes exist" do
      result = described_class.new(
        metadata_changes: { title: { old: "A", new: "B" } },
      )
      expect(result).not_to be_empty
    end

    it "is not empty when style changes exist" do
      result = described_class.new(
        style_changes: [{ type: :style, change: :added }],
      )
      expect(result).not_to be_empty
    end
  end

  describe "#total_changes" do
    it "sums changes across all categories" do
      result = described_class.new(
        text_changes: [{}, {}],
        format_changes: [{}],
        style_changes: [{}, {}, {}],
      )
      expect(result.total_changes).to eq(6)
    end

    it "returns 0 when empty" do
      result = described_class.new
      expect(result.total_changes).to eq(0)
    end
  end

  describe "#summary" do
    it "reports no differences when empty" do
      result = described_class.new
      expect(result.summary).to eq("No differences found.")
    end

    it "lists change categories" do
      result = described_class.new(
        text_changes: [{}, {}],
        format_changes: [{}],
      )
      expect(result.summary).to eq("2 text change(s), 1 format change(s)")
    end
  end

  describe "#to_json" do
    it "produces valid JSON" do
      require "json"
      result = described_class.new(
        text_changes: [{ change: :added }],
      )
      parsed = JSON.parse(result.to_json)
      expect(parsed["text_changes"].length).to eq(1)
      expect(parsed["summary"]).to include("text change")
    end
  end
end
