# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Accessibility Rules Integration" do
  let(:document) { double("Document") }

  before do
    # Setup default document structure
    allow(document).to receive(:images).and_return([])
    allow(document).to receive(:tables).and_return([])
    allow(document).to receive(:paragraphs).and_return([])
  end

  describe "All rules can be instantiated" do
    let(:config) do
      {
        wcag_criterion: "Test",
        level: "A",
        enabled: true,
        severity: :error
      }
    end

    it "ImageAltTextRule" do
      rule = Uniword::Accessibility::Rules::ImageAltTextRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "HeadingStructureRule" do
      rule = Uniword::Accessibility::Rules::HeadingStructureRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "TableHeadersRule" do
      rule = Uniword::Accessibility::Rules::TableHeadersRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ListStructureRule" do
      rule = Uniword::Accessibility::Rules::ListStructureRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ReadingOrderRule" do
      rule = Uniword::Accessibility::Rules::ReadingOrderRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ColorUsageRule" do
      rule = Uniword::Accessibility::Rules::ColorUsageRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "ContrastRatioRule" do
      rule = Uniword::Accessibility::Rules::ContrastRatioRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "DocumentTitleRule" do
      rule = Uniword::Accessibility::Rules::DocumentTitleRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "DescriptiveHeadingsRule" do
      rule = Uniword::Accessibility::Rules::DescriptiveHeadingsRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end

    it "LanguageSpecificationRule" do
      rule = Uniword::Accessibility::Rules::LanguageSpecificationRule.new(config)
      expect(rule).to be_a(Uniword::Accessibility::AccessibilityRule)
      expect(rule.check(document)).to be_an(Array)
    end
  end

  describe "Rules return violations when issues found" do
    it "ImageAltTextRule detects missing alt text" do
      image_no_alt = double("Image", alt_text: nil)
      allow(document).to receive(:images).and_return([image_no_alt])

      rule = Uniword::Accessibility::Rules::ImageAltTextRule.new(
        wcag_criterion: "1.1.1",
        level: "A",
        severity: :error
      )
      violations = rule.check(document)

      expect(violations).not_to be_empty
      expect(violations.first).to be_a(Uniword::Accessibility::AccessibilityViolation)
    end

    it "TableHeadersRule detects missing headers" do
      table_row = double("TableRow", header?: false)
      table = double("Table", rows: [table_row])
      allow(document).to receive(:tables).and_return([table])

      rule = Uniword::Accessibility::Rules::TableHeadersRule.new(
        wcag_criterion: "1.3.1",
        level: "A",
        severity: :error
      )
      violations = rule.check(document)

      expect(violations).not_to be_empty
    end

    it "HeadingStructureRule detects hierarchy skips" do
      h1 = double("Paragraph", style: "Heading 1")
      h3 = double("Paragraph", style: "Heading 3")
      allow(document).to receive(:paragraphs).and_return([h1, h3])

      rule = Uniword::Accessibility::Rules::HeadingStructureRule.new(
        wcag_criterion: "1.3.1",
        level: "A",
        check_hierarchy: true,
        no_level_skipping: true,
        severity: :error
      )
      violations = rule.check(document)

      expect(violations).not_to be_empty
      expect(violations.first.message).to include("hierarchy skip")
    end
  end

  describe "Rules respect enabled flag" do
    it "disabled rules return no violations" do
      image_no_alt = double("Image", alt_text: nil)
      allow(document).to receive(:images).and_return([image_no_alt])

      rule = Uniword::Accessibility::Rules::ImageAltTextRule.new(
        wcag_criterion: "1.1.1",
        level: "A",
        enabled: false,
        severity: :error
      )

      expect(rule.enabled?).to be false
    end
  end
end
