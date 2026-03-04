# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Document do
  describe '.new' do
    it 'creates a new document' do
      document = described_class.new
      expect(document).to be_a(Uniword::Document)
    end

    it 'initializes with nil body' do
      document = described_class.new
      expect(document.body).to be_nil
    end

    it 'has empty paragraphs when body is nil' do
      document = described_class.new
      expect(document.paragraphs).to eq([])
    end
  end

  describe '#add_paragraph' do
    let(:document) { described_class.new }

    it 'creates a body if not present' do
      expect(document.body).to be_nil
      document.add_paragraph('Hello')
      expect(document.body).to be_a(Uniword::Body)
    end

    it 'adds a paragraph with text' do
      para = document.add_paragraph('Hello World')
      expect(para).to be_a(Uniword::Paragraph)
      expect(para.text).to eq('Hello World')
    end

    it 'adds paragraph to body.paragraphs' do
      para = document.add_paragraph('Test')
      expect(document.paragraphs).to include(para)
    end

    it 'applies bold formatting' do
      para = document.add_paragraph('Bold text', bold: true)
      expect(para.runs.first.properties.bold).to be true
    end

    it 'applies italic formatting' do
      para = document.add_paragraph('Italic text', italic: true)
      expect(para.runs.first.properties.italic).to be true
    end

    it 'applies style' do
      para = document.add_paragraph('Heading', style: 'Heading1')
      expect(para.properties.style).to eq('Heading1')
    end

    it 'applies heading option' do
      para = document.add_paragraph('Title', heading: 1)
      expect(para.properties.style).to eq('Heading1')
    end
  end

  describe '#add_table' do
    let(:document) { described_class.new }

    it 'creates a body if not present' do
      expect(document.body).to be_nil
      document.add_table(2, 2)
      expect(document.body).to be_a(Uniword::Body)
    end

    it 'creates table with dimensions' do
      table = document.add_table(2, 3)
      expect(table).to be_a(Uniword::Table)
      expect(table.rows.count).to eq(2)
      expect(table.rows.first.cells.count).to eq(3)
    end

    it 'adds table to body.tables' do
      table = document.add_table(1, 1)
      expect(document.tables).to include(table)
    end
  end

  describe '#text' do
    let(:document) { described_class.new }

    it 'returns empty string for empty document' do
      expect(document.text).to eq('')
    end

    it 'returns combined paragraph text' do
      document.add_paragraph('First')
      document.add_paragraph('Second')
      expect(document.text).to eq("First\nSecond")
    end
  end

  describe '#paragraphs' do
    let(:document) { described_class.new }

    it 'returns empty array when no body' do
      expect(document.paragraphs).to eq([])
    end

    it 'returns paragraphs from body' do
      document.add_paragraph('One')
      document.add_paragraph('Two')
      expect(document.paragraphs.count).to eq(2)
    end
  end

  describe '#tables' do
    let(:document) { described_class.new }

    it 'returns empty array when no body' do
      expect(document.tables).to eq([])
    end

    it 'returns tables from body' do
      document.add_table(1, 1)
      document.add_table(2, 2)
      expect(document.tables.count).to eq(2)
    end
  end
end
