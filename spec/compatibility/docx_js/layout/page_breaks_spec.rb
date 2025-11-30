# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Docx.js Compatibility: Page Breaks', :compatibility do
  describe 'Page break before paragraph' do
    it 'should set page break before on paragraph' do
      doc = Uniword::Document.new

      para1 = Uniword::Paragraph.new
      para1.add_text('Hello World')
      doc.add_element(para1)

      para2 = Uniword::Paragraph.new
      para2.add_text('Hello World on another page')
      para2.properties = Uniword::Properties::ParagraphProperties.new(
        page_break_before: true
      )
      doc.add_element(para2)

      expect(doc.paragraphs.count).to eq(2)
      expect(para2.properties.page_break_before).to be true
    end

    it 'should not have page break by default' do
      para = Uniword::Paragraph.new
      para.add_text('Normal paragraph')

      # Default should be false or nil
      expect(para.properties&.page_break_before).to be_falsy
    end

    it 'should support multiple paragraphs with page breaks' do
      doc = Uniword::Document.new

      3.times do |i|
        para = Uniword::Paragraph.new
        para.add_text("Page #{i + 1}")

        if i > 0
          para.properties = Uniword::Properties::ParagraphProperties.new(
            page_break_before: true
          )
        end

        doc.add_element(para)
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

      run1 = Uniword::Run.new(text: 'First Page')
      run1.page_break = true
      para.add_run(run1)

      run2 = Uniword::Run.new(text: 'Second Page')
      para.add_run(run2)

      doc.add_element(para)

      expect(para.runs.count).to eq(2)
      expect(run1.page_break).to be true
    end

    it 'should combine text runs with page break' do
      para = Uniword::Paragraph.new

      para.add_text('Content before break')

      break_run = Uniword::Run.new
      break_run.page_break = true
      para.add_run(break_run)

      para.add_text('Content after break')

      expect(para.runs.count).to eq(3)
    end
  end

  describe 'Section breaks' do
    it 'should support section break for new page' do
      skip 'Section breaks not yet implemented'

      doc = Uniword::Document.new

      # First section
      para1 = Uniword::Paragraph.new
      para1.add_text('Section 1')
      doc.add_element(para1)

      # Add new section
      doc.add_section
      para2 = Uniword::Paragraph.new
      para2.add_text('Section 2')
      doc.add_element(para2)

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
      para.add_text('Column 1')

      break_run = Uniword::Run.new
      break_run.column_break = true
      para.add_run(break_run)

      para.add_text('Column 2')

      expect(para.runs.count).to eq(3)
    end
  end

  describe 'Keep together properties' do
    it 'should keep paragraph on same page' do
      para = Uniword::Paragraph.new
      para.add_text('Content to keep on one page')
      para.properties = Uniword::Properties::ParagraphProperties.new(
        keep_lines: true
      )

      expect(para.properties.keep_lines).to be true
    end

    it 'should keep paragraph with next' do
      para = Uniword::Paragraph.new
      para.add_text('Heading')
      para.properties = Uniword::Properties::ParagraphProperties.new(
        keep_next: true
      )

      expect(para.properties.keep_next).to be true
    end

    it 'should combine keep properties' do
      para = Uniword::Paragraph.new
      para.add_text('Important heading')
      para.properties = Uniword::Properties::ParagraphProperties.new(
        keep_lines: true,
        keep_next: true
      )

      expect(para.properties.keep_lines).to be true
      expect(para.properties.keep_next).to be true
    end
  end
end
