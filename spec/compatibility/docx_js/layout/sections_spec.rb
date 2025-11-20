# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Docx.js Compatibility: Sections", :compatibility do
  describe "Multiple sections" do
    it "should create document with single section by default" do
      doc = Uniword::Document.new

      expect(doc.sections).not_to be_nil
      expect(doc.sections.count).to be >= 1
    end

    it "should add multiple sections to document" do
      doc = Uniword::Document.new

      # First section (default)
      para1 = Uniword::Paragraph.new
      para1.add_text("Hello World")
      doc.add_element(para1)

      # Add new section
      section2 = doc.add_section

      para2 = Uniword::Paragraph.new
      para2.add_text("Section 2 content")
      doc.add_element(para2)

      expect(doc.sections.count).to eq(2)
    end

    it "should get current section" do
      doc = Uniword::Document.new
      current = doc.current_section

      expect(current).not_to be_nil
      expect(current).to be_a(Uniword::Section)
    end
  end

  describe "Section properties" do
    it "should set section orientation" do
      skip "Section orientation not yet fully implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.page_orientation = "landscape"

      expect(section.properties.page_orientation).to eq("landscape")
    end

    it "should have different orientations per section" do
      skip "Multiple sections with different orientations not yet implemented"

      doc = Uniword::Document.new

      # Section 1 - portrait
      section1 = doc.current_section
      section1.properties ||= Uniword::SectionProperties.new
      section1.properties.page_orientation = "portrait"

      # Section 2 - landscape
      section2 = doc.add_section
      section2.properties ||= Uniword::SectionProperties.new
      section2.properties.page_orientation = "landscape"

      # Section 3 - back to portrait
      section3 = doc.add_section
      section3.properties ||= Uniword::SectionProperties.new
      section3.properties.page_orientation = "portrait"

      expect(doc.sections.count).to eq(3)
      expect(section1.properties.page_orientation).to eq("portrait")
      expect(section2.properties.page_orientation).to eq("landscape")
      expect(section3.properties.page_orientation).to eq("portrait")
    end
  end

  describe "Page numbering per section" do
    it "should set page number start" do
      skip "Page numbering per section not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new

      section.properties.page_number_start = 1
      section.properties.page_number_format = "decimal"

      expect(section.properties.page_number_start).to eq(1)
      expect(section.properties.page_number_format).to eq("decimal")
    end

    it "should restart page numbering in new section" do
      skip "Page numbering restart not yet implemented"

      doc = Uniword::Document.new

      # Section 1
      section1 = doc.current_section
      section1.properties ||= Uniword::SectionProperties.new
      section1.properties.page_number_start = 1
      section1.properties.page_number_format = "decimal"

      # Section 2 - restart at 1
      section2 = doc.add_section
      section2.properties ||= Uniword::SectionProperties.new
      section2.properties.page_number_start = 1
      section2.properties.page_number_format = "decimal"

      expect(section2.properties.page_number_start).to eq(1)
    end

    it "should support different number formats per section" do
      skip "Multiple page number formats not yet implemented"

      doc = Uniword::Document.new

      # Section 1 - decimal
      section1 = doc.current_section
      section1.properties ||= Uniword::SectionProperties.new
      section1.properties.page_number_format = "decimal"

      # Section 2 - upper roman
      section2 = doc.add_section
      section2.properties ||= Uniword::SectionProperties.new
      section2.properties.page_number_format = "upperRoman"

      # Section 3 - decimal starting at 25
      section3 = doc.add_section
      section3.properties ||= Uniword::SectionProperties.new
      section3.properties.page_number_start = 25
      section3.properties.page_number_format = "decimal"

      expect(section1.properties.page_number_format).to eq("decimal")
      expect(section2.properties.page_number_format).to eq("upperRoman")
      expect(section3.properties.page_number_start).to eq(25)
    end

    it "should continue page numbering by default" do
      skip "Page number continuation not yet implemented"

      doc = Uniword::Document.new

      section1 = doc.current_section
      section1.properties ||= Uniword::SectionProperties.new
      # No explicit start means continue from previous

      section2 = doc.add_section
      section2.properties ||= Uniword::SectionProperties.new
      # Should continue numbering from section1

      expect(doc.sections.count).to eq(2)
    end
  end

  describe "Section type" do
    it "should support nextPage section type" do
      skip "Section types not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.section_type = "nextPage"

      expect(section.properties.section_type).to eq("nextPage")
    end

    it "should support continuous section type" do
      skip "Continuous section not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.section_type = "continuous"

      expect(section.properties.section_type).to eq("continuous")
    end

    it "should support evenPage and oddPage section types" do
      skip "Even/odd page sections not yet implemented"

      doc = Uniword::Document.new

      section1 = doc.current_section
      section1.properties ||= Uniword::SectionProperties.new
      section1.properties.section_type = "evenPage"

      section2 = doc.add_section
      section2.properties ||= Uniword::SectionProperties.new
      section2.properties.section_type = "oddPage"

      expect(section1.properties.section_type).to eq("evenPage")
      expect(section2.properties.section_type).to eq("oddPage")
    end
  end

  describe "Title page" do
    it "should mark section as having title page" do
      skip "Title page property not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      expect(section.properties.title_page).to be true
    end

    it "should have different first page header/footer" do
      skip "Title page with different headers not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      # First page header should be different
      section.first_header = Uniword::Header.new
      section.default_header = Uniword::Header.new

      expect(section.properties.title_page).to be true
    end
  end

  describe "Section integration" do
    it "should associate content with sections" do
      doc = Uniword::Document.new

      para1 = Uniword::Paragraph.new
      para1.add_text("Content in section 1")
      doc.add_element(para1)

      section2 = doc.add_section

      para2 = Uniword::Paragraph.new
      para2.add_text("Content in section 2")
      doc.add_element(para2)

      expect(doc.paragraphs.count).to eq(2)
      expect(doc.sections.count).to eq(2)
    end

    it "should support sections with different page setup" do
      skip "Full section page setup not yet implemented"

      doc = Uniword::Document.new

      # Section 1 - A4 portrait
      section1 = doc.current_section
      section1.properties ||= Uniword::SectionProperties.new
      section1.properties.page_orientation = "portrait"
      section1.properties.page_size = "A4"

      # Section 2 - A4 landscape
      section2 = doc.add_section
      section2.properties ||= Uniword::SectionProperties.new
      section2.properties.page_orientation = "landscape"
      section2.properties.page_size = "A4"

      # Section 3 - Letter portrait
      section3 = doc.add_section
      section3.properties ||= Uniword::SectionProperties.new
      section3.properties.page_orientation = "portrait"
      section3.properties.page_size = "Letter"

      expect(doc.sections.count).to eq(3)
    end
  end
end