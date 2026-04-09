# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Quality::QualityRule do
  # Create a test rule class for testing
  class TestRule < Uniword::Quality::QualityRule
    def check(_document)
      [create_violation(
        severity: :error,
        message: 'Test violation',
        location: 'Test location'
      )]
    end
  end

  describe '#initialize' do
    it 'accepts configuration hash' do
      config = { enabled: false, custom: 'value' }
      rule = TestRule.new(config)

      expect(rule.config).to eq(config)
      expect(rule.enabled?).to be false
    end

    it 'defaults enabled to true' do
      rule = TestRule.new
      expect(rule.enabled?).to be true
    end
  end

  describe '#name' do
    it 'generates name from class name' do
      rule = TestRule.new
      expect(rule.name).to eq('test')
    end
  end

  describe '#check' do
    it 'must be implemented by subclass' do
      rule = described_class.new
      expect { rule.check(nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#create_violation' do
    let(:rule) { TestRule.new }

    it 'creates a violation with required fields' do
      violation = rule.send(:create_violation,
                            severity: :warning,
                            message: 'Test message',
                            location: 'Line 10')

      expect(violation).to be_a(Uniword::Quality::QualityViolation)
      expect(violation.severity).to eq(:warning)
      expect(violation.message).to eq('Test message')
      expect(violation.location).to eq('Line 10')
      expect(violation.rule).to eq('test')
    end
  end
end

RSpec.describe Uniword::Quality::QualityViolation do
  describe '#initialize' do
    it 'creates violation with valid severity' do
      violation = described_class.new(
        rule: 'test_rule',
        severity: :error,
        message: 'Error message',
        location: 'Line 1'
      )

      expect(violation.rule).to eq('test_rule')
      expect(violation.severity).to eq(:error)
      expect(violation.message).to eq('Error message')
      expect(violation.location).to eq('Line 1')
    end

    it 'raises error for invalid severity' do
      expect do
        described_class.new(
          rule: 'test',
          severity: :invalid,
          message: 'Test',
          location: 'Test'
        )
      end.to raise_error(ArgumentError, /Invalid severity/)
    end
  end

  describe 'severity checks' do
    it 'identifies error severity' do
      violation = described_class.new(
        rule: 'test', severity: :error,
        message: 'Test', location: 'Test'
      )
      expect(violation.error?).to be true
      expect(violation.warning?).to be false
      expect(violation.info?).to be false
    end

    it 'identifies warning severity' do
      violation = described_class.new(
        rule: 'test', severity: :warning,
        message: 'Test', location: 'Test'
      )
      expect(violation.error?).to be false
      expect(violation.warning?).to be true
      expect(violation.info?).to be false
    end

    it 'identifies info severity' do
      violation = described_class.new(
        rule: 'test', severity: :info,
        message: 'Test', location: 'Test'
      )
      expect(violation.error?).to be false
      expect(violation.warning?).to be false
      expect(violation.info?).to be true
    end
  end

  describe '#to_h' do
    it 'converts violation to hash' do
      violation = described_class.new(
        rule: 'test_rule',
        severity: :warning,
        message: 'Warning message',
        location: 'Paragraph 5'
      )

      hash = violation.to_h
      expect(hash).to eq(
        rule: 'test_rule',
        severity: :warning,
        message: 'Warning message',
        location: 'Paragraph 5'
      )
    end
  end
end
