# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'v1.1.0 Features Smoke Test' do
  describe 'Feature class loading' do
    it 'loads Hyperlink class' do
      expect(Uniword::Hyperlink).to be_a(Class)
    end

    it 'loads PageBorders classes' do
      expect(Uniword::PageBorders).to be_a(Class)
      expect(Uniword::PageBorderSide).to be_a(Class)
    end

    it 'loads ParagraphBorders classes' do
      expect(Uniword::ParagraphBorders).to be_a(Class)
      expect(Uniword::ParagraphBorderSide).to be_a(Class)
    end

    it 'loads TabStop class' do
      expect(Uniword::TabStop).to be_a(Class)
    end

    it 'loads Shading class' do
      expect(Uniword::Shading).to be_a(Class)
    end

    it 'loads Column classes' do
      expect(Uniword::ColumnConfiguration).to be_a(Class)
      expect(Uniword::Column).to be_a(Class)
    end

    it 'loads LineNumbering class' do
      expect(Uniword::LineNumbering).to be_a(Class)
    end

    it 'loads TextFrame class' do
      expect(Uniword::TextFrame).to be_a(Class)
    end

    it 'loads HtmlImporter class' do
      expect(Uniword::HtmlImporter).to be_a(Class)
    end
  end

  describe 'Hyperlink' do
    it 'creates external hyperlink' do
      link = Uniword::Hyperlink.new(url: 'https://example.com', text: 'Click here')
      expect(link.url).to eq('https://example.com')
      expect(link.text).to eq('Click here')
      expect(link.external?).to be true
    end

    it 'creates internal hyperlink' do
      link = Uniword::Hyperlink.new(anchor: 'section1', text: 'Go to section')
      expect(link.anchor).to eq('section1')
      expect(link.internal?).to be true
    end
  end

  describe 'PageBorders' do
    it 'creates page borders with all sides' do
      borders = Uniword::PageBorders.all_sides(style: 'double', color: '000000')
      expect(borders.any?).to be true
      expect(borders.top).to be_a(Uniword::PageBorderSide)
    end
  end

  describe 'ParagraphBorders' do
    it 'creates paragraph border box' do
      borders = Uniword::ParagraphBorders.box(style: 'single', color: 'FF0000')
      expect(borders.box?).to be true
    end
  end

  describe 'TabStop' do
    it 'creates left-aligned tab stop' do
      tab = Uniword::TabStop.left(720, leader: 'dot')
      expect(tab.position).to eq(720)
      expect(tab.alignment).to eq('left')
      expect(tab.leader).to eq('dot')
    end
  end

  describe 'Shading' do
    it 'creates solid shading' do
      shading = Uniword::Shading.solid('FFFF00')
      expect(shading.fill).to eq('FFFF00')
      expect(shading.type).to eq('clear')
    end

    it 'creates pattern shading' do
      shading = Uniword::Shading.diagonal_stripe(color: '0000FF', fill: 'FFFFFF')
      expect(shading.type).to eq('diagStripe')
    end
  end

  describe 'ColumnConfiguration' do
    it 'creates two-column layout' do
      cols = Uniword::ColumnConfiguration.two_columns(space: 720)
      expect(cols.count).to eq(2)
      expect(cols.equal_width).to be true
    end

    it 'creates three-column layout' do
      cols = Uniword::ColumnConfiguration.three_columns
      expect(cols.count).to eq(3)
    end
  end

  describe 'LineNumbering' do
    it 'creates continuous line numbering' do
      ln = Uniword::LineNumbering.continuous(count_by: 5)
      expect(ln.continuous?).to be true
      expect(ln.count_by).to eq(5)
    end

    it 'creates per-page line numbering' do
      ln = Uniword::LineNumbering.per_page
      expect(ln.per_page?).to be true
    end
  end

  describe 'TextFrame' do
    it 'creates absolute positioned frame' do
      frame = Uniword::TextFrame.absolute(
        width: 4000,
        height: 1000,
        x: 500,
        y: 1000
      )
      expect(frame.absolute_position?).to be true
      expect(frame.width).to eq(4000)
    end

    it 'creates aligned frame' do
      frame = Uniword::TextFrame.aligned(
        width: 3000,
        h_alignment: 'right',
        v_alignment: 'top'
      )
      expect(frame.aligned_position?).to be true
    end
  end

  describe 'Image base64 support' do
    it 'creates image from base64' do
      base64_data = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
      image = Uniword::Image.from_base64(base64_data, width: 100, height: 100)
      expect(image).to be_a(Uniword::Image)
      expect(image.width).to eq(100)
    end
  end

  describe 'HtmlImporter' do
    it 'imports simple HTML' do
      html = '<p>Hello <b>World</b></p>'
      doc = Uniword::HtmlImporter.new(html).to_document
      expect(doc).to be_a(Uniword::Document)
      expect(doc.paragraphs.count).to be > 0
    end

    it 'imports headings' do
      html = '<h1>Title</h1><p>Content</p>'
      doc = Uniword::HtmlImporter.new(html).to_document
      expect(doc.paragraphs.count).to eq(2)
    end
  end

  describe 'Module-level HTML API' do
    it 'has from_html method' do
      expect(Uniword).to respond_to(:from_html)
    end

    it 'has html_to_doc method' do
      expect(Uniword).to respond_to(:html_to_doc)
    end

    it 'has html_to_docx method' do
      expect(Uniword).to respond_to(:html_to_docx)
    end

    it 'converts HTML to document' do
      html = '<p>Test</p>'
      doc = Uniword.from_html(html)
      expect(doc).to be_a(Uniword::Document)
    end
  end

  describe 'Integration with existing classes' do
    it 'adds hyperlink to paragraph' do
      para = Uniword::Paragraph.new
      para.add_hyperlink('Click', url: 'https://example.com')
      expect(para.runs.count).to eq(1)
      expect(para.runs.first).to be_a(Uniword::Hyperlink)
    end

    it 'adds page borders to section' do
      section = Uniword::SectionProperties.new
      section.page_borders = Uniword::PageBorders.all_sides
      expect(section.page_borders).to be_a(Uniword::PageBorders)
    end

    it 'sets page size on section' do
      section = Uniword::SectionProperties.new
      section.set_page_size(:a4, orientation: :landscape)
      expect(section.page_width).to eq(16_838)
      expect(section.orientation).to eq('landscape')
    end

    it 'sets columns on section' do
      section = Uniword::SectionProperties.new
      section.set_columns(2, space: 720)
      expect(section.columns).to be_a(Uniword::ColumnConfiguration)
      expect(section.columns.count).to eq(2)
    end

    it 'enables line numbering on section' do
      section = Uniword::SectionProperties.new
      section.enable_line_numbering(count_by: 5)
      expect(section.line_numbering).to be_a(Uniword::LineNumbering)
    end
  end
end
