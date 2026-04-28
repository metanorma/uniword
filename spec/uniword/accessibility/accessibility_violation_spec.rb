# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Accessibility::AccessibilityViolation do
  subject(:violation) { described_class.new(violation_attributes) }

  let(:violation_attributes) do
    {
      rule_id: :image_alt_text,
      wcag_criterion: "1.1.1 Non-text Content",
      level: "A",
      message: "Image 1 missing alternative text",
      element: double("Image"),
      severity: :error,
      suggestion: "Add descriptive alternative text for images",
    }
  end

  describe "#initialize" do
    it "sets all attributes correctly" do
      expect(violation.rule_id).to eq(:image_alt_text)
      expect(violation.wcag_criterion).to eq("1.1.1 Non-text Content")
      expect(violation.level).to eq("A")
      expect(violation.message).to eq("Image 1 missing alternative text")
      expect(violation.element).to be_a(RSpec::Mocks::Double)
      expect(violation.severity).to eq(:error)
      expect(violation.suggestion).to eq("Add descriptive alternative text for images")
    end
  end

  describe "#error?" do
    context "when severity is error" do
      it "returns true" do
        expect(violation.error?).to be true
      end
    end

    context "when severity is not error" do
      let(:violation_attributes) { super().merge(severity: :warning) }

      it "returns false" do
        expect(violation.error?).to be false
      end
    end
  end

  describe "#warning?" do
    context "when severity is warning" do
      let(:violation_attributes) { super().merge(severity: :warning) }

      it "returns true" do
        expect(violation.warning?).to be true
      end
    end

    context "when severity is not warning" do
      it "returns false" do
        expect(violation.warning?).to be false
      end
    end
  end

  describe "#info?" do
    context "when severity is info" do
      let(:violation_attributes) { super().merge(severity: :info) }

      it "returns true" do
        expect(violation.info?).to be true
      end
    end

    context "when severity is not info" do
      it "returns false" do
        expect(violation.info?).to be false
      end
    end
  end

  describe "#to_h" do
    it "returns hash representation without element" do
      hash = violation.to_h

      expect(hash).to eq(
        rule_id: :image_alt_text,
        wcag_criterion: "1.1.1 Non-text Content",
        level: "A",
        severity: :error,
        message: "Image 1 missing alternative text",
        suggestion: "Add descriptive alternative text for images",
      )
    end

    it "does not include element in hash" do
      expect(violation.to_h).not_to have_key(:element)
    end
  end
end
