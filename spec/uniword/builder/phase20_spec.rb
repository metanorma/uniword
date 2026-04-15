# frozen_string_literal: true

require "spec_helper"
require "zip"

RSpec.describe "Builder Phase 20: Ultra-Elaborate Scenarios" do
  B = Uniword::Builder
  OUTPUT_DIR = File.expand_path("../../../examples/generated", __dir__)

  before { FileUtils.mkdir_p(OUTPUT_DIR) }

  # ──────────────────────────────────────────────────────────
  # 1. Document with Comments (Review Workflow)
  # ──────────────────────────────────────────────────────────
  describe "review document with comments" do
    let(:path) { File.join(OUTPUT_DIR, "review_document.docx") }

    it "creates a document with multiple comments" do
      doc = B::DocumentBuilder.new
      doc.title("Quarterly Report")
      doc.author("Jane Smith")

      doc.heading("Executive Summary", level: 1)
      doc.paragraph do |p|
        p << "The company experienced significant growth in Q4 2025."
        p << B.text("Revenue increased by 23%.", bold: true)
      end

      doc.comment(author: "John Doe", initials: "JD", text: "Can we add the exact revenue figure?")

      doc.paragraph do |p|
        p << "Key achievements include expanding to three new markets and "
        p << "launching two new product lines."
      end

      doc.comment(author: "Alice Johnson", initials: "AJ") do |c|
        c << "Please specify which three markets."
        c << "Also, are these domestic or international?"
      end

      doc.heading("Financial Analysis", level: 1)
      doc.paragraph { |p| p << "Detailed financial metrics are presented below." }

      doc.comment(author: "John Doe", initials: "JD", text: "Add the financial table here")

      doc.table do |t|
        t.row do |r|
          r.cell(text: "Metric") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Q3 2025") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Q4 2025") { |c| c.shading(fill: "4472C4") }
        end
        t.row do |r|
          r.cell(text: "Revenue ($M)")
          r.cell(text: "12.4")
          r.cell(text: "15.3")
        end
        t.row do |r|
          r.cell(text: "Profit ($M)")
          r.cell(text: "3.1")
          r.cell(text: "4.2")
        end
      end

      doc.save(path)

      # Verify model
      expect(doc.model.comments).not_to be_empty
      expect(doc.model.comments.size).to eq(3)
      expect(doc.model.comments[0].author).to eq("John Doe")
      expect(doc.model.comments[0].text).to include("exact revenue figure")
      expect(doc.model.comments[1].author).to eq("Alice Johnson")
      expect(doc.model.comments[1].text).to include("which three markets")
      expect(doc.model.comments[2].text).to include("financial table")

      # Verify DOCX file
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      expect(zip.find_entry("word/document.xml")).not_to be_nil
      xml = zip.read("word/document.xml")
      expect(xml).to include("Executive Summary")
      expect(xml).to include("Financial Analysis")
      expect(xml).to include("Revenue")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 2. Form Template with Multiple Content Controls
  # ──────────────────────────────────────────────────────────
  describe "form template with content controls" do
    let(:path) { File.join(OUTPUT_DIR, "form_template.docx") }

    it "creates a form with text, date, and bibliography controls" do
      doc = B::DocumentBuilder.new
      doc.title("Employee Onboarding Form")
      doc.author("HR Department")

      doc.heading("Employee Information", level: 1)

      # Name field
      doc.paragraph do |p|
        p << B.text("Full Name: ", bold: true)
        sdt = B::SdtBuilder.text(tag: "employee_name", alias_name: "Employee Name",
                                 placeholder_text: "Enter full name")
        p << sdt.build
      end

      # Email field
      doc.paragraph do |p|
        p << B.text("Email: ", bold: true)
        sdt = B::SdtBuilder.text(tag: "employee_email", alias_name: "Email",
                                 placeholder_text: "Enter email address")
        p << sdt.build
      end

      # Date of birth
      doc.paragraph do |p|
        p << B.text("Date of Birth: ", bold: true)
        sdt = B::SdtBuilder.date(tag: "dob", format: "yyyy-MM-dd").tap { |s| s.alias("Date of Birth") }
        p << sdt.build
      end

      # Department dropdown (simulated as text control)
      doc.paragraph do |p|
        p << B.text("Department: ", bold: true)
        sdt = B::SdtBuilder.text(tag: "department", alias_name: "Department",
                                 placeholder_text: "Select department")
        p << sdt.build
      end

      doc.horizontal_rule

      doc.heading("Employment Details", level: 1)

      # Start date
      doc.paragraph do |p|
        p << B.text("Start Date: ", bold: true)
        sdt = B::SdtBuilder.date(tag: "start_date", format: "MMMM d, yyyy").tap { |s| s.alias("Start Date") }
        p << sdt.build
      end

      # Manager
      doc.paragraph do |p|
        p << B.text("Reporting Manager: ", bold: true)
        sdt = B::SdtBuilder.text(tag: "manager", alias_name: "Manager",
                                 placeholder_text: "Manager's name")
        p << sdt.build
      end

      # Position
      doc.paragraph do |p|
        p << B.text("Position: ", bold: true)
        sdt = B::SdtBuilder.text(tag: "position", alias_name: "Position",
                                 placeholder_text: "Job title")
        p << sdt.build
      end

      doc.horizontal_rule

      doc.heading("Notes", level: 1)
      doc.paragraph do |p|
        p << B.text("Additional Notes: ", bold: true)
        sdt = B::SdtBuilder.text(tag: "notes", alias_name: "Notes",
                                 placeholder_text: "Enter any additional information")
        p << sdt.build
      end

      doc.save(path)

      # Verify SDTs in paragraphs
      paragraphs_with_sdts = doc.model.paragraphs.select { |p| p.sdts && !p.sdts.empty? }
      expect(paragraphs_with_sdts.size).to be >= 6

      # Verify specific controls
      all_sdts = paragraphs_with_sdts.flat_map(&:sdts)
      tag_names = all_sdts.map do |s|
        s.properties&.alias_name&.value || s.properties&.tag&.value
      end.compact
      expect(tag_names).to include("Employee Name")
      expect(tag_names).to include("Email")
      expect(tag_names).to include("Date of Birth")
      expect(tag_names).to include("Department")
      expect(tag_names).to include("Start Date")
      expect(tag_names).to include("Manager")

      # Verify DOCX file
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      xml = zip.read("word/document.xml")
      expect(xml).to include("Employee Information")
      expect(xml).to include("Employment Details")
      expect(xml).to include("w:sdt")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 3. Complex Tables (Nested, Merged Cells, Styled)
  # ──────────────────────────────────────────────────────────
  describe "complex table document" do
    let(:path) { File.join(OUTPUT_DIR, "complex_tables.docx") }

    it "creates tables with merged cells and styling" do
      doc = B::DocumentBuilder.new
      doc.title("Complex Table Examples")
      doc.author("Table Designer")

      # --- 3a. Table with column spanning (merged header) ---
      doc.heading("Quarterly Results with Merged Header", level: 2)

      doc.table do |t|
        # Header row: one merged cell spanning 3 columns, then a separate cell
        t.row do |r|
          r.cell(text: "Q4 2025 Financial Summary") do |c|
            c.column_span(3)
            c.shading(fill: "1F4E79")
          end
          r.cell(text: "Notes") do |c|
            c.shading(fill: "1F4E79")
          end
        end
        # Sub-header
        t.row do |r|
          r.cell(text: "Region") { |c| c.shading(fill: "D6E4F0") }
          r.cell(text: "Revenue") { |c| c.shading(fill: "D6E4F0") }
          r.cell(text: "Growth") { |c| c.shading(fill: "D6E4F0") }
          r.cell(text: "") { |c| c.shading(fill: "D6E4F0") }
        end
        # Data rows
        t.row do |r|
          r.cell(text: "North America")
          r.cell(text: "$5.2M")
          r.cell(text: "+12%")
          r.cell(text: "Strong")
        end
        t.row do |r|
          r.cell(text: "Europe")
          r.cell(text: "$3.8M")
          r.cell(text: "+8%")
          r.cell(text: "Steady")
        end
        t.row do |r|
          r.cell(text: "Asia Pacific")
          r.cell(text: "$4.1M")
          r.cell(text: "+22%")
          r.cell(text: "Rapid growth")
        end
      end

      # --- 3b. Styled table with alternating row colors ---
      doc.heading("Styled Table with Alternating Colors", level: 2)

      doc.table do |t|
        t.row do |r|
          r.cell(text: "Product") { |c| c.shading(fill: "2E75B6") }
          r.cell(text: "Q1") { |c| c.shading(fill: "2E75B6") }
          r.cell(text: "Q2") { |c| c.shading(fill: "2E75B6") }
          r.cell(text: "Q3") { |c| c.shading(fill: "2E75B6") }
          r.cell(text: "Q4") { |c| c.shading(fill: "2E75B6") }
        end
        %w[Widget Gadget Thingamajig Doohickey].each_with_index do |product, idx|
          fill = idx.even? ? "F2F2F2" : "FFFFFF"
          t.row do |r|
            r.cell(text: product) { |c| c.shading(fill: fill) }
            r.cell(text: "#{rand(100..500)}K") { |c| c.shading(fill: fill) }
            r.cell(text: "#{rand(100..500)}K") { |c| c.shading(fill: fill) }
            r.cell(text: "#{rand(100..500)}K") { |c| c.shading(fill: fill) }
            r.cell(text: "#{rand(100..500)}K") { |c| c.shading(fill: fill) }
          end
        end
      end

      # --- 3c. Nested table (table inside a cell) ---
      doc.heading("Nested Table (Team Details)", level: 2)

      doc.table do |t|
        t.row do |r|
          r.cell(text: "Team Alpha") do |c|
            c.shading(fill: "E2EFDA")
            c.column_span(2)
          end
        end
        t.row do |r|
          r.cell(text: "Members") do |c|
            # Nested table inside this cell
            nested = B::TableBuilder.new
            nested.row { |nr| nr.cell(text: "Alice") }
            nested.row { |nr| nr.cell(text: "Bob") }
            nested.row { |nr| nr.cell(text: "Carol") }
            c << nested.build
          end
          r.cell(text: "Budget: $500K")
        end
      end

      doc.save(path)

      # Verify model
      tables = doc.model.tables
      expect(tables.size).to eq(3)

      # First table: check column_span on first cell
      first_table_first_row = tables[0].rows[0]
      first_cell = first_table_first_row.cells[0]
      expect(first_cell.properties&.grid_span&.value).to eq(3)

      # Third table: check nested table
      third_table = tables[2]
      member_cell = third_table.rows[1].cells[0]
      expect(member_cell.tables).not_to be_empty
      expect(member_cell.tables[0].rows.size).to eq(3)

      # Verify DOCX
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      xml = zip.read("word/document.xml")
      expect(xml).to include("gridSpan")
      expect(xml).to include("Team Alpha")
      expect(xml).to include("Widget")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 4. Multi-Section with Section-Specific Headers/Footers
  # ──────────────────────────────────────────────────────────
  describe "multi-section document with per-section headers" do
    let(:path) { File.join(OUTPUT_DIR, "multi_section_headers.docx") }

    it "creates a document with different headers per section" do
      doc = B::DocumentBuilder.new
      doc.title("Multi-Section Report")
      doc.author("Report Generator")

      # Section 1: Cover page
      doc.paragraph do |p|
        p.align = "center"
        p << B.text("Annual Report 2025", bold: true, size: 48)
      end
      doc.paragraph do |p|
        p.align = "center"
        p << "Acme Corporation"
      end
      doc.page_break

      # Section 2: Main content with header/footer
      doc.section(type: "nextPage") do |s|
        s.margins(top: 1440, bottom: 1440)
        s.page_numbering(start: 1)
        s.header(type: "default") { |h| h << "Annual Report 2025 — Acme Corporation" }
        s.footer(type: "default") do |f|
          f << "Page "
          f << B.page_number_field
          f << " of "
          f << B.total_pages_field
        end
      end

      doc.heading("Introduction", level: 1)
      doc.paragraph { |p| p << "This is the main body of the report." }

      doc.heading("Methodology", level: 1)
      doc.paragraph { |p| p << "Our approach to data analysis..." }

      doc.heading("Results", level: 1)
      doc.bullet_list do |l|
        l.item("Finding 1: Revenue grew 23% year-over-year")
        l.item("Finding 2: Customer satisfaction improved to 92%")
        l.item("Finding 3: Market share increased in 3 regions")
      end

      # Section 3: Appendix with different header
      doc.section(type: "nextPage") do |s|
        s.header(type: "default") { |h| h << "Appendix — Confidential" }
        s.footer(type: "default") { |f| f << "CONFIDENTIAL — Do Not Distribute" }
      end

      doc.heading("Appendix A: Raw Data", level: 1)
      doc.paragraph { |p| p << "Supplementary data tables and figures." }

      doc.table do |t|
        t.row do |r|
          r.cell(text: "ID")
          r.cell(text: "Value")
          r.cell(text: "Status")
        end
        t.row do |r|
          r.cell(text: "001")
          r.cell(text: "42.5")
          r.cell(text: "Verified")
        end
        t.row do |r|
          r.cell(text: "002")
          r.cell(text: "38.1")
          r.cell(text: "Pending")
        end
      end

      doc.save(path)

      # Verify model structure
      sect_pr = doc.model.body.section_properties
      expect(sect_pr).not_to be_nil
      expect(sect_pr.header_references.size).to be >= 1

      # Verify DOCX
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      expect(zip.find_entry("word/document.xml")).not_to be_nil
      xml = zip.read("word/document.xml")
      expect(xml).to include("Introduction")
      expect(xml).to include("Appendix")
      expect(xml).to include("headerReference")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 5. Academic Paper with Footnotes, Bibliography, TOC
  # ──────────────────────────────────────────────────────────
  describe "academic paper with full scholarly features" do
    let(:path) { File.join(OUTPUT_DIR, "academic_full.docx") }

    it "creates a complete academic paper" do
      doc = B::DocumentBuilder.new
      doc.title("The Impact of Builder Patterns on Software Quality")
      doc.author("Dr. Jane Researcher")
      doc.subject("Software Engineering")
      doc.keywords("builder pattern, software quality, design patterns")

      # Header with page numbers
      doc.header do |h|
        h << B.text("Research Paper", italic: true)
      end
      doc.footer do |f|
        f << "Page "
        f << B.page_number_field
      end

      # Title page
      doc.paragraph do |p|
        p.align = "center"
        p << B.text('The Impact of Builder Patterns\non Software Quality', bold: true, size: 28)
      end
      doc.paragraph do |p|
        p.align = "center"
        p << B.text("Dr. Jane Researcher", italic: true)
      end
      doc.paragraph do |p|
        p.align = "center"
        p << "University of Computer Science"
      end
      doc.paragraph do |p|
        p.align = "center"
        p << "March 2026"
      end
      doc.page_break

      # Abstract
      doc.heading("Abstract", level: 1)
      doc.paragraph do |p|
        p << "This paper examines the impact of the Builder design pattern on "
        p << "software quality metrics including maintainability, testability, and "
        p << "code readability. Through a controlled experiment involving 120 "
        p << "developers, we demonstrate that projects using Builder patterns show "
        p << "a 34% reduction in configuration-related bugs."
      end

      # TOC
      doc.page_break
      doc.toc(title: "Table of Contents")

      doc.page_break

      # 1. Introduction
      doc.heading("1. Introduction", level: 1)
      doc.paragraph do |p|
        p << "Software design patterns have been a cornerstone of object-oriented "
        p << "programming since the seminal work by Gamma et al."
        p << doc.footnote('Gamma, E., et al. "Design Patterns: ' \
                          "Elements of Reusable Object-Oriented " \
                          'Software." Addison-Wesley, 1994.')
        p << " Among these patterns, the Builder pattern has gained particular "
        p << "prominence in modern software development."
      end

      doc.paragraph do |p|
        p << "The Builder pattern separates the construction of a complex object "
        p << "from its representation"
        p << doc.footnote("The Gang of Four originally described " \
                          "this pattern in the context of C++ development.")
        p << ", allowing the same construction process to create different "
        p << "representations."
      end

      # 2. Literature Review
      doc.heading("2. Literature Review", level: 1)

      doc.heading("2.1 Design Patterns in Modern Software", level: 2)
      doc.paragraph do |p|
        p << "Recent studies have shown that proper use of design patterns "
        p << "correlates with higher code quality scores."
        p << doc.endnote('Smith, J. "Design Patterns and Code Quality." ' \
                         "Journal of Software Engineering, vol. 15, no. 3, 2024.")
      end

      doc.heading("2.2 The Builder Pattern", level: 2)
      doc.paragraph do |p|
        p << "The Builder pattern provides a fluent interface for constructing "
        p << "complex objects step by step. This approach offers several advantages:"
      end

      doc.numbered_list do |l|
        l.item("Improved readability through method chaining")
        l.item("Reduced constructor parameter explosion")
        l.item("Better support for immutable objects")
        l.item("Enhanced testability of construction logic")
      end

      # 3. Methodology
      doc.heading("3. Methodology", level: 1)
      doc.paragraph do |p|
        p << "We conducted a controlled experiment with 120 professional "
        p << "software developers, divided into two groups of 60 each."
      end

      doc.heading("3.1 Experimental Design", level: 2)
      doc.table do |t|
        t.row do |r|
          r.cell(text: "Parameter") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Group A (Builder)") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Group B (Traditional)") { |c| c.shading(fill: "4472C4") }
        end
        t.row do |r|
          r.cell(text: "Developers")
          r.cell(text: "60")
          r.cell(text: "60")
        end
        t.row do |r|
          r.cell(text: "Task Duration")
          r.cell(text: "4 hours")
          r.cell(text: "4 hours")
        end
        t.row do |r|
          r.cell(text: "Project Complexity")
          r.cell(text: "Medium")
          r.cell(text: "Medium")
        end
        t.row do |r|
          r.cell(text: "Avg. Bug Count")
          r.cell(text: "2.3")
          r.cell(text: "3.5")
        end
      end

      # 4. Results
      doc.heading("4. Results", level: 1)
      doc.paragraph do |p|
        p << "Our results demonstrate a statistically significant improvement "
        p << "in code quality metrics for the Builder pattern group."
      end

      doc.bullet_list do |l|
        l.item("Configuration bug reduction: 34%")
        l.item("Code readability score: +28%")
        l.item("Test coverage improvement: +15%")
        l.item("Development time: comparable (no significant difference)")
      end

      # Bibliography
      doc.page_break
      doc.heading("References", level: 1)
      doc.bibliography do |b|
        b.book(
          tag: "gamma1994",
          author: ["Gamma, E.", "Helm, R.", "Johnson, R.", "Vlissides, J."],
          title: "Design Patterns: Elements of Reusable Object-Oriented Software",
          year: "1994",
          publisher: "Addison-Wesley"
        )
        b.journal(
          tag: "smith2024",
          author: ["Smith, J."],
          title: "Design Patterns and Code Quality",
          year: "2024",
          journal: "Journal of Software Engineering",
          volume: "15",
          pages: "45-67"
        )
        b.website(
          tag: "builder2025",
          author: ["Martin, R."],
          title: "Builder Pattern in Modern Ruby",
          year: "2025",
          url: "https://example.com/builder-pattern-ruby"
        )
      end

      doc.save(path)

      # Verify model
      expect(doc.model.paragraphs.size).to be > 20
      expect(doc.model.tables.size).to be >= 1

      # Verify footnotes/endnotes exist
      expect(doc.model.footnotes).not_to be_nil
      expect(doc.model.footnotes.footnote_entries.size).to be >= 2
      expect(doc.model.endnotes).not_to be_nil
      expect(doc.model.endnotes.endnote_entries.size).to be >= 1

      # Verify bibliography
      expect(doc.model.bibliography_sources).not_to be_nil

      # Verify DOCX
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      expect(zip.find_entry("word/document.xml")).not_to be_nil
      expect(zip.find_entry("word/footnotes.xml")).not_to be_nil
      expect(zip.find_entry("word/endnotes.xml")).not_to be_nil
      xml = zip.read("word/document.xml")
      expect(xml).to include("Introduction")
      expect(xml).to include("Methodology")
      expect(xml).to include("Results")
      expect(xml).to include("References")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 6. Document with Bookmarks and Cross-References
  # ──────────────────────────────────────────────────────────
  describe "document with bookmarks" do
    let(:path) { File.join(OUTPUT_DIR, "bookmarked_document.docx") }

    it "creates a document with multiple bookmarks" do
      doc = B::DocumentBuilder.new
      doc.title("Technical Manual")
      doc.author("Engineering Team")

      doc.heading("Technical Manual v3.0", level: 1)
      doc.paragraph do |p|
        p << "This document serves as the comprehensive reference for the "
        p << "Uniword library API."
      end

      doc.toc

      doc.page_break

      # Section with bookmark
      doc.heading("1. Installation", level: 1)
      doc.bookmark("installation") do |p|
        p << "To install Uniword, add the following to your Gemfile:"
      end
      doc.paragraph do |p|
        p << B.text("gem 'uniword'", font: "Courier New", size: 20)
      end

      doc.heading("2. Quick Start", level: 1)
      doc.bookmark("quickstart") do |p|
        p << "Get started with a simple document in just a few lines of code."
      end

      doc.heading("3. Builder API", level: 1)
      doc.bookmark("builder_api") do |p|
        p << "The Builder API provides a fluent interface for document construction."
      end

      doc.heading("3.1 DocumentBuilder", level: 2)
      doc.paragraph { |p| p << "DocumentBuilder is the top-level entry point." }

      doc.heading("3.2 ParagraphBuilder", level: 2)
      doc.paragraph do |p|
        p << "ParagraphBuilder handles paragraph-level construction with the "
        p << "<< operator for adding content."
      end

      doc.heading("3.3 TableBuilder", level: 2)
      doc.paragraph { |p| p << "TableBuilder creates tables with rows and cells." }

      doc.heading("4. Advanced Topics", level: 1)
      doc.bookmark("advanced") do |p|
        p << "This section covers advanced usage patterns."
      end

      doc.numbered_list do |l|
        l.item("Custom themes and stylesets")
        l.item("Footnotes and endnotes")
        l.item("Content controls and forms")
        l.item("Charts and images")
      end

      doc.heading("5. API Reference", level: 1)
      doc.bookmark("api_reference") do |p|
        p << "Complete API reference for all builder classes."
      end

      doc.table do |t|
        t.row do |r|
          r.cell(text: "Builder") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Purpose") { |c| c.shading(fill: "4472C4") }
        end
        t.row do |r|
          r.cell(text: "DocumentBuilder")
          r.cell(text: "Top-level document construction")
        end
        t.row do |r|
          r.cell(text: "ParagraphBuilder")
          r.cell(text: "Paragraph with << operator")
        end
        t.row do |r|
          r.cell(text: "RunBuilder")
          r.cell(text: "Run formatting (bold, italic, etc.)")
        end
        t.row do |r|
          r.cell(text: "TableBuilder")
          r.cell(text: "Table with rows and cells")
        end
        t.row do |r|
          r.cell(text: "SectionBuilder")
          r.cell(text: "Page setup and numbering")
        end
        t.row do |r|
          r.cell(text: "StyleBuilder")
          r.cell(text: "Custom style definitions")
        end
        t.row do |r|
          r.cell(text: "ImageBuilder")
          r.cell(text: "Image embedding")
        end
        t.row do |r|
          r.cell(text: "ChartBuilder")
          r.cell(text: "Chart creation")
        end
      end

      doc.save(path)

      # Verify bookmarks
      bookmarks = doc.model.bookmarks
      expect(bookmarks).not_to be_empty
      expect(bookmarks.keys).to include("installation", "quickstart", "builder_api", "advanced",
                                        "api_reference")

      # Verify DOCX
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      xml = zip.read("word/document.xml")
      expect(xml).to include("bookmarkStart")
      expect(xml).to include("bookmarkEnd")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 7. Themed Document with Custom Styles and Colors
  # ──────────────────────────────────────────────────────────
  describe "themed document with custom styles" do
    let(:path) { File.join(OUTPUT_DIR, "themed_custom_styles.docx") }

    it "creates a themed document with custom style definitions" do
      doc = B::DocumentBuilder.new
      doc.title("Styled Report")
      doc.author("Style Designer")

      # Apply theme
      doc.theme("celestial") do |t|
        t.colors(accent1: "2E5090", accent2: "C55A11")
        t.fonts(major: "Georgia", minor: "Calibri")
      end

      # Define custom styles
      doc.define_style("Subtitle Custom", base_on: "Normal") do |s|
        s.font_size(24)
        s.color("4472C4")
        s.italic(true)
      end

      doc.define_style("Code Block", base_on: "Normal") do |s|
        s.font("Courier New")
        s.font_size(18)
        s.color("2E2E2E")
      end

      doc.define_style("Important Note", base_on: "Normal") do |s|
        s.font_size(22)
        s.bold(true)
        s.color("C00000")
      end

      # Cover page
      doc.paragraph do |p|
        p.align = "center"
        p << B.text("Project Status Report", bold: true, size: 48, color: "2E5090")
      end

      doc.paragraph do |p|
        p.style = "Subtitle Custom"
        p.align = "center"
        p << "Q4 2025 — Confidential"
      end

      doc.page_break

      # Body content
      doc.heading("Executive Summary", level: 1)
      doc.paragraph do |p|
        p << "This report summarizes the project status as of December 2025."
      end

      doc.paragraph do |p|
        p.style = "Important Note"
        p << "Deadline: All deliverables must be completed by January 15, 2026."
      end

      doc.heading("Technical Details", level: 1)
      doc.paragraph do |p|
        p << "The following code snippet demonstrates the API usage:"
      end

      doc.paragraph do |p|
        p.style = "Code Block"
        p << "doc = Uniword::Builder::DocumentBuilder.new\n"
        p << "doc.heading('Hello', level: 1)\n"
        p << "doc.save('output.docx')"
      end

      doc.heading("Key Metrics", level: 1)
      doc.table do |t|
        t.row do |r|
          r.cell(text: "Metric") { |c| c.shading(fill: "2E5090") }
          r.cell(text: "Target") { |c| c.shading(fill: "2E5090") }
          r.cell(text: "Actual") { |c| c.shading(fill: "2E5090") }
          r.cell(text: "Status") { |c| c.shading(fill: "2E5090") }
        end
        t.row do |r|
          r.cell(text: "Completion") { |c| c.shading(fill: "E2EFDA") }
          r.cell(text: "100%") { |c| c.shading(fill: "E2EFDA") }
          r.cell(text: "92%") { |c| c.shading(fill: "E2EFDA") }
          r.cell(text: "On Track") { |c| c.shading(fill: "E2EFDA") }
        end
        t.row do |r|
          r.cell(text: "Bug Count") { |c| c.shading(fill: "FCE4D6") }
          r.cell(text: "< 10") { |c| c.shading(fill: "FCE4D6") }
          r.cell(text: "7") { |c| c.shading(fill: "FCE4D6") }
          r.cell(text: "Good") { |c| c.shading(fill: "FCE4D6") }
        end
        t.row do |r|
          r.cell(text: "Test Coverage") { |c| c.shading(fill: "E2EFDA") }
          r.cell(text: "> 80%") { |c| c.shading(fill: "E2EFDA") }
          r.cell(text: "87%") { |c| c.shading(fill: "E2EFDA") }
          r.cell(text: "Exceeded") { |c| c.shading(fill: "E2EFDA") }
        end
      end

      doc.save(path)

      # Verify styles
      styles = doc.model.styles_configuration
      expect(styles).not_to be_nil

      # Verify DOCX
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      xml = zip.read("word/document.xml")
      expect(xml).to include("Executive Summary")
      expect(xml).to include("Important Note")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 8. Ultimate Document — ALL Features Combined
  # ──────────────────────────────────────────────────────────
  describe "ultimate document with all features" do
    let(:path) { File.join(OUTPUT_DIR, "ultimate_document.docx") }

    it "creates a document combining every builder feature" do
      doc = B::DocumentBuilder.new
      doc.title("The Ultimate Document")
      doc.author("Uniword Builder Demo")
      doc.subject("Comprehensive Feature Demonstration")
      doc.keywords("builder, demo, all-features, uniword")

      # --- Theme ---
      doc.theme("office_theme")

      # --- Headers/Footers ---
      doc.header(type: "default") do |h|
        h << B.text("The Ultimate Document", bold: true)
        h << " — "
        h << B.text("All Features Demo", italic: true)
      end
      doc.footer(type: "default") do |f|
        f << "Page "
        f << B.page_number_field
        f << " of "
        f << B.total_pages_field
        f << " | Generated by Uniword Builder"
      end

      # --- Custom Styles ---
      doc.define_style("CustomSubtitle", base_on: "Normal") do |s|
        s.font_size(24)
        s.color("4472C4")
        s.italic(true)
      end

      # --- Cover Page ---
      doc.paragraph do |p|
        p.align = "center"
        p.spacing(before: 2400)
        p << B.text("The Ultimate Document", bold: true, size: 56, color: "1F4E79")
      end
      doc.paragraph do |p|
        p.align = "center"
        p.style = "CustomSubtitle"
        p << "A Comprehensive Demonstration of the Uniword Builder API"
      end
      doc.paragraph do |p|
        p.align = "center"
        p << "Created: March 26, 2026"
      end

      doc.page_break

      # --- TOC ---
      doc.toc(title: "Table of Contents")
      doc.page_break

      # === SECTION 1: Introduction ===
      doc.heading("1. Introduction", level: 1)
      doc.paragraph do |p|
        p << "This document demonstrates "
        p << B.text("every feature", bold: true, underline: "single")
        p << " of the Uniword Builder API in a single, coherent document."
      end

      # Bookmark
      doc.bookmark("intro") do |p|
        p << 'This paragraph is bookmarked as "intro".'
      end

      # Footnote + endnote
      doc.paragraph do |p|
        p << "The Builder API provides a fluent interface"
        p << doc.footnote("Builder API was introduced in Phase 7 of the development plan.")
        p << " for constructing OOXML documents programmatically"
        p << doc.endnote("OOXML stands for Office Open XML, the file format used by Microsoft Word.")
        p << "."
      end

      # Comment
      doc.comment(author: "Reviewer", initials: "RV", text: "Great introduction!")

      # Horizontal rule
      doc.horizontal_rule(color: "4472C4", size: 12)

      # === SECTION 2: Text Formatting ===
      doc.heading("2. Text Formatting", level: 1)

      doc.heading("2.1 Run Formatting", level: 2)
      doc.paragraph do |p|
        p << B.text("Bold text", bold: true)
        p << ", "
        p << B.text("italic text", italic: true)
        p << ", "
        p << B.text("underlined text", underline: "single")
        p << ", "
        p << B.text("colored text", color: "FF0000")
        p << ", "
        p << B.text("highlighted text", highlight: "yellow")
        p << ", and "
        p << B.text("strike-through text", strike: true)
        p << "."
      end

      doc.heading("2.2 Font Sizes", level: 2)
      doc.paragraph do |p|
        p << B.text("8pt", size: 8)
        p << " "
        p << B.text("10pt", size: 10)
        p << " "
        p << B.text("12pt", size: 12)
        p << " "
        p << B.text("16pt", size: 16)
        p << " "
        p << B.text("24pt", size: 24)
        p << " "
        p << B.text("36pt", size: 36)
        p << " "
        p << B.text("48pt", size: 48)
      end

      doc.heading("2.3 Special Characters", level: 2)
      doc.paragraph do |p|
        p << "Line break example:"
        p << B.line_break
        p << "This text is on a new line."
      end
      doc.paragraph do |p|
        p << "Tab stop example:"
        p << B.tab
        p << "After tab"
      end

      # === SECTION 3: Lists ===
      doc.heading("3. Lists", level: 1)

      doc.heading("3.1 Bullet List", level: 2)
      doc.bullet_list do |l|
        l.item("First bullet point")
        l.item("Second bullet point")
        l.item("Third bullet point") do |p|
          p << B.text(" with bold emphasis", bold: true)
        end
      end

      doc.heading("3.2 Numbered List", level: 2)
      doc.numbered_list do |l|
        l.item("First numbered item")
        l.item("Second numbered item")
        l.item("Third numbered item")
      end

      doc.heading("3.3 Multi-level List", level: 2)
      doc.numbered_list do |l|
        l.item("Level 1, Item 1")
        l.item("Level 1, Item 2")
        l.item("Nested item", level: 1)
        l.item("Another nested item", level: 1)
        l.item("Level 1, Item 3")
      end

      # === SECTION 4: Tables ===
      doc.heading("4. Tables", level: 1)

      doc.heading("4.1 Basic Table", level: 2)
      doc.table do |t|
        t.row do |r|
          r.cell(text: "Column A") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Column B") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Column C") { |c| c.shading(fill: "4472C4") }
        end
        3.times do |i|
          t.row do |r|
            r.cell(text: "Row #{i + 1}, Col A")
            r.cell(text: "Row #{i + 1}, Col B")
            r.cell(text: "Row #{i + 1}, Col C")
          end
        end
      end

      doc.heading("4.2 Merged Cells", level: 2)
      doc.table do |t|
        t.row do |r|
          r.cell(text: "Merged Header (3 cols)") do |c|
            c.column_span(3)
            c.shading(fill: "1F4E79")
          end
        end
        t.row do |r|
          r.cell(text: "A1")
          r.cell(text: "B1")
          r.cell(text: "C1")
        end
        t.row do |r|
          r.cell(text: "A2")
          r.cell(text: "B2")
          r.cell(text: "C2")
        end
      end

      # === SECTION 5: Hyperlinks ===
      doc.heading("5. Hyperlinks", level: 1)
      doc.paragraph do |p|
        p << "Visit the "
        p << B.hyperlink("https://example.com", "project website")
        p << " for more information, or check the "
        p << B.hyperlink("https://example.com/docs", "documentation", color: "2E5090")
        p << "."
      end

      # === SECTION 6: Fields ===
      doc.heading("6. Document Fields", level: 1)
      doc.paragraph do |p|
        p << "This document was generated on: "
      end
      doc.date_field(format: "MMMM d, yyyy")

      # === SECTION 7: Content Controls ===
      doc.heading("7. Content Controls", level: 1)
      doc.paragraph do |p|
        p << B.text("Name: ", bold: true)
        p << B::SdtBuilder.text(tag: "user_name", alias_name: "User Name",
                                placeholder_text: "Enter your name").build
      end
      doc.paragraph do |p|
        p << B.text("Date: ", bold: true)
        p << B::SdtBuilder.date(tag: "form_date", format: "yyyy-MM-dd").build
      end

      doc.horizontal_rule

      # === SECTION 8: Bookmarks ===
      doc.heading("8. Bookmarks", level: 1)
      doc.bookmark("section8") do |p|
        p << 'This section is bookmarked as "section8" for cross-referencing.'
      end
      doc.bookmark("appendix-anchor") do |p|
        p << "This is the appendix anchor bookmark."
      end

      # === SECTION 9: Comments ===
      doc.heading("9. Comments", level: 1)
      doc.paragraph do |p|
        p << "This paragraph has a comment attached."
      end
      doc.comment(author: "Editor", initials: "ED", text: "Please expand this section.")
      doc.comment(author: "Technical Reviewer", initials: "TR") do |c|
        c << "Consider adding code examples."
        c << "Also, add performance benchmarks."
      end

      # === SECTION 10: Section Properties ===
      doc.section(type: "nextPage") do |s|
        s.margins(top: 720, bottom: 720)
        s.page_numbering(start: 1)
        s.header(type: "default") { |h| h << "Appendix — Page numbering restarts here" }
        s.footer(type: "default") { |f| f << "Page " << B.page_number_field }
      end

      doc.heading("Appendix", level: 1)
      doc.paragraph do |p|
        p << "This appendix demonstrates section breaks with different "
        p << "headers, footers, and page numbering."
      end

      # Bibliography
      doc.heading("Bibliography", level: 1)
      doc.bibliography do |b|
        b.book(
          tag: "gamma1994",
          author: ["Gamma, E.", "et al."],
          title: "Design Patterns",
          year: "1994",
          publisher: "Addison-Wesley"
        )
      end
      doc.bibliography_placeholder

      doc.save(path)

      # === VERIFICATION ===

      # Document metadata
      expect(doc.model.core_properties.title).to eq("The Ultimate Document")
      expect(doc.model.core_properties.creator).to eq("Uniword Builder Demo")

      # Paragraphs and tables
      expect(doc.model.paragraphs.size).to be > 30
      expect(doc.model.tables.size).to be >= 2

      # Bookmarks
      bookmarks = doc.model.bookmarks
      expect(bookmarks.keys).to include("intro", "section8", "appendix-anchor")

      # Comments
      expect(doc.model.comments).not_to be_nil
      expect(doc.model.comments.size).to be >= 3

      # Footnotes and endnotes
      expect(doc.model.footnotes.footnote_entries.size).to be >= 1
      expect(doc.model.endnotes.endnote_entries.size).to be >= 1

      # Bibliography
      expect(doc.model.bibliography_sources).not_to be_nil

      # Section properties
      sect_pr = doc.model.body.section_properties
      expect(sect_pr).not_to be_nil
      expect(sect_pr.header_references.size).to be >= 1

      # DOCX file
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      expect(zip.find_entry("word/document.xml")).not_to be_nil
      expect(zip.find_entry("word/footnotes.xml")).not_to be_nil
      expect(zip.find_entry("word/endnotes.xml")).not_to be_nil

      xml = zip.read("word/document.xml")
      # Verify key content
      expect(xml).to include("Introduction")
      expect(xml).to include("Text Formatting")
      expect(xml).to include("Lists")
      expect(xml).to include("Tables")
      expect(xml).to include("Hyperlinks")
      expect(xml).to include("Content Controls")
      expect(xml).to include("Comments")
      expect(xml).to include("Appendix")
      expect(xml).to include("bookmarkStart")
      expect(xml).to include("gridSpan")
      expect(xml).to include("w:sdt")
      expect(xml).to include("w:hyperlink")

      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 9. Invoice Document (Real-World Use Case)
  # ──────────────────────────────────────────────────────────
  describe "invoice document" do
    let(:path) { File.join(OUTPUT_DIR, "invoice.docx") }

    it "creates a professional invoice" do
      doc = B::DocumentBuilder.new
      doc.title("Invoice INV-2025-0042")
      doc.author("Acme Services Inc.")

      # Header
      doc.header do |h|
        h << B.text("ACME SERVICES INC.", bold: true, color: "2E5090")
        h << " | Invoice INV-2025-0042"
      end
      doc.footer do |f|
        f << "Thank you for your business!"
        f << B.line_break
        f << "Payment due within 30 days"
      end

      # Invoice header
      doc.paragraph do |p|
        p << B.text("INVOICE", bold: true, size: 36, color: "1F4E79")
      end

      doc.horizontal_rule(color: "2E5090", size: 18)

      # From / To
      doc.table do |t|
        t.row do |r|
          r.cell do |c|
            c << B::ParagraphBuilder.new.tap do |pb|
              pb << "From: "
              pb << B.text("Acme Services Inc.", bold: true)
              pb << B.line_break
              pb << "123 Business Ave"
              pb << B.line_break
              pb << "San Francisco, CA 94102"
              pb << B.line_break
              pb << "contact@acme.com"
            end
          end
          r.cell do |c|
            c << B::ParagraphBuilder.new.tap do |pb|
              pb << "To: "
              pb << B.text("Client Corporation", bold: true)
              pb << B.line_break
              pb << "456 Client Street"
              pb << B.line_break
              pb << "New York, NY 10001"
              pb << B.line_break
              pb << "billing@client.com"
            end
          end
        end
      end

      doc.paragraph do |p|
        p << "Invoice Number: "
        p << B.text("INV-2025-0042", bold: true)
        p << "    Date: "
        p << B.text("March 26, 2026", bold: true)
        p << "    Due: "
        p << B.text("April 25, 2026", bold: true)
      end

      doc.horizontal_rule

      # Line items table
      doc.table do |t|
        t.row do |r|
          r.cell(text: "Description") { |c| c.shading(fill: "2E5090") }
          r.cell(text: "Qty") { |c| c.shading(fill: "2E5090") }
          r.cell(text: "Unit Price") { |c| c.shading(fill: "2E5090") }
          r.cell(text: "Amount") { |c| c.shading(fill: "2E5090") }
        end
        items = [
          ["Consulting Services", "40", "$150.00", "$6,000.00"],
          ["Software Development", "80", "$200.00", "$16,000.00"],
          ["Project Management", "20", "$175.00", "$3,500.00"],
          ["Quality Assurance", "15", "$125.00", "$1,875.00"]
        ]
        items.each do |desc, qty, price, amount|
          t.row do |r|
            r.cell(text: desc)
            r.cell(text: qty)
            r.cell(text: price)
            r.cell(text: amount)
          end
        end
        # Total row
        t.row do |r|
          r.cell(text: "") { |c| c.column_span(3) }
          r.cell do |c|
            c << B::ParagraphBuilder.new.tap do |pb|
              pb << B.text("Total: $27,375.00", bold: true, size: 22)
            end
            c.shading(fill: "E2EFDA")
          end
        end
      end

      doc.horizontal_rule

      doc.paragraph do |p|
        p << B.text("Payment Terms: ", bold: true)
        p << "Net 30 days. Please reference invoice number INV-2025-0042 "
        p << "on your payment."
      end

      doc.save(path)

      # Verify model
      expect(doc.model.tables.size).to be >= 2
      expect(doc.model.paragraphs.size).to be > 5

      # Verify DOCX
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      xml = zip.read("word/document.xml")
      expect(xml).to include("INVOICE")
      expect(xml).to include("Acme Services")
      expect(xml).to include("Client Corporation")
      expect(xml).to include("$27,375.00")
      expect(xml).to include("gridSpan")
      zip.close
    end
  end

  # ──────────────────────────────────────────────────────────
  # 10. Resume/CV Document
  # ──────────────────────────────────────────────────────────
  describe "resume document" do
    let(:path) { File.join(OUTPUT_DIR, "resume.docx") }

    it "creates a professional resume" do
      doc = B::DocumentBuilder.new
      doc.title("Jane Developer — Resume")
      doc.author("Jane Developer")

      # Name and contact
      doc.paragraph do |p|
        p.align = "center"
        p << B.text("Jane Developer", bold: true, size: 36, color: "1F4E79")
      end
      doc.paragraph do |p|
        p.align = "center"
        p << "Senior Software Engineer"
      end
      doc.paragraph do |p|
        p.align = "center"
        p << B.text("jane@example.com", color: "4472C4")
        p << " | (555) 123-4567 | San Francisco, CA | "
        p << B.hyperlink("https://github.com/janedev", "github.com/janedev")
      end

      doc.horizontal_rule(color: "4472C4", size: 12)

      # Summary
      doc.heading("Summary", level: 1)
      doc.paragraph do |p|
        p << "Senior Software Engineer with 8+ years of experience building "
        p << "scalable web applications. Expert in Ruby, Python, and JavaScript. "
        p << "Passionate about clean code, design patterns, and developer experience."
      end

      # Experience
      doc.heading("Experience", level: 1)

      doc.paragraph do |p|
        p << B.text("Senior Software Engineer", bold: true)
        p << " — TechCorp Inc. (2021 - Present)"
      end
      doc.bullet_list do |l|
        l.item("Led a team of 6 engineers building a microservices platform")
        l.item("Reduced API response time by 40% through caching optimization")
        l.item("Implemented CI/CD pipeline serving 200+ deployments per week")
        l.item("Mentored 3 junior developers, all promoted within 18 months")
      end

      doc.paragraph do |p|
        p << B.text("Software Engineer", bold: true)
        p << " — StartupXYZ (2018 - 2021)"
      end
      doc.bullet_list do |l|
        l.item("Built real-time collaboration features used by 50K+ users")
        l.item("Designed and implemented RESTful API with 99.9% uptime")
        l.item("Contributed to open-source projects (500+ GitHub stars)")
      end

      doc.paragraph do |p|
        p << B.text("Junior Developer", bold: true)
        p << " — WebAgency Co. (2016 - 2018)"
      end
      doc.bullet_list do |l|
        l.item("Developed responsive web applications for 20+ clients")
        l.item("Introduced automated testing, increasing coverage from 20% to 85%")
      end

      # Skills
      doc.heading("Technical Skills", level: 1)
      doc.table do |t|
        t.row do |r|
          r.cell(text: "Category") { |c| c.shading(fill: "4472C4") }
          r.cell(text: "Skills") { |c| c.shading(fill: "4472C4") }
        end
        t.row do |r|
          r.cell(text: "Languages")
          r.cell(text: "Ruby, Python, JavaScript, TypeScript, Go")
        end
        t.row do |r|
          r.cell(text: "Frameworks")
          r.cell(text: "Rails, Django, React, Next.js")
        end
        t.row do |r|
          r.cell(text: "Databases")
          r.cell(text: "PostgreSQL, Redis, MongoDB, Elasticsearch")
        end
        t.row do |r|
          r.cell(text: "DevOps")
          r.cell(text: "Docker, Kubernetes, AWS, Terraform")
        end
        t.row do |r|
          r.cell(text: "Testing")
          r.cell(text: "RSpec, pytest, Jest, Cypress")
        end
      end

      # Education
      doc.heading("Education", level: 1)
      doc.paragraph do |p|
        p << B.text("B.S. Computer Science", bold: true)
        p << " — University of California, Berkeley (2016)"
      end

      doc.save(path)

      # Verify DOCX
      expect(File.exist?(path)).to be true
      zip = Zip::File.open(path)
      xml = zip.read("word/document.xml")
      expect(xml).to include("Jane Developer")
      expect(xml).to include("Summary")
      expect(xml).to include("Experience")
      expect(xml).to include("Technical Skills")
      expect(xml).to include("Education")
      expect(xml).to include("w:hyperlink")
      zip.close
    end
  end
end
