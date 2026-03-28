# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

# v2.0 API: Style inheritance features are not yet implemented
# This spec tests planned features for a future version
RSpec.describe 'Run Properties Inheritance', pending: 'Style inheritance not implemented in v2.0' do
  let(:doc) do
    d = Uniword::Wordprocessingml::DocumentRoot.new
    # Set up document with styles
    d.styles_configuration = Uniword::StylesConfiguration.new

    # Add custom heading style with run properties
    heading_style = Uniword::Wordprocessingml::ParagraphStyle.new(
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
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Heading text')
      para.runs << run

      # Run should inherit bold from Heading1 style
      expect(run.properties&.bold&.value == true).to be true
    end

    it 'inherits font size when not explicitly set' do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Heading text')
      para.runs << run

      # Run should inherit font size from Heading1 style
      # 32 half-points = 16 points
      expect(run.font_size).to eq(16)
    end

    it 'inherits color when not explicitly set' do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Heading text')
      para.runs << run

      # Run should inherit color from Heading1 style
      expect(run.properties&.color&.value).to eq('FF0000')
    end

    it 'prefers explicit run properties over inherited' do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Custom text')
      # Explicitly override via RunBuilder
      Uniword::Builder::RunBuilder.new(run).bold(false).size(10) # size in points; 10*2=20 half-points
      para.runs << run

      # Run should use explicit values, not inherited
      expect(run.properties.bold&.value == true).to be false
      expect(run.properties.size.value).to eq(20)
    end

    it 'returns nil when no style and no explicit property' do
      para = Uniword::Wordprocessingml::Paragraph.new # No style
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Plain text')
      para.runs << run

      # No style, no explicit property = nil/false
      expect(run.properties&.bold&.value == true).to be false
      expect(run.properties&.size).to be_nil
      expect(run.properties&.color).to be_nil
    end
  end

  describe 'Multiple runs with mixed inheritance' do
    it 'handles runs with different inheritance patterns' do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'TestHeading1'
      para.parent_document = doc

      # Run 1: Inherits all
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Inherited ')
      para.runs << run1

      # Run 2: Overrides bold
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Mixed ')
      Uniword::Builder::RunBuilder.new(run2).bold(false)
      para.runs << run2

      # Run 3: Overrides all
      run3 = Uniword::Wordprocessingml::Run.new(text: 'Custom')
      Uniword::Builder::RunBuilder.new(run3).bold(false).size(8).color('0000FF') # 8pt = 16 half-points
      para.runs << run3

      expect(run1.properties&.bold&.value == true).to be true
      expect(run1.properties&.size&.value).to eq(32)

      expect(run2.properties.bold&.value == true).to be false
      expect(run2.properties&.size&.value).to eq(32) # Still inherited

      expect(run3.properties.bold&.value == true).to be false
      expect(run3.properties.size.value).to eq(16)
      expect(run3.properties.color.value).to eq('0000FF')
    end
  end
end
