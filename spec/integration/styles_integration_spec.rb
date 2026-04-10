# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

RSpec.describe 'Styles Integration', :integration do
  describe 'document with styled paragraphs' do
    it 'creates and reads back styled paragraphs' do
      temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        # Create document with styled paragraphs
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        # Add Normal paragraph
        p1 = Uniword::Wordprocessingml::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(
            style: 'Normal'
          )
        )
        p1_run = Uniword::Wordprocessingml::Run.new(text: 'This is a normal paragraph.')
        p1.runs << p1_run
        doc.body.paragraphs << p1

        # Add Heading 1
        p2 = Uniword::Wordprocessingml::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(
            style: 'Heading1'
          )
        )
        p2_run = Uniword::Wordprocessingml::Run.new(text: 'This is Heading 1')
        p2.runs << p2_run
        doc.body.paragraphs << p2

        # Add Heading 2
        p3 = Uniword::Wordprocessingml::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(
            style: 'Heading2'
          )
        )
        p3_run = Uniword::Wordprocessingml::Run.new(text: 'This is Heading 2')
        p3.runs << p3_run
        doc.body.paragraphs << p3

        # Save document
        doc.save(temp_path)

        # Verify file exists
        expect(File.exist?(temp_path)).to be true
        expect(File.size(temp_path)).to be > 0

        # Read document back
        loaded_doc = Uniword.load(temp_path)

        # Verify paragraphs (style is on properties)
        expect(loaded_doc.paragraphs.size).to eq(3)
        expect(loaded_doc.paragraphs[0].properties&.style).to eq('Normal')
        expect(loaded_doc.paragraphs[0].text).to eq('This is a normal paragraph.')
        expect(loaded_doc.paragraphs[1].properties&.style).to eq('Heading1')
        expect(loaded_doc.paragraphs[1].text).to eq('This is Heading 1')
        expect(loaded_doc.paragraphs[2].properties&.style).to eq('Heading2')
        expect(loaded_doc.paragraphs[2].text).to eq('This is Heading 2')
      ensure
        File.delete(temp_path) if File.exist?(temp_path)
      end
    end
  end

  describe 'styles configuration' do
    it 'includes default styles in new document' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Verify default styles exist
      expect(doc.styles_configuration.style_by_id('Normal')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Heading1')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Heading2')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('DefaultParagraphFont')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Emphasis')).not_to be_nil
      expect(doc.styles_configuration.style_by_id('Strong')).not_to be_nil
    end

    it 'preserves custom styles' do
      temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        doc = Uniword::Wordprocessingml::DocumentRoot.new

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
        p = Uniword::Wordprocessingml::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(
            style: 'MyCustomStyle'
          )
        )
        p_run = Uniword::Wordprocessingml::Run.new(text: 'Styled with custom style')
        p.runs << p_run
        doc.body.paragraphs << p

        # Save and reload
        doc.save(temp_path)
        loaded_doc = Uniword.load(temp_path)

        # Verify custom style was preserved
        loaded_style = loaded_doc.styles_configuration.style_by_id('MyCustomStyle')
        expect(loaded_style).not_to be_nil
        expect(loaded_style.name.val).to eq('My Custom Style')
        expect(loaded_style.custom?).to be true
        expect(loaded_style.paragraph_properties.alignment.value).to eq('center')
        expect(loaded_style.run_properties).to be_bold
        expect(loaded_style.run_properties.color.value).to eq('FF0000')

        # Verify paragraph uses the style (style is on properties)
        expect(loaded_doc.paragraphs.first.properties&.style&.value).to eq('MyCustomStyle')
      ensure
        File.delete(temp_path) if File.exist?(temp_path)
      end
    end
  end

  describe 'style inheritance' do
    it 'creates styles with basedOn relationship' do
      temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        doc = Uniword::Wordprocessingml::DocumentRoot.new

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
        p = Uniword::Wordprocessingml::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(
            style: 'DerivedHeading'
          )
        )
        p_run = Uniword::Wordprocessingml::Run.new(text: 'Derived heading text')
        p.runs << p_run
        doc.body.paragraphs << p

        doc.save(temp_path)
        loaded_doc = Uniword.load(temp_path)

        # Verify inheritance
        loaded_style = loaded_doc.styles_configuration.style_by_id('DerivedHeading')
        expect(loaded_style).not_to be_nil
        expect(loaded_style.based_on).to eq('Heading1')
      ensure
        File.delete(temp_path) if File.exist?(temp_path)
      end
    end
  end

  describe 'character styles' do
    it 'applies character styles to runs' do
      temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        p = Uniword::Wordprocessingml::Paragraph.new

        # Add run with Strong style
        strong_run = Uniword::Wordprocessingml::Run.new(
          text: 'Bold text',
          properties: Uniword::Wordprocessingml::RunProperties.new(
            style: 'Strong'
          )
        )
        p.runs << strong_run

        # Add run with Emphasis style
        emphasis_run = Uniword::Wordprocessingml::Run.new(
          text: ' and italic text',
          properties: Uniword::Wordprocessingml::RunProperties.new(
            style: 'Emphasis'
          )
        )
        p.runs << emphasis_run

        doc.body.paragraphs << p

        # Save and reload
        doc.save(temp_path)
        loaded_doc = Uniword.load(temp_path)

        # Verify character styles
        para = loaded_doc.paragraphs.first
        expect(para.runs[0].properties.style.value).to eq('Strong')
        expect(para.runs[1].properties.style.value).to eq('Emphasis')
      ensure
        File.delete(temp_path) if File.exist?(temp_path)
      end
    end
  end

  describe 'all heading levels' do
    it 'creates document with all 9 heading levels' do
      temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        (1..9).each do |level|
          p = Uniword::Wordprocessingml::Paragraph.new(
            properties: Uniword::Wordprocessingml::ParagraphProperties.new(
              style: "Heading#{level}"
            )
          )
          p_run = Uniword::Wordprocessingml::Run.new(text: "Heading level #{level}")
          p.runs << p_run
          doc.body.paragraphs << p
        end

        # Save and reload
        doc.save(temp_path)
        loaded_doc = Uniword.load(temp_path)

        # Verify all headings (style is on properties)
        expect(loaded_doc.paragraphs.size).to eq(9)
        (1..9).each do |level|
          expect(loaded_doc.paragraphs[level - 1].properties&.style).to eq("Heading#{level}")
        end
      ensure
        File.delete(temp_path) if File.exist?(temp_path)
      end
    end
  end
end
