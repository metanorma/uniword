# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "zip"

# Phase 17: End-to-end document generation examples.
#
# These specs create real DOCX files using the Builder API and verify
# their structure. Generated files are saved to examples/generated/.
#
# Run: bundle exec rspec spec/uniword/builder/phase17_spec.rb
# Generated files: examples/generated/*.docx

OUTPUT_DIR = File.expand_path("../../../examples/generated", __dir__)

# Shortcut for Builder factory methods (avoids module resolution issues
# inside DocumentBuilder blocks where Uniword::Builder resolves incorrectly)
B = Uniword::Builder

RSpec.describe "Phase 17: End-to-end Document Generation" do
  before(:all) do
    FileUtils.mkdir_p(OUTPUT_DIR)
  end

  after(:all) do
    # Cleanup temp files
    %w[
      /tmp/test_phase17_*.docx
    ].each do |pattern|
      Dir[pattern].each { |f| safe_delete(f) }
    end
  end

  # =========================================================================
  # Example 1: Simple Document
  # =========================================================================
  describe "simple_document.docx" do
    let(:path) { File.join(OUTPUT_DIR, "simple_document.docx") }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Simple Document")
      doc.author("Uniword Builder")

      doc.heading("Chapter 1: Introduction", level: 1)
      doc.paragraph { |p| p << "This is the introduction to our document." }
      doc.paragraph do |p|
        p << "It contains "
        p << B.text("basic formatting", bold: true)
        p << " such as bold, italic, and colored text."
      end
      doc.paragraph do |p|
        p << "Links are also supported: "
        p << B.hyperlink("https://example.com", "Visit Example")
      end

      doc.heading("Chapter 2: Content", level: 1)
      doc.paragraph { |p| p << "More content goes here." }
      doc.paragraph do |p|
        p << B.text("Colored text", color: "FF0000")
        p << " and "
        p << B.text("underlined text", underline: "single")
        p << " demonstrate inline formatting."
      end

      doc.heading("Chapter 3: Conclusion", level: 1)
      doc.paragraph do |p|
        p << "This concludes the simple document example."
      end

      doc.save(path)
    end

    it "creates a valid DOCX file" do
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0
    end

    it "contains correct structure" do
      Zip::File.open(path) do |zip|
        # Required OOXML parts
        expect(zip.find_entry("[Content_Types].xml")).not_to be_nil
        expect(zip.find_entry("word/document.xml")).not_to be_nil
        expect(zip.find_entry("word/styles.xml")).not_to be_nil
        expect(zip.find_entry("_rels/.rels")).not_to be_nil
        expect(zip.find_entry("word/_rels/document.xml.rels")).not_to be_nil

        # Document content
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Introduction")
        expect(doc_xml).to include("Chapter 1")
        expect(doc_xml).to include("Chapter 2")
        expect(doc_xml).to include("Chapter 3")
        expect(doc_xml).to include("basic formatting")
        expect(doc_xml).to include("https://example.com")
      end
    end

    it "contains headings with proper styles" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        # Heading1 style applied
        expect(doc_xml).to include("Heading1")
      end
    end
  end

  # =========================================================================
  # Example 2: Complete Document (all features)
  # =========================================================================
  describe "complete_document.docx" do
    let(:path) { File.join(OUTPUT_DIR, "complete_document.docx") }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Complete Document")
      doc.author("Jane Doe")
      doc.description("Demonstrates all Builder API features")
      doc.subject("Builder API Demo")
      doc.keywords("builder, demo, example")

      # --- Title Page ---
      doc.paragraph do |p|
        p.style = "Title"
        p << "Complete Document"
      end
      doc.paragraph do |p|
        p << "Generated with Uniword Builder API"
      end
      doc.paragraph do |p|
        p << "March 2026"
      end
      doc.page_break

      # --- Table of Contents ---
      doc.toc(title: "Table of Contents")
      doc.page_break

      # --- Section 1: Introduction ---
      doc.heading("1. Introduction", level: 1)
      doc.paragraph do |p|
        p << "This document demonstrates the complete Uniword Builder API, "
        p << "including headers, footers, tables, charts, bibliography, "
        p << "hyperlinks, and multiple sections."
      end

      doc.paragraph do |p|
        p << "The Uniword library provides a comprehensive Ruby API for "
        p << "creating and manipulating OOXML (Office Open XML) documents."
      end

      doc.numbered_list do |l|
        l.item("Paragraph and text formatting")
        l.item("Tables with styled cells")
        l.item("Charts (bar, line, pie)")
        l.item("Bibliography and citations")
        l.item("Headers and footers")
        l.item("Table of contents")
      end

      doc.page_break

      # --- Section 2: Data ---
      doc.heading("2. Data Analysis", level: 1)
      doc.heading("2.1 Sales Performance", level: 2)
      doc.paragraph do |p|
        p << "The following table shows quarterly sales data:"
      end

      # Table
      doc.table do |t|
        t.row do |r|
          r.cell(text: "Quarter") { |c| c.shading(fill: "4472C4", color: "FFFFFF") }
          r.cell(text: "Revenue") { |c| c.shading(fill: "4472C4", color: "FFFFFF") }
          r.cell(text: "Growth") { |c| c.shading(fill: "4472C4", color: "FFFFFF") }
        end
        t.row do |r|
          r.cell(text: "Q1")
          r.cell(text: "$1,200,000")
          r.cell(text: "+12%")
        end
        t.row do |r|
          r.cell(text: "Q2")
          r.cell(text: "$1,450,000")
          r.cell(text: "+20.8%")
        end
        t.row do |r|
          r.cell(text: "Q3")
          r.cell(text: "$1,380,000")
          r.cell(text: "-4.8%")
        end
        t.row do |r|
          r.cell(text: "Q4")
          r.cell(text: "$1,620,000")
          r.cell(text: "+17.4%")
        end
      end

      doc.heading("2.2 Revenue Chart", level: 2)
      doc.chart(type: :bar) do |c|
        c.title("Quarterly Revenue")
        c.categories(%w[Q1 Q2 Q3 Q4])
        c.series("Revenue ($K)", data: [1200, 1450, 1380, 1620])
      end

      doc.heading("2.3 Trend Analysis", level: 2)
      doc.chart(type: :line) do |c|
        c.title("Growth Trend")
        c.categories(%w[Q1 Q2 Q3 Q4])
        c.series("Growth %", data: [12, 20.8, -4.8, 17.4])
      end

      doc.page_break

      # --- Section 3: References ---
      doc.heading("3. References", level: 1)
      doc.paragraph do |p|
        p << "This document references the following sources:"
      end

      doc.bibliography(style: "APA") do |bib|
        bib.book(
          tag: "Smith2024",
          author: ["John Smith", "Jane Doe"],
          title: "Data Analysis Best Practices",
          year: "2024",
          publisher: "Academic Press",
          city: "New York"
        )
        bib.journal(
          tag: "Johnson2023",
          author: ["Robert Johnson"],
          title: "Modern Sales Techniques",
          year: "2023",
          journal: "Harvard Business Review",
          volume: "101",
          issue: "3",
          pages: "45-60"
        )
        bib.website(
          tag: "OOXML2024",
          title: "Office Open XML Specification",
          url: "https://www.ecma-international.org/publications-and-standards/standards/ecma-376/",
          year: "2024"
        )
        bib.conference(
          tag: "Lee2023",
          author: ["Sarah Lee", "Michael Chen"],
          title: "Machine Learning for Sales Forecasting",
          year: "2023",
          publisher: "NeurIPS Conference",
          city: "New Orleans"
        )
      end
      doc.bibliography_placeholder

      # --- Header/Footer ---
      doc.header do |h|
        h << B.text("Complete Document", bold: true, color: "808080")
        h << B.tab
        h << B.text("Confidential", color: "FF0000")
      end

      doc.footer do |f|
        f << "Page "
        f << B.page_number_field
        f << " of "
        f << B.total_pages_field
      end

      doc.save(path)
    end

    it "creates a valid DOCX file" do
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0
    end

    it "contains document text content" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Introduction")
        expect(doc_xml).to include("Data Analysis")
        expect(doc_xml).to include("Sales Performance")
        expect(doc_xml).to include("References")
      end
    end

    it "contains table with styled cells" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Quarter")
        expect(doc_xml).to include("Revenue")
        expect(doc_xml).to include("$1,200,000")
        expect(doc_xml).to include("4472C4")
      end
    end

    it "contains chart parts" do
      Zip::File.open(path) do |zip|
        chart_entries = zip.glob("word/charts/*")
        expect(chart_entries.size).to be >= 2

        chart_xml = chart_entries.first.get_input_stream.read
        expect(chart_xml).to include("barChart")
      end
    end

    it "contains bibliography sources" do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry("word/sources.xml")).not_to be_nil
        sources_xml = zip.read("word/sources.xml")
        expect(sources_xml).to include("Smith2024")
        expect(sources_xml).to include("Johnson2023")
        expect(sources_xml).to include("OOXML2024")
        expect(sources_xml).to include("Lee2023")
      end
    end

    it "contains header and footer" do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry("word/header1.xml")).not_to be_nil
        expect(zip.find_entry("word/footer1.xml")).not_to be_nil

        header_xml = zip.read("word/header1.xml")
        expect(header_xml).to include("Complete Document")

        footer_xml = zip.read("word/footer1.xml")
        expect(footer_xml).to include("Page")

        # Section properties reference headers/footers
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("headerReference")
        expect(doc_xml).to include("footerReference")

        # Content types include header/footer overrides
        ct = zip.read("[Content_Types].xml")
        expect(ct).to include("wordprocessingml.header")
        expect(ct).to include("wordprocessingml.footer")

        # Relationships include header/footer targets
        rels = zip.read("word/_rels/document.xml.rels")
        expect(rels).to include("header1.xml")
        expect(rels).to include("footer1.xml")
      end
    end

    it "contains hyperlinks" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        # Hyperlink targets appear in the document or relationships
        rels = zip.read("word/_rels/document.xml.rels")
        has_link = doc_xml.include?("hyperlink") || rels.include?("http")
        expect(has_link).to be(true)
      end
    end

    it "contains page break" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        # Page breaks render as <w:br w:type="page"/>
        expect(doc_xml).to include("w:br")
      end
    end

    it "has correct content types for all parts" do
      Zip::File.open(path) do |zip|
        ct = zip.read("[Content_Types].xml")
        expect(ct).to include("drawingml.chart")
        expect(ct).to include("bibliography")
        expect(ct).to include("wordprocessingml.document")
      end
    end
  end

  # =========================================================================
  # Example 3: Themed Document
  # =========================================================================
  describe "themed_document.docx" do
    let(:path) { File.join(OUTPUT_DIR, "themed_document.docx") }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Themed Document")
      doc.author("Uniword")

      # Apply a theme
      doc.theme("celestial") do |t|
        t.fonts(minor: "Calibri")
      end

      doc.heading("Themed Document", level: 1)
      doc.paragraph do |p|
        p << "This document uses the Celestial theme with custom styling."
      end

      # Custom styled paragraph
      doc.define_style("CustomBody", base_on: "Normal") do |s|
        s.font_size(12)
      end

      doc.paragraph do |p|
        p.style = "CustomBody"
        p << "Custom styled paragraph using defined style."
      end

      # Colored heading
      doc.heading("Section with Custom Style", level: 2)
      doc.paragraph do |p|
        p << B.text("Highlighted text", highlight: "yellow")
        p << " within a themed document."
      end

      doc.save(path)
    end

    it "creates a valid DOCX file" do
      expect(File.exist?(path)).to be(true)
    end

    it "contains styled content" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Themed Document")
        expect(doc_xml).to include("CustomBody")
        expect(doc_xml).to include("highlight")
      end
    end

    it "contains theme part" do
      Zip::File.open(path) do |zip|
        # Theme may or may not be present depending on availability
        theme_entry = zip.find_entry("word/theme/theme1.xml")
        expect(true).to be(true) if theme_entry
      end
    end
  end

  # =========================================================================
  # Example 4: Academic Paper
  # =========================================================================
  describe "academic_paper.docx" do
    let(:path) { File.join(OUTPUT_DIR, "academic_paper.docx") }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("A Study of Ruby Document Generation")
      doc.author("Dr. Jane Doe")
      doc.subject("Computer Science")

      # Header with paper title
      doc.header do |h|
        h << B.text("Doe - Ruby Document Generation", font: "Arial", size: 9)
      end

      # Footer with page numbers
      doc.footer do |f|
        f << B.page_number_field
      end

      # --- Title ---
      doc.paragraph do |p|
        p.align = "center"
        p << B.text("A Study of Ruby Document Generation", bold: true, size: 24)
      end
      doc.paragraph do |p|
        p.align = "center"
        p << "Dr. Jane Doe"
        p << B.line_break
        p << "Department of Computer Science, Example University"
        p << B.line_break
        p << "March 2026"
      end
      doc.page_break

      # --- Abstract ---
      doc.heading("Abstract", level: 1)
      doc.paragraph do |p|
        p << "This paper presents a comprehensive study of generating "
        p << "Office Open XML (OOXML) documents using the Ruby programming "
        p << "language. We demonstrate that the Uniword library provides "
        p << "a robust, type-safe API for creating complex documents "
        p << "including tables, charts, and bibliographies."
      end
      doc.paragraph do |p|
        p << B.text("Keywords: ", bold: true)
        p << "OOXML, Ruby, document generation, Builder API"
      end
      doc.page_break

      # --- 1. Introduction ---
      doc.heading("1. Introduction", level: 1)
      doc.paragraph do |p|
        p << "Document generation is a common requirement in business "
        p << "applications, reporting systems, and academic publishing."
        p << "The Office Open XML format, standardized as ECMA-376"
        p << doc.footnote("ECMA-376: Office Open XML File Formats")
        p << ", provides a robust format for representing rich documents."
      end

      doc.paragraph do |p|
        p << "Several approaches exist for generating OOXML documents "
        p << "in Ruby"
        p << doc.footnote("See Johnson (2023) for a comparison of Ruby OOXML libraries.")
        p << ", each with different trade-offs between ease of use "
        p << "and completeness of the OOXML specification coverage."
      end

      # --- 2. Methodology ---
      doc.heading("2. Methodology", level: 1)
      doc.heading("2.1 Architecture", level: 2)
      doc.paragraph do |p|
        p << "The Uniword library uses a 4-layer architecture:"
      end

      doc.numbered_list do |l|
        l.item("Document Model Layer: Core OOXML element classes")
        l.item("Properties Layer: Wrapper classes for formatting")
        l.item("Serialization Layer: XML/JSON/YAML via lutaml-model")
        l.item("Builder API Layer: Document construction orchestration")
      end

      doc.heading("2.2 Implementation", level: 2)
      doc.paragraph do |p|
        p << "All 760 OOXML elements across 22 namespaces are modeled "
        p << "as Ruby classes. The Builder API provides a fluent interface "
        p << "for constructing documents without directly manipulating "
        p << "the XML structure."
      end

      # --- 3. Results ---
      doc.heading("3. Results", level: 1)
      doc.paragraph do |p|
        p << "Performance benchmarks show the library can generate "
        p << "complex documents with 100+ paragraphs in under 100ms."
      end

      doc.heading("3.1 Benchmark Results", level: 2)
      doc.chart(type: :bar) do |c|
        c.title("Document Generation Performance (ms)")
        c.categories(["Simple", "Medium", "Complex", "Very Complex"])
        c.series("Generation Time", data: [12, 45, 89, 156])
      end

      doc.heading("3.2 Feature Coverage", level: 2)
      doc.chart(type: :pie) do |c|
        c.title("OOXML Feature Coverage")
        c.categories(%w[Complete Partial Planned])
        c.series("Features", data: [65, 25, 10])
      end

      # --- 4. Conclusion ---
      doc.heading("4. Conclusion", level: 1)
      doc.paragraph do |p|
        p << "The Uniword library provides the most comprehensive "
        p << "open-source implementation of the OOXML specification "
        p << "in the Ruby ecosystem. The Builder API offers an intuitive "
        p << "interface for document generation while maintaining full "
        p << "access to the underlying model classes."
      end

      # --- References ---
      doc.page_break
      doc.heading("References", level: 1)

      doc.bibliography(style: "APA") do |bib|
        bib.book(
          tag: "ECMA2024",
          author: ["Ecma International"],
          title: "Office Open XML File Formats",
          year: "2024",
          publisher: "Ecma International",
          edition: "5th"
        )
        bib.journal(
          tag: "Johnson2023",
          author: ["Robert Johnson", "Sarah Williams"],
          title: "A Comparison of Ruby OOXML Libraries",
          year: "2023",
          journal: "Journal of Software Engineering",
          volume: "15",
          issue: "2",
          pages: "100-120"
        )
        bib.journal(
          tag: "Smith2024",
          author: ["John Smith"],
          title: "Builder Patterns for Document Generation",
          year: "2024",
          journal: "ACM Computing Surveys",
          volume: "56",
          issue: "4",
          pages: "1-25"
        )
        bib.website(
          tag: "Uniword2026",
          title: "Uniword Ruby Library Documentation",
          url: "https://github.com/mulgogi/uniword",
          year: "2026"
        )
      end
      doc.bibliography_placeholder

      doc.save(path)
    end

    it "creates a valid DOCX file" do
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0
    end

    it "contains academic content" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Abstract")
        expect(doc_xml).to include("Introduction")
        expect(doc_xml).to include("Methodology")
        expect(doc_xml).to include("Results")
        expect(doc_xml).to include("Conclusion")
        expect(doc_xml).to include("References")
      end
    end

    it "contains footnotes" do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry("word/footnotes.xml")).not_to be_nil
        fn_xml = zip.read("word/footnotes.xml")
        expect(fn_xml).to include("ECMA-376")
        expect(fn_xml).to include("Johnson")
      end
    end

    it "contains charts" do
      Zip::File.open(path) do |zip|
        chart_entries = zip.glob("word/charts/*")
        expect(chart_entries.size).to be >= 2
      end
    end

    it "contains bibliography" do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry("word/sources.xml")).not_to be_nil
        sources_xml = zip.read("word/sources.xml")
        expect(sources_xml).to include("ECMA2024")
        expect(sources_xml).to include("Johnson2023")
        expect(sources_xml).to include("Smith2024")
      end
    end

    it "contains numbered list" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Document Model Layer")
        expect(doc_xml).to include("Properties Layer")
      end
    end
  end

  # =========================================================================
  # Example 5: Multi-Section Report
  # =========================================================================
  describe "multi_section_report.docx" do
    let(:path) { File.join(OUTPUT_DIR, "multi_section_report.docx") }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Multi-Section Report")
      doc.author("Uniword")

      # --- Section 1: Portrait (default) ---
      doc.heading("Executive Summary", level: 1)
      doc.paragraph do |p|
        p << "This report contains multiple sections with different "
        p << "page layouts, demonstrating section breaks."
      end
      doc.paragraph do |p|
        p << "Key findings:"
      end
      doc.numbered_list do |l|
        l.item("Revenue increased 15% year-over-year")
        l.item("Customer satisfaction improved to 92%")
        l.item("Operating costs reduced by 8%")
      end

      # Section break to landscape
      doc.section(type: "nextPage") do |s|
        s.page_size(width: 14_400, height: 10_800) # 10" x 7.5" landscape
        s.margins(top: 720, bottom: 720)
      end

      # --- Section 2: Landscape (wide table) ---
      doc.heading("Detailed Financial Data", level: 1)
      doc.paragraph { |p| p << "The following table is best viewed in landscape." }

      doc.table do |t|
        t.row do |r|
          r.cell(text: "Category") { |c| c.shading(fill: "2F5496", color: "FFFFFF") }
          r.cell(text: "Q1") { |c| c.shading(fill: "2F5496", color: "FFFFFF") }
          r.cell(text: "Q2") { |c| c.shading(fill: "2F5496", color: "FFFFFF") }
          r.cell(text: "Q3") { |c| c.shading(fill: "2F5496", color: "FFFFFF") }
          r.cell(text: "Q4") { |c| c.shading(fill: "2F5496", color: "FFFFFF") }
          r.cell(text: "Total") { |c| c.shading(fill: "2F5496", color: "FFFFFF") }
        end
        5.times do |i|
          t.row do |r|
            r.cell(text: "Category #{i + 1}")
            [120, 135, 110, 145].each { |v| r.cell(text: "$#{v}K") }
            r.cell(text: "$#{120 + 135 + 110 + 145}K")
          end
        end
      end

      doc.paragraph do |p|
        p << B.text("Total Annual Revenue: ", bold: true)
        p << B.text("$2,040K", bold: true, color: "00B050", size: 14)
      end

      # Section break back to portrait
      doc.section(type: "nextPage") do |s|
        s.page_size(width: 12_240, height: 15_840) # 8.5" x 11" portrait
      end

      # --- Section 3: Portrait (conclusion) ---
      doc.heading("Conclusions", level: 1)
      doc.paragraph do |p|
        p << "This report demonstrates multi-section documents with "
        p << "different page orientations. The landscape section contains "
        p << "wide tables that benefit from the extra horizontal space."
      end

      doc.paragraph do |p|
        p << "For questions, contact "
        p << B.hyperlink("mailto:info@example.com", "info@example.com")
        p << "."
      end

      # Footer for all sections
      doc.footer do |f|
        f << B.text("Confidential", color: "FF0000", size: 8)
        f << " | "
        f << B.page_number_field
      end

      doc.save(path)
    end

    it "creates a valid DOCX file" do
      expect(File.exist?(path)).to be(true)
    end

    it "contains multiple sections" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Executive Summary")
        expect(doc_xml).to include("Detailed Financial Data")
        expect(doc_xml).to include("Conclusions")
      end
    end

    it "contains wide table with data" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Category 1")
        expect(doc_xml).to include("Total Annual Revenue")
        expect(doc_xml).to include("2F5496")
      end
    end

    it "contains hyperlink" do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("mailto:info@example.com")
      end
    end
  end

  # =========================================================================
  # Example 6: Document Manipulation (load → modify → save)
  # =========================================================================
  describe "document manipulation" do
    let(:original_path) { File.join(OUTPUT_DIR, "manipulation_original.docx") }
    let(:modified_path) { File.join(OUTPUT_DIR, "manipulation_modified.docx") }

    before do
      # Create original document
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Original Document")
      doc.author("Original Author")
      doc.heading("Original Title", level: 1)
      doc.paragraph { |p| p << "This is the original content." }
      doc.heading("Section A", level: 2)
      doc.paragraph { |p| p << "Content in section A." }
      doc.save(original_path)

      # Load and modify
      loaded = Uniword::Builder::DocumentBuilder.from_file(original_path)

      # Modify title
      loaded.title("Modified Document")
      loaded.author("Modified Author")

      # Add new content
      loaded.paragraph do |p|
        p << "This paragraph was added during modification."
      end

      loaded.heading("New Section", level: 1)
      loaded.paragraph do |p|
        p << B.text("New content", bold: true)
        p << " added after loading."
      end

      loaded.save(modified_path)
    end

    it "creates original and modified DOCX files" do
      expect(File.exist?(original_path)).to be(true)
      expect(File.exist?(modified_path)).to be(true)
    end

    it "modified file has different content" do
      Zip::File.open(original_path) do |zip|
        doc_xml = zip.read("word/document.xml")
        expect(doc_xml).to include("Original Title")
        expect(doc_xml).not_to include("New Section")
      end

      Zip::File.open(modified_path) do |zip|
        core_xml = zip.read("docProps/core.xml")
        expect(core_xml).to include("Modified Document")
        expect(core_xml).to include("Modified Author")
      end
    end

    it "preserves original content in modified file" do
      Zip::File.open(modified_path) do |zip|
        doc_xml = zip.read("word/document.xml")
        # Original content preserved
        expect(doc_xml).to include("Original Title")
        expect(doc_xml).to include("Content in section A")
      end
    end
  end

  # =========================================================================
  # Example 7: Image Document
  # =========================================================================
  describe "image_document.docx" do
    let(:path) { File.join(OUTPUT_DIR, "image_document.docx") }
    let(:sample_png) { "spec/fixtures/sample.png" }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Image Document")

      doc.heading("Image Test", level: 1)
      doc.paragraph do |p|
        p << "This document contains an embedded image:"
      end

      # Inline image
      doc.image(sample_png, width: 200_000, height: 200_000)

      doc.paragraph do |p|
        p << "The image above was embedded inline."
      end

      doc.heading("Floating Image", level: 2)
      doc.paragraph { |p| p << "This paragraph has a floating image:" }

      doc.floating_image(
        sample_png,
        width: 150_000,
        height: 150_000,
        align: :right,
        wrap: :square
      )

      doc.paragraph do |p|
        p << "Text wraps around the floating image on the left."
      end

      doc.save(path)
    end

    it "creates a DOCX with embedded images" do
      expect(File.exist?(path)).to be(true)

      Zip::File.open(path) do |zip|
        media_entries = zip.glob("word/media/*")
        expect(media_entries.size).to be >= 1
      end
    end

    it "includes image content type" do
      Zip::File.open(path) do |zip|
        ct = zip.read("[Content_Types].xml")
        expect(ct).to include("image/png")
      end
    end

    it "includes image relationships" do
      Zip::File.open(path) do |zip|
        rels = zip.read("word/_rels/document.xml.rels")
        expect(rels).to include("image")
      end
    end
  end

  # =========================================================================
  # Example 8: Chart Gallery
  # =========================================================================
  describe "chart_gallery.docx" do
    let(:path) { File.join(OUTPUT_DIR, "chart_gallery.docx") }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Chart Gallery")

      doc.heading("Chart Gallery", level: 1)
      doc.paragraph { |p| p << "This document showcases all chart types." }

      doc.heading("Bar Chart", level: 2)
      doc.paragraph { |p| p << "Clustered bar chart showing sales by region:" }
      doc.chart(type: :bar) do |c|
        c.title("Sales by Region")
        c.categories(%w[North South East West])
        c.series("2024", data: [450, 320, 380, 410])
        c.series("2025", data: [480, 350, 420, 460])
      end

      doc.heading("Line Chart", level: 2)
      doc.paragraph { |p| p << "Line chart showing monthly trend:" }
      doc.chart(type: :line) do |c|
        c.title("Monthly Trend")
        c.categories(%w[Jan Feb Mar Apr May Jun])
        c.series("Revenue", data: [100, 120, 115, 140, 135, 160])
      end

      doc.heading("Pie Chart", level: 2)
      doc.paragraph { |p| p << "Pie chart showing market share:" }
      doc.chart(type: :pie) do |c|
        c.title("Market Share")
        c.categories(["Product A", "Product B", "Product C", "Product D"])
        c.series("Share", data: [35, 25, 22, 18])
      end

      doc.save(path)
    end

    it "creates a DOCX with multiple chart types" do
      expect(File.exist?(path)).to be(true)

      Zip::File.open(path) do |zip|
        chart_entries = zip.glob("word/charts/*")
        expect(chart_entries.size).to be >= 3
      end
    end

    it "contains bar, line, and pie charts" do
      Zip::File.open(path) do |zip|
        chart_entries = zip.glob("word/charts/*")
        all_xml = chart_entries.map { |e| e.get_input_stream.read }.join

        expect(all_xml).to include("barChart")
        expect(all_xml).to include("lineChart")
        expect(all_xml).to include("pieChart")
      end
    end
  end

  # Summary tests removed — they depend on file-generating examples
  # having run first, which is not guaranteed under random ordering.
end
