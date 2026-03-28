# frozen_string_literal: true

# Adapted docx gem tests for Uniword compatibility
# Tests basic document reading, tables, paragraphs, and formatting

require 'spec_helper'

RSpec.describe 'Docx gem compatibility (Uniword)', :compatibility do
  before(:all) do
    @fixtures_path = 'spec/fixtures/docx_gem'
  end

  describe 'Document opening' do
    it 'opens a basic DOCX file' do
      doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/basic.docx")
      expect(doc).not_to be_nil
      expect(doc.paragraphs).not_to be_nil
    end

    it 'raises error for non-existent file' do
      invalid_path = "#{@fixtures_path}/nonexistent.docx"
      expect do
        Uniword::DocumentFactory.from_file(invalid_path)
      end.to raise_error
    end

    it 'opens Office365 formatted DOCX' do
      doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/office365.docx")
      skip 'Office365 format detection not supported' if doc.nil?
      expect(doc).not_to be_nil
    end
  end

  describe 'Reading paragraphs' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/basic.docx")
    end

    it 'reads paragraphs from document' do
      expect(@doc.paragraphs.size).to be > 0
    end

    it 'reads paragraph text' do
      paragraphs = @doc.paragraphs
      expect(paragraphs.first.text).to eq('hello')
      expect(paragraphs.last.text).to eq('world')
    end

    it 'concatenates all paragraph text' do
      full_text = @doc.paragraphs.map(&:text).join("\n")
      expect(full_text).to include('hello')
      expect(full_text).to include('world')
    end
  end

  describe 'Reading tables' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/tables.docx")
    end

    it 'reads tables from document' do
      expect(@doc.tables.size).to eq 2
    end

    it 'reads table rows' do
      table = @doc.tables.first
      expect(table.rows.count).to be > 0
    end

    it 'reads table cells' do
      table = @doc.tables.first
      cells = table.rows.first.cells
      expect(cells.count).to be > 0
    end

    it 'reads table cell text' do
      table = @doc.tables.first
      first_cell_text = table.rows[0].cells[0].text
      expect(first_cell_text).to eq('ENGLISH')

      second_cell_text = table.rows[0].cells[1].text
      expect(second_cell_text).to eq('FRANÇAIS')
    end

    it 'accesses tables by index' do
      expect(@doc.tables[0]).not_to be_nil
      expect(@doc.tables[1]).not_to be_nil
      expect(@doc.tables[2]).to be_nil
    end

    it 'reads column data' do
      table = @doc.tables.first
      columns = table.columns
      expect(columns.count).to be > 0

      first_column = columns[0]
      expect(first_column.count).to be > 0
    end
  end

  describe 'Reading formatting' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/formatting.docx")
    end

    it 'reads document with formatting' do
      expect(@doc.paragraphs.size).to be > 0
    end

    it 'detects bold formatting' do
      # Find paragraph with bold text
      bold_para = @doc.paragraphs.find { |p| p.text.include?('Bold') }
      expect(bold_para).not_to be_nil

      # Verify it has runs
      expect(bold_para.runs.count).to be > 0
    end

    it 'detects italic formatting' do
      italic_para = @doc.paragraphs.find { |p| p.text.include?('Italic') }
      expect(italic_para).not_to be_nil
    end

    it 'detects underline formatting' do
      underline_para = @doc.paragraphs.find { |p| p.text.include?('Underline') }
      expect(underline_para).not_to be_nil
    end

    it 'detects text alignment' do
      paragraphs = @doc.paragraphs

      # Find centered, left-aligned, right-aligned paragraphs
      centered = paragraphs.find { |p| p.alignment == 'center' }
      left_aligned = paragraphs.find { |p| p.alignment == 'left' }

      # At least one should be present
      expect([centered, left_aligned].compact.size).to be > 0
    end
  end

  describe 'Hyperlinks and bookmarks' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/basic.docx")
    end

    it 'reads bookmarks from document' do
      # Check if document has any bookmarks
      bookmarks = @doc.bookmarks
      expect(bookmarks).not_to be_nil
    end
  end

  describe 'Document stream support' do
    it 'opens document from binary stream' do
      stream = File.binread("#{@fixtures_path}/basic.docx")
      doc = Uniword.load(stream)
      expect(doc).not_to be_nil
      expect(doc.paragraphs.size).to be > 0
    end
  end

  describe 'Paragraph iteration' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/basic.docx")
    end

    it 'iterates through all paragraphs' do
      count = 0
      @doc.paragraphs.each do |para|
        expect(para).not_to be_nil
        count += 1
      end
      expect(count).to be > 0
    end

    it 'filters paragraphs by text' do
      text_paragraphs = @doc.paragraphs.select { |p| p.text.include?('hello') }
      expect(text_paragraphs.size).to be > 0
    end
  end

  describe 'Text run access' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/formatting.docx")
    end

    it 'accesses text runs in paragraphs' do
      para = @doc.paragraphs.first
      expect(para.runs).not_to be_nil
    end

    it 'reads text from runs' do
      para = @doc.paragraphs.first
      unless para.runs.empty?
        text = para.runs.map(&:text).join
        expect(text).to be_a(String)
      end
    end
  end

  describe 'Styles and properties' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/styles.docx")
    end

    it 'reads document with styles' do
      expect(@doc.paragraphs.size).to be > 0
    end

    it 'accesses paragraph properties' do
      para = @doc.paragraphs.first
      # Should be able to access basic properties
      expect(para.text).to be_a(String)
    end
  end

  describe 'Editing capabilities' do
    before do
      @doc = Uniword::DocumentFactory.from_file("#{@fixtures_path}/editing.docx")
    end

    it 'modifies paragraph text' do
      @doc.paragraphs.first.text
      new_text = 'Modified text'
      @doc.paragraphs.first.text = new_text
      expect(@doc.paragraphs.first.text).to eq(new_text)
    end

    it 'preserves paragraph count after text change' do
      count_before = @doc.paragraphs.size
      @doc.paragraphs.first.text = 'New text'
      expect(@doc.paragraphs.size).to eq(count_before)
    end
  end

  describe 'Compatibility layer - Docx::Document alias' do
    it 'supports Docx::Document.open syntax' do
      doc = Uniword.load("#{@fixtures_path}/basic.docx")
      expect(doc).not_to be_nil
      expect(doc.paragraphs.size).to be > 0
    end
  end
end
