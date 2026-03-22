# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Quality::DocumentChecker do
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }

  describe '#initialize' do
    it 'loads default configuration' do
      checker = described_class.new
      expect(checker.rules).not_to be_empty
      expect(checker.config).to be_a(Hash)
    end

    it 'loads custom rules file' do
      # Use default config file for this test
      config_path = File.join(
        Uniword::Configuration::ConfigurationLoader::CONFIG_DIR,
        'quality_rules.yml'
      )
      checker = described_class.new(rules_file: config_path)
      expect(checker.rules).not_to be_empty
    end

    it 'accepts direct configuration' do
      config = {
        quality_rules: {
          paragraph_length: {
            enabled: true,
            max_words: 100
          }
        }
      }
      checker = described_class.new(config: config)
      expect(checker.config).to eq(config)
    end
  end

  describe '#check' do
    let(:checker) { described_class.new }

    it 'returns quality report' do
      report = checker.check(document)
      expect(report).to be_a(Uniword::Quality::QualityReport)
    end

    it 'executes enabled rules' do
      # Add a paragraph that will trigger violations
      document.add_paragraph(('word ' * 600).strip) # Exceeds max length

      report = checker.check(document)
      expect(report.violations).not_to be_empty
    end

    it 'skips disabled rules' do
      config = {
        quality_rules: {
          paragraph_length: { enabled: false }
        }
      }
      checker = described_class.new(config: config)

      document.add_paragraph(('word ' * 600).strip)

      report = checker.check(document)
      # Should have fewer violations since paragraph_length is disabled
      expect(report.violations.select { |v| v.rule == 'paragraph_length' }).to be_empty
    end

    it 'raises error for invalid document' do
      expect do
        checker.check('not a document')
      end.to raise_error(ArgumentError, /must respond to/)
    end
  end

  describe '#enabled_rules' do
    it 'returns names of enabled rules' do
      checker = described_class.new
      expect(checker.enabled_rules).to be_an(Array)
      expect(checker.enabled_rules).not_to be_empty
    end
  end

  describe '#disabled_rules' do
    it 'returns names of disabled rules' do
      config = {
        quality_rules: {
          paragraph_length: { enabled: false },
          image_alt_text: { enabled: true }
        }
      }
      checker = described_class.new(config: config)
      expect(checker.disabled_rules).to include('paragraph_length')
      expect(checker.disabled_rules).not_to include('image_alt_text')
    end
  end
end
