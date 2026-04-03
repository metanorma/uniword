# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe Uniword::Builder::DocumentBuilder do
  describe '#initialize' do
    it 'creates a builder with a new DocumentRoot' do
      builder = described_class.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end
  end

  describe '#paragraph' do
    it 'creates and adds a paragraph with text' do
      builder = described_class.new
      para_builder = builder.paragraph('Hello World')
      expect(builder.model.body.paragraphs.size).to eq(1)
      expect(builder.model.body.paragraphs.first.text).to eq('Hello World')
    end

    it 'creates a paragraph with block configuration' do
      builder = described_class.new
      builder.paragraph do |p|
        p << 'Styled text'
        p.style = 'Heading1'
        p.align = :center
      end
      expect(builder.model.body.paragraphs.size).to eq(1)
      para = builder.model.body.paragraphs.first
      expect(para.text).to eq('Styled text')
      expect(para.properties.style.value).to eq('Heading1')
      expect(para.properties.alignment.value).to eq('center')
    end
  end

  describe '#heading' do
    it 'creates a heading paragraph with correct style' do
      builder = described_class.new
      builder.heading('Introduction', level: 1)
      para = builder.model.body.paragraphs.first
      expect(para.text).to eq('Introduction')
      expect(para.properties.style).to eq('Heading1')
    end

    it 'supports different heading levels' do
      builder = described_class.new
      builder.heading('Section', level: 2)
      expect(builder.model.body.paragraphs.first.properties.style).to eq('Heading2')
    end
  end

  describe '#<< operator' do
    it 'appends a Paragraph' do
      builder = described_class.new
      para = Uniword::Wordprocessingml::Paragraph.new
      para.runs << Uniword::Wordprocessingml::Run.new(text: 'Direct')
      builder << para
      expect(builder.model.body.paragraphs).to include(para)
    end

    it 'appends a ParagraphBuilder' do
      builder = described_class.new
      para_builder = Uniword::Builder::ParagraphBuilder.new
      para_builder << 'From builder'
      builder << para_builder
      expect(builder.model.body.paragraphs.size).to eq(1)
      expect(builder.model.body.paragraphs.first.text).to eq('From builder')
    end

    it 'raises ArgumentError for unsupported types' do
      builder = described_class.new
      expect { builder << 'string' }.to raise_error(ArgumentError, /Cannot add/)
    end
  end

  describe '#table' do
    it 'creates and adds a table with rows and cells' do
      builder = described_class.new
      builder.table do |t|
        t.row do |r|
          r.cell(text: 'Header 1')
          r.cell(text: 'Header 2')
        end
      end
      expect(builder.model.body.tables.size).to eq(1)
      table = builder.model.body.tables.first
      expect(table.rows.size).to eq(1)
      expect(table.rows.first.cells.size).to eq(2)
      expect(table.rows.first.cells.first.text).to eq('Header 1')
    end
  end

  describe '#build' do
    it 'returns the underlying DocumentRoot' do
      builder = described_class.new
      expect(builder.build).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end
  end
end
