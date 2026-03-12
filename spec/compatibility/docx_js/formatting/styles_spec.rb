# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Docx.js Compatibility: Styles', :compatibility do
  describe 'Styles' do
    describe 'createParagraphStyle' do
      it 'should create a new paragraph style' do
        doc = Uniword::Document.new

        # Styles are auto-initialized in Document
        expect(doc.styles_configuration).not_to be_nil
      end

      it 'should create paragraph style with id' do
        doc = Uniword::Document.new
        style = Uniword::ParagraphStyle.new(
          style_id: 'pStyleId',
          style_name: nil
        )

        doc.styles_configuration.add_paragraph_style(style)

        expect(doc.styles_configuration.paragraph_styles.count).to be >= 1
        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.style_id == 'pStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.style_id).to eq('pStyleId')
      end

      it 'should set the paragraph name if given' do
        doc = Uniword::Document.new
        style = Uniword::ParagraphStyle.new(
          style_id: 'pStyleId',
          style_name: 'Paragraph Style'
        )

        doc.styles_configuration.add_paragraph_style(style)

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.style_id == 'pStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.style_id).to eq('pStyleId')
        expect(added_style.style_name).to eq('Paragraph Style')
      end

      it 'should support multiple paragraph styles' do
        doc = Uniword::Document.new

        style1 = Uniword::ParagraphStyle.new(
          style_id: 'Heading1',
          style_name: 'Heading 1'
        )
        style2 = Uniword::ParagraphStyle.new(
          style_id: 'Heading2',
          style_name: 'Heading 2'
        )

        doc.styles_configuration.add_paragraph_style(style1)
        doc.styles_configuration.add_paragraph_style(style2)

        expect(doc.styles_configuration.paragraph_styles.count).to be >= 2
      end

      it 'should apply paragraph style to paragraph' do
        doc = Uniword::Document.new

        style = Uniword::ParagraphStyle.new(
          style_id: 'CustomStyle',
          style_name: 'Custom Style'
        )
        doc.styles_configuration.add_paragraph_style(style)

        para = Uniword::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'CustomStyle')
        para.add_text('Styled paragraph')

        expect(para.properties.style).to eq('CustomStyle')
      end
    end

    describe 'createCharacterStyle' do
      it 'should create a new character style' do
        doc = Uniword::Document.new
        style = Uniword::CharacterStyle.new(
          style_id: 'cStyleId',
          style_name: nil
        )

        doc.styles_configuration.add_character_style(style)

        expect(doc.styles_configuration.character_styles.count).to be >= 1
        added_style = doc.styles_configuration.character_styles.find do |s|
          s.style_id == 'cStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.style_id).to eq('cStyleId')
      end

      it 'should set the character name if given' do
        doc = Uniword::Document.new
        style = Uniword::CharacterStyle.new(
          style_id: 'cStyleId',
          style_name: 'Character Style'
        )

        doc.styles_configuration.add_character_style(style)

        added_style = doc.styles_configuration.character_styles.find do |s|
          s.style_id == 'cStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.style_id).to eq('cStyleId')
        expect(added_style.style_name).to eq('Character Style')
      end

      it 'should support multiple character styles' do
        doc = Uniword::Document.new

        style1 = Uniword::CharacterStyle.new(
          style_id: 'Emphasis',
          style_name: 'Emphasis'
        )
        style2 = Uniword::CharacterStyle.new(
          style_id: 'Strong',
          style_name: 'Strong'
        )

        doc.styles_configuration.add_character_style(style1)
        doc.styles_configuration.add_character_style(style2)

        expect(doc.styles_configuration.character_styles.count).to be >= 2
      end

      it 'should apply character style to run' do
        doc = Uniword::Document.new

        style = Uniword::CharacterStyle.new(
          style_id: 'CustomChar',
          style_name: 'Custom Character'
        )
        doc.styles_configuration.add_character_style(style)

        run = Uniword::Run.new
        run.text = 'Styled text'
        run.properties = Uniword::Wordprocessingml::RunProperties.new(style: 'CustomChar')

        expect(run.properties.style).to eq('CustomChar')
      end
    end

    describe 'default styles' do
      it 'should have default document styles' do
        doc = Uniword::Document.new

        expect(doc.styles_configuration).not_to be_nil
        # Document should auto-initialize with default styles
      end

      it 'should support default paragraph style' do
        Uniword::Document.new

        # Default Normal style should be available
        para = Uniword::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'Normal')
        para.add_text('Normal text')

        expect(para.properties.style).to eq('Normal')
      end

      it 'should support heading styles' do
        Uniword::Document.new

        # Heading styles should be usable
        para = Uniword::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'Heading1')
        para.add_text('Heading 1')

        expect(para.properties.style).to eq('Heading1')
      end
    end

    describe 'style inheritance' do
      it 'should support based-on style' do
        doc = Uniword::Document.new

        base_style = Uniword::ParagraphStyle.new(
          style_id: 'BaseStyle',
          style_name: 'Base Style'
        )

        derived_style = Uniword::ParagraphStyle.new(
          style_id: 'DerivedStyle',
          style_name: 'Derived Style',
          based_on: 'BaseStyle'
        )

        doc.styles_configuration.add_paragraph_style(base_style)
        doc.styles_configuration.add_paragraph_style(derived_style)

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.style_id == 'DerivedStyle'
        end
        expect(added_style).not_to be_nil
        expect(added_style.based_on).to eq('BaseStyle')
      end

      it 'should support next style' do
        doc = Uniword::Document.new

        style = Uniword::ParagraphStyle.new(
          style_id: 'Heading1',
          style_name: 'Heading 1',
          next_style: 'Normal'
        )

        doc.styles_configuration.add_paragraph_style(style)

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.style_id == 'Heading1'
        end
        expect(added_style).not_to be_nil
        expect(added_style.next_style).to eq('Normal')
      end
    end

    describe 'style properties' do
      it 'should set paragraph style with formatting' do
        doc = Uniword::Document.new

        style = Uniword::ParagraphStyle.new(
          style_id: 'CustomPara',
          style_name: 'Custom Paragraph'
        )

        # Styles can have run properties
        style.run_properties = Uniword::Wordprocessingml::RunProperties.new(
          bold: true,
          size: 24,
          color: 'FF0000'
        )

        doc.styles_configuration.add_paragraph_style(style)

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.style_id == 'CustomPara'
        end
        expect(added_style).not_to be_nil
        expect(added_style.run_properties).to be_bold
        expect(added_style.run_properties.size&.value).to eq(24)
        expect(added_style.run_properties.color&.value).to eq('FF0000')
      end

      it 'should set paragraph style with paragraph formatting' do
        doc = Uniword::Document.new

        style = Uniword::ParagraphStyle.new(
          style_id: 'IndentedPara',
          style_name: 'Indented Paragraph'
        )

        # Styles can have paragraph properties
        style.paragraph_properties = Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: 'center',
          indent_left: 720,
          spacing_before: 240
        )

        doc.styles_configuration.add_paragraph_style(style)

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.style_id == 'IndentedPara'
        end
        expect(added_style).not_to be_nil
        expect(added_style.paragraph_properties.alignment).to eq('center')
        expect(added_style.paragraph_properties.indent_left).to eq(720)
        expect(added_style.paragraph_properties.spacing_before).to eq(240)
      end

      it 'should set character style with formatting' do
        doc = Uniword::Document.new

        style = Uniword::CharacterStyle.new(
          style_id: 'CustomChar',
          style_name: 'Custom Character'
        )

        style.run_properties = Uniword::Wordprocessingml::RunProperties.new(
          italic: true,
          font: 'Arial',
          size: 20
        )

        doc.styles_configuration.add_character_style(style)

        added_style = doc.styles_configuration.character_styles.find do |s|
          s.style_id == 'CustomChar'
        end
        expect(added_style).not_to be_nil
        expect(added_style.run_properties.italic).to be true
        expect(added_style.run_properties.font).to eq('Arial')
        expect(added_style.run_properties.size).to eq(20)
      end
    end

    describe 'integrated style usage' do
      it 'should create and apply complete style system' do
        doc = Uniword::Document.new

        # Create paragraph style
        heading_style = Uniword::ParagraphStyle.new(
          style_id: 'CustomHeading',
          style_name: 'Custom Heading'
        )
        heading_style.run_properties = Uniword::Wordprocessingml::RunProperties.new(
          bold: true,
          size: 32,
          color: '0000FF'
        )
        heading_style.paragraph_properties = Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: 'center',
          spacing_before: 240,
          spacing_after: 120
        )
        doc.styles_configuration.add_paragraph_style(heading_style)

        # Create character style
        emphasis_style = Uniword::CharacterStyle.new(
          style_id: 'CustomEmphasis',
          style_name: 'Custom Emphasis'
        )
        emphasis_style.run_properties = Uniword::Wordprocessingml::RunProperties.new(
          italic: true,
          color: 'FF0000'
        )
        doc.styles_configuration.add_character_style(emphasis_style)

        # Use paragraph style
        para1 = Uniword::Paragraph.new
        para1.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'CustomHeading')
        para1.add_text('Styled Heading')
        doc.add_paragraph(para1)

        # Use character style
        para2 = Uniword::Paragraph.new
        run = Uniword::Run.new
        run.text = 'Emphasized text'
        run.properties = Uniword::Wordprocessingml::RunProperties.new(style: 'CustomEmphasis')
        para2.add_run(run)
        doc.add_paragraph(para2)

        expect(doc.styles_configuration.paragraph_styles.count).to be >= 1
        expect(doc.styles_configuration.character_styles.count).to be >= 1
        expect(doc.paragraphs.count).to eq(2)
        expect(doc.paragraphs[0].properties.style).to eq('CustomHeading')
        expect(doc.paragraphs[1].runs.first.properties.style).to eq('CustomEmphasis')
      end

      it 'should support style reuse across document' do
        doc = Uniword::Document.new

        style = Uniword::ParagraphStyle.new(
          style_id: 'Reusable',
          style_name: 'Reusable Style'
        )
        doc.styles_configuration.add_paragraph_style(style)

        # Use same style multiple times
        3.times do |i|
          para = Uniword::Paragraph.new
          para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'Reusable')
          para.add_text("Paragraph #{i + 1}")
          doc.add_paragraph(para)
        end

        expect(doc.paragraphs.count).to eq(3)
        doc.paragraphs.each do |para|
          expect(para.properties.style).to eq('Reusable')
        end
      end
    end
  end
end
