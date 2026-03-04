# frozen_string_literal: true

require 'spec_helper'
require 'uniword/assembly/toc_generator'

RSpec.describe Uniword::Assembly::TocGenerator do
  let(:document) do
    doc = Uniword::Document.new

    # Add headings
    add_heading(doc, 'Introduction', 1)
    add_heading(doc, 'Background', 2)
    add_heading(doc, 'Methods', 1)
    add_heading(doc, 'Results', 2)
    add_heading(doc, 'Discussion', 2)
    add_heading(doc, 'Conclusion', 1)

    doc
  end

  def add_heading(doc, text, level)
    para = Uniword::Paragraph.new
    para.style = "Heading #{level}"
    run = Uniword::Run.new
    run.text = text
    para.add_run(run)
    doc.add_paragraph(para)
  end

  describe '#initialize' do
    it 'creates generator with default settings' do
      gen = described_class.new
      expect(gen.max_level).to eq(9)
      expect(gen.title).to eq('Table of Contents')
    end

    it 'accepts custom max level' do
      gen = described_class.new(max_level: 3)
      expect(gen.max_level).to eq(3)
    end

    it 'accepts custom title' do
      gen = described_class.new(title: 'Contents')
      expect(gen.title).to eq('Contents')
    end
  end

  describe '#generate' do
    let(:gen) { described_class.new }

    it 'generates TOC paragraphs' do
      toc = gen.generate(document)
      expect(toc).to be_an(Array)
      expect(toc).not_to be_empty
    end

    it 'includes title paragraph' do
      toc = gen.generate(document)
      title_para = toc.first

      expect(title_para.runs.first.text).to eq('Table of Contents')
      expect(title_para.runs.first.bold).to be true
    end

    it 'includes heading entries' do
      toc = gen.generate(document)
      # Skip title paragraph
      entries = toc[1..]

      texts = entries.map { |p| p.runs.first.text }
      expect(texts).to include('Introduction', 'Methods', 'Conclusion')
    end

    it 'respects max level' do
      gen = described_class.new(max_level: 1)
      toc = gen.generate(document)

      entries = toc[1..]
      texts = entries.map { |p| p.runs.first.text }

      # Should only include level 1 headings
      expect(texts).to include('Introduction', 'Methods', 'Conclusion')
      expect(texts).not_to include('Background', 'Results', 'Discussion')
    end

    it 'uses custom title' do
      gen = described_class.new(title: 'Contents')
      toc = gen.generate(document)

      expect(toc.first.runs.first.text).to eq('Contents')
    end
  end

  describe '#generate_document' do
    let(:gen) { described_class.new }

    it 'creates new document with TOC' do
      toc_doc = gen.generate_document(document)
      expect(toc_doc).to be_a(Uniword::Document)
      expect(toc_doc.paragraphs).not_to be_empty
    end

    it 'includes all TOC paragraphs' do
      toc_doc = gen.generate_document(document)
      expect(toc_doc.paragraphs.size).to be > 1
    end
  end

  describe '#insert_toc' do
    let(:gen) { described_class.new }
    let(:target_doc) { Uniword::Document.new }

    before do
      # Add some content to target document
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Existing content'
      para.add_run(run)
      target_doc.add_paragraph(para)
    end

    it 'inserts TOC at specified position' do
      original_count = target_doc.paragraphs.size
      gen.insert_toc(target_doc, 0)

      expect(target_doc.paragraphs.size).to be > original_count
    end

    it 'inserts at beginning by default' do
      gen.insert_toc(target_doc)

      # First paragraph should be TOC title
      expect(target_doc.paragraphs.first.runs.first.text)
        .to eq('Table of Contents')
    end
  end

  describe 'heading extraction' do
    it 'extracts headings with correct levels' do
      gen = described_class.new
      toc = gen.generate(document)

      # Check that different heading levels are represented
      entries = toc[1..]
      expect(entries.size).to eq(6) # All headings
    end

    it 'handles documents without headings' do
      empty_doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Regular paragraph'
      para.add_run(run)
      empty_doc.add_paragraph(para)

      gen = described_class.new
      toc = gen.generate(empty_doc)

      # Should only have title, no entries
      expect(toc.size).to eq(1)
    end
  end

  describe 'TOC styling' do
    let(:gen) { described_class.new }

    it 'applies TOC styles to entries' do
      toc = gen.generate(document)
      title = toc[0]

      expect(title.style).to eq('TOCHeading')
    end

    it 'sets appropriate styles for different levels' do
      toc = gen.generate(document)
      entries = toc[1..]

      # Each entry should have a TOC style
      entries.each do |entry|
        expect(entry.style).to match(/^TOC\d+$/)
      end
    end
  end
end
