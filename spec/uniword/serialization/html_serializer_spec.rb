# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Serialization::HtmlSerializer do
  let(:serializer) { described_class.new }
  let(:document) { Uniword::Document.new }

  describe '#serialize' do
    it 'raises ArgumentError for nil document' do
      expect { serializer.serialize(nil) }.to raise_error(ArgumentError, /cannot be nil/)
    end

    it 'raises ArgumentError for non-Document object' do
      expect { serializer.serialize('not a document') }.to raise_error(ArgumentError, /Must be a Document instance/)
    end

    it 'returns hash with html, css, and images keys' do
      result = serializer.serialize(document)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:html)
      expect(result).to have_key(:css)
      expect(result).to have_key(:images)
    end

    it 'returns valid HTML structure' do
      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('<!DOCTYPE html>')
      expect(html).to include('<html')
      expect(html).to include('</html>')
      expect(html).to include('<head>')
      expect(html).to include('<body')
    end

    it 'includes Word namespaces' do
      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('xmlns:v="urn:schemas-microsoft-com:vml"')
      expect(html).to include('xmlns:o="urn:schemas-microsoft-com:office:office"')
      expect(html).to include('xmlns:w="urn:schemas-microsoft-com:office:word"')
    end

    it 'includes generator meta tag' do
      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('Uniword')
      expect(html).to include('Generator')
    end

    it 'includes WordSection1 div' do
      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('class="WordSection1"')
    end

    it 'returns CSS styles' do
      result = serializer.serialize(document)
      css = result[:css]

      expect(css).to be_a(String)
      expect(css).not_to be_empty
      expect(css).to include('MsoNormal')
    end
  end

  describe 'paragraph serialization' do
    it 'serializes empty paragraph' do
      para = Uniword::Paragraph.new
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('<p class="MsoNormal">&nbsp;</p>')
    end

    it 'serializes paragraph with text' do
      para = Uniword::Paragraph.new
      para.add_text('Hello, World!')
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('<p class="MsoNormal">Hello, World!</p>')
    end

    it 'escapes HTML special characters' do
      para = Uniword::Paragraph.new
      para.add_text('<script>alert("XSS")</script>')
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('&lt;script&gt;')
      expect(result[:html]).to include('&lt;/script&gt;')
      expect(result[:html]).not_to include('<script>')
    end

    it 'maps Heading1 style' do
      props = Uniword::Properties::ParagraphProperties.new(style: 'Heading1')
      para = Uniword::Paragraph.new(properties: props)
      para.add_text('Heading')
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('class="MsoHeading1"')
    end

    it 'maps Heading2 style' do
      props = Uniword::Properties::ParagraphProperties.new(style: 'Heading2')
      para = Uniword::Paragraph.new(properties: props)
      para.add_text('Heading')
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('class="MsoHeading2"')
    end

    it 'applies alignment style' do
      props = Uniword::Properties::ParagraphProperties.new(alignment: 'center')
      para = Uniword::Paragraph.new(properties: props)
      para.add_text('Centered text')
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('text-align:center')
    end

    it 'applies indentation styles' do
      props = Uniword::Properties::ParagraphProperties.new(
        indent_left: 720,
        indent_right: 360,
        indent_first_line: 360
      )
      para = Uniword::Paragraph.new(properties: props)
      para.add_text('Indented')
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('margin-left:720pt')
      expect(result[:html]).to include('margin-right:360pt')
      expect(result[:html]).to include('text-indent:360pt')
    end

    it 'applies spacing styles' do
      props = Uniword::Properties::ParagraphProperties.new(
        spacing_before: 240,
        spacing_after: 120,
        line_spacing: 360
      )
      para = Uniword::Paragraph.new(properties: props)
      para.add_text('Spaced')
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('margin-top:240pt')
      expect(result[:html]).to include('margin-bottom:120pt')
      expect(result[:html]).to include('line-height:360pt')
    end
  end

  describe 'run serialization' do
    it 'serializes bold text' do
      props = Uniword::Properties::RunProperties.new(bold: true)
      para = Uniword::Paragraph.new
      para.add_text('Bold text', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('font-weight:bold')
    end

    it 'serializes italic text' do
      props = Uniword::Properties::RunProperties.new(italic: true)
      para = Uniword::Paragraph.new
      para.add_text('Italic text', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('font-style:italic')
    end

    it 'serializes underlined text' do
      props = Uniword::Properties::RunProperties.new(underline: 'single')
      para = Uniword::Paragraph.new
      para.add_text('Underlined', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('text-decoration:underline')
    end

    it 'serializes strikethrough text' do
      props = Uniword::Properties::RunProperties.new(strike: true)
      para = Uniword::Paragraph.new
      para.add_text('Strikethrough', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('text-decoration:line-through')
    end

    it 'serializes font size' do
      props = Uniword::Properties::RunProperties.new(size: 24)
      para = Uniword::Paragraph.new
      para.add_text('Large text', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('font-size:12pt')
    end

    it 'serializes font color' do
      props = Uniword::Properties::RunProperties.new(color: 'FF0000')
      para = Uniword::Paragraph.new
      para.add_text('Red text', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('color:#FF0000')
    end

    it 'serializes font family' do
      props = Uniword::Properties::RunProperties.new(font: 'Arial')
      para = Uniword::Paragraph.new
      para.add_text('Arial text', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include("font-family:'Arial'")
    end

    it 'serializes highlight color' do
      props = Uniword::Properties::RunProperties.new(highlight: 'FFFF00')
      para = Uniword::Paragraph.new
      para.add_text('Highlighted', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('background-color:#FFFF00')
    end

    it 'serializes superscript' do
      props = Uniword::Properties::RunProperties.new(vertical_align: 'superscript')
      para = Uniword::Paragraph.new
      para.add_text('x²', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('vertical-align:super')
    end

    it 'serializes subscript' do
      props = Uniword::Properties::RunProperties.new(vertical_align: 'subscript')
      para = Uniword::Paragraph.new
      para.add_text('H₂O', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)

      expect(result[:html]).to include('vertical-align:sub')
    end

    it 'combines multiple formatting properties' do
      props = Uniword::Properties::RunProperties.new(
        bold: true,
        italic: true,
        size: 28,
        color: '0000FF'
      )
      para = Uniword::Paragraph.new
      para.add_text('Formatted', properties: props)
      document.add_element(para)
      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('font-weight:bold')
      expect(html).to include('font-style:italic')
      expect(html).to include('font-size:14pt')
      expect(html).to include('color:#0000FF')
    end
  end

  describe 'table serialization' do
    it 'serializes empty table' do
      table = Uniword::Table.new
      document.body.add_table(table)
      result = serializer.serialize(document)

      expect(result[:html]).to include('<table')
      expect(result[:html]).to include('</table>')
      expect(result[:html]).to include('class="MsoNormalTable"')
    end

    it 'serializes table with rows and cells' do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      para = Uniword::Paragraph.new
      para.add_text('Cell content')
      cell.add_paragraph(para)
      row.add_cell(cell)
      table.add_row(row)
      document.body.add_table(table)
      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('<table')
      expect(html).to include('<tr>')
      expect(html).to include('<td>')
      expect(html).to include('Cell content')
      expect(html).to include('</td>')
      expect(html).to include('</tr>')
      expect(html).to include('</table>')
    end

    it 'serializes table with borders' do
      table = Uniword::Table.new
      document.body.add_table(table)
      result = serializer.serialize(document)

      expect(result[:html]).to include('border="1"')
      expect(result[:html]).to include('cellspacing="0"')
      expect(result[:html]).to include('cellpadding="0"')
    end

    it 'applies table width' do
      props = Uniword::Properties::TableProperties.new(width: 5000)
      table = Uniword::Table.new(properties: props)
      document.body.add_table(table)
      result = serializer.serialize(document)

      expect(result[:html]).to include('width:5000pt')
    end

    it 'applies cell colspan' do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      cell.instance_variable_set(:@colspan, 2)
      def cell.colspan; @colspan; end
      para = Uniword::Paragraph.new
      para.add_text('Merged cell')
      cell.add_paragraph(para)
      row.add_cell(cell)
      table.add_row(row)
      document.body.add_table(table)
      result = serializer.serialize(document)

      expect(result[:html]).to include('colspan="2"')
    end

    it 'applies cell rowspan' do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      cell.instance_variable_set(:@rowspan, 3)
      def cell.rowspan; @rowspan; end
      para = Uniword::Paragraph.new
      para.add_text('Merged cell')
      cell.add_paragraph(para)
      row.add_cell(cell)
      table.add_row(row)
      document.body.add_table(table)
      result = serializer.serialize(document)

      expect(result[:html]).to include('rowspan="3"')
    end
  end

  describe 'CSS generation' do
    it 'includes MsoNormal style' do
      result = serializer.serialize(document)
      css = result[:css]

      expect(css).to include('MsoNormal')
      expect(css).to include('font-size')
      expect(css).to include('font-family')
    end

    it 'includes heading styles' do
      result = serializer.serialize(document)
      css = result[:css]

      expect(css).to include('h1')
      expect(css).to include('h2')
      expect(css).to include('h3')
    end

    it 'includes table styles' do
      result = serializer.serialize(document)
      css = result[:css]

      expect(css).to include('MsoNormalTable')
    end

    it 'includes hyperlink styles' do
      result = serializer.serialize(document)
      css = result[:css]

      expect(css).to include('MsoHyperlink')
      expect(css).to include('text-decoration')
      expect(css).to include('underline')
    end
  end

  describe 'complex document' do
    it 'serializes document with multiple paragraphs' do
      3.times do |i|
        para = Uniword::Paragraph.new
        para.add_text("Paragraph #{i + 1}")
        document.add_element(para)
      end

      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('Paragraph 1')
      expect(html).to include('Paragraph 2')
      expect(html).to include('Paragraph 3')
    end

    it 'serializes document with mixed content' do
      # Add heading
      heading_props = Uniword::Properties::ParagraphProperties.new(style: 'Heading1')
      heading = Uniword::Paragraph.new(properties: heading_props)
      heading.add_text('Document Title')
      document.add_element(heading)

      # Add normal paragraph
      para = Uniword::Paragraph.new
      para.add_text('Normal paragraph text.')
      document.add_element(para)

      # Add table
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      cell_para = Uniword::Paragraph.new
      cell_para.add_text('Table data')
      cell.add_paragraph(cell_para)
      row.add_cell(cell)
      table.add_row(row)
      document.body.add_table(table)

      result = serializer.serialize(document)
      html = result[:html]

      expect(html).to include('MsoHeading1')
      expect(html).to include('Document Title')
      expect(html).to include('Normal paragraph text')
      expect(html).to include('<table')
      expect(html).to include('Table data')
    end
  end
end
