# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Transformation::Transformer do
  let(:transformer) { described_class.new }

  describe '#initialize' do
    it 'creates a new transformer with registered rules' do
      expect(transformer).to be_a(described_class)
    end
  end

  describe '#transform' do
    let(:source_doc) do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.bold = Uniword::Properties::Bold.new(value: true)
      para.runs << run
      doc.body.paragraphs << para
      doc
    end

    context 'with explicit parameters' do
      it 'transforms DOCX model to MHTML model' do
        result = transformer.transform(
          source: source_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        expect(result).to be_a(Uniword::Mhtml::Document)
        expect(result.text).to include('Hello World')
      end

      it 'transforms MHTML model to DOCX model' do
        # First create an MHTML document
        mhtml_doc = Uniword::Mhtml::Document.new
        mhtml_doc.raw_html = '<p>Hello World</p>'

        result = transformer.transform(
          source: mhtml_doc,
          source_format: :mhtml,
          target_format: :docx
        )

        expect(result).to be_a(Uniword::Wordprocessingml::DocumentRoot)
        expect(result.paragraphs.count).to eq(1)
        expect(result.text).to include('Hello World')
      end

      it 'requires source parameter' do
        expect do
          transformer.transform(
            source: nil,
            source_format: :docx,
            target_format: :mhtml
          )
        end.to raise_error(ArgumentError, /Source must be a Document/)
      end

      it 'requires valid source_format' do
        expect do
          transformer.transform(
            source: source_doc,
            source_format: :invalid,
            target_format: :mhtml
          )
        end.to raise_error(ArgumentError, /Source format must be/)
      end

      it 'requires valid target_format' do
        expect do
          transformer.transform(
            source: source_doc,
            source_format: :docx,
            target_format: :invalid
          )
        end.to raise_error(ArgumentError, /Target format must be/)
      end
    end

    context 'with complex document' do
      let(:complex_doc) do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        # Add paragraph with formatting
        para1 = Uniword::Wordprocessingml::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Bold text')
        run1.properties = Uniword::Wordprocessingml::RunProperties.new
        run1.properties.bold = Uniword::Properties::Bold.new(value: true)
        para1.runs << run1
        run2 = Uniword::Wordprocessingml::Run.new(text: ' and italic text')
        run2.properties = Uniword::Wordprocessingml::RunProperties.new
        run2.properties.italic = Uniword::Properties::Italic.new(value: true)
        para1.runs << run2
        para1.properties = Uniword::Wordprocessingml::ParagraphProperties.new(alignment: 'center')
        doc.body.paragraphs << para1

        # Add table
        table = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: 'Cell content')
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
        table.rows << row
        doc.body.tables << table

        doc
      end

      it 'transforms all elements' do
        result = transformer.transform(
          source: complex_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        expect(result).to be_a(Uniword::Mhtml::Document)
        expect(result.text).to include('Bold text')
        expect(result.text).to include('Cell content')
      end

      it 'preserves text content' do
        result = transformer.transform(
          source: complex_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        # Text extraction from HTML preserves content
        expect(result.text).to include('Bold text')
        expect(result.text).to include('italic text')
        expect(result.text).to include('Cell content')
      end

      it 'preserves formatting in HTML' do
        result = transformer.transform(
          source: complex_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        # HTML should contain formatting tags
        expect(result.raw_html).to include('<strong>')
        expect(result.raw_html).to include('<em>')
      end
    end
  end

  describe '#docx_to_mhtml' do
    it 'explicitly names the transformation direction' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test')
      para.runs << run
      doc.body.paragraphs << para

      result = transformer.docx_to_mhtml(doc)

      expect(result).to be_a(Uniword::Mhtml::Document)
      expect(result.text).to include('Test')
    end
  end

  describe '#mhtml_to_docx' do
    it 'explicitly names the transformation direction' do
      mhtml_doc = Uniword::Mhtml::Document.new
      mhtml_doc.raw_html = '<p>Test</p>'

      result = transformer.mhtml_to_docx(mhtml_doc)

      expect(result).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(result.paragraphs.first.text).to eq('Test')
    end
  end

  describe '#register_rule' do
    it 'allows registering custom transformation rules' do
      custom_rule_class = Class.new(Uniword::Transformation::TransformationRule) do
        def initialize
          super(source_format: :docx, target_format: :mhtml)
        end

        def matches?(element_type:, source_format:, target_format:)
          false
        end

        def transform(element)
          element
        end
      end
      custom_rule = custom_rule_class.new

      expect { transformer.register_rule(custom_rule) }.not_to raise_error
    end
  end
end
