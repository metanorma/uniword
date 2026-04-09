# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Run Properties Inheritance' do
  let(:doc) do
    d = Uniword::Wordprocessingml::DocumentRoot.new
    d.styles_configuration = Uniword::Wordprocessingml::StylesConfiguration.new

    # Add custom heading style with run properties
    heading_style = Uniword::Wordprocessingml::Style.new
    heading_style.type = 'paragraph'
    heading_style.id = 'TestHeading1'
    heading_style.name = Uniword::Wordprocessingml::StyleName.new(val: 'Test Heading 1')

    rp = Uniword::Wordprocessingml::RunProperties.new
    rp.bold = Uniword::Properties::Bold.new(val: true)
    rp.size = Uniword::Properties::FontSize.new(value: 32) # 16pt = 32 half-points
    rp.color = Uniword::Properties::ColorValue.new(value: 'FF0000')
    heading_style.rPr = rp
    d.styles_configuration.add_style(heading_style)

    d
  end

  describe 'Run inherits properties from paragraph style' do
    it 'inherits bold property when not explicitly set' do
      para = Uniword::Wordprocessingml::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Heading text')
      run.parent_paragraph = para
      para.runs << run

      # Run should inherit bold from Heading1 style
      expect(run.effective_run_properties&.bold&.value).to eq(true)
    end

    it 'inherits font size when not explicitly set' do
      para = Uniword::Wordprocessingml::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Heading text')
      run.parent_paragraph = para
      para.runs << run

      # Run should inherit font size from Heading1 style
      # 32 half-points = 16 points
      expect(run.font_size).to eq(16)
    end

    it 'inherits color when not explicitly set' do
      para = Uniword::Wordprocessingml::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Heading text')
      run.parent_paragraph = para
      para.runs << run

      # Run should inherit color from Heading1 style
      expect(run.effective_run_properties&.color&.value).to eq('FF0000')
    end

    it 'prefers explicit run properties over inherited' do
      para = Uniword::Wordprocessingml::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = 'TestHeading1'
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Custom text')
      # Explicitly set run properties that override the style
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.bold = Uniword::Properties::Bold.new(val: false)
      run.properties.size = Uniword::Properties::FontSize.new(value: 20) # 10pt
      run.parent_paragraph = para
      para.runs << run

      # Run should use explicit values, not inherited
      expect(run.effective_run_properties.bold.value).to eq(false)
      expect(run.effective_run_properties.size.value).to eq(20)
    end

    it 'returns nil when no style and no explicit property' do
      para = Uniword::Wordprocessingml::Paragraph.new # No style
      para.parent_document = doc

      run = Uniword::Wordprocessingml::Run.new(text: 'Plain text')
      run.parent_paragraph = para
      para.runs << run

      # No style, no explicit property = nil
      expect(run.effective_run_properties).to be_nil
    end
  end

  describe 'Multiple runs with mixed inheritance' do
    it 'handles runs with different inheritance patterns' do
      para = Uniword::Wordprocessingml::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = 'TestHeading1'
      para.parent_document = doc

      # Run 1: Inherits all (no explicit properties)
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Inherited ')
      run1.parent_paragraph = para
      para.runs << run1

      # Run 2: Overrides bold only
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Mixed ')
      run2.properties = Uniword::Wordprocessingml::RunProperties.new
      run2.properties.bold = Uniword::Properties::Bold.new(val: false)
      run2.parent_paragraph = para
      para.runs << run2

      # Run 3: Overrides all
      run3 = Uniword::Wordprocessingml::Run.new(text: 'Custom')
      run3.properties = Uniword::Wordprocessingml::RunProperties.new
      run3.properties.bold = Uniword::Properties::Bold.new(val: false)
      run3.properties.size = Uniword::Properties::FontSize.new(value: 16) # 8pt
      run3.properties.color = Uniword::Properties::ColorValue.new(value: '0000FF')
      run3.parent_paragraph = para
      para.runs << run3

      # Run 1: inherits everything from style
      expect(run1.effective_run_properties.bold.value).to eq(true)
      expect(run1.effective_run_properties.size.value).to eq(32)

      # Run 2: explicit bold=false overrides, but size inherited
      expect(run2.effective_run_properties.bold.value).to eq(false)
      expect(run2.effective_run_properties.size.value).to eq(32)

      # Run 3: all explicit
      expect(run3.effective_run_properties.bold.value).to eq(false)
      expect(run3.effective_run_properties.size.value).to eq(16)
      expect(run3.effective_run_properties.color.value).to eq('0000FF')
    end
  end
end
