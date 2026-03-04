# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Quality Rules' do
  let(:document) { Uniword::Document.new }

  describe Uniword::Quality::HeadingHierarchyRule do
    let(:rule) { described_class.new(max_level: 6, require_sequential: true) }

    it 'passes for sequential headings' do
      para1 = Uniword::Paragraph.new
      para1.set_style('Heading 1')
      para1.add_text('Heading 1')

      para2 = Uniword::Paragraph.new
      para2.set_style('Heading 2')
      para2.add_text('Heading 2')

      document.add_element(para1)
      document.add_element(para2)

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects skipped heading levels' do
      para1 = Uniword::Paragraph.new
      para1.set_style('Heading 1')
      para1.add_text('Heading 1')

      para2 = Uniword::Paragraph.new
      para2.set_style('Heading 3')
      para2.add_text('Heading 3')

      document.add_element(para1)
      document.add_element(para2)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('skips from 1 to 3')
    end

    it 'detects headings exceeding max level' do
      para = Uniword::Paragraph.new
      para.set_style('Heading 7')
      para.add_text('Heading 7')
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:error)
      expect(violations.first.message).to include('exceeds maximum')
    end
  end

  describe Uniword::Quality::TableHeaderRule do
    let(:rule) { described_class.new(require_headers: true) }

    it 'passes for tables with rows' do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      row.add_cell(cell)
      table.add_row(row)
      document.add_element(table)

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects tables without headers' do
      table = Uniword::Table.new
      document.add_element(table)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('does not have a header row')
    end
  end

  describe Uniword::Quality::ParagraphLengthRule do
    let(:rule) { described_class.new(max_words: 500, warning_words: 400) }

    it 'passes for short paragraphs' do
      para = Uniword::Paragraph.new
      para.add_text('Short paragraph with few words.')
      document.add_element(para)

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'warns for long paragraphs' do
      para = Uniword::Paragraph.new
      para.add_text('word ' * 450) # 450 words
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('warning threshold')
    end

    it 'errors for very long paragraphs' do
      para = Uniword::Paragraph.new
      para.add_text('word ' * 600) # 600 words
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:error)
      expect(violations.first.message).to include('maximum')
    end

    it 'skips empty paragraphs' do
      para = Uniword::Paragraph.new
      document.add_element(para)

      violations = rule.check(document)
      expect(violations).to be_empty
    end
  end

  describe Uniword::Quality::ImageAltTextRule do
    let(:rule) { described_class.new(require_alt_text: true, min_length: 10) }

    it 'passes for images with sufficient alt text' do
      para = Uniword::Paragraph.new
      image = Uniword::Image.new(
        relationship_id: 'rId1',
        alt_text: 'Detailed description of the image content'
      )
      para.add_run(image)
      document.add_element(para)

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects images without alt text' do
      para = Uniword::Paragraph.new
      image = Uniword::Image.new(relationship_id: 'rId1')
      para.add_run(image)
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:error)
      expect(violations.first.message).to include('missing alt text')
    end

    it 'warns for short alt text' do
      para = Uniword::Paragraph.new
      image = Uniword::Image.new(
        relationship_id: 'rId1',
        alt_text: 'Short'
      )
      para.add_run(image)
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('too short')
    end
  end

  describe Uniword::Quality::LinkValidationRule do
    let(:rule) { described_class.new(check_internal: true, check_external: true) }

    it 'passes for valid external links' do
      para = Uniword::Paragraph.new
      para.add_hyperlink('Click here', url: 'https://example.com')
      document.add_element(para)

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects invalid URL format' do
      para = Uniword::Paragraph.new
      para.add_hyperlink('Click here', url: 'not-a-valid-url')
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('invalid URL format')
    end

    it 'detects broken internal links' do
      para = Uniword::Paragraph.new
      hyperlink = Uniword::Hyperlink.new(
        anchor: 'nonexistent_bookmark',
        text: 'Link'
      )
      para.add_run(hyperlink)
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:error)
      expect(violations.first.message).to include('non-existent bookmark')
    end
  end

  describe Uniword::Quality::StyleConsistencyRule do
    let(:rule) do
      described_class.new(
        allow_direct_formatting: false,
        require_standard_styles: true
      )
    end

    it 'passes for paragraphs with styles' do
      para = Uniword::Paragraph.new
      para.set_style('Normal')
      para.add_text('Styled paragraph')
      document.add_element(para)

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'warns for direct formatting without styles' do
      para = Uniword::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        alignment: 'center'
      )
      para.add_text('Unst yled paragraph')
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('direct formatting')
    end

    it 'detects direct text formatting' do
      para = Uniword::Paragraph.new
      para.set_style('Normal')
      para.add_text('Bold text', bold: true)
      document.add_element(para)

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:info)
      expect(violations.first.message).to include('Direct text formatting')
    end
  end
end
