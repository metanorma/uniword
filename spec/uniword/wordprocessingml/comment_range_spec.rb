# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::CommentRange do
  describe "#initialize" do
    it "creates a start marker by default" do
      range = described_class.new(comment_id: "1")
      expect(range.marker_type).to eq(:start)
      expect(range.comment_id).to eq("1")
    end

    it "creates a start marker explicitly" do
      range = described_class.new(
        comment_id: "1",
        marker_type: :start
      )
      expect(range.marker_type).to eq(:start)
    end

    it "creates an end marker" do
      range = described_class.new(
        comment_id: "1",
        marker_type: :end
      )
      expect(range.marker_type).to eq(:end)
    end

    it "creates a reference marker" do
      range = described_class.new(
        comment_id: "1",
        marker_type: :reference
      )
      expect(range.marker_type).to eq(:reference)
    end
  end

  describe "#start?" do
    it "returns true for start marker" do
      range = described_class.new(comment_id: "1", marker_type: :start)
      expect(range).to be_start
    end

    it "returns false for non-start marker" do
      range = described_class.new(comment_id: "1", marker_type: :end)
      expect(range).not_to be_start
    end
  end

  describe "#end?" do
    it "returns true for end marker" do
      range = described_class.new(comment_id: "1", marker_type: :end)
      expect(range).to be_end
    end

    it "returns false for non-end marker" do
      range = described_class.new(comment_id: "1", marker_type: :start)
      expect(range).not_to be_end
    end
  end

  describe "#reference?" do
    it "returns true for reference marker" do
      range = described_class.new(comment_id: "1", marker_type: :reference)
      expect(range).to be_reference
    end

    it "returns false for non-reference marker" do
      range = described_class.new(comment_id: "1", marker_type: :start)
      expect(range).not_to be_reference
    end
  end

  describe "#xml_element_name" do
    it "returns correct name for start marker" do
      range = described_class.new(comment_id: "1", marker_type: :start)
      expect(range.xml_element_name).to eq("commentRangeStart")
    end

    it "returns correct name for end marker" do
      range = described_class.new(comment_id: "1", marker_type: :end)
      expect(range.xml_element_name).to eq("commentRangeEnd")
    end

    it "returns correct name for reference marker" do
      range = described_class.new(comment_id: "1", marker_type: :reference)
      expect(range.xml_element_name).to eq("commentReference")
    end

    it "raises error for invalid marker type" do
      range = described_class.new(comment_id: "1")
      range.instance_variable_set(:@marker_type, :invalid)
      expect do
        range.xml_element_name
      end.to raise_error(ArgumentError, /Invalid marker type/)
    end
  end

  describe "#valid?" do
    it "returns true with valid attributes" do
      range = described_class.new(
        comment_id: "1",
        marker_type: :start
      )
      expect(range).to be_valid
    end

    it "returns false without comment_id" do
      range = described_class.new(marker_type: :start)
      expect(range).not_to be_valid
    end

    it "returns false with empty comment_id" do
      range = described_class.new(
        comment_id: "",
        marker_type: :start
      )
      expect(range).not_to be_valid
    end

    it "returns false without marker_type" do
      range = described_class.new(comment_id: "1")
      range.instance_variable_set(:@marker_type, nil)
      expect(range).not_to be_valid
    end
  end

  describe "#accept" do
    it "calls visitor visit_comment_range method" do
      range = described_class.new(comment_id: "1")
      visitor = double("visitor")
      expect(visitor).to receive(:visit_comment_range).with(range)
      range.accept(visitor)
    end
  end
end
