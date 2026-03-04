# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Paragraph do
  let(:run1) { Uniword::Run.new(text: 'Hello ') }
  let(:run2) { Uniword::Run.new(text: 'World') }
  let(:properties) do
    Uniword::Wordprocessingml::ParagraphProperties.new(
      style: 'Normal',
      alignment: 'left'
    )
  end

  describe '#initialize' do
    it 'creates a paragraph with no runs' do
      paragraph = described_class.new
      expect(paragraph.runs).to eq([])
    end

    it 'creates a paragraph with properties' do
      paragraph = described_class.new(properties: properties)
      expect(paragraph.properties).to eq(properties)
    end

    it 'creates a paragraph with an id' do
      paragraph = described_class.new(id: 'para-1')
      expect(paragraph.id).to eq('para-1')
    end
  end

  describe '#accept' do
    it 'accepts a visitor' do
      paragraph = described_class.new
      visitor = double('visitor')

      expect(visitor).to receive(:visit_paragraph).with(paragraph)
      paragraph.accept(visitor)
    end
  end

  describe '#text' do
    it 'returns empty string for paragraph with no runs' do
      paragraph = described_class.new
      expect(paragraph.text).to eq('')
    end

    it 'returns text from a single run' do
      paragraph = described_class.new(runs: [run1])
      expect(paragraph.text).to eq('Hello ')
    end

    it 'concatenates text from multiple runs' do
      paragraph = described_class.new(runs: [run1, run2])
      expect(paragraph.text).to eq('Hello World')
    end

    it 'handles runs with nil text' do
      run_with_nil = Uniword::Run.new
      paragraph = described_class.new(runs: [run1, run_with_nil, run2])
      expect(paragraph.text).to eq('Hello World')
    end
  end

  describe '#add_run' do
    let(:paragraph) { described_class.new }

    it 'adds a run to the paragraph' do
      paragraph.add_run(run1)
      expect(paragraph.runs).to include(run1)
    end

    it 'adds multiple runs' do
      paragraph.add_run(run1)
      paragraph.add_run(run2)
      expect(paragraph.runs).to eq([run1, run2])
    end

    it 'raises error for non-Run objects' do
      paragraph = described_class.new
      expect { paragraph.add_run(123) }
        .to raise_error(ArgumentError,
                        /must be a Run, Image, Hyperlink, Bookmark, or UnknownElement instance/)
    end

    it 'returns the updated runs array' do
      result = paragraph.add_run(run1)
      expect(result).to be_an(Array)
      expect(result).to include(run1)
    end
  end

  describe '#add_text' do
    let(:paragraph) { described_class.new }

    it 'creates and adds a run with text' do
      paragraph.add_text('Hello')
      expect(paragraph.runs.size).to eq(1)
      expect(paragraph.runs.first.text).to eq('Hello')
    end

    it 'creates and adds a run with properties' do
      run_props = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      paragraph.add_text('Bold text', properties: run_props)
      expect(paragraph.runs.first.properties).to eq(run_props)
    end

    it 'returns the created run' do
      run = paragraph.add_text('Test')
      expect(run).to be_a(Uniword::Run)
      expect(run.text).to eq('Test')
    end

    it 'adds multiple text runs' do
      paragraph.add_text('First')
      paragraph.add_text('Second')
      expect(paragraph.text).to eq('FirstSecond')
    end
  end

  describe '#empty?' do
    it 'returns true for paragraph with no runs' do
      paragraph = described_class.new
      expect(paragraph.empty?).to be true
    end

    it 'returns true for paragraph with empty runs' do
      empty_run = Uniword::Run.new(text: '')
      paragraph = described_class.new(runs: [empty_run])
      expect(paragraph.empty?).to be true
    end

    it 'returns true for paragraph with nil text runs' do
      nil_run = Uniword::Run.new
      paragraph = described_class.new(runs: [nil_run])
      expect(paragraph.empty?).to be true
    end

    it 'returns false for paragraph with text' do
      paragraph = described_class.new(runs: [run1])
      expect(paragraph.empty?).to be false
    end
  end

  describe '#run_count' do
    it 'returns 0 for paragraph with no runs' do
      paragraph = described_class.new
      expect(paragraph.run_count).to eq(0)
    end

    it 'returns correct count for multiple runs' do
      paragraph = described_class.new(runs: [run1, run2])
      expect(paragraph.run_count).to eq(2)
    end
  end

  describe '#alignment' do
    it 'returns nil when no properties' do
      paragraph = described_class.new
      expect(paragraph.alignment).to be_nil
    end

    it 'returns alignment from properties' do
      paragraph = described_class.new(properties: properties)
      expect(paragraph.alignment).to eq('left')
    end
  end

  describe '#style' do
    it 'returns nil when no properties' do
      paragraph = described_class.new
      expect(paragraph.style).to be_nil
    end

    it 'returns style from properties' do
      paragraph = described_class.new(properties: properties)
      expect(paragraph.style).to eq('Normal')
    end
  end

  describe '#valid?' do
    it 'returns true for empty paragraph' do
      paragraph = described_class.new
      expect(paragraph.valid?).to be true
    end

    it 'returns true for paragraph with runs' do
      paragraph = described_class.new(runs: [run1, run2])
      expect(paragraph.valid?).to be true
    end
  end

  describe 'inheritance' do
    it 'inherits from Element' do
      expect(described_class.ancestors).to include(Uniword::Element)
    end

    it 'is not abstract' do
      expect(described_class.abstract?).to be false
    end
  end
end
