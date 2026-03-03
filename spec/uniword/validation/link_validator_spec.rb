# frozen_string_literal: true

require 'spec_helper'
require 'uniword/validation/link_validator'
require 'uniword/wordprocessingml/hyperlink'
require 'uniword/bookmark'
require 'uniword/footnote'

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
    let(:mock_document) do
      double('Document',
             paragraphs: paragraphs,
             tables: [],
             headers: [],
             footers: [],
             bookmarks: {},
             footnotes: {})
    end

    let(:hyperlink) do
      Uniword::Hyperlink.new(url: 'https://example.com', text: 'Example')
    end

    let(:paragraphs) do
      [
        double('Paragraph', runs: [hyperlink], hyperlinks: [])
      ]
    end

    it 'returns a ValidationReport' do
      report = validator.validate(mock_document)

      expect(report).to be_a(Uniword::Validation::ValidationReport)
    end

    it 'validates hyperlinks in document' do
      report = validator.validate(mock_document)

      expect(report.total_count).to be > 0
    end

    context 'with external links' do
      let(:paragraphs) do
        [
          double('Paragraph',
                 runs: [
                   Uniword::Hyperlink.new(url: 'https://example.com', text: 'Link')
                 ],
                 hyperlinks: [])
        ]
      end

      it 'validates external links' do
        # Mock HTTP response
        allow_any_instance_of(Net::HTTP).to receive(:request).and_return(
          double('Response', code: '200', message: 'OK')
        )

        report = validator.validate(mock_document)

        expect(report.total_count).to eq(1)
      end
    end

    context 'with internal bookmarks' do
      let(:anchor_link) do
        Uniword::Hyperlink.new(anchor: 'section1', text: 'Go to section')
      end

      let(:paragraphs) do
        [
          double('Paragraph', runs: [anchor_link], hyperlinks: [])
        ]
      end

      let(:mock_document) do
        double('Document',
               paragraphs: paragraphs,
               tables: [],
               headers: [],
               footers: [],
               bookmarks: { 'section1' => Uniword::Bookmark.new(name: 'section1') },
               footnotes: {})
      end

      it 'validates internal bookmark links' do
        report = validator.validate(mock_document)

        expect(report.total_count).to eq(1)
      end
    end

    context 'with tables' do
      let(:table_link) do
        Uniword::Hyperlink.new(url: 'https://table.example.com', text: 'Table Link')
      end

      let(:mock_cell) do
        double('Cell',
               paragraphs: [
                 double('Paragraph', runs: [table_link], hyperlinks: [])
               ])
      end

      let(:mock_row) do
        double('Row', cells: [mock_cell])
      end

      let(:mock_table) do
        double('Table', rows: [mock_row])
      end

      let(:mock_document) do
        double('Document',
               paragraphs: [],
               tables: [mock_table],
               headers: [],
               footers: [],
               bookmarks: {},
               footnotes: {})
      end

      it 'validates links in tables' do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_return(
          double('Response', code: '200', message: 'OK')
        )

        report = validator.validate(mock_document)

        expect(report.total_count).to eq(1)
      end
    end

    context 'with empty document' do
      let(:empty_document) do
        double('Document',
               paragraphs: [],
               tables: [],
               headers: [],
               footers: [],
               bookmarks: {},
               footnotes: {})
      end

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
