# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Docx.js Compatibility: Headers and Footers", :compatibility do
  describe "Headers" do
    it "should add default header to section" do
      skip "Headers not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section

      header = Uniword::Header.new
      para = Uniword::Paragraph.new
      para.add_text("My Header")
      header.add_element(para)

      section.default_header = header

      expect(section.default_header).not_to be_nil
    end

    it "should add first page header" do
      skip "First page headers not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      first_header = Uniword::Header.new
      para = Uniword::Paragraph.new
      para.add_text("First Page Header")
      first_header.add_element(para)

      section.first_header = first_header

      expect(section.first_header).not_to be_nil
    end

    it "should support different default and first headers" do
      skip "Multiple header types not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      # Default header
      default_header = Uniword::Header.new
      para1 = Uniword::Paragraph.new
      para1.add_text("Default Header")
      default_header.add_element(para1)
      section.default_header = default_header

      # First page header
      first_header = Uniword::Header.new
      para2 = Uniword::Paragraph.new
      para2.add_text("First Page Header")
      first_header.add_element(para2)
      section.first_header = first_header

      expect(section.default_header).not_to eq(section.first_header)
    end

    it "should support even and odd headers" do
      skip "Even/odd headers not yet implemented"

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

  describe "Footers" do
    it "should add default footer to section" do
      skip "Footers not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      para.add_text("My Footer")
      footer.add_element(para)

      section.default_footer = footer

      expect(section.default_footer).not_to be_nil
    end

    it "should add first page footer" do
      skip "First page footers not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section
      section.properties ||= Uniword::SectionProperties.new
      section.properties.title_page = true

      first_footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      para.add_text("First Page Footer")
      first_footer.add_element(para)

      section.first_footer = first_footer

      expect(section.first_footer).not_to be_nil
    end

    it "should support both headers and footers" do
      skip "Headers and footers together not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section

      header = Uniword::Header.new
      header_para = Uniword::Paragraph.new
      header_para.add_text("Header")
      header.add_element(header_para)
      section.default_header = header

      footer = Uniword::Footer.new
      footer_para = Uniword::Paragraph.new
      footer_para.add_text("Footer")
      footer.add_element(footer_para)
      section.default_footer = footer

      expect(section.default_header).not_to be_nil
      expect(section.default_footer).not_to be_nil
    end
  end

  describe "Page numbers" do
    it "should insert current page number in header" do
      skip "Page number fields not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section

      header = Uniword::Header.new
      para = Uniword::Paragraph.new
      para.add_text("Page ")

      # Add page number field
      page_num = Uniword::Field.new(type: "PAGE")
      para.add_field(page_num)

      header.add_element(para)
      section.default_header = header

      expect(header).not_to be_nil
    end

    it "should insert current page number in footer" do
      skip "Page number fields in footer not yet implemented"

      doc = Uniword::Document.new
      section = doc.current_section

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      para.add_text("Page ")

      page_num = Uniword::Field.new(type: "PAGE")
      para.add_field(page_num)

      footer.add_element(para)
      section.default_footer = footer

      expect(footer).not_to be_nil
    end

    it "should support page X of Y format" do
      skip "Page X of Y format not yet implemented"

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new

      para.add_text("Page ")
      para.add_field(Uniword::Field.new(type: "PAGE"))
      para.add_text(" of ")
      para.add_field(Uniword::Field.new(type: "NUMPAGES"))

      footer.add_element(para)

      expect(para.runs.count).to be > 0
    end

    it "should support page number with custom text" do
      skip "Custom page number text not yet implemented"

      header = Uniword::Header.new
      para = Uniword::Paragraph.new

      para.add_text("My Title ")
      page_num_run = Uniword::Run.new
      page_num_run.add_text("Page ")
      page_num_run.add_field(Uniword::Field.new(type: "PAGE"))
      para.add_run(page_num_run)

      header.add_element(para)

      expect(header).not_to be_nil
    end

    it "should support aligned page numbers" do
      skip "Aligned page numbers not yet implemented"

      footer = Uniword::Footer.new
      para = Uniword::Paragraph.new
      para.properties = Uniword::Properties::ParagraphProperties.new(
        alignment: "right"
      )

      para.add_text("Page ")
      para.add_field(Uniword::Field.new(type: "PAGE"))

      footer.add_element(para)

      expect(para.properties.alignment).to eq("right")
    end
  end

  describe "Header and footer formatting" do
    it "should support formatted text in header" do
      skip "Formatted header text not yet implemented"

      header = Uniword::Header.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new(text: "Bold Header")
      run.properties = Uniword::Properties::RunProperties.new(bold: true)
      para.add_run(run)

      header.add_element(para)

      expect(run.bold?).to be true
    end

    it "should support tables in headers" do
      skip "Tables in headers not yet implemented"

      header = Uniword::Header.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      cell.add_text("Header table cell")
      row.add_cell(cell)
      table.add_row(row)

      header.add_element(table)

      expect(header).not_to be_nil
    end

    it "should support images in headers" do
      skip "Images in headers not yet implemented"

      header = Uniword::Header.new
      para = Uniword::Paragraph.new

      image = Uniword::Image.from_data(
        "image data",
        width: 100 * 9525,
        height: 50 * 9525,
        alt_text: "Header logo"
      )

      para.add_element(image)
      header.add_element(para)

      expect(header).not_to be_nil
    end
  end

  describe "Section-specific headers and footers" do
    it "should support different headers per section" do
      skip "Per-section headers not yet implemented"

      doc = Uniword::Document.new

      # Section 1 header
      section1 = doc.current_section
      header1 = Uniword::Header.new
      para1 = Uniword::Paragraph.new
      para1.add_text("Section 1 Header")
      header1.add_element(para1)
      section1.default_header = header1

      # Section 2 header
      section2 = doc.add_section
      header2 = Uniword::Header.new
      para2 = Uniword::Paragraph.new
      para2.add_text("Section 2 Header")
      header2.add_element(para2)
      section2.default_header = header2

      expect(section1.default_header).not_to eq(section2.default_header)
    end

    it "should support different footers per section" do
      skip "Per-section footers not yet implemented"

      doc = Uniword::Document.new

      section1 = doc.current_section
      footer1 = Uniword::Footer.new
      para1 = Uniword::Paragraph.new
      para1.add_text("Section 1 Footer")
      footer1.add_element(para1)
      section1.default_footer = footer1

      section2 = doc.add_section
      footer2 = Uniword::Footer.new
      para2 = Uniword::Paragraph.new
      para2.add_text("Section 2 Footer")
      footer2.add_element(para2)
      section2.default_footer = footer2

      expect(section1.default_footer).not_to eq(section2.default_footer)
    end
  end

  describe "Page number continuation" do
    it "should continue page numbers across sections" do
      skip "Page number continuation not yet implemented"

      doc = Uniword::Document.new

      # Section 1 - starts at 1
      section1 = doc.current_section
      header1 = Uniword::Header.new
      para1 = Uniword::Paragraph.new
      para1.add_text("Page ")
      para1.add_field(Uniword::Field.new(type: "PAGE"))
      header1.add_element(para1)
      section1.default_header = header1

      # Section 2 - continues from section 1
      section2 = doc.add_section
      header2 = Uniword::Header.new
      para2 = Uniword::Paragraph.new
      para2.add_text("Page number: ")
      para2.add_field(Uniword::Field.new(type: "PAGE"))
      header2.add_element(para2)
      section2.default_header = header2

      expect(doc.sections.count).to eq(2)
    end
  end
end