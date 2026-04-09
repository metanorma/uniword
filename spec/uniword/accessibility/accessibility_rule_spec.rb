# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Accessibility::AccessibilityRule do
  # Create a concrete test rule for testing
  class TestAccessibilityRule < Uniword::Accessibility::AccessibilityRule
    def check(_document)
      []
    end
  end

  let(:config) do
    {
      wcag_criterion: '1.1.1 Non-text Content',
      level: 'A',
      enabled: true,
      severity: :error
    }
  end

  subject(:rule) { TestAccessibilityRule.new(config) }

  describe '#initialize' do
    it 'sets configuration' do
      expect(rule.config).to eq(config)
    end

    it 'sets WCAG criterion from config' do
      expect(rule.wcag_criterion).to eq('1.1.1 Non-text Content')
    end

    it 'sets level from config' do
      expect(rule.level).to eq('A')
    end

    it 'derives rule_id from class name' do
      expect(rule.rule_id).to eq(:test_accessibility)
    end

    context 'with nil config' do
      let(:config) { nil }

      it 'uses empty hash as default' do
        expect(rule.config).to eq({})
      end
    end
  end

  describe '#enabled?' do
    context 'when enabled is true in config' do
      it 'returns true' do
        expect(rule.enabled?).to be true
      end
    end

    context 'when enabled is false in config' do
      let(:config) { super().merge(enabled: false) }

      it 'returns false' do
        expect(rule.enabled?).to be false
      end
    end

    context 'when enabled is not specified' do
      let(:config) { { wcag_criterion: '1.1.1', level: 'A' } }

      it 'defaults to true' do
        expect(rule.enabled?).to be true
      end
    end
  end

  describe '#check' do
    context 'when not implemented by subclass' do
      subject(:base_rule) { described_class.new(config) }

      it 'raises NotImplementedError' do
        document = double('Document')
        expect { base_rule.check(document) }.to raise_error(
          NotImplementedError,
          /must implement #check/
        )
      end
    end

    context 'when implemented by subclass' do
      it 'can be called without error' do
        document = double('Document')
        expect { rule.check(document) }.not_to raise_error
      end
    end
  end

  describe '#create_violation' do
    let(:element) { double('Element') }
    let(:violation_params) do
      {
        message: 'Test violation',
        element: element,
        severity: :error,
        suggestion: 'Fix the issue'
      }
    end

    it 'creates an AccessibilityViolation' do
      violation = rule.send(:create_violation, **violation_params)

      expect(violation).to be_a(Uniword::Accessibility::AccessibilityViolation)
    end

    it 'includes rule information in violation' do
      violation = rule.send(:create_violation, **violation_params)

      expect(violation.rule_id).to eq(:test_accessibility)
      expect(violation.wcag_criterion).to eq('1.1.1 Non-text Content')
      expect(violation.level).to eq('A')
    end

    it 'includes provided information in violation' do
      violation = rule.send(:create_violation, **violation_params)

      expect(violation.message).to eq('Test violation')
      expect(violation.element).to eq(element)
      expect(violation.severity).to eq(:error)
      expect(violation.suggestion).to eq('Fix the issue')
    end
  end

  describe 'rule_id derivation' do
    # Test various class names to ensure proper derivation
    it 'derives image_alt_text from ImageAltTextRule' do
      klass = Class.new(described_class) do
        def self.name
          'Uniword::Accessibility::ImageAltTextRule'
        end

        def check(_document)
          []
        end
      end
      instance = klass.new(config)
      expect(instance.rule_id).to eq(:image_alt_text)
    end

    it 'derives table_headers from TableHeadersRule' do
      klass = Class.new(described_class) do
        def self.name
          'Uniword::Accessibility::TableHeadersRule'
        end

        def check(_document)
          []
        end
      end
      instance = klass.new(config)
      expect(instance.rule_id).to eq(:table_headers)
    end

    it 'derives heading_structure from HeadingStructureRule' do
      klass = Class.new(described_class) do
        def self.name
          'Uniword::Accessibility::HeadingStructureRule'
        end

        def check(_document)
          []
        end
      end
      instance = klass.new(config)
      expect(instance.rule_id).to eq(:heading_structure)
    end

    it 'derives language_specification from LanguageSpecificationRule' do
      klass = Class.new(described_class) do
        def self.name
          'Uniword::Accessibility::LanguageSpecificationRule'
        end

        def check(_document)
          []
        end
      end
      instance = klass.new(config)
      expect(instance.rule_id).to eq(:language_specification)
    end
  end
end
