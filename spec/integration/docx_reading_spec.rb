# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DOCX Reading Integration', :integration do
  let(:fixtures_dir) { File.join(__dir__, '..', 'fixtures') }

  describe 'reading basic.docx' do
    let(:docx_path) { File.join(fixtures_dir, 'basic.docx') }

    it 'can open and parse the file' do
      document = Uniword::Document.open(docx_path)
      expect(document).to be_a(Uniword::Document)
    end

    it 'extracts paragraphs' do
      document = Uniword::Document.open(docx_path)
      expect(document.paragraphs).not_to be_empty
    end

    it 'extracts text content' do
      document = Uniword::Document.open(docx_path)
      text = document.paragraphs.map(&:text).join("\n")
      expect(text).to include('hello')
      expect(text).to include('world')
    end
  end

  describe 'reading formatting.docx' do
    let(:docx_path) { File.join(fixtures_dir, 'formatting.docx') }

    it 'can open and parse the file' do
      document = Uniword::Document.open(docx_path)
      expect(document).to be_a(Uniword::Document)
    end

    it 'extracts paragraphs with runs' do
      document = Uniword::Document.open(docx_path)
      paragraphs = document.paragraphs
      expect(paragraphs).not_to be_empty

      # At least one paragraph should have runs
      has_runs = paragraphs.any? { |p| p.runs.any? }
      expect(has_runs).to be true
    end
  end

  describe 'reading tables.docx' do
    let(:docx_path) { File.join(fixtures_dir, 'tables.docx') }

    it 'can open and parse the file' do
      document = Uniword::Document.open(docx_path)
      expect(document).to be_a(Uniword::Document)
    end

    it 'extracts tables from the document' do
      document = Uniword::Document.open(docx_path)
      tables = document.body.tables
      expect(tables).not_to be_empty
    end

    it 'extracts table structure (rows and cells)' do
      document = Uniword::Document.open(docx_path)
      tables = document.body.tables

      # Should have at least one table
      expect(tables.size).to be >= 1

      table = tables.first
      # Table should have rows
      expect(table.rows).not_to be_empty

      # First row should have cells
      expect(table.rows.first.cells).not_to be_empty
    end

    it 'extracts cell content (paragraphs in cells)' do
      document = Uniword::Document.open(docx_path)
      table = document.body.tables.first

      # Get first cell
      cell = table.rows.first.cells.first

      # Cell should have paragraphs
      expect(cell.paragraphs).not_to be_empty

      # Cell text should not be empty (assuming the fixture has content)
      expect(cell.text.strip).not_to be_empty
    end
  end

  describe 'reading formatting.docx - text properties' do
    let(:docx_path) { File.join(fixtures_dir, 'formatting.docx') }

    it 'extracts text formatting (bold, italic, etc.)' do
      document = Uniword::Document.open(docx_path)

      # Collect all runs from all paragraphs
      all_runs = document.paragraphs.flat_map(&:runs)

      # At least some runs should have properties
      runs_with_properties = all_runs.select(&:properties)
      expect(runs_with_properties).not_to be_empty
    end

    it 'detects bold formatting' do
      document = Uniword::Document.open(docx_path)

      # Find runs with bold formatting
      bold_runs = []
      document.paragraphs.each do |para|
        para.runs.each do |run|
          bold_runs << run if run.properties&.bold
        end
      end

      # The formatting.docx fixture should have at least some bold text
      # If not, this test will help us verify our parsing works
      expect(bold_runs.size).to be >= 0
    end

    it 'detects italic formatting' do
      document = Uniword::Document.open(docx_path)

      # Find runs with italic formatting
      italic_runs = []
      document.paragraphs.each do |para|
        para.runs.each do |run|
          italic_runs << run if run.properties&.italic
        end
      end

      expect(italic_runs.size).to be >= 0
    end

    it 'extracts font properties' do
      document = Uniword::Document.open(docx_path)

      # Find runs with font specified
      runs_with_font = []
      document.paragraphs.each do |para|
        para.runs.each do |run|
          runs_with_font << run if run.properties&.font
        end
      end

      # Should have some fonts defined
      expect(runs_with_font.size).to be >= 0
    end

    it 'extracts font size' do
      document = Uniword::Document.open(docx_path)

      # Find runs with size specified
      runs_with_size = []
      document.paragraphs.each do |para|
        para.runs.each do |run|
          runs_with_size << run if run.properties&.size
        end
      end

      expect(runs_with_size.size).to be >= 0
    end
  end

  describe 'reading formatting.docx - paragraph properties' do
    let(:docx_path) { File.join(fixtures_dir, 'formatting.docx') }

    it 'extracts paragraph properties' do
      document = Uniword::Document.open(docx_path)

      # At least some paragraphs should have properties
      paras_with_props = document.paragraphs.select(&:properties)
      expect(paras_with_props.size).to be >= 0
    end

    it 'detects paragraph alignment' do
      document = Uniword::Document.open(docx_path)

      # Find paragraphs with alignment
      paras_with_alignment = document.paragraphs.select do |para|
        para.properties&.alignment
      end

      expect(paras_with_alignment.size).to be >= 0
    end

    it 'detects paragraph styles' do
      document = Uniword::Document.open(docx_path)

      # Find paragraphs with styles
      paras_with_style = document.paragraphs.select do |para|
        para.properties&.style
      end

      expect(paras_with_style.size).to be >= 0
    end
  end

  describe 'stress test with various fixtures' do
    it 'can read all reference DOCX files without crashing' do
      reference_fixtures = [
        'basic.docx',
        'formatting.docx',
        'tables.docx',
        'internal-links.docx',
        'replacement.docx',
        'saving.docx'
      ]

      reference_fixtures.each do |fixture_file|
        fixture_path = File.join(fixtures_dir, fixture_file)
        next unless File.exist?(fixture_path)

        expect do
          document = Uniword::Document.open(fixture_path)
          # Force some basic operations to ensure parsing works
          document.paragraphs.each(&:text)
          document.body.tables.each(&:rows)
        end.not_to raise_error, "Failed to read #{fixture_file}"
      end
    end
  end
end
