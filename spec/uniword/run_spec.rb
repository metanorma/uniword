# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Run do
  let(:properties) do
    Uniword::Properties::RunProperties.new(
      bold: true,
      italic: false,
      size: 24
    )
  end

  describe '#initialize' do
    it 'creates a run with text' do
      run = described_class.new(text: 'Hello')
      expect(run.text).to eq('Hello')
    end

    it 'creates a run with properties' do
      run = described_class.new(text: 'Hello', properties: properties)
      expect(run.properties).to eq(properties)
    end

    it 'accepts text_element parameter for compatibility' do
      run = described_class.new(text_element: 'World')
      expect(run.text).to eq('World')
    end

    it 'prefers text over text_element when both provided' do
      run = described_class.new(text: 'Text', text_element: 'Element')
      expect(run.text).to eq('Text')
    end

    it 'creates a run with an id' do
      run = described_class.new(id: 'run-1', text: 'Test')
      expect(run.id).to eq('run-1')
    end
  end

  describe '#text_element' do
    it 'returns the text content' do
      run = described_class.new(text: 'Hello')
      expect(run.text_element).to eq('Hello')
    end

    it 'returns nil when no text' do
      run = described_class.new
      expect(run.text_element).to be_nil
    end
  end

  describe '#text_element=' do
    it 'sets the text content' do
      run = described_class.new
      run.text_element = 'New text'
      expect(run.text).to eq('New text')
    end
  end

  describe '#accept' do
    it 'accepts a visitor' do
      run = described_class.new(text: 'Test')
      visitor = double('visitor')

      expect(visitor).to receive(:visit_run).with(run)
      run.accept(visitor)
    end
  end

  describe '#bold?' do
    it 'returns false when no properties' do
      run = described_class.new(text: 'Test')
      expect(run.bold?).to be false
    end

    it 'returns false when bold is false' do
      props = Uniword::Properties::RunProperties.new(bold: false)
      run = described_class.new(text: 'Test', properties: props)
      expect(run.bold?).to be false
    end

    it 'returns true when bold is true' do
      props = Uniword::Properties::RunProperties.new(bold: true)
      run = described_class.new(text: 'Test', properties: props)
      expect(run.bold?).to be true
    end
  end

  describe '#italic?' do
    it 'returns false when no properties' do
      run = described_class.new(text: 'Test')
      expect(run.italic?).to be false
    end

    it 'returns false when italic is false' do
      props = Uniword::Properties::RunProperties.new(italic: false)
      run = described_class.new(text: 'Test', properties: props)
      expect(run.italic?).to be false
    end

    it 'returns true when italic is true' do
      props = Uniword::Properties::RunProperties.new(italic: true)
      run = described_class.new(text: 'Test', properties: props)
      expect(run.italic?).to be true
    end
  end

  describe '#underline?' do
    it 'returns false when no properties' do
      run = described_class.new(text: 'Test')
      expect(run.underline?).to be false
    end

    it 'returns false when underline is nil' do
      props = Uniword::Properties::RunProperties.new
      run = described_class.new(text: 'Test', properties: props)
      expect(run.underline?).to be false
    end

    it 'returns false when underline is "none"' do
      props = Uniword::Properties::RunProperties.new(underline: 'none')
      run = described_class.new(text: 'Test', properties: props)
      expect(run.underline?).to be false
    end

    it 'returns true when underline is set' do
      props = Uniword::Properties::RunProperties.new(underline: 'single')
      run = described_class.new(text: 'Test', properties: props)
      expect(run.underline?).to be true
    end
  end

  describe '#font_size' do
    it 'returns nil when no properties' do
      run = described_class.new(text: 'Test')
      expect(run.font_size).to be_nil
    end

    it 'returns nil when size is not set' do
      props = Uniword::Properties::RunProperties.new
      run = described_class.new(text: 'Test', properties: props)
      expect(run.font_size).to be_nil
    end

    it 'returns font size in points (half of size attribute)' do
      props = Uniword::Properties::RunProperties.new(size: 24)
      run = described_class.new(text: 'Test', properties: props)
      expect(run.font_size).to eq(12)
    end

    it 'handles odd sizes correctly' do
      props = Uniword::Properties::RunProperties.new(size: 25)
      run = described_class.new(text: 'Test', properties: props)
      expect(run.font_size).to eq(12)
    end
  end

  describe '#valid?' do
    it 'returns true when text is present' do
      run = described_class.new(text: 'Test')
      expect(run.valid?).to be true
    end

    it 'returns false when text is nil' do
      run = described_class.new
      expect(run.valid?).to be false
    end

    it 'returns true when text is empty string' do
      run = described_class.new(text: '')
      expect(run.valid?).to be true
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
