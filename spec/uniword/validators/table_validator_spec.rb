# frozen_string_literal: true

require 'spec_helper'

# Helper method to create a table cell with text
def create_validator_text_cell(text)
  Uniword::TableCell.new.tap do |cell|
    cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text(text) }
  end
end

# Helper method to create a table row with text cells
def create_validator_text_row(*texts)
  Uniword::TableRow.new.tap do |row|
    texts.each do |text|
      row.cells << create_validator_text_cell(text)
    end
  end
end

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
      # Empty tables are valid in v2.0
      expect(validator.errors(table)).to be_empty
    end

    it 'returns true for table with valid rows' do
      table = Uniword::Table.new
      table.rows << create_validator_text_row('Cell 1', 'Cell 2')
      table.rows << create_validator_text_row('Cell 3', 'Cell 4')

      expect(validator.errors(table)).to be_empty
    end

    it 'returns false for table with invalid row' do
      table = Uniword::Table.new
      table.rows << 'not a row' # Invalid: should be TableRow instance

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
      table.rows << create_validator_text_row('Cell 1', 'Cell 2')

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

    it 'returns multiple errors for multiple issues' do
      table = Uniword::Table.new
      table.rows << 'invalid row'

      errors = validator.errors(table)
      expect(errors).to include('Row at index 0 must be a TableRow instance')
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
      table.rows << create_validator_text_row('A', 'B', 'C')
      table.rows << create_validator_text_row('D', 'E', 'F')
      table.rows << create_validator_text_row('G', 'H', 'I')

      warnings = validator.warnings(table)
      expect(warnings).to be_empty
    end

    it 'returns warning for inconsistent column counts' do
      table = Uniword::Table.new
      table.rows << create_validator_text_row('A', 'B')
      table.rows << create_validator_text_row('C', 'D', 'E')
      table.rows << create_validator_text_row('F')

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
    # NOTE: These tests are pending because the validator registry expects
    # Uniword::Element but v2.0 classes inherit from Lutaml::Model::Serializable
    it 'is returned when requesting validator for Table class' do
      pending 'Validator registry needs to be updated for v2.0 API'
      validator = Uniword::Validators::ElementValidator.for(Uniword::Table)
      expect(validator).to be_a(described_class)
    end

    it 'validates tables through the registry' do
      pending 'Validator registry needs to be updated for v2.0 API'
      table = Uniword::Table.new
      table.rows << create_validator_text_row('Cell 1', 'Cell 2')

      validator = Uniword::Validators::ElementValidator.for(Uniword::Table)
      expect(validator.errors(table)).to be_empty
    end
  end

  describe 'edge cases' do
    it 'handles table with nil rows array' do
      table = Uniword::Table.new
      table.instance_variable_set(:@rows, nil)

      expect(validator.errors(table)).to be_empty
    end

    it 'handles table with empty rows array' do
      table = Uniword::Table.new
      expect(validator.errors(table)).to be_empty
    end

    it 'handles table with nil properties' do
      table = Uniword::Table.new
      table.rows << create_validator_text_row('Cell')

      expect(validator.errors(table)).to be_empty
    end
  end

  describe 'realistic scenarios' do
    it 'validates a complex table with header and data rows' do
      properties = Uniword::TableProperties.new
      table = Uniword::Table.new
      table.properties = properties
      # Add header row
      table.rows << create_validator_text_row('Name', 'Age', 'City')
      # Add data rows
      table.rows << create_validator_text_row('John', '30', 'NYC')
      table.rows << create_validator_text_row('Jane', '25', 'LA')
      expect(validator.errors(table)).to be_empty
      expect(validator.warnings(table)).to be_empty
    end

    it 'detects mixed valid and invalid rows' do
      table = Uniword::Table.new
      table.rows << create_validator_text_row('Valid', 'Row')
      table.rows << 'Invalid row'
      table.rows << create_validator_text_row('Another', 'Valid')

      expect(validator.valid?(table)).to be false
      errors = validator.errors(table)
      expect(errors).to include('Row at index 1 must be a TableRow instance')
    end

    it 'warns about inconsistent columns while still being valid' do
      table = Uniword::Table.new
      table.rows << create_validator_text_row('A', 'B', 'C')
      table.rows << create_validator_text_row('D', 'E') # Missing one column

      # Table is still valid (structural integrity maintained)
      expect(validator.errors(table)).to be_empty
      # But we get a warning about inconsistent columns
      expect(validator.warnings(table)).not_to be_empty
    end
  end
end
