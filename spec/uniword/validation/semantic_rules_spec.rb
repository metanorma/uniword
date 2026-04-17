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

    it "has 10 built-in rules registered" do
      expect(described_class::Registry.all.size).to eq(10)
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

        def applicable?(context)
          true
        end

        def check(context)
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
      ctx = instance_double(Uniword::Validation::Rules::DocumentContext)
      allow(ctx).to receive(:part_exists?).with("word/settings.xml").and_return(true)
      expect(rule.applicable?(ctx)).to be true
    end

    it "does not apply when settings.xml missing" do
      ctx = instance_double(Uniword::Validation::Rules::DocumentContext)
      allow(ctx).to receive(:part_exists?).with("word/settings.xml").and_return(false)
      expect(rule.applicable?(ctx)).to be false
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
end
