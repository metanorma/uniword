# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Docx.js Compatibility: Page Breaks', :compatibility do
  describe 'Page break before paragraph' do
    it 'should set page break before on paragraph' do
      doc = Uniword::Document.new

      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      para1.runs << run1
      doc.body.paragraphs << para1

      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Hello World on another page')
      para2.runs << run2
      para2.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        page_break_before: true
      )
      doc.body.paragraphs << para2

      expect(doc.paragraphs.count).to eq(2)
      expect(para2.properties.page_break_before).to be true
    end

    it 'should not have page break by default' do
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Normal paragraph')
      para.runs << run

      # Default should be false or nil
      expect(para.properties&.page_break_before).to be_falsy
    end

    it 'should support multiple paragraphs with page breaks' do
      doc = Uniword::Document.new

      3.times do |i|
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Page #{i + 1}")
        para.runs << run

        if i > 0
          para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
            page_break_before: true
          )
        end

        doc.body.paragraphs << para
      end

      expect(doc.paragraphs.count).to eq(3)
      expect(doc.paragraphs[1].properties.page_break_before).to be true
      expect(doc.paragraphs[2].properties.page_break_before).to be true
    end
  end

  describe 'Page break in run' do
    it 'should insert page break in paragraph via run' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      run1 = Uniword::Wordprocessingml::Run.new(text: 'First Page')
      run1.break = Uniword::Wordprocessingml::Break.new(type: 'page')
      para.runs << run1

      run2 = Uniword::Wordprocessingml::Run.new(text: 'Second Page')
      para.runs << run2

      doc.body.paragraphs << para

      expect(para.runs.count).to eq(2)
      expect(run1.break).not_to be_nil
    end

    it 'should combine text runs with page break' do
      para = Uniword::Paragraph.new

      run1 = Uniword::Wordprocessingml::Run.new(text: 'Content before break')
      para.runs << run1

      break_run = Uniword::Wordprocessingml::Run.new
      break_run.break = Uniword::Wordprocessingml::Break.new(type: 'page')
      para.runs << break_run

      run2 = Uniword::Wordprocessingml::Run.new(text: 'Content after break')
      para.runs << run2

      expect(para.runs.count).to eq(3)
    end
  end

  describe 'Section breaks' do
    it 'should support section break for new page' do
      skip 'Section breaks not yet implemented'

      doc = Uniword::Document.new

      # First section
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Section 1')
      para1.runs << run1
      doc.body.paragraphs << para1

      # Add new section
      doc.add_section
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Section 2')
      para2.runs << run2
      doc.body.paragraphs << para2

      expect(doc.sections.count).to eq(2)
    end

    it 'should support continuous section break' do
      skip 'Continuous section breaks not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.section_type = 'continuous'

      expect(section.properties.section_type).to eq('continuous')
    end

    it 'should support even/odd page section breaks' do
      skip 'Even/odd page section breaks not yet implemented'

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.section_type = 'evenPage'

      expect(section.properties.section_type).to eq('evenPage')
    end
  end

  describe 'Column breaks' do
    it 'should insert column break' do
      skip 'Column breaks not yet implemented'

      para = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Column 1')
      para.runs << run1

      break_run = Uniword::Run.new
      break_run.column_break = true
      para.runs << break_run

      run2 = Uniword::Wordprocessingml::Run.new(text: 'Column 2')
      para.runs << run2

      expect(para.runs.count).to eq(3)
    end
  end

  describe 'Keep together properties' do
    it 'should keep paragraph on same page' do
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Content to keep on one page')
      para.runs << run
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        keep_lines: true
      )

      expect(para.properties.keep_lines).to be true
    end

    it 'should keep paragraph with next' do
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Heading')
      para.runs << run
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        keep_next: true
      )

      expect(para.properties.keep_next).to be true
    end

    it 'should combine keep properties' do
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Important heading')
      para.runs << run
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        keep_lines: true,
        keep_next: true
      )

      expect(para.properties.keep_lines).to be true
      expect(para.properties.keep_next).to be true
    end
  end
end
