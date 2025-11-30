# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Run Properties Inheritance' do
  let(:doc) do
    d = Uniword::Document.new
    # Set up document with styles
    d.styles_configuration = Uniword::StylesConfiguration.new

    # Add custom heading style with run properties
    heading_style = Uniword::ParagraphStyle.new(
      id: 'TestHeading1',
      name: 'Test Heading 1',
      type: 'paragraph',
      run_properties: Uniword::Properties::RunProperties.new(
        bold: true,
        size: 32, # 16pt = 32 half-points
        color: 'FF0000'
      ),
      paragraph_properties: Uniword::Properties::ParagraphProperties.new(
        spacing_before: 240,
        spacing_after: 120
      )
    )
    d.styles_configuration.add_style(heading_style)
    d
  end

  describe 'Run inherits properties from paragraph style' do
    it 'inherits bold property when not explicitly set' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Heading text')
      para.add_run(run)

      # Run should inherit bold from Heading1 style
      expect(run.bold?).to be true
    end

    it 'inherits font size when not explicitly set' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Heading text')
      para.add_run(run)

      # Run should inherit font size from Heading1 style
      # 32 half-points = 16 points
      expect(run.font_size).to eq(16)
    end

    it 'inherits color when not explicitly set' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Heading text')
      para.add_run(run)

      # Run should inherit color from Heading1 style
      expect(run.color).to eq('FF0000')
    end

    it 'prefers explicit run properties over inherited' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Custom text')
      run.bold = false # Explicitly override
      run.font_size = 10 # Explicitly override
      para.add_run(run)

      # Run should use explicit values, not inherited
      expect(run.bold?).to be false
      expect(run.font_size).to eq(10)
    end

    it 'returns nil when no style and no explicit property' do
      para = Uniword::Paragraph.new # No style
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Plain text')
      para.add_run(run)

      # No style, no explicit property = nil/false
      expect(run.bold?).to be false
      expect(run.font_size).to be_nil
      expect(run.color).to be_nil
    end
  end

  describe 'Multiple runs with mixed inheritance' do
    it 'handles runs with different inheritance patterns' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      # Run 1: Inherits all
      run1 = Uniword::Run.new(text: 'Inherited ')
      para.add_run(run1)

      # Run 2: Overrides bold
      run2 = Uniword::Run.new(text: 'Mixed ')
      run2.bold = false
      para.add_run(run2)

      # Run 3: Overrides all
      run3 = Uniword::Run.new(text: 'Custom')
      run3.bold = false
      run3.font_size = 8
      run3.color = '0000FF'
      para.add_run(run3)

      expect(run1.bold?).to be true
      expect(run1.font_size).to eq(16)
      expect(run1.color).to eq('FF0000')

      expect(run2.bold?).to be false
      expect(run2.font_size).to eq(16) # Still inherited
      expect(run2.color).to eq('FF0000') # Still inherited

      expect(run3.bold?).to be false
      expect(run3.font_size).to eq(8)
      expect(run3.color).to eq('0000FF')
    end
  end
end
