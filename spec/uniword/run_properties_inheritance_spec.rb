# frozen_string_literal: true

require 'spec_helper'

# v2.0 API: Style inheritance features are not yet implemented
# This spec tests planned features for a future version
RSpec.describe 'Run Properties Inheritance', pending: 'Style inheritance not implemented in v2.0' do
  let(:doc) do
    d = Uniword::Document.new
    # Set up document with styles
    d.styles_configuration = Uniword::StylesConfiguration.new

    # Add custom heading style with run properties
    heading_style = Uniword::ParagraphStyle.new(
      id: 'TestHeading1',
      name: 'Test Heading 1',
      type: 'paragraph',
      run_properties: Uniword::Wordprocessingml::RunProperties.new(
        bold: true,
        size: 32, # 16pt = 32 half-points
        color: 'FF0000'
      ),
      paragraph_properties: Uniword::Wordprocessingml::ParagraphProperties.new(
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
      para.runs << run

      # Run should inherit bold from Heading1 style
      expect(run.bold?).to be true
    end

    it 'inherits font size when not explicitly set' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Heading text')
      para.runs << run

      # Run should inherit font size from Heading1 style
      # 32 half-points = 16 points
      expect(run.font_size).to eq(16)
    end

    it 'inherits color when not explicitly set' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Heading text')
      para.runs << run

      # Run should inherit color from Heading1 style
      expect(run.color).to eq('FF0000')
    end

    it 'prefers explicit run properties over inherited' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Custom text')
      run.bold = false # Explicitly override
      run.size = 20 # Explicitly override (in half-points)
      para.runs << run

      # Run should use explicit values, not inherited
      expect(run.bold?).to be false
      expect(run.properties.size.value).to eq(20)
    end

    it 'returns nil when no style and no explicit property' do
      para = Uniword::Paragraph.new # No style
      para.parent_document = doc

      run = Uniword::Run.new(text: 'Plain text')
      para.runs << run

      # No style, no explicit property = nil/false
      expect(run.bold?).to be false
      expect(run.properties&.size&.value).to be_nil
      expect(run.properties&.color&.value).to be_nil
    end
  end

  describe 'Multiple runs with mixed inheritance' do
    it 'handles runs with different inheritance patterns' do
      para = Uniword::Paragraph.new
      para.set_style('TestHeading1')
      para.parent_document = doc

      # Run 1: Inherits all
      run1 = Uniword::Run.new(text: 'Inherited ')
      para.runs << run1

      # Run 2: Overrides bold
      run2 = Uniword::Run.new(text: 'Mixed ')
      run2.bold = false
      para.runs << run2

      # Run 3: Overrides all
      run3 = Uniword::Run.new(text: 'Custom')
      run3.bold = false
      run3.size = 16
      run3.color = '0000FF'
      para.runs << run3

      expect(run1.bold?).to be true
      expect(run1.properties&.size&.value).to eq(32)

      expect(run2.bold?).to be false
      expect(run2.properties&.size&.value).to eq(32) # Still inherited

      expect(run3.bold?).to be false
      expect(run3.properties.size.value).to eq(16)
      expect(run3.properties.color.value).to eq('0000FF')
    end
  end
end
