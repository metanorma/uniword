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

        style = doc.styles_configuration.create_paragraph_style(
          'pStyleId', nil
        )

        expect(doc.styles_configuration.paragraph_styles.count).to be >= 1
        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.id == 'pStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.id).to eq('pStyleId')
      end

      it 'should set the paragraph name if given' do
        doc = Uniword::Document.new

        style = doc.styles_configuration.create_paragraph_style(
          'pStyleId', 'Paragraph Style'
        )

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.id == 'pStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.id).to eq('pStyleId')
        expect(added_style.style_name).to eq('Paragraph Style')
      end

      it 'should support multiple paragraph styles' do
        doc = Uniword::Document.new

        doc.styles_configuration.create_paragraph_style(
          'CustomHeading1', 'Custom Heading 1'
        )
        doc.styles_configuration.create_paragraph_style(
          'CustomHeading2', 'Custom Heading 2'
        )

        expect(doc.styles_configuration.paragraph_styles.count).to be >= 2
      end

      it 'should apply paragraph style to paragraph' do
        doc = Uniword::Document.new

        doc.styles_configuration.create_paragraph_style(
          'CustomStyle', 'Custom Style'
        )

        para = Uniword::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'CustomStyle')
        run = Uniword::Wordprocessingml::Run.new(text: 'Styled paragraph')
        para.runs << run

        expect(para.properties.style).to eq('CustomStyle')
      end
    end

    describe 'createCharacterStyle' do
      it 'should create a new character style' do
        doc = Uniword::Document.new

        style = doc.styles_configuration.create_character_style(
          'cStyleId', nil
        )

        expect(doc.styles_configuration.character_styles.count).to be >= 1
        added_style = doc.styles_configuration.character_styles.find do |s|
          s.id == 'cStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.id).to eq('cStyleId')
      end

      it 'should set the character name if given' do
        doc = Uniword::Document.new

        style = doc.styles_configuration.create_character_style(
          'cStyleId', 'Character Style'
        )

        added_style = doc.styles_configuration.character_styles.find do |s|
          s.id == 'cStyleId'
        end
        expect(added_style).not_to be_nil
        expect(added_style.id).to eq('cStyleId')
        expect(added_style.style_name).to eq('Character Style')
      end

      it 'should support multiple character styles' do
        doc = Uniword::Document.new

        doc.styles_configuration.create_character_style(
          'CustomEmphasis', 'Custom Emphasis'
        )
        doc.styles_configuration.create_character_style(
          'CustomStrong', 'Custom Strong'
        )

        expect(doc.styles_configuration.character_styles.count).to be >= 2
      end

      it 'should apply character style to run' do
        doc = Uniword::Document.new

        doc.styles_configuration.create_character_style(
          'CustomChar', 'Custom Character'
        )

        run = Uniword::Run.new
        run.text = 'Styled text'
        run.properties = Uniword::Wordprocessingml::RunProperties.new(style: 'CustomChar')

        expect(run.properties.style.value).to eq('CustomChar')
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
        run = Uniword::Wordprocessingml::Run.new(text: 'Normal text')
        para.runs << run

        expect(para.properties.style).to eq('Normal')
      end

      it 'should support heading styles' do
        Uniword::Document.new

        # Heading styles should be usable
        para = Uniword::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'Heading1')
        run = Uniword::Wordprocessingml::Run.new(text: 'Heading 1')
        para.runs << run

        expect(para.properties.style).to eq('Heading1')
      end
    end

    describe 'style inheritance' do
      it 'should support based-on style' do
        doc = Uniword::Document.new

        doc.styles_configuration.create_paragraph_style(
          'BaseStyle', 'Base Style'
        )

        doc.styles_configuration.create_paragraph_style(
          'DerivedStyle', 'Derived Style', based_on: 'BaseStyle'
        )

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.id == 'DerivedStyle'
        end
        expect(added_style).not_to be_nil
        expect(added_style.based_on).to eq('BaseStyle')
      end

      it 'should support next style' do
        doc = Uniword::Document.new

        doc.styles_configuration.create_paragraph_style(
          'CustomHeading1', 'Custom Heading 1', next_style: 'Normal'
        )

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.id == 'Heading1'
        end
        expect(added_style).not_to be_nil
        expect(added_style.next_style).to eq('Normal')
      end
    end

    describe 'style properties' do
      it 'should set paragraph style with formatting' do
        doc = Uniword::Document.new

        style = doc.styles_configuration.create_paragraph_style(
          'CustomPara', 'Custom Paragraph',
          run_properties: Uniword::Wordprocessingml::RunProperties.new(
            bold: true,
            size: 24,
            color: 'FF0000'
          )
        )

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.id == 'CustomPara'
        end
        expect(added_style).not_to be_nil
        expect(added_style.bold).to eq(true)
        expect(added_style.font_size).to eq(24)
        expect(added_style.font_color).to eq('FF0000')
      end

      it 'should set paragraph style with paragraph formatting' do
        doc = Uniword::Document.new

        style = Uniword::Wordprocessingml::Style.new(
          type: 'paragraph',
          styleId: 'IndentedPara',
          name: Uniword::Wordprocessingml::StyleName.new(val: 'Indented Paragraph'),
          customStyle: true,
          pPr: Uniword::Wordprocessingml::ParagraphProperties.new(
            alignment: 'center',
            indent_left: 720,
            spacing_before: 240
          )
        )
        doc.styles_configuration.add_paragraph_style(style)

        added_style = doc.styles_configuration.paragraph_styles.find do |s|
          s.id == 'IndentedPara'
        end
        expect(added_style).not_to be_nil
        expect(added_style.alignment).to eq('center')
        expect(added_style.paragraph_properties.indent_left).to eq(720)
        expect(added_style.paragraph_properties.spacing_before).to eq(240)
      end

      it 'should set character style with formatting' do
        doc = Uniword::Document.new

        style = Uniword::Wordprocessingml::Style.new(
          type: 'character',
          styleId: 'CustomChar',
          name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom Character'),
          customStyle: true,
          rPr: Uniword::Wordprocessingml::RunProperties.new(
            italic: true,
            font: 'Arial',
            size: 20
          )
        )
        doc.styles_configuration.add_character_style(style)

        added_style = doc.styles_configuration.character_styles.find do |s|
          s.id == 'CustomChar'
        end
        expect(added_style).not_to be_nil
        expect(added_style.run_properties.italic.value).to eq(true)
        expect(added_style.run_properties.font).to eq('Arial')
        expect(added_style.run_properties.size.value).to eq(20)
      end
    end

    describe 'integrated style usage' do
      it 'should create and apply complete style system' do
        doc = Uniword::Document.new

        # Create paragraph style
        heading_style = doc.styles_configuration.create_paragraph_style(
          'CustomHeading', 'Custom Heading',
          run_properties: Uniword::Wordprocessingml::RunProperties.new(
            bold: true,
            size: 32,
            color: '0000FF'
          )
        )
        heading_style.pPr = Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: 'center',
          spacing_before: 240,
          spacing_after: 120
        )

        # Create character style
        emphasis_style = doc.styles_configuration.create_character_style(
          'CustomEmphasis', 'Custom Emphasis',
          run_properties: Uniword::Wordprocessingml::RunProperties.new(
            italic: true,
            color: 'FF0000'
          )
        )

        # Use paragraph style
        para1 = Uniword::Paragraph.new
        para1.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'CustomHeading')
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Styled Heading')
        para1.runs << run1
        doc.body.paragraphs << para1

        # Use character style
        para2 = Uniword::Paragraph.new
        run2 = Uniword::Run.new
        run2.text = 'Emphasized text'
        run2.properties = Uniword::Wordprocessingml::RunProperties.new(style: 'CustomEmphasis')
        para2.runs << run2
        doc.body.paragraphs << para2

        expect(doc.styles_configuration.paragraph_styles.count).to be >= 1
        expect(doc.styles_configuration.character_styles.count).to be >= 1
        expect(doc.body.paragraphs.count).to eq(2)
        expect(doc.body.paragraphs[0].properties.style).to eq('CustomHeading')
        expect(doc.body.paragraphs[1].runs.first.properties.style.value).to eq('CustomEmphasis')
      end

      it 'should support style reuse across document' do
        doc = Uniword::Document.new

        doc.styles_configuration.create_paragraph_style(
          'Reusable', 'Reusable Style'
        )

        # Use same style multiple times
        3.times do |i|
          para = Uniword::Paragraph.new
          para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'Reusable')
          run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1}")
          para.runs << run
          doc.body.paragraphs << para
        end

        expect(doc.body.paragraphs.count).to eq(3)
        doc.body.paragraphs.each do |para|
          expect(para.properties.style).to eq('Reusable')
        end
      end
    end
  end
end
