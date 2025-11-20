# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Validators::TableValidator do
  let(:validator) { described_class.new }

  describe 'inheritance' do
    it 'inherits from ElementValidator' do
      expect(described_class).to be < Uniword::Validators::ElementValidator
    end
  end

  describe '#valid?' do
    it 'returns false for nil' do
      expect(validator.valid?(nil)).to be false
    end

    it 'returns false for non-Table element' do
      paragraph = Uniword::Paragraph.new
      expect(validator.valid?(paragraph)).to be false
    end

    it 'returns true for empty table' do
      table = Uniword::Table.new
      expect(validator.valid?(table)).to be true
    end

    it 'returns true for table with valid rows' do
      table = Uniword::Table.new
      table.add_text_row(['Cell 1', 'Cell 2'])
      table.add_text_row(['Cell 3', 'Cell 4'])

      expect(validator.valid?(table)).to be true
    end

    it 'returns true for table with valid properties' do
      properties = Uniword::Properties::TableProperties.new(
        width: '100%'
      )
      table = Uniword::Table.new(properties: properties)
      table.add_text_row(['Cell 1'])

      expect(validator.valid?(table)).to be true
    end

    it 'returns false for table with invalid row' do
      table = Uniword::Table.new
      table.rows << 'not a row' # Invalid: should be TableRow instance

      expect(validator.valid?(table)).to be false
    end

    it 'returns false for table with invalid properties' do
      table = Uniword::Table.new
      table.instance_variable_set(:@properties, 'not properties')

      expect(validator.valid?(table)).to be false
    end
  end

  describe '#errors' do
    it 'returns element error for nil' do
      errors = validator.errors(nil)
      expect(errors).to include('Element is nil')
    end

    it 'returns type error for non-Table element' do
      paragraph = Uniword::Paragraph.new
      errors = validator.errors(paragraph)
      expect(errors).to include('Element must be a Table')
    end

    it 'returns empty array for valid table' do
      table = Uniword::Table.new
      table.add_text_row(['Cell 1', 'Cell 2'])

      errors = validator.errors(table)
      expect(errors).to be_empty
    end

    it 'returns row errors for invalid rows' do
      table = Uniword::Table.new
      table.rows << 'not a row'
      table.rows << Uniword::TableRow.new
      table.rows << 123

      errors = validator.errors(table)
      expect(errors).to include('Row at index 0 must be a TableRow instance')
      expect(errors).to include('Row at index 2 must be a TableRow instance')
      expect(errors.size).to eq(2)
    end

    it 'returns property error for invalid properties' do
      table = Uniword::Table.new
      table.instance_variable_set(:@properties, 'invalid')

      errors = validator.errors(table)
      expect(errors).to include('Properties must be a TableProperties instance')
    end

    it 'returns multiple errors for multiple issues' do
      table = Uniword::Table.new
      table.rows << 'invalid row'
      table.instance_variable_set(:@properties, 'invalid properties')

      errors = validator.errors(table)
      expect(errors.size).to eq(2)
      expect(errors).to include('Row at index 0 must be a TableRow instance')
      expect(errors).to include('Properties must be a TableProperties instance')
    end
  end

  describe '#warnings' do
    it 'returns empty array for empty table' do
      table = Uniword::Table.new
      warnings = validator.warnings(table)
      expect(warnings).to be_empty
    end

    it 'returns empty array for table with consistent column counts' do
      table = Uniword::Table.new
      table.add_text_row(%w[A B C])
      table.add_text_row(%w[D E F])
      table.add_text_row(%w[G H I])

      warnings = validator.warnings(table)
      expect(warnings).to be_empty
    end

    it 'returns warning for inconsistent column counts' do
      table = Uniword::Table.new
      table.add_text_row(%w[A B])
      table.add_text_row(%w[C D E])
      table.add_text_row(['F'])

      warnings = validator.warnings(table)
      expect(warnings).to include(/inconsistent column counts/)
      expect(warnings.first).to match(/2, 3, 1/)
    end

    it 'returns empty array for non-Table element' do
      paragraph = Uniword::Paragraph.new
      warnings = validator.warnings(paragraph)
      expect(warnings).to be_empty
    end
  end

  describe 'integration with ElementValidator.for' do
    it 'is returned when requesting validator for Table class' do
      validator = Uniword::Validators::ElementValidator.for(Uniword::Table)
      expect(validator).to be_a(described_class)
    end

    it 'validates tables through the registry' do
      table = Uniword::Table.new
      table.add_text_row(['Cell 1', 'Cell 2'])

      validator = Uniword::Validators::ElementValidator.for(Uniword::Table)
      expect(validator.valid?(table)).to be true
    end
  end

  describe 'edge cases' do
    it 'handles table with nil rows array' do
      table = Uniword::Table.new
      table.instance_variable_set(:@rows, nil)

      expect(validator.valid?(table)).to be true
    end

    it 'handles table with empty rows array' do
      table = Uniword::Table.new
      expect(validator.valid?(table)).to be true
    end

    it 'handles table with nil properties' do
      table = Uniword::Table.new
      table.add_text_row(['Cell'])

      expect(validator.valid?(table)).to be true
      expect(validator.errors(table)).to be_empty
    end
  end

  describe 'realistic scenarios' do
    it 'validates a complex table with header and data rows' do
      properties = Uniword::Properties::TableProperties.new(
        width: '100%',
        border_style: 'single'
      )
      table = Uniword::Table.new(properties: properties)

      # Add header row
      table.add_text_row(%w[Name Age City], header: true)

      # Add data rows
      table.add_text_row(%w[John 30 NYC])
      table.add_text_row(%w[Jane 25 LA])

      expect(validator.valid?(table)).to be true
      expect(validator.errors(table)).to be_empty
      expect(validator.warnings(table)).to be_empty
    end

    it 'detects mixed valid and invalid rows' do
      table = Uniword::Table.new
      table.add_text_row(%w[Valid Row])
      table.rows << 'Invalid row'
      table.add_text_row(%w[Another Valid])

      expect(validator.valid?(table)).to be false
      errors = validator.errors(table)
      expect(errors).to include('Row at index 1 must be a TableRow instance')
    end

    it 'warns about inconsistent columns while still being valid' do
      table = Uniword::Table.new
      table.add_text_row(%w[A B C])
      table.add_text_row(%w[D E]) # Missing one column

      # Table is still valid (structural integrity maintained)
      expect(validator.valid?(table)).to be true
      # But we get a warning about inconsistent columns
      expect(validator.warnings(table)).not_to be_empty
    end
  end
end
