# frozen_string_literal: true

require 'spec_helper'
require 'uniword/validation/link_validator'
require 'uniword/wordprocessingml/hyperlink'

RSpec.describe Uniword::Validation::LinkValidator do
  let(:validator) { described_class.new }

  describe '#initialize' do
    it 'initializes with default config' do
      expect(validator).to be_a(described_class)
      expect(validator.checkers).not_to be_empty
    end

    it 'loads configuration from file' do
      expect(validator.config).to be_a(Hash)
    end

    it 'initializes all checkers' do
      expect(validator.checkers.size).to eq(4)
      expect(validator.checkers.map(&:class).map(&:name)).to include(
        'Uniword::Validation::Checkers::ExternalLinkChecker',
        'Uniword::Validation::Checkers::InternalLinkChecker',
        'Uniword::Validation::Checkers::FileReferenceChecker',
        'Uniword::Validation::Checkers::FootnoteReferenceChecker'
      )
    end
  end

  describe '#validate' do
    let(:document) do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      doc.add_paragraph('Hello World')
      doc
    end

    it 'returns a ValidationReport' do
      report = validator.validate(document)

      expect(report).to be_a(Uniword::Validation::ValidationReport)
    end

    context 'with external links' do
      let(:document) do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        hyperlink = Uniword::Wordprocessingml::Hyperlink.new(id: 'https://example.com')
        para.runs << hyperlink
        doc.body.paragraphs << para
        doc
      end

      it 'validates external links' do
        # Note: External link validation makes HTTP requests
        # The result depends on network connectivity
        report = validator.validate(document)

        expect(report.total_count).to eq(1)
      end
    end

    context 'with internal bookmarks' do
      let(:document) do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        anchor_link = Uniword::Wordprocessingml::Hyperlink.new(anchor: 'section1')
        para.runs << anchor_link
        doc.body.paragraphs << para
        # Add bookmark to document
        doc.instance_variable_set(:@bookmarks, { 'section1' => Uniword::Bookmark.new(name: 'section1') })
        doc
      end

      it 'validates internal bookmark links' do
        report = validator.validate(document)

        expect(report.total_count).to eq(1)
      end
    end

    context 'with tables containing links' do
      let(:document) do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        # Create table with link
        table = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new
        cell = Uniword::Wordprocessingml::TableCell.new

        para = Uniword::Wordprocessingml::Paragraph.new
        table_link = Uniword::Wordprocessingml::Hyperlink.new(id: 'https://table.example.com')
        para.runs << table_link
        cell.paragraphs << para
        row.cells << cell
        table.rows << row
        doc.body.tables << table

        doc
      end

      it 'validates links in tables' do
        report = validator.validate(document)

        expect(report.total_count).to eq(1)
      end
    end

    context 'with empty document' do
      let(:empty_document) { Uniword::Wordprocessingml::DocumentRoot.new }

      it 'returns empty report' do
        report = validator.validate(empty_document)

        expect(report.total_count).to eq(0)
        expect(report.valid?).to be true
      end
    end
  end

  describe 'integration with checkers' do
    it 'has checkers registered for all link types' do
      expect(validator.checkers.size).to eq(4)

      # Verify each checker type is present
      checker_classes = validator.checkers.map(&:class)
      expect(checker_classes).to include(
        Uniword::Validation::Checkers::ExternalLinkChecker,
        Uniword::Validation::Checkers::InternalLinkChecker,
        Uniword::Validation::Checkers::FileReferenceChecker,
        Uniword::Validation::Checkers::FootnoteReferenceChecker
      )
    end
  end

  describe 'configuration handling' do
    context 'with missing config file' do
      it 'uses defaults when config file not found' do
        validator = described_class.new(config_file: 'nonexistent.yml')

        expect(validator.checkers).not_to be_empty
      end
    end

    context 'with custom config file' do
      it 'accepts custom config file path' do
        # Use existing config file
        validator = described_class.new(
          config_file: 'config/link_validation_rules.yml'
        )

        expect(validator.config).to be_a(Hash)
      end
    end
  end
end
