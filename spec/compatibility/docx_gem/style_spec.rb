# frozen_string_literal: true

require 'spec_helper'

# Compatibility tests adapted from the docx gem
# Original: reference/docx/spec/docx/elements/style_spec.rb
# These tests verify that Uniword provides equivalent style functionality

RSpec.describe 'Docx Gem Compatibility - Styles' do
  let(:fixture_path) { 'spec/fixtures/docx_gem/partial_styles/full.xml' }
  let(:fixture_xml) { File.read(fixture_path) }
  let(:styles_config) { Uniword::StylesConfiguration.new({}, include_defaults: false) }
  let(:node) { Nokogiri::XML(fixture_xml).root.children[1] }

  # Parse style from node (similar to docx gem)
  let(:style) do
    # Manually create style from XML for testing
    style_id = node['w:styleId']
    style_name = node.at_xpath('./w:name', {'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'})&.[]('w:val')

    Uniword::ParagraphStyle.new(
      id: style_id,
      name: style_name,
      type: 'paragraph'
    )
  end

  describe 'attribute extraction' do
    it 'extracts ID' do
      expect(style.id).to eq('Red')
    end

    it 'extracts name' do
      expect(style.name).to eq('Red')
    end

    it 'has type' do
      expect(style.type).to eq('paragraph')
    end
  end

  describe 'reading from styles.xml' do
    let(:doc) { Uniword::Document.open('spec/fixtures/docx_gem/styles.docx') }

    it 'loads document styles' do
      expect(doc.styles_configuration).not_to be_nil
      expect(doc.styles_configuration.all_styles.count).to be > 0
    end

    it 'finds specific styles' do
      normal_style = doc.styles_configuration.find_by_id('Normal')
      expect(normal_style).not_to be_nil
      expect(normal_style.id).to eq('Normal')
    end

    it 'has Heading styles' do
      heading1 = doc.styles_configuration.find_by_id('Heading1')
      expect(heading1).not_to be_nil
      expect(heading1.name).to eq('Heading 1')
    end
  end

  describe 'style manipulation' do
    let(:doc) { Uniword::Document.open('spec/fixtures/docx_gem/styles.docx') }

    it 'can add custom styles' do
      initial_count = doc.styles_configuration.all_styles.count

      doc.styles_configuration.create_paragraph_style(
        'CustomTest',
        'Custom Test Style'
      )

      expect(doc.styles_configuration.all_styles.count).to eq(initial_count + 1)

      custom = doc.styles_configuration.find_by_id('CustomTest')
      expect(custom).not_to be_nil
      expect(custom.name).to eq('Custom Test Style')
    end

    it 'can remove styles' do
      # Add a style first
      doc.styles_configuration.create_paragraph_style('Temporary', 'Temp Style')
      initial_count = doc.styles_configuration.all_styles.count

      doc.styles_configuration.remove_style('Temporary')

      expect(doc.styles_configuration.all_styles.count).to eq(initial_count - 1)
      expect(doc.styles_configuration.find_by_id('Temporary')).to be_nil
    end
  end

  describe 'applying styles to paragraphs' do
    let(:doc) { Uniword::Document.open('spec/fixtures/docx_gem/styles.docx') }

    it 'reads paragraph styles' do
      para = doc.paragraphs.find { |p| p.style == 'Heading 1' }
      expect(para).not_to be_nil
    end

    it 'sets paragraph style via set_style' do
      para = doc.paragraphs.first
      para.set_style('Heading1')

      expect(para.properties.style).to eq('Heading1')
    end
  end

  describe 'default styles' do
    it 'includes Normal style' do
      doc = Uniword::Document.new
      normal = doc.styles_configuration.find_by_id('Normal')

      expect(normal).not_to be_nil
      expect(normal.name).to eq('Normal')
      expect(normal.type).to eq('paragraph')
    end

    it 'includes Heading styles' do
      doc = Uniword::Document.new

      (1..9).each do |i|
        heading = doc.styles_configuration.find_by_id("Heading#{i}")
        expect(heading).not_to be_nil
        expect(heading.name).to eq("Heading #{i}")
      end
    end
  end
end