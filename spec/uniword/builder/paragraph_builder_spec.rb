# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe Uniword::Builder::ParagraphBuilder do
  describe '#initialize' do
    it 'creates a builder with a new Paragraph model' do
      builder = described_class.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::Paragraph)
    end

    it 'wraps an existing Paragraph model' do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = described_class.new(para)
      expect(builder.model).to eq(para)
    end
  end

  describe '.from_model' do
    it 'creates a builder from an existing Paragraph' do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = described_class.from_model(para)
      expect(builder.model).to eq(para)
    end
  end

  describe '#build' do
    it 'returns the underlying Paragraph model' do
      builder = described_class.new
      builder << 'Hello'
      model = builder.build
      expect(model).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(model.text).to eq('Hello')
    end
  end

  describe '#<< operator' do
    it 'appends a String as a Run' do
      builder = described_class.new
      builder << 'Hello World'
      expect(builder.model.runs.size).to eq(1)
      expect(builder.model.text).to eq('Hello World')
    end

    it 'appends multiple Strings as separate Runs' do
      builder = described_class.new
      builder << 'Hello '
      builder << 'World'
      expect(builder.model.runs.size).to eq(2)
      expect(builder.model.text).to eq('Hello World')
    end

    it 'appends a Run object' do
      builder = described_class.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test')
      builder << run
      expect(builder.model.runs).to include(run)
    end

    it 'appends a RunBuilder' do
      builder = described_class.new
      run_builder = Uniword::Builder::RunBuilder.new.text('Test').bold
      builder << run_builder
      expect(builder.model.runs.size).to eq(1)
      expect(builder.model.text).to eq('Test')
    end

    it 'appends a Hyperlink' do
      builder = described_class.new
      hl = Uniword::Wordprocessingml::Hyperlink.new
      hl.target = 'https://example.com'
      builder << hl
      expect(builder.model.hyperlinks).to include(hl)
    end

    it 'appends a TabStop to properties' do
      builder = described_class.new
      tab = Uniword::Properties::TabStop.new(position: 7200, alignment: 'right')
      builder << tab
      expect(builder.model.properties.tabs).not_to be_nil
      expect(builder.model.properties.tabs.size).to eq(1)
    end

    it 'raises ArgumentError for unsupported types' do
      builder = described_class.new
      expect { builder << 42 }.to raise_error(ArgumentError, /Cannot add/)
    end

    it 'returns self for chaining' do
      builder = described_class.new
      result = builder << 'Hello'
      expect(result).to eq(builder)
    end
  end

  describe 'property setters' do
    it 'sets style' do
      builder = described_class.new
      builder.style = 'Heading1'
      expect(builder.model.properties.style).to eq('Heading1')
    end

    it 'sets alignment' do
      builder = described_class.new
      builder.align = :center
      expect(builder.model.properties.alignment).to eq('center')
    end

    it 'sets numbering' do
      builder = described_class.new
      builder.numbering(1, 0)
      expect(builder.model.properties.numbering_properties).not_to be_nil
      expect(builder.model.properties.numbering_properties.num_id.value).to eq(1)
      expect(builder.model.properties.numbering_properties.ilvl.value).to eq(0)
    end

    it 'sets keep_next' do
      builder = described_class.new
      builder.keep_next
      expect(builder.model.properties.keep_next).to eq(true)
    end

    it 'sets page_break_before' do
      builder = described_class.new
      builder.page_break_before
      expect(builder.model.properties.page_break_before).to eq(true)
    end
  end

  describe '#spacing' do
    it 'sets spacing before and after' do
      builder = described_class.new
      builder.spacing(before: 240, after: 120)
      expect(builder.model.properties.spacing.before).to eq(240)
      expect(builder.model.properties.spacing.after).to eq(120)
    end

    it 'sets line spacing with rule' do
      builder = described_class.new
      builder.spacing(line: 360, rule: 'exact')
      expect(builder.model.properties.spacing.line).to eq(360)
      expect(builder.model.properties.spacing.line_rule).to eq('exact')
    end
  end

  describe '#indent' do
    it 'sets indentation' do
      builder = described_class.new
      builder.indent(left: 720, right: 360, first_line: 480)
      expect(builder.model.properties.indentation.left).to eq(720)
      expect(builder.model.properties.indentation.right).to eq(360)
      expect(builder.model.properties.indentation.first_line).to eq(480)
    end
  end

  describe '#shading' do
    it 'sets paragraph shading' do
      builder = described_class.new
      builder.shading(fill: '4472C4', color: 'auto')
      expect(builder.model.properties.shading).to be_a(Uniword::Properties::Shading)
    end
  end
end
