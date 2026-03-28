# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Docx.js Compatibility: Headers and Footers', :compatibility do
  describe 'Headers' do
    it 'should add default header to section' do
      skip 'Headers not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section

      header = Uniword::Header.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'My Header')
      para.runs << run
      header.body.paragraphs << para

      section.default_header = header

      expect(section.default_header).not_to be_nil
    end

    it 'should add first page header' do
      skip 'First page headers not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      first_header = Uniword::Header.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'First Page Header')
      para.runs << run
      first_header.body.paragraphs << para

      section.first_header = first_header

      expect(section.first_header).not_to be_nil
    end

    it 'should support different default and first headers' do
      skip 'Multiple header types not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      # Default header
      default_header = Uniword::Header.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Default Header')
      para1.runs << run1
      default_header.body.paragraphs << para1
      section.default_header = default_header

      # First page header
      first_header = Uniword::Header.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'First Page Header')
      para2.runs << run2
      first_header.body.paragraphs << para2
      section.first_header = first_header

      expect(section.default_header).not_to eq(section.first_header)
    end

    it 'should support even and odd headers' do
      skip 'Even/odd headers not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.different_odd_and_even_pages = true

      even_header = Uniword::Header.new
      odd_header = Uniword::Header.new

      section.even_header = even_header
      section.odd_header = odd_header

      expect(section.even_header).not_to be_nil
      expect(section.odd_header).not_to be_nil
    end
  end

  describe 'Footers' do
    it 'should add default footer to section' do
      skip 'Footers not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'My Footer')
      para.runs << run
      footer.body.paragraphs << para

      section.default_footer = footer

      expect(section.default_footer).not_to be_nil
    end

    it 'should add first page footer' do
      skip 'First page footers not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      first_footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'First Page Footer')
      para.runs << run
      first_footer.body.paragraphs << para

      section.first_footer = first_footer

      expect(section.first_footer).not_to be_nil
    end

    it 'should support both headers and footers' do
      skip 'Headers and footers together not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section

      header = Uniword::Header.new
      header_para = Uniword::Paragraph.new
      run_header = Uniword::Wordprocessingml::Run.new(text: 'Header')
      header_para.runs << run_header
      header.body.paragraphs << header_para
      section.default_header = header

      footer = Uniword::Footer.new
      footer_para = Uniword::Paragraph.new
      run_footer = Uniword::Wordprocessingml::Run.new(text: 'Footer')
      footer_para.runs << run_footer
      footer.body.paragraphs << footer_para
      section.default_footer = footer

      expect(section.default_header).not_to be_nil
      expect(section.default_footer).not_to be_nil
    end
  end

  describe 'Page numbers' do
    it 'should insert current page number in header' do
      skip 'Page number fields not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section

      header = Uniword::Header.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Page ')
      para.runs << run

      # Add page number field
      page_num = Uniword::Field.new(type: 'PAGE')
      para.add_field(page_num)

      header.body.paragraphs << para
      section.default_header = header

      expect(header).not_to be_nil
    end

    it 'should insert current page number in footer' do
      skip 'Page number fields in footer not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Page ')
      para.runs << run

      page_num = Uniword::Field.new(type: 'PAGE')
      para.add_field(page_num)

      footer.body.paragraphs << para
      section.default_footer = footer

      expect(footer).not_to be_nil
    end

    it 'should support page X of Y format' do
      skip 'Page X of Y format not yet implemented'

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new

      run1 = Uniword::Wordprocessingml::Run.new(text: 'Page ')
      para.runs << run1
      para.add_field(Uniword::Field.new(type: 'PAGE'))

      run2 = Uniword::Wordprocessingml::Run.new(text: ' of ')
      para.runs << run2
      para.add_field(Uniword::Field.new(type: 'NUMPAGES'))

      footer.body.paragraphs << para

      expect(para.runs.count).to be > 0
    end

    it 'should support page number with custom text' do
      skip 'Custom page number text not yet implemented'

      header = Uniword::Header.new
      para = Uniword::Paragraph.new

      run = Uniword::Wordprocessingml::Run.new(text: 'My Title ')
      para.runs << run
      page_num_run = Uniword::Run.new
      page_num_run.text = 'Page '
      page_num_run.add_field(Uniword::Field.new(type: 'PAGE'))
      para.runs << page_num_run

      header.body.paragraphs << para

      expect(header).not_to be_nil
    end

    it 'should support aligned page numbers' do
      skip 'Aligned page numbers not yet implemented'

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        alignment: 'right'
      )

      run = Uniword::Wordprocessingml::Run.new(text: 'Page ')
      para.runs << run
      para.add_field(Uniword::Field.new(type: 'PAGE'))

      footer.body.paragraphs << para

      expect(para.properties.alignment).to eq('right')
    end
  end

  describe 'Header and footer formatting' do
    it 'should support formatted text in header' do
      skip 'Formatted header text not yet implemented'

      header = Uniword::Header.new
      para = Uniword::Paragraph.new

      run = Uniword::Builder::RunBuilder.new.text('Bold Header').bold.build
      para.runs << run

      header.body.paragraphs << para

      expect(run.properties&.bold&.value == true).to be true
    end

    it 'should support tables in headers' do
      skip 'Tables in headers not yet implemented'

      header = Uniword::Header.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      cell_para = Uniword::Paragraph.new
      cell_run = Uniword::Wordprocessingml::Run.new(text: 'Header table cell')
      cell_para.runs << cell_run
      cell.paragraphs << cell_para
      row.cells << cell
      table.rows << row

      header.body.tables << table

      expect(header).not_to be_nil
    end

    it 'should support images in headers' do
      skip 'Images in headers not yet implemented'

      header = Uniword::Header.new
      para = Uniword::Paragraph.new

      image = Uniword::Image.from_data(
        'image data',
        width: 100 * 9525,
        height: 50 * 9525,
        alt_text: 'Header logo'
      )

      para.runs << image
      header.body.paragraphs << para

      expect(header).not_to be_nil
    end
  end

  describe 'Section-specific headers and footers' do
    it 'should support different headers per section' do
      skip 'Per-section headers not yet implemented'

      doc = Uniword::Document.new

      # Section 1 header
      section1 = doc.current_section
      header1 = Uniword::Header.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Section 1 Header')
      para1.runs << run1
      header1.body.paragraphs << para1
      section1.default_header = header1

      # Section 2 header
      section2 = doc.add_section
      header2 = Uniword::Header.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Section 2 Header')
      para2.runs << run2
      header2.body.paragraphs << para2
      section2.default_header = header2

      expect(section1.default_header).not_to eq(section2.default_header)
    end

    it 'should support different footers per section' do
      skip 'Per-section footers not yet implemented'

      doc = Uniword::Document.new

      section1 = doc.current_section
      footer1 = Uniword::Footer.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Section 1 Footer')
      para1.runs << run1
      footer1.body.paragraphs << para1
      section1.default_footer = footer1

      section2 = doc.add_section
      footer2 = Uniword::Footer.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Section 2 Footer')
      para2.runs << run2
      footer2.body.paragraphs << para2
      section2.default_footer = footer2

      expect(section1.default_footer).not_to eq(section2.default_footer)
    end
  end

  describe 'Page number continuation' do
    it 'should continue page numbers across sections' do
      skip 'Page number continuation not yet implemented'

      doc = Uniword::Document.new

      # Section 1 - starts at 1
      section1 = doc.current_section
      header1 = Uniword::Header.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Page ')
      para1.runs << run1
      para1.add_field(Uniword::Field.new(type: 'PAGE'))
      header1.body.paragraphs << para1
      section1.default_header = header1

      # Section 2 - continues from section 1
      section2 = doc.add_section
      header2 = Uniword::Header.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Page number: ')
      para2.runs << run2
      para2.add_field(Uniword::Field.new(type: 'PAGE'))
      header2.body.paragraphs << para2
      section2.default_header = header2

      expect(doc.sections.count).to eq(2)
    end
  end
end
