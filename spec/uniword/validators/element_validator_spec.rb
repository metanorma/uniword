# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Validators::ElementValidator do
  let(:validator) { described_class.new }

  # Ensure validators are registered before each test
  before do
    # Register validators if not already registered
    unless described_class.validator_registry[Uniword::Wordprocessingml::Paragraph]
      described_class.register(Uniword::Wordprocessingml::Paragraph,
                               Uniword::Validators::ParagraphValidator)
    end
    unless described_class.validator_registry[Uniword::Wordprocessingml::Table]
      described_class.register(Uniword::Wordprocessingml::Table,
                               Uniword::Validators::TableValidator)
    end
  end

  describe '.for' do
    it 'returns an ElementValidator for Element class' do
      result = described_class.for(Uniword::Element)
      expect(result).to be_a(described_class)
    end

    it 'returns a ParagraphValidator for Paragraph class' do
      result = described_class.for(Uniword::Wordprocessingml::Paragraph)
      expect(result).to be_a(Uniword::Validators::ParagraphValidator)
    end

    it 'returns a TableValidator for Table class' do
      result = described_class.for(Uniword::Wordprocessingml::Table)
      expect(result).to be_a(Uniword::Validators::TableValidator)
    end

    it 'raises ArgumentError for non-Element class' do
      expect do
        described_class.for(String)
      end.to raise_error(ArgumentError, /must be a lutaml-model serializable class/)
    end

    it 'raises ArgumentError for non-class argument' do
      expect do
        described_class.for('not a class')
      end.to raise_error(ArgumentError, /must be a lutaml-model serializable class/)
    end

    it 'returns base validator for unregistered element types' do
      result = described_class.for(Uniword::Wordprocessingml::Run)
      expect(result).to be_a(described_class)
      expect(result).not_to be_a(Uniword::Validators::ParagraphValidator)
    end
  end

  describe '.register' do
    after do
      # Reset registry after each test
      described_class.reset_registry
      # Re-register default validators manually since require won't reload
      described_class.register(Uniword::Wordprocessingml::Paragraph, Uniword::Validators::ParagraphValidator)
      described_class.register(Uniword::Wordprocessingml::Table, Uniword::Validators::TableValidator)
    end

    it 'registers a custom validator for an element class' do
      custom_validator = Class.new(described_class)
      described_class.register(Uniword::Wordprocessingml::Run, custom_validator)

      result = described_class.for(Uniword::Wordprocessingml::Run)
      expect(result).to be_a(custom_validator)
    end

    it "raises ArgumentError if validator doesn't inherit from ElementValidator" do
      expect do
        described_class.register(Uniword::Wordprocessingml::Run, String)
      end.to raise_error(ArgumentError, /must inherit from ElementValidator/)
    end

    it 'allows overriding existing validator registrations' do
      custom_validator = Class.new(described_class)
      described_class.register(Uniword::Wordprocessingml::Paragraph, custom_validator)

      result = described_class.for(Uniword::Wordprocessingml::Paragraph)
      expect(result).to be_a(custom_validator)
    end
  end

  describe '.validator_registry' do
    it 'returns a hash' do
      expect(described_class.validator_registry).to be_a(Hash)
    end

    it 'includes registered validators' do
      registry = described_class.validator_registry
      expect(registry[Uniword::Wordprocessingml::Paragraph]).to eq(Uniword::Validators::ParagraphValidator)
      expect(registry[Uniword::Wordprocessingml::Table]).to eq(Uniword::Validators::TableValidator)
    end
  end

  describe '.reset_registry' do
    it 'clears the validator registry' do
      saved = described_class.validator_registry.dup
      described_class.reset_registry
      expect(described_class.validator_registry).to be_empty
      described_class.instance_variable_set(:@validator_registry, saved)
    end
  end

  describe '#valid?' do
    it 'returns false for nil element' do
      expect(validator.valid?(nil)).to be false
    end

    it 'returns false for non-Element object' do
      expect(validator.valid?('not an element')).to be false
    end

    it 'returns true for valid element' do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      expect(validator.valid?(paragraph)).to be true
    end
  end

  describe '#errors' do
    it 'returns error for nil element' do
      errors = validator.errors(nil)
      expect(errors).to eq(['Element is nil'])
    end

    it 'returns error for non-Element object' do
      errors = validator.errors('not an element')
      expect(errors).to eq(['Element must be a Uniword::Element'])
    end

    it 'returns empty array for valid element' do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      errors = validator.errors(paragraph)
      expect(errors).to be_empty
    end
  end

  describe 'integration with element classes' do
    it 'validates paragraphs correctly' do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello')
      paragraph.runs << run

      expect(validator.valid?(paragraph)).to be true
    end

    it 'validates tables correctly' do
      table = Uniword::Wordprocessingml::Table.new
      table.rows << Uniword::Wordprocessingml::TableRow.new.tap do |row|
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: 'Cell 1')
          para.runs << run
          cell.paragraphs << para
        end
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: 'Cell 2')
          para.runs << run
          cell.paragraphs << para
        end
      end

      expect(validator.valid?(table)).to be true
    end

    it 'validates runs correctly' do
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello')
      expect(validator.valid?(run)).to be true
    end

    it 'validates images correctly' do
      image = Uniword::Image.new(relationship_id: 'rId1')
      expect(validator.valid?(image)).to be true
    end
  end
end
