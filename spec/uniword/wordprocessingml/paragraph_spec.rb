# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Paragraph do
  let(:run1) { Uniword::Run.new(text: 'Hello ') }
  let(:run2) { Uniword::Run.new(text: 'World') }
  let(:properties) do
    Uniword::Wordprocessingml::ParagraphProperties.new.tap do |p|
      p.style = 'Normal'
      p.alignment = 'left'
    end
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

    it 'does not have an id attribute (v2.0 API)' do
      paragraph = described_class.new
      expect(paragraph).not_to respond_to(:id)
    end
  end

  describe '#accept' do
    # v2.0 API: Paragraph has accept method for visitor pattern
    it 'has accept method for visitor pattern' do
      paragraph = described_class.new
      expect(paragraph).to respond_to(:accept)
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

    it 'adds a run to the paragraph with text' do
      run = paragraph.add_run('Hello')
      expect(run).to be_a(Uniword::Run)
      expect(run.text).to eq('Hello')
      expect(paragraph.runs).to include(run)
    end

    it 'adds multiple runs with text' do
      paragraph.add_run('Hello ')
      paragraph.add_run('World')
      expect(paragraph.runs.size).to eq(2)
      expect(paragraph.text).to eq('Hello World')
    end

    it 'returns the created run' do
      run = paragraph.add_run('Test')
      expect(run).to be_a(Uniword::Run)
      expect(run.text).to eq('Test')
    end

    it 'accepts options for formatting' do
      run = paragraph.add_run('Bold', bold: true)
      expect(run.properties&.bold).to be_truthy
    end
  end

  describe '#add_text' do
    let(:paragraph) { described_class.new }

    it 'creates and adds a run with text' do
      paragraph.add_text('Hello')
      expect(paragraph.runs.size).to eq(1)
      expect(paragraph.runs.first.text).to eq('Hello')
    end

    it 'creates and adds a run with formatting options' do
      paragraph.add_text('Bold text', bold: true)
      expect(paragraph.runs.first.properties&.bold).to be_truthy
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
    # v2.0 API: run_count method does not exist, use runs.count instead
    it 'does not have run_count method (use runs.count)' do
      paragraph = described_class.new
      expect(paragraph).not_to respond_to(:run_count)
      expect(paragraph.runs.count).to eq(0)
    end

    it 'uses runs.count for multiple runs' do
      paragraph = described_class.new(runs: [run1, run2])
      expect(paragraph.runs.count).to eq(2)
    end
  end

  describe '#alignment' do
    # v2.0 API: alignment is not a direct method, access via properties
    it 'returns nil when no properties' do
      paragraph = described_class.new
      expect(paragraph.properties).to be_nil
    end

    it 'accesses alignment via properties object' do
      paragraph = described_class.new(properties: properties)
      # Access alignment via paragraph.alignment which handles wrapper extraction
      expect(paragraph.alignment).to eq('left')
    end
  end

  describe '#style' do
    # v2.0 API: style is not a direct method, access via properties
    it 'returns nil when no properties' do
      paragraph = described_class.new
      expect(paragraph.properties).to be_nil
    end

    it 'accesses style via properties object' do
      paragraph = described_class.new(properties: properties)
      # Access style via properties.style
      expect(paragraph.properties.style).to eq('Normal')
    end
  end

  describe '#valid?' do
    # v2.0 API: Paragraph does not have valid? method (lutaml-model handles validation)
    it 'does not have valid? method (lutaml-model handles validation)' do
      paragraph = described_class.new
      expect(paragraph).not_to respond_to(:valid?)
    end
  end

  describe 'inheritance' do
    it 'is a Lutaml::Model::Serializable' do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end

    it 'does not inherit from Element (v2.0 uses direct lutaml-model inheritance)' do
      expect(described_class.ancestors).not_to include(Uniword::Element)
    end
  end
end
