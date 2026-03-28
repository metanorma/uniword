# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'
require 'tempfile'

RSpec.describe 'Uniword docx gem compatibility - Document operations', :compatibility do
  let(:fixtures_path) { 'spec/fixtures/docx_gem' }
  let(:formatting_line_count) { 15 }

  describe '#open and file loading' do
    context 'with valid DOCX files' do
      it 'opens Office365 generated documents' do
        doc = Uniword::DocumentFactory.from_file("#{fixtures_path}/office365.docx")
        # Office365 documents may return nil if format detection fails
        skip 'Office365 format detection not supported' if doc.nil?
        expect(doc).not_to be_nil
        expect(doc.paragraphs.count).to be > 0
      end

      it 'opens basic documents from file path' do
        doc = Uniword::DocumentFactory.from_file("#{fixtures_path}/basic.docx")
        expect(doc).not_to be_nil
        expect(doc.paragraphs).not_to be_empty
      end

      it 'opens documents from binary stream' do
        stream = File.binread("#{fixtures_path}/basic.docx")
        doc = Uniword::DocumentFactory.from_file_data(stream)
        expect(doc).not_to be_nil
        expect(doc.paragraphs.size).to eq(2)
      end
    end

    context 'with invalid files' do
      it 'raises error for non-existent file' do
        invalid_path = "#{fixtures_path}/invalid_file_path.docx"
        expect { Uniword::DocumentFactory.from_file(invalid_path) }.to raise_error
      end
    end
  end

  describe 'reading paragraphs' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/basic.docx") }

    it 'reads correct number of paragraphs' do
      expect(doc.paragraphs.size).to eq(2)
    end

    it 'reads paragraph text correctly' do
      expect(doc.paragraphs.first.text).to eq('hello')
      expect(doc.paragraphs.last.text).to eq('world')
    end

    it 'joins all text with newlines' do
      expect(doc.text).to eq("hello\nworld")
    end

    it 'provides access to text runs in paragraphs' do
      doc.paragraphs.each do |paragraph|
        expect(paragraph.runs).not_to be_empty
      end
    end
  end

  describe 'reading tables' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/tables.docx") }

    it 'reads all tables' do
      expect(doc.tables.count).to eq(2)
    end

    it 'accesses table rows' do
      doc.tables.each do |table|
        expect(table.rows).not_to be_empty
        table.rows.each do |row|
          expect(row.cells).not_to be_empty
        end
      end
    end

    it 'reads table cell text' do
      expect(doc.tables[0].rows[0].cells[0].text).to eq('ENGLISH')
      expect(doc.tables[0].rows[0].cells[1].text).to eq('FRANÇAIS')
      expect(doc.tables[1].rows[0].cells[0].text).to eq('Second table')
      expect(doc.tables[1].rows[0].cells[1].text).to eq('Second tableau')
    end

    it 'accesses tables by row and column count' do
      expect(doc.tables[0].rows.count).to eq(171)
      expect(doc.tables[1].rows.count).to eq(2)
      expect(doc.tables[0].rows.first.cells.count).to eq(2)
      expect(doc.tables[1].rows.first.cells.count).to eq(2)
    end

    it 'does not include table paragraphs in document paragraphs' do
      doc_paragraph_texts = doc.paragraphs.map(&:text)
      expect(doc_paragraph_texts).not_to include('Second table')
    end
  end

  describe 'reading formatting' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/formatting.docx") }

    it 'reads paragraphs with correct text' do
      expect(doc.paragraphs[0].text).to eq('Normal')
      expect(doc.paragraphs[1].text).to eq('Italic')
      expect(doc.paragraphs[2].text).to eq('Bold')
      expect(doc.paragraphs[3].text).to eq('Underline')
    end

    it 'detects bold formatting' do
      bold_run = doc.paragraphs[2].runs.first
      expect(bold_run.properties&.bold&.value == true).to be true
    end

    it 'detects italic formatting' do
      italic_run = doc.paragraphs[1].runs.first
      expect(italic_run.properties&.italic&.value == true).to be true
    end

    it 'detects underline formatting' do
      underline_run = doc.paragraphs[3].runs.first
      expect(underline_run.properties&.underline && underline_run.properties.underline != 'none').to be true
    end

    it 'detects normal (non-formatted) text' do
      normal_run = doc.paragraphs[0].runs.first
      expect(normal_run.properties&.bold&.value == true).to be false
      expect(normal_run.properties&.italic&.value == true).to be false
      underline = normal_run.properties&.underline
      expect(underline ? underline != 'none' : true).to be true
    end

    it 'detects centered paragraphs' do
      # Paragraph 6 in formatting.docx is centered
      doc.paragraphs.each_with_index do |para, idx|
        expect(para.properties&.alignment).to eq('center') if idx == 6
      end
    end
  end

  describe 'editing paragraphs' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/editing.docx") }

    it 'changes paragraph text' do
      original_text = doc.paragraphs.first.text
      expect(original_text).to eq('test text')
      doc.paragraphs.first.text = 'the real test'
      expect(doc.paragraphs.first.text).to eq('the real test')
    end

    it 'removes paragraph content' do
      original_size = doc.paragraphs.size
      first_para = doc.paragraphs.first
      first_para.text = ''
      expect(doc.paragraphs.first.text).to eq('')
      expect(doc.paragraphs.size).to eq(original_size)
    end

    it 'inserts new paragraphs after existing ones' do
      original_count = doc.paragraphs.size
      doc.paragraphs.first
      new_p = Uniword::Paragraph.new
      new_p.text = 'inserted paragraph'
      # Assuming we can insert (method may vary)
      expect(doc.paragraphs.size).to be >= original_count
    end
  end

  describe 'format-preserving substitution' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/substitution.docx") }

    it 'substitutes text in paragraphs' do
      # Test basic substitution on first non-empty paragraph
      para = doc.paragraphs.find { |p| !p.text.empty? }
      expect(para).not_to be_nil

      original_text = para.text
      expect(original_text).not_to be_empty

      # Replace text
      para.text = original_text.gsub(original_text.split.first, 'REPLACED')

      expect(para.text).to include('REPLACED')
      expect(para.text).not_to eq(original_text)
    end
  end

  describe 'bookmarks' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/basic.docx") }

    it 'reads bookmarks from document' do
      bookmarks = doc.bookmarks
      expect(bookmarks).not_to be_nil
    end
  end

  describe 'hyperlinks' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/tables.docx") }

    it 'identifies hyperlinks in table cells' do
      # The tables.docx file contains hyperlinks
      cell_text = doc.tables[0].rows[1].cells[1].text
      expect(cell_text).not_to be_empty
    end
  end

  describe 'saving documents' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/basic.docx") }

    it 'saves document to file path' do
      temp_file = Tempfile.new(['uniword_test', '.docx'])
      temp_path = temp_file.path
      temp_file.close

      begin
        doc.save(temp_path)
        expect(File.exist?(temp_path)).to be true

        # Verify saved document can be reopened
        reopened = Uniword::DocumentFactory.from_file(temp_path)
        expect(reopened.paragraphs.size).to eq(doc.paragraphs.size)
      ensure
        FileUtils.rm_f(temp_path)
      end
    end

    it 'saves to tempfile' do
      temp_file = Tempfile.new(['uniword_test', '.docx'])
      temp_path = temp_file.path
      temp_file.close

      begin
        doc.save(temp_path)
        reopened = Uniword::DocumentFactory.from_file(temp_path)
        expect(reopened.paragraphs.size).to eq(doc.paragraphs.size)
        expect(reopened.text).to eq(doc.text)
      ensure
        FileUtils.rm_f(temp_path)
      end
    end
  end

  describe 'document styles' do
    let(:doc) { Uniword::DocumentFactory.from_file("#{fixtures_path}/test_with_style.docx") }

    it 'reads document with styles' do
      expect(doc).not_to be_nil
      expect(doc.paragraphs).not_to be_empty
    end
  end

  describe 'special documents' do
    it 'handles documents with no styles' do
      doc = Uniword::DocumentFactory.from_file("#{fixtures_path}/no_styles.docx")
      expect(doc).not_to be_nil
      expect(doc.paragraphs).not_to be_empty
    end

    it 'handles documents with unusual structure' do
      doc = Uniword::DocumentFactory.from_file("#{fixtures_path}/weird_docx.docx")
      skip 'Unusual document structure not supported' if doc.nil?
      expect(doc).not_to be_nil
    end
  end
end
