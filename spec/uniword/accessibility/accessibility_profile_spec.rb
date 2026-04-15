# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Accessibility::AccessibilityProfile do
  let(:base_profile_config) do
    {
      name: "WCAG 2.1",
      level: "Level AA",
      rules: {
        image_alt_text: {
          enabled: true,
          wcag_criterion: "1.1.1 Non-text Content",
          level: "A",
          severity: :error
        },
        contrast_ratio: {
          enabled: true,
          wcag_criterion: "1.4.3 Contrast (Minimum)",
          level: "AA",
          severity: :error,
          min_contrast_ratio: 4.5
        }
      }
    }
  end

  let(:config) do
    {
      profiles: {
        wcag_2_1_aa: base_profile_config
      }
    }
  end

  describe ".load" do
    it "loads profile by symbol name" do
      profile = described_class.load(config, :wcag_2_1_aa)
      expect(profile).to be_a(described_class)
    end

    it "loads profile by string name" do
      config_with_string = {
        profiles: {
          "wcag_2_1_aa" => base_profile_config
        }
      }
      profile = described_class.load(config_with_string, :wcag_2_1_aa)
      expect(profile).to be_a(described_class)
    end

    it "raises error when profile not found" do
      expect do
        described_class.load(config, :nonexistent)
      end.to raise_error(ArgumentError, /not found/)
    end

    it "raises error when no profiles in config" do
      expect do
        described_class.load({}, :any)
      end.to raise_error(ArgumentError, /No profiles found/)
    end

    it "works with string keys in config" do
      string_config = {
        "profiles" => {
          "wcag_2_1_aa" => base_profile_config
        }
      }
      profile = described_class.load(string_config, :wcag_2_1_aa)
      expect(profile.name).to eq("WCAG 2.1")
    end
  end

  describe "#initialize" do
    subject(:profile) { described_class.new(base_profile_config) }

    it "sets name from config" do
      expect(profile.name).to eq("WCAG 2.1")
    end

    it "sets level from config" do
      expect(profile.level).to eq("Level AA")
    end

    it "sets rules from config" do
      expect(profile.rules).to be_a(Hash)
      expect(profile.rules[:image_alt_text]).to be_a(Hash)
    end

    it "sets inherits to nil when not specified" do
      expect(profile.inherits).to be_nil
    end

    it "sets overrides to empty hash when not specified" do
      expect(profile.overrides).to eq({})
    end

    context "with string keys" do
      let(:string_config) do
        {
          "name" => "WCAG 2.1",
          "level" => "Level AA",
          "rules" => {
            "image_alt_text" => {
              "enabled" => true,
              "wcag_criterion" => "1.1.1"
            }
          }
        }
      end

      it "normalizes keys to symbols" do
        profile = described_class.new(string_config)
        expect(profile.rules[:image_alt_text]).to be_a(Hash)
      end
    end
  end

  describe "#rule_config" do
    subject(:profile) { described_class.new(base_profile_config) }

    it "returns rule config by symbol" do
      config = profile.rule_config(:image_alt_text)
      expect(config).to be_a(Hash)
      expect(config[:wcag_criterion]).to eq("1.1.1 Non-text Content")
    end

    it "returns rule config by string" do
      config = profile.rule_config("image_alt_text")
      expect(config).to be_a(Hash)
    end

    it "returns nil for non-existent rule" do
      expect(profile.rule_config(:nonexistent)).to be_nil
    end
  end

  describe "#rule_enabled?" do
    subject(:profile) { described_class.new(base_profile_config) }

    context "when rule is explicitly enabled" do
      it "returns true" do
        expect(profile.rule_enabled?(:image_alt_text)).to be true
      end
    end

    context "when rule is explicitly disabled" do
      let(:base_profile_config) do
        {
          name: "Test",
          level: "A",
          rules: {
            disabled_rule: { enabled: false }
          }
        }
      end

      it "returns false" do
        expect(profile.rule_enabled?(:disabled_rule)).to be false
      end
    end

    context "when rule enabled is not specified" do
      let(:base_profile_config) do
        {
          name: "Test",
          level: "A",
          rules: {
            default_rule: { wcag_criterion: "1.1.1" }
          }
        }
      end

      it "defaults to true" do
        expect(profile.rule_enabled?(:default_rule)).to be true
      end
    end

    context "when rule does not exist" do
      it "returns false" do
        expect(profile.rule_enabled?(:nonexistent)).to be false
      end
    end
  end

  describe "profile inheritance" do
    let(:parent_profile_config) do
      {
        name: "WCAG 2.1",
        level: "Level AA",
        rules: {
          image_alt_text: {
            enabled: true,
            wcag_criterion: "1.1.1",
            severity: :error
          },
          contrast_ratio: {
            enabled: true,
            wcag_criterion: "1.4.3",
            severity: :error
          }
        }
      }
    end

    let(:child_profile_config) do
      {
        name: "WCAG 2.1",
        level: "Level A",
        inherits: :wcag_2_1_aa,
        overrides: {
          contrast_ratio: {
            enabled: false
          }
        }
      }
    end

    let(:config_with_inheritance) do
      {
        profiles: {
          wcag_2_1_aa: parent_profile_config,
          wcag_2_1_a: child_profile_config
        }
      }
    end

    it "inherits rules from parent profile" do
      profile = described_class.load(config_with_inheritance, :wcag_2_1_a)
      expect(profile.rule_config(:image_alt_text)).not_to be_nil
    end

    it "applies overrides to inherited rules" do
      profile = described_class.load(config_with_inheritance, :wcag_2_1_a)
      expect(profile.rule_enabled?(:contrast_ratio)).to be false
    end

    it "preserves non-overridden inherited rules" do
      profile = described_class.load(config_with_inheritance, :wcag_2_1_a)
      expect(profile.rule_enabled?(:image_alt_text)).to be true
    end

    it "deep merges override configuration" do
      child_with_merge = {
        name: "Test",
        level: "A",
        inherits: :wcag_2_1_aa,
        overrides: {
          contrast_ratio: {
            min_contrast_ratio: 7.0
          }
        }
      }

      config = {
        profiles: {
          wcag_2_1_aa: parent_profile_config,
          test: child_with_merge
        }
      }

      profile = described_class.load(config, :test)
      rule = profile.rule_config(:contrast_ratio)
      expect(rule[:enabled]).to be true # preserved from parent
      expect(rule[:min_contrast_ratio]).to eq(7.0) # overridden
    end
  end

  describe "profile with multiple rules" do
    let(:complex_config) do
      {
        name: "Complex Profile",
        level: "AAA",
        rules: {
          image_alt_text: {
            enabled: true,
            wcag_criterion: "1.1.1",
            check_quality: true
          },
          heading_structure: {
            enabled: true,
            wcag_criterion: "1.3.1"
          },
          table_headers: {
            enabled: false,
            wcag_criterion: "1.3.1"
          }
        }
      }
    end

    subject(:profile) { described_class.new(complex_config) }

    it "stores all rules" do
      expect(profile.rules.keys).to contain_exactly(
        :image_alt_text,
        :heading_structure,
        :table_headers
      )
    end

    it "correctly identifies enabled rules" do
      expect(profile.rule_enabled?(:image_alt_text)).to be true
      expect(profile.rule_enabled?(:heading_structure)).to be true
      expect(profile.rule_enabled?(:table_headers)).to be false
    end

    it "provides access to all rule configurations" do
      expect(profile.rule_config(:image_alt_text)[:check_quality]).to be true
    end
  end
end
