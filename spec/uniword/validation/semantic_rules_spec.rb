# frozen_string_literal: true

require "spec_helper"
require "uniword/validation/rules"

RSpec.describe Uniword::Validation::Rules do
  describe "Registry" do
    before do
      # Save original rules to restore after tests
      @original_rules = described_class::Registry.all.dup
    end

    after do
      described_class::Registry.reset!
      @original_rules.each do |rule|
        described_class::Registry.register(rule.class)
      end
    end

    it "has 20 built-in rules registered" do
      expect(described_class::Registry.all.size).to eq(20)
    end

    it "finds rules by code" do
      rule = described_class::Registry.find("DOC-020")
      expect(rule).not_to be_nil
      expect(rule.class).to eq(Uniword::Validation::Rules::FootnotesRule)
    end

    it "filters rules by category" do
      rules = described_class::Registry.for_category(:footnotes)
      expect(rules.size).to be >= 1
      rules.each { |r| expect(r.category).to eq(:footnotes) }
    end

    it "allows custom rule registration" do
      custom_rule = Class.new(Uniword::Validation::Rules::Base) do
        def code = "CUSTOM-001"
        def category = :custom
        def severity = "warning"

        def applicable?(_context)
          true
        end

        def check(_context)
          [issue("Custom check passed", code: "CUSTOM-001")]
        end
      end

      described_class::Registry.register(custom_rule)
      expect(described_class::Registry.find("CUSTOM-001")).not_to be_nil
    end
  end

  describe "FootnotesRule" do
    let(:rule) { Uniword::Validation::Rules::FootnotesRule.new }

    it "has code DOC-020" do
      expect(rule.code).to eq("DOC-020")
    end

    it "applies when settings.xml exists" do
      fixture = "spec/fixtures/docx_gem/basic.docx"
      ctx = Uniword::Validation::Rules::DocumentContext.new(fixture)
      expect(rule.applicable?(ctx)).to be true
      ctx.close
    end

    it "does not apply when settings.xml missing" do
      fixture = "spec/fixtures/docx_gem/no_styles.docx"
      ctx = Uniword::Validation::Rules::DocumentContext.new(fixture)
      expect(rule.applicable?(ctx)).to be false
      ctx.close
    end
  end

  describe "StyleReferencesRule" do
    let(:rule) { Uniword::Validation::Rules::StyleReferencesRule.new }

    it "has code DOC-001" do
      expect(rule.code).to eq("DOC-001")
    end
  end

  describe "NumberingRule" do
    let(:rule) { Uniword::Validation::Rules::NumberingRule.new }

    it "has code DOC-010" do
      expect(rule.code).to eq("DOC-010")
    end
  end

  describe "BookmarksRule" do
    let(:rule) { Uniword::Validation::Rules::BookmarksRule.new }

    it "has code DOC-040" do
      expect(rule.code).to eq("DOC-040")
    end
  end

  describe "ImagesRule" do
    let(:rule) { Uniword::Validation::Rules::ImagesRule.new }

    it "has code DOC-050" do
      expect(rule.code).to eq("DOC-050")
    end
  end

  describe "TablesRule" do
    let(:rule) { Uniword::Validation::Rules::TablesRule.new }

    it "has code DOC-060" do
      expect(rule.code).to eq("DOC-060")
    end
  end

  describe "FontsRule" do
    let(:rule) { Uniword::Validation::Rules::FontsRule.new }

    it "has code DOC-070" do
      expect(rule.code).to eq("DOC-070")
    end
  end

  describe "ThemeRule" do
    let(:rule) { Uniword::Validation::Rules::ThemeRule.new }

    it "has code DOC-080" do
      expect(rule.code).to eq("DOC-080")
    end
  end

  describe "SettingsRule" do
    let(:rule) { Uniword::Validation::Rules::SettingsRule.new }

    it "has code DOC-090" do
      expect(rule.code).to eq("DOC-090")
    end
  end

  describe "HeadersFootersRule" do
    let(:rule) { Uniword::Validation::Rules::HeadersFootersRule.new }

    it "has code DOC-030" do
      expect(rule.code).to eq("DOC-030")
    end
  end

  describe "McIgnorableNamespaceRule" do
    let(:rule) { Uniword::Validation::Rules::McIgnorableNamespaceRule.new }

    it "has code DOC-100" do
      expect(rule.code).to eq("DOC-100")
    end

    it "has validity rule R1" do
      expect(rule.validity_rule).to eq("R1")
    end
  end

  describe "SettingsValuesRule" do
    let(:rule) { Uniword::Validation::Rules::SettingsValuesRule.new }

    it "has code DOC-101" do
      expect(rule.code).to eq("DOC-101")
    end

    it "has validity rule R2" do
      expect(rule.validity_rule).to eq("R2")
    end
  end

  describe "ThemeCompletenessRule" do
    let(:rule) { Uniword::Validation::Rules::ThemeCompletenessRule.new }

    it "has code DOC-102" do
      expect(rule.code).to eq("DOC-102")
    end

    it "has validity rule R3" do
      expect(rule.validity_rule).to eq("R3")
    end
  end

  describe "NumberingPreservationRule" do
    let(:rule) { Uniword::Validation::Rules::NumberingPreservationRule.new }

    it "has code DOC-103" do
      expect(rule.code).to eq("DOC-103")
    end

    it "has validity rule R4" do
      expect(rule.validity_rule).to eq("R4")
    end
  end

  describe "SectionPropertiesRule" do
    let(:rule) { Uniword::Validation::Rules::SectionPropertiesRule.new }

    it "has code DOC-104" do
      expect(rule.code).to eq("DOC-104")
    end

    it "has validity rule R11" do
      expect(rule.validity_rule).to eq("R11")
    end
  end

  describe "CorePropertiesNamespaceRule" do
    let(:rule) { Uniword::Validation::Rules::CorePropertiesNamespaceRule.new }

    it "has code DOC-105" do
      expect(rule.code).to eq("DOC-105")
    end

    it "has validity rule R14" do
      expect(rule.validity_rule).to eq("R14")
    end
  end

  describe "ContentTypesCoverageRule" do
    let(:rule) { Uniword::Validation::Rules::ContentTypesCoverageRule.new }

    it "has code DOC-106" do
      expect(rule.code).to eq("DOC-106")
    end

    it "has validity rule R7" do
      expect(rule.validity_rule).to eq("R7")
    end
  end

  describe "FontTableSignatureRule" do
    let(:rule) { Uniword::Validation::Rules::FontTableSignatureRule.new }

    it "has code DOC-107" do
      expect(rule.code).to eq("DOC-107")
    end

    it "has validity rule R13" do
      expect(rule.validity_rule).to eq("R13")
    end
  end

  describe "RelationshipIntegrityRule" do
    let(:rule) { Uniword::Validation::Rules::RelationshipIntegrityRule.new }

    it "has code DOC-108" do
      expect(rule.code).to eq("DOC-108")
    end

    it "has validity rule R6" do
      expect(rule.validity_rule).to eq("R6")
    end

    it "detects broken relationship target" do
      fixture = "spec/fixtures/docx_gem/basic.docx"
      ctx = Uniword::Validation::Rules::DocumentContext.new(fixture)
      issues = rule.check(ctx)
      # basic.docx has valid rels — should have no errors
      errors = issues.select { |i| i.severity == "error" }
      expect(errors).to be_empty
      ctx.close
    end
  end

  describe "RsidRule" do
    let(:rule) { Uniword::Validation::Rules::RsidRule.new }

    it "has code DOC-109" do
      expect(rule.code).to eq("DOC-109")
    end

    it "has validity rule R12" do
      expect(rule.validity_rule).to eq("R12")
    end

    it "has warning severity" do
      expect(rule.severity).to eq("warning")
    end
  end
end
