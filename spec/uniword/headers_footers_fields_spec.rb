# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Headers, Footers, Fields, and Text Boxes' do
  # Feature 5: Headers
  describe Uniword::Header do
    it 'creates header with default type' do
      header = Uniword::Header.new
      expect(header.type).to eq('default')
      expect(header.paragraphs).to be_empty
      expect(header.tables).to be_empty
    end

    it 'creates header with specific type' do
      header = Uniword::Header.new(type: 'first')
      expect(header.type).to eq('first')
    end

    it 'raises error for invalid type' do
      expect {
        Uniword::Header.new(type: 'invalid')
      }.to raise_error(ArgumentError, /Invalid header type/)
    end

    it 'adds paragraphs' do
      header = Uniword::Header.new
      para = Uniword::Paragraph.new
      header.add_paragraph(para)
      expect(header.paragraphs).to include(para)
    end

    it 'adds text' do
      header = Uniword::Header.new
      para = header.add_text('Header text')
      expect(para.text).to eq('Header text')
      expect(header.paragraphs).to include(para)
    end

    it 'checks if empty' do
      header = Uniword::Header.new
      expect(header.empty?).to be true
      header.add_text('Text')
      expect(header.empty?).to be false
    end
  end

  describe Uniword::SectionProperties do
    it 'creates with default values' do
      props = Uniword::SectionProperties.new
      expect(props.orientation).to eq('portrait')
      expect(props.section_type).to eq('nextPage')
    end

    it 'creates A4 portrait' do
      props = Uniword::SectionProperties.a4_portrait
      expect(props.page_width).to eq(11906)
      expect(props.page_height).to eq(16838)
      expect(props.orientation).to eq('portrait')
    end

    it 'creates A4 landscape' do
      props = Uniword::SectionProperties.a4_landscape
      expect(props.page_width).to eq(16838)
      expect(props.page_height).to eq(11906)
      expect(props.orientation).to eq('landscape')
    end

    it 'creates Letter portrait' do
      props = Uniword::SectionProperties.letter_portrait
      expect(props.page_width).to eq(12240)
      expect(props.page_height).to eq(15840)
    end

    it 'raises error for invalid orientation' do
      expect {
        Uniword::SectionProperties.new(orientation: 'invalid')
      }.to raise_error(ArgumentError, /Invalid orientation/)
    end
  end

  describe Uniword::Section do
    it 'creates with default properties' do
      section = Uniword::Section.new
      expect(section.properties).to be_a(Uniword::SectionProperties)
      expect(section.headers).to be_empty
      expect(section.footers).to be_empty
    end

    it 'adds headers' do
      section = Uniword::Section.new
      header = Uniword::Header.new
      section.add_header(header)
      expect(section.headers).to include(header)
    end

    it 'gets or creates header' do
      section = Uniword::Section.new
      header = section.header('default')
      expect(header).to be_a(Uniword::Header)
      expect(header.type).to eq('default')
      expect(section.headers).to include(header)
    end

    it 'checks for headers' do
      section = Uniword::Section.new
      expect(section.has_headers?).to be false
      section.header('default')
      expect(section.has_headers?).to be true
    end
  end

  # Feature 6: Footers
  describe Uniword::Footer do
    it 'creates footer with default type' do
      footer = Uniword::Footer.new
      expect(footer.type).to eq('default')
      expect(footer.paragraphs).to be_empty
    end

    it 'creates footer with specific type' do
      footer = Uniword::Footer.new(type: 'even')
      expect(footer.type).to eq('even')
    end

    it 'adds text' do
      footer = Uniword::Footer.new
      para = footer.add_text('Footer text')
      expect(para.text).to eq('Footer text')
    end
  end

  # Feature 8: Fields and Captions
  describe Uniword::Field do
    describe '.page_number' do
      it 'creates page number field' do
        field = Uniword::Field.page_number
        expect(field.type).to eq('PAGE')
        expect(field.instruction).to include('PAGE')
        expect(field.simple?).to be true
      end
    end

    describe '.total_pages' do
      it 'creates total pages field' do
        field = Uniword::Field.total_pages
        expect(field.type).to eq('NUMPAGES')
        expect(field.instruction).to include('NUMPAGES')
      end
    end

    describe '.date' do
      it 'creates date field' do
        field = Uniword::Field.date
        expect(field.type).to eq('DATE')
        expect(field.instruction).to include('DATE')
      end
    end

    describe '.sequence' do
      it 'creates sequence field for captions' do
        field = Uniword::Field.sequence('Figure')
        expect(field.type).to eq('SEQ')
        expect(field.instruction).to include('SEQ Figure')
        expect(field.complex?).to be true
      end
    end

    describe '.caption' do
      it 'creates caption field' do
        field = Uniword::Field.caption(label: 'Table')
        expect(field.type).to eq('SEQ')
        expect(field.instruction).to include('SEQ Table')
      end
    end
  end

  # Feature 7: Text Boxes
  describe Uniword::TextBox do
    it 'creates text box with default wrapping' do
      box = Uniword::TextBox.new
      expect(box.wrapping).to eq('square')
      expect(box.paragraphs).to be_empty
    end

    it 'creates text box with position and size' do
      box = Uniword::TextBox.new(
        x: 1000,
        y: 2000,
        width: 3000,
        height: 1500
      )
      expect(box.x).to eq(1000)
      expect(box.y).to eq(2000)
      expect(box.width).to eq(3000)
      expect(box.height).to eq(1500)
    end

    it 'adds text to text box' do
      box = Uniword::TextBox.new
      para = box.add_text('Box content')
      expect(para.text).to eq('Box content')
      expect(box.paragraphs).to include(para)
    end

    it 'raises error for invalid wrapping' do
      expect {
        Uniword::TextBox.new(wrapping: 'invalid')
      }.to raise_error(ArgumentError, /Invalid wrapping/)
    end

    it 'checks if empty' do
      box = Uniword::TextBox.new
      expect(box.empty?).to be true
      box.add_text('Text')
      expect(box.empty?).to be false
    end
  end

  # Integration tests
  describe 'Document Integration' do
    it 'initializes with default section' do
      doc = Uniword::Document.new
      expect(doc.sections).not_to be_empty
      expect(doc.current_section).to be_a(Uniword::Section)
    end

    it 'adds sections' do
      doc = Uniword::Document.new
      section = doc.add_section
      expect(doc.sections).to include(section)
    end

    it 'adds header to section' do
      doc = Uniword::Document.new
      header = doc.current_section.header('default')
      header.add_text('My Header')
      expect(header.paragraphs.first.text).to eq('My Header')
    end

    it 'creates document with page numbers in footer' do
      doc = Uniword::Document.new
      footer = doc.current_section.footer('default')
      para = Uniword::Paragraph.new

      # This would be where we'd add field support to paragraphs
      # For now just verify footer exists
      footer.add_paragraph(para)
      expect(footer.paragraphs).to include(para)
    end
  end
end