# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Quality Rules' do
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }

  describe Uniword::Quality::HeadingHierarchyRule do
    let(:rule) { described_class.new(max_level: 6, require_sequential: true) }

    it 'passes for sequential headings' do
      para1 = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para1).style = 'Heading 1'
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Heading 1')
      para1.runs << run1

      para2 = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para2).style = 'Heading 2'
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Heading 2')
      para2.runs << run2

      document.body.paragraphs << para1
      document.body.paragraphs << para2

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects skipped heading levels' do
      para1 = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para1).style = 'Heading 1'
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Heading 1')
      para1.runs << run1

      para2 = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para2).style = 'Heading 3'
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Heading 3')
      para2.runs << run2

      document.body.paragraphs << para1
      document.body.paragraphs << para2

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('skips from 1 to 3')
    end

    it 'detects headings exceeding max level' do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'Heading 7'
      run = Uniword::Wordprocessingml::Run.new(text: 'Heading 7')
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:error)
      expect(violations.first.message).to include('exceeds maximum')
    end
  end

  describe Uniword::Quality::TableHeaderRule do
    let(:rule) { described_class.new(require_headers: true) }

    it 'passes for tables with rows' do
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new
      cell = Uniword::Wordprocessingml::TableCell.new
      row.cells << cell
      table.rows << row
      document.body.tables << table

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects tables without headers' do
      table = Uniword::Wordprocessingml::Table.new
      document.body.tables << table

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('does not have a header row')
    end
  end

  describe Uniword::Quality::ParagraphLengthRule do
    let(:rule) { described_class.new(max_words: 500, warning_words: 400) }

    it 'passes for short paragraphs' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Short paragraph with few words.')
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'warns for long paragraphs' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'word ' * 450) # 450 words
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('warning threshold')
    end

    it 'errors for very long paragraphs' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'word ' * 600) # 600 words
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:error)
      expect(violations.first.message).to include('maximum')
    end

    it 'skips empty paragraphs' do
      para = Uniword::Wordprocessingml::Paragraph.new
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations).to be_empty
    end
  end

  describe Uniword::Quality::ImageAltTextRule do
    let(:rule) { described_class.new(require_alt_text: true, min_length: 10) }

    # Helper to create a proper OOXML image model
    def create_image_with_alt_text(alt_text)
      drawing = Uniword::Wordprocessingml::Drawing.new
      inline = Uniword::WpDrawing::Inline.new
      inline.doc_properties = Uniword::WpDrawing::DocProperties.new(
        id: '1',
        name: 'image1',
        descr: alt_text
      )
      drawing.inline = inline
      drawing
    end

    it 'passes for images with sufficient alt text' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      drawing = create_image_with_alt_text('Detailed description of the image content')
      run.drawings << drawing
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects images without alt text' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      drawing = create_image_with_alt_text(nil)  # nil = no alt text
      run.drawings << drawing
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:error)
      expect(violations.first.message).to include('missing alt text')
    end

    it 'warns for short alt text' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      drawing = create_image_with_alt_text('Short')  # Less than 10 chars
      run.drawings << drawing
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('too short')
    end
  end

  describe Uniword::Quality::LinkValidationRule do
    let(:rule) { described_class.new(check_internal: true, check_external: true) }

    it 'passes for valid external links' do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder << Uniword::Builder.hyperlink('https://example.com', 'Click here')
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'detects invalid URL format' do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder << Uniword::Builder.hyperlink('not-a-valid-url', 'Click here')
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('invalid URL format')
    end

    it 'detects broken internal links' do
      para = Uniword::Wordprocessingml::Paragraph.new
      hyperlink = Uniword::Wordprocessingml::Hyperlink.new(
        anchor: 'nonexistent_bookmark'
      )
      para.hyperlinks << hyperlink
      document.body.paragraphs << para

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
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'Normal'
      run = Uniword::Wordprocessingml::Run.new(text: 'Styled paragraph')
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations).to be_empty
    end

    it 'warns for direct formatting without styles' do
      para = Uniword::Wordprocessingml::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        alignment: 'center'
      )
      run = Uniword::Wordprocessingml::Run.new(text: 'Unst yled paragraph')
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:warning)
      expect(violations.first.message).to include('direct formatting')
    end

    it 'detects direct text formatting' do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).style = 'Normal'
      run = Uniword::Wordprocessingml::Run.new(text: 'Bold text')
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.bold = Uniword::Properties::Bold.new(value: true)
      para.runs << run
      document.body.paragraphs << para

      violations = rule.check(document)
      expect(violations.size).to eq(1)
      expect(violations.first.severity).to eq(:info)
      expect(violations.first.message).to include('Direct text formatting')
    end
  end
end
