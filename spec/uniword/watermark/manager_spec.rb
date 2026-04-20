# frozen_string_literal: true

require "spec_helper"
require "uniword/watermark"

RSpec.describe Uniword::Watermark::Manager do
  let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }
  let(:manager) { described_class.new(doc) }

  describe "#add" do
    it "adds a watermark to the document" do
      manager.add("DRAFT")
      expect(manager.present?).to be(true)
    end

    it "adds watermark with custom options" do
      manager.add("CONFIDENTIAL",
                  color: "#FF0000",
                  font_size: 48,
                  font: "Arial")
      expect(manager.list).to include("CONFIDENTIAL")
    end
  end

  describe "#remove" do
    it "removes watermarks" do
      manager.add("DRAFT")
      count = manager.remove
      expect(count).to eq(1)
      expect(manager.present?).to be(false)
    end

    it "returns 0 when no watermarks" do
      count = manager.remove
      expect(count).to eq(0)
    end
  end

  describe "#list" do
    it "returns empty array when no watermarks" do
      expect(manager.list).to eq([])
    end

    it "lists watermark texts" do
      manager.add("DRAFT")
      expect(manager.list).to include("DRAFT")
    end
  end

  describe "#present?" do
    it "returns false when no watermarks" do
      expect(manager.present?).to be(false)
    end

    it "returns true when watermark exists" do
      manager.add("DRAFT")
      expect(manager.present?).to be(true)
    end
  end
end
