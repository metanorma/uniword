# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe 'Styles Integration', :integration do
  let(:temp_file) { Tempfile.new(['styles_test', '.docx']) }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe 'document with styled paragraphs' do
    it 'creates and reads back styled paragraphs' do
      # Create document with styled paragraphs
      doc = Uniword::Document.new

      # Add Normal paragraph
      p1 = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Normal'
        )
      )
      p1.add_text('This is a normal paragraph.')
      doc.body.paragraphs << p1

      # Add Heading 1
      p2 = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Heading1'
        )
      )
      p2.add_text('This is Heading 1')
      doc.body.paragraphs << p2

      # Add Heading 2
      p3 = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Heading2'
        )
      )
      p3.add_text('This is Heading 2')
      doc.body.paragraphs << p3

      # Save document
      doc.save(temp_file.path)

      # Verify file exists
      expect(File.exist?(temp_file.path)).to be true
      expect(File.size(temp_file.path)).to be > 0

      # Read document back
      loaded_doc = Uniword.load(temp_file.path)

      # Verify paragraphs (style returns ID, not NAME)
      expect(loaded_doc.paragraphs.size).to eq(3)
      expect(loaded_doc.paragraphs[0].style).to eq('Normal')
      expect(loaded_doc.paragraphs[0].text).to eq('This is a normal paragraph.')
      expect(loaded_doc.paragraphs[1].style).to eq('Heading1')
      expect(loaded_doc.paragraphs[1].text).to eq('This is Heading 1')
      expect(loaded_doc.paragraphs[2].style).to eq('Heading2')
      expect(loaded_doc.paragraphs[2].text).to eq('This is Heading 2')
    end
  end

  describe 'styles configuration' do
    it 'includes default styles in new document' do
      doc = Uniword::Document.new

      # Verify default styles exist
      expect(doc.styles_configuration.style_by_id('Normal')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Heading1')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Heading2')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('DefaultParagraphFont')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Emphasis')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Strong')).not_to be_nil
    end

    it 'preserves custom styles' do
      doc = Uniword::Document.new

      # Create custom paragraph style
      doc.styles_configuration.create_paragraph_style(
        'MyCustomStyle',
        'My Custom Style',
        pPr: Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: 'center',
          spacing_before: 240,
          spacing_after: 120
        ),
        rPr: Uniword::Wordprocessingml::RunProperties.new(
          bold: true,
          size: 32,
          color: 'FF0000'
        )
      )

      # Use the custom style
      p = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'MyCustomStyle'
        )
      )
      p.add_text('Styled with custom style')
      doc.body.paragraphs << p

      # Save and reload
      doc.save(temp_file.path)
      loaded_doc = Uniword.load(temp_file.path)

      # Verify custom style was preserved
      loaded_style = loaded_doc.styles_configuration.style_by_id('MyCustomStyle')
      expect(loaded_style).not_to be_nil
      expect(loaded_style.name.val).to eq('My Custom Style')
      expect(loaded_style.custom).to be true
      expect(loaded_style.paragraph_properties.alignment).to eq('center')
      expect(loaded_style.run_properties).to be_bold
      expect(loaded_style.run_properties.color.value).to eq('FF0000')

      # Verify paragraph uses the style (style returns ID, not NAME)
      expect(loaded_doc.paragraphs.first.style).to eq('MyCustomStyle')
    end
  end

  describe 'style inheritance' do
    it 'creates styles with basedOn relationship' do
      doc = Uniword::Document.new

      # Create derived style based on Heading1
      derived_style = doc.styles_configuration.create_paragraph_style(
        'DerivedHeading',
        'Derived Heading',
        based_on: 'Heading1',
        paragraph_properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: 'right'
        )
      )

      expect(derived_style.based_on).to eq('Heading1')

      # Save and reload
      p = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'DerivedHeading'
        )
      )
      p.add_text('Derived heading text')
      doc.body.paragraphs << p

      doc.save(temp_file.path)
      loaded_doc = Uniword.load(temp_file.path)

      # Verify inheritance
      loaded_style = loaded_doc.styles_configuration.style_by_id('DerivedHeading')
      expect(loaded_style).not_to be_nil
      expect(loaded_style.based_on).to eq('Heading1')
    end
  end

  describe 'character styles' do
    it 'applies character styles to runs' do
      doc = Uniword::Document.new

      p = Uniword::Paragraph.new

      # Add run with Strong style
      p.add_text(
        'Bold text',
        properties: Uniword::Wordprocessingml::RunProperties.new(
          style: 'Strong'
        )
      )

      # Add run with Emphasis style
      p.add_text(
        ' and italic text',
        properties: Uniword::Wordprocessingml::RunProperties.new(
          style: 'Emphasis'
        )
      )

      doc.body.paragraphs << p

      # Save and reload
      doc.save(temp_file.path)
      loaded_doc = Uniword.load(temp_file.path)

      # Verify character styles
      para = loaded_doc.paragraphs.first
      expect(para.runs[0].properties.style.value).to eq('Strong')
      expect(para.runs[1].properties.style.value).to eq('Emphasis')
    end
  end

  describe 'all heading levels' do
    it 'creates document with all 9 heading levels' do
      doc = Uniword::Document.new

      (1..9).each do |level|
        p = Uniword::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(
            style: "Heading#{level}"
          )
        )
        p.add_text("Heading level #{level}")
        doc.body.paragraphs << p
      end

      # Save and reload
      doc.save(temp_file.path)
      loaded_doc = Uniword.load(temp_file.path)

      # Verify all headings (style returns ID, not NAME)
      expect(loaded_doc.paragraphs.size).to eq(9)
      (1..9).each do |level|
        expect(loaded_doc.paragraphs[level - 1].style).to eq("Heading#{level}")
      end
    end
  end
end
