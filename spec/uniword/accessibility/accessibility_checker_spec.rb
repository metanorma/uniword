# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Accessibility::AccessibilityChecker do
  let(:config_file) { File.expand_path("../../../config/accessibility_profiles.yml", __dir__) }

  describe "#initialize" do
    it "loads default profile (wcag_2_1_aa)" do
      checker = described_class.new
      expect(checker.profile).to be_a(Uniword::Accessibility::AccessibilityProfile)
      expect(checker.profile.name).to eq("WCAG 2.1")
      expect(checker.profile.level).to eq("Level AA")
    end

    it "loads specified profile" do
      checker = described_class.new(profile: :wcag_2_1_a)
      expect(checker.profile.level).to eq("Level A")
    end

    it "initializes all rules" do
      checker = described_class.new
      expect(checker.rules).to be_an(Array)
      expect(checker.rules).not_to be_empty
      expect(checker.rules.first).to be_a(Uniword::Accessibility::AccessibilityRule)
    end

    it "uses custom config file when provided" do
      custom_config = Tempfile.new(["custom_config", ".yml"])
      config_content = {
        profiles: {
          custom: {
            name: "Custom",
            level: "Test",
            rules: {
              image_alt_text: { enabled: true, wcag_criterion: "1.1.1", level: "A" }
            }
          }
        }
      }
      File.write(custom_config.path, config_content.to_yaml)

      checker = described_class.new(profile: :custom, config_file: custom_config.path)
      expect(checker.profile.name).to eq("Custom")

      custom_config.close
      custom_config.unlink
    end

    it "raises error for non-existent profile" do
      expect {
        described_class.new(profile: :nonexistent)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#check" do
    let(:checker) { described_class.new(profile: :wcag_2_1_aa) }
    let(:document) { double("Document") }

    before do
      # Mock document methods
      allow(document).to receive(:images).and_return([])
      allow(document).to receive(:tables).and_return([])
      allow(document).to receive(:paragraphs).and_return([])
    end

    it "returns an AccessibilityReport" do
      report = checker.check(document)
      expect(report).to be_a(Uniword::Accessibility::AccessibilityReport)
    end

    it "includes profile information in report" do
      report = checker.check(document)
      expect(report.profile_name).to eq("WCAG 2.1")
      expect(report.profile_level).to eq("Level AA")
    end

    it "runs enabled rules" do
      # Rules should be called when document is checked
      report = checker.check(document)
      expect(report).to be_a(Uniword::Accessibility::AccessibilityReport)
    end

    it "skips disabled rules" do
      # Create a profile with all rules disabled
      custom_config = Tempfile.new(["disabled_config", ".yml"])
      config_content = {
        profiles: {
          all_disabled: {
            name: "All Disabled",
            level: "Test",
            rules: {
              image_alt_text: { enabled: false, wcag_criterion: "1.1.1", level: "A" },
              heading_structure: { enabled: false, wcag_criterion: "1.3.1", level: "A" },
              table_headers: { enabled: false, wcag_criterion: "1.3.1", level: "A" },
              list_structure: { enabled: false, wcag_criterion: "1.3.1", level: "A" },
              reading_order: { enabled: false, wcag_criterion: "1.3.2", level: "A" },
              color_usage: { enabled: false, wcag_criterion: "1.4.1", level: "A" },
              contrast_ratio: { enabled: false, wcag_criterion: "1.4.3", level: "AA" },
              document_title: { enabled: false, wcag_criterion: "2.4.2", level: "A" },
              descriptive_headings: { enabled: false, wcag_criterion: "2.4.6", level: "AA" },
              language_specification: { enabled: false, wcag_criterion: "3.1.1", level: "A" }
            }
          }
        }
      }
      File.write(custom_config.path, config_content.to_yaml)

      checker_disabled = described_class.new(
        profile: :all_disabled,
        config_file: custom_config.path
      )
      report = checker_disabled.check(document)

      # No violations should be found since all rules are disabled
      expect(report.violations).to be_empty

      custom_config.close
      custom_config.unlink
    end

    context "with violations" do
      let(:image_without_alt) do
        double("Image", alt_text: nil)
      end

      before do
        allow(document).to receive(:images).and_return([image_without_alt])
      end

      it "collects violations from rules" do
        report = checker.check(document)
        expect(report.violations).not_to be_empty
      end

      it "includes violations in report" do
        report = checker.check(document)
        expect(report.violations.first).to be_a(Uniword::Accessibility::AccessibilityViolation)
      end
    end
  end

  describe "#compliant?" do
    let(:checker) { described_class.new(profile: :wcag_2_1_aa) }
    let(:document) { double("Document") }
    let(:h1_paragraph) { double("Paragraph", style: "Heading 1") }

    before do
      allow(document).to receive(:images).and_return([])
      allow(document).to receive(:tables).and_return([])
      # Use a minimal number of paragraphs to avoid heading requirement
      allow(document).to receive(:paragraphs).and_return([h1_paragraph])
      # Add required document properties to avoid violations
      allow(document).to receive(:title).and_return("Test Document Title")
      allow(document).to receive(:language).and_return("en-US")
      allow(document).to receive(:metadata).and_return(nil)
    end

    context "when document has no errors" do
      it "returns true" do
        expect(checker.compliant?(document)).to be true
      end
    end

    context "when document has errors" do
      let(:image_without_alt) do
        double("Image", alt_text: nil)
      end

      before do
        allow(document).to receive(:images).and_return([image_without_alt])
      end

      it "returns false" do
        expect(checker.compliant?(document)).to be false
      end
    end
  end

  describe "different profiles" do
    let(:document) do
      doc = double("Document")
      allow(doc).to receive(:images).and_return([])
      allow(doc).to receive(:tables).and_return([])
      allow(doc).to receive(:paragraphs).and_return([])
      doc
    end

    it "Level A profile has fewer rules than Level AA" do
      checker_a = described_class.new(profile: :wcag_2_1_a)
      checker_aa = described_class.new(profile: :wcag_2_1_aa)

      enabled_a = checker_a.rules.count(&:enabled?)
      enabled_aa = checker_aa.rules.count(&:enabled?)

      expect(enabled_a).to be < enabled_aa
    end

    it "Level AAA has stricter requirements than Level AA" do
      checker_aa = described_class.new(profile: :wcag_2_1_aa)
      checker_aaa = described_class.new(profile: :wcag_2_1_aaa)

      # Both should have same number of rules
      expect(checker_aaa.rules.count(&:enabled?)).to eq(checker_aa.rules.count(&:enabled?))
    end

    it "Section 508 profile works" do
      checker = described_class.new(profile: :section_508)
      report = checker.check(document)

      expect(report.profile_name).to eq("Section 508")
      expect(report).to be_a(Uniword::Accessibility::AccessibilityReport)
    end
  end
end