# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'zip'

# Phase 19: Elaborated Document Generation — Themed, Styled, Complete
#
# Tests elaborate Builder API scenarios including:
# - Simple document with just headings and paragraphs
# - Complete document with ALL features (header/footer/TOC/charts/tables/
#   bibliography/links/many sections/bullet lists)
# - Documents with themes (applying/changing themes, fonts, colors)
# - Document manipulation (load → modify → save)
#
# Run: bundle exec rspec spec/uniword/builder/phase19_spec.rb
# Generated files: examples/generated/*.docx

OUTPUT_DIR = File.expand_path('../../../examples/generated', __dir__)
B = Uniword::Builder

RSpec.describe 'Phase 19: Elaborated Document Generation' do
  before(:all) do
    FileUtils.mkdir_p(OUTPUT_DIR)
  end

  # =========================================================================
  # Example 1: Simple Document (headings + paragraphs only)
  # =========================================================================
  describe 'simple_headings_paragraphs.docx' do
    let(:path) { File.join(OUTPUT_DIR, 'simple_headings_paragraphs.docx') }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Simple Document')
      doc.author('Uniword')

      doc.heading('Chapter 1: Getting Started', level: 1)
      doc.paragraph do |p|
        p << 'This is the first paragraph of a simple document. '
        p << 'It contains only headings and paragraphs.'
      end

      doc.heading('1.1 Prerequisites', level: 2)
      doc.paragraph do |p|
        p << 'Before you begin, make sure you have Ruby installed.'
      end
      doc.paragraph do |p|
        p << 'Uniword requires Ruby 3.0 or later.'
      end

      doc.heading('1.2 Installation', level: 2)
      doc.paragraph do |p|
        p << 'Install Uniword via RubyGems:'
      end

      doc.heading('Chapter 2: Basic Usage', level: 1)
      doc.paragraph do |p|
        p << 'Creating a new document is straightforward. '
        p << 'Use the DocumentBuilder class to get started.'
      end

      doc.heading('2.1 Creating Documents', level: 2)
      doc.paragraph do |p|
        p << 'The DocumentBuilder provides a fluent API for building documents.'
      end

      doc.heading('2.2 Modifying Documents', level: 2)
      doc.paragraph do |p|
        p << 'You can also load existing documents and modify them.'
      end

      doc.save(path)
    end

    it 'creates a valid DOCX file' do
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0
    end

    it 'contains all headings and paragraphs' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Chapter 1')
        expect(doc_xml).to include('Chapter 2')
        expect(doc_xml).to include('Prerequisites')
        expect(doc_xml).to include('Installation')
        expect(doc_xml).to include('Basic Usage')
        expect(doc_xml).to include('Ruby')
      end
    end

    it 'has correct metadata' do
      Zip::File.open(path) do |zip|
        core = zip.read('docProps/core.xml')
        expect(core).to include('Simple Document')
        expect(core).to include('Uniword')
      end
    end
  end

  # =========================================================================
  # Example 2: Complete Document with ALL Features
  # =========================================================================
  describe 'complete_all_features.docx' do
    let(:path) { File.join(OUTPUT_DIR, 'complete_all_features.docx') }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Complete Feature Showcase')
      doc.author('Jane Doe')
      doc.description('A document demonstrating every Builder API feature')
      doc.subject('Builder API Feature Showcase')
      doc.keywords('builder, demo, complete, showcase')

      # --- Title Page ---
      doc.paragraph do |p|
        p.style = 'Title'
        p << 'Complete Feature Showcase'
      end
      doc.paragraph do |p|
        p.style = 'Subtitle'
        p << 'Every Builder API Feature in One Document'
      end
      doc.paragraph do |p|
        p << 'Jane Doe'
        p << ' — March 26, 2026'
      end
      doc.page_break

      # --- Table of Contents ---
      doc.toc(title: 'Contents')
      doc.page_break

      # --- Section 1: Text Formatting ---
      doc.heading('1. Text Formatting', level: 1)
      doc.paragraph do |p|
        p << 'This paragraph demonstrates '
        p << ::B.text('bold', bold: true)
        p << ', '
        p << ::B.text('italic', italic: true)
        p << ', '
        p << ::B.text('underline', underline: 'single')
        p << ', '
        p << ::B.text('colored', color: 'FF0000')
        p << ', '
        p << ::B.text('highlighted', highlight: 'yellow')
        p << ', and '
        p << ::B.text('bold italic colored', bold: true, italic: true, color: '0000FF')
        p << ' text.'
      end

      doc.paragraph do |p|
        p << 'Different sizes: '
        p << ::B.text('small', size: 16)
        p << ', '
        p << ::B.text('normal', size: 22)
        p << ', '
        p << ::B.text('large', size: 32)
      end

      doc.paragraph do |p|
        p << 'Text effects: '
        p << ::B.text('superscript', size: 16) << ::B.text('2', size: 16)
        p << ' and '
        p << ::B.text('H', size: 16) << ::B.text('2', size: 16)
        p << 'O'
      end

      # --- Section 2: Lists ---
      doc.heading('2. Lists', level: 1)

      doc.heading('2.1 Bullet List', level: 2)
      doc.paragraph do |p|
        p << 'Key features of Uniword:'
      end
      doc.bullet_list do |l|
        l.item('Comprehensive OOXML model coverage')
        l.item('Builder API for document construction')
        l.item('Round-trip fidelity')
        l.item('Theme support')
        l.item do |p|
          p << ::B.text('Rich text', bold: true)
          p << ' in list items'
        end
      end

      doc.heading('2.2 Numbered List', level: 2)
      doc.paragraph do |p|
        p << 'Getting started steps:'
      end
      doc.numbered_list do |l|
        l.item('Install the gem')
        l.item('Require the library')
        l.item('Create a DocumentBuilder')
        l.item('Add content')
        l.item('Save the document')
      end

      # --- Section 3: Tables ---
      doc.heading('3. Tables', level: 1)
      doc.paragraph do |p|
        p << 'The following table shows project metrics:'
      end

      doc.table do |t|
        # Header row
        t.row do |r|
          r.cell(text: 'Metric') { |c| c.shading(fill: '2E5090', color: 'FFFFFF') }
          r.cell(text: 'Q1') { |c| c.shading(fill: '2E5090', color: 'FFFFFF') }
          r.cell(text: 'Q2') { |c| c.shading(fill: '2E5090', color: 'FFFFFF') }
          r.cell(text: 'Q3') { |c| c.shading(fill: '2E5090', color: 'FFFFFF') }
          r.cell(text: 'Q4') { |c| c.shading(fill: '2E5090', color: 'FFFFFF') }
        end
        # Data rows
        t.row do |r|
          r.cell(text: 'Revenue')
          r.cell(text: '$1.2M')
          r.cell(text: '$1.5M')
          r.cell(text: '$1.4M')
          r.cell(text: '$1.6M')
        end
        t.row do |r|
          r.cell(text: 'Users')
          r.cell(text: '10K')
          r.cell(text: '15K')
          r.cell(text: '18K')
          r.cell(text: '25K')
        end
        t.row do |r|
          r.cell(text: 'NPS Score')
          r.cell(text: '72')
          r.cell(text: '78')
          r.cell(text: '81')
          r.cell(text: '85')
        end
      end

      # --- Section 4: Charts ---
      doc.heading('4. Charts', level: 1)

      doc.heading('4.1 Bar Chart', level: 2)
      doc.chart(type: :bar) do |c|
        c.title('Quarterly Revenue ($M)')
        c.categories(['Q1', 'Q2', 'Q3', 'Q4'])
        c.series('Revenue', data: [1.2, 1.5, 1.4, 1.6])
      end

      doc.heading('4.2 Line Chart', level: 2)
      doc.chart(type: :line) do |c|
        c.title('User Growth (K)')
        c.categories(['Q1', 'Q2', 'Q3', 'Q4'])
        c.series('Users', data: [10, 15, 18, 25])
      end

      # --- Section 5: Links ---
      doc.heading('5. Hyperlinks', level: 1)
      doc.paragraph do |p|
        p << 'Visit the '
        p << ::B.hyperlink('https://www.ecma-international.org/publications-and-standards/standards/ecma-376/',
                            'ECMA-376 specification')
        p << ' for the complete OOXML standard.'
      end
      doc.paragraph do |p|
        p << 'Uniword is hosted at '
        p << ::B.hyperlink('https://github.com/publicruby/uniword', 'GitHub')
        p << '.'
      end

      # --- Section 6: Bibliography ---
      doc.heading('6. References', level: 1)
      doc.paragraph do |p|
        p << 'This document references the following sources:'
      end

      doc.bibliography(style: 'APA') do |bib|
        bib.book(
          tag: 'ECMA376',
          author: ['ECMA International'],
          title: 'Office Open XML File Formats',
          year: '2024',
          publisher: 'ECMA International',
          city: 'Geneva'
        )
        bib.journal(
          tag: 'Smith2024',
          author: ['John Smith'],
          title: 'Document Generation with Ruby',
          year: '2024',
          journal: 'Ruby Journal',
          volume: '12',
          issue: '1',
          pages: '15-30'
        )
        bib.website(
          tag: 'OOXMLSpec',
          title: 'ISO/IEC 29500 Information Technology',
          url: 'https://standards.iso.org/iso/29500',
          year: '2024'
        )
      end
      doc.bibliography_placeholder

      doc.page_break

      # --- Section 7: Special Elements ---
      doc.heading('7. Special Elements', level: 1)

      doc.heading('7.1 Horizontal Rule', level: 2)
      doc.paragraph do |p|
        p << 'Content above the rule.'
      end
      doc.horizontal_rule
      doc.paragraph do |p|
        p << 'Content below the rule.'
      end

      doc.heading('7.2 Bookmark', level: 2)
      doc.bookmark('appendix-anchor') do |p|
        p << 'This paragraph is bookmarked as "appendix-anchor".'
      end

      doc.heading('7.3 Date and Time Fields', level: 2)
      doc.paragraph { |p| p << 'Current date: ' }
      doc.date_field
      doc.paragraph { |p| p << 'Current time: ' }
      doc.time_field

      # --- Section 8: Section Break ---
      doc.page_break

      doc.heading('8. Appendix', level: 1)
      doc.paragraph do |p|
        p << 'This is the appendix section, separated by a page break.'
      end

      doc.bullet_list do |l|
        l.item('Additional resource A')
        l.item('Additional resource B')
        l.item('Additional resource C')
      end

      # --- Header/Footer ---
      doc.header do |h|
        h << ::B.text('Complete Feature Showcase', bold: true, color: '808080')
        h << ::B.tab
        h << ::B.text('CONFIDENTIAL', color: 'CC0000')
      end

      doc.footer do |f|
        f << 'Page '
        f << ::B.page_number_field
        f << ' of '
        f << ::B.total_pages_field
        f << ::B.tab
        f << 'Generated by Uniword'
      end

      # --- Section Properties ---
      doc.section do |s|
        s.page_size(width: 12240, height: 15840)
        s.margins(top: 1440, bottom: 1440, left: 1440, right: 1440)
        s.page_numbering(start: 1)
      end

      doc.save(path)
    end

    it 'creates a valid DOCX file' do
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0
    end

    it 'contains all section headings' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Text Formatting')
        expect(doc_xml).to include('Lists')
        expect(doc_xml).to include('Tables')
        expect(doc_xml).to include('Charts')
        expect(doc_xml).to include('Hyperlinks')
        expect(doc_xml).to include('References')
        expect(doc_xml).to include('Special Elements')
        expect(doc_xml).to include('Appendix')
      end
    end

    it 'contains formatted text' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('bold')
        expect(doc_xml).to include('italic')
        expect(doc_xml).to include('underline')
      end
    end

    it 'contains bullet list items with numPr' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('numPr')
        expect(doc_xml).to include('Comprehensive OOXML model coverage')
      end
    end

    it 'contains table data' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Revenue')
        expect(doc_xml).to include('$1.2M')
        expect(doc_xml).to include('2E5090')
      end
    end

    it 'contains charts' do
      Zip::File.open(path) do |zip|
        chart_entries = zip.glob('word/charts/*')
        expect(chart_entries.size).to be >= 2
      end
    end

    it 'contains hyperlinks' do
      Zip::File.open(path) do |zip|
        rels = zip.read('word/_rels/document.xml.rels')
        expect(rels).to include('http')
      end
    end

    it 'contains bibliography' do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry('word/sources.xml')).not_to be_nil
      end
    end

    it 'contains header and footer in ZIP' do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry('word/header1.xml')).not_to be_nil
        expect(zip.find_entry('word/footer1.xml')).not_to be_nil

        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('headerReference')
        expect(doc_xml).to include('footerReference')
      end
    end

    it 'has content types for all parts' do
      Zip::File.open(path) do |zip|
        ct = zip.read('[Content_Types].xml')
        expect(ct).to include('wordprocessingml.document')
        expect(ct).to include('wordprocessingml.header')
        expect(ct).to include('wordprocessingml.footer')
        expect(ct).to include('drawingml.chart')
        expect(ct).to include('bibliography')
      end
    end

    it 'has correct metadata' do
      Zip::File.open(path) do |zip|
        core = zip.read('docProps/core.xml')
        expect(core).to include('Complete Feature Showcase')
        expect(core).to include('Jane Doe')
        expect(core).to match(/\d{4}-\d{2}-\d{2}/)
      end
    end
  end

  # =========================================================================
  # Example 3: Themed Document — Multiple Themes
  # =========================================================================
  describe 'themed_multi.docx' do
    let(:path) { File.join(OUTPUT_DIR, 'themed_multi.docx') }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Themed Document')
      doc.author('Uniword')

      # Apply the celestial theme
      doc.theme('celestial') do |t|
        t.fonts(minor: 'Calibri')
      end

      doc.heading('Celestial Theme Demo', level: 1)
      doc.paragraph do |p|
        p << 'This document uses the Celestial theme. '
        p << 'The color scheme and fonts are applied from the theme.'
      end

      doc.heading('Styled Content', level: 2)
      doc.paragraph do |p|
        p << 'Paragraphs inherit theme fonts and colors. '
        p << ::B.text('This text uses explicit formatting.', bold: true, color: '0070C0')
      end

      doc.bullet_list do |l|
        l.item('Theme-driven bullet 1')
        l.item('Theme-driven bullet 2')
        l.item('Theme-driven bullet 3')
      end

      doc.table do |t|
        t.row do |r|
          r.cell(text: 'Feature') { |c| c.shading(fill: '0070C0', color: 'FFFFFF') }
          r.cell(text: 'Value') { |c| c.shading(fill: '0070C0', color: 'FFFFFF') }
        end
        t.row do |r|
          r.cell(text: 'Theme')
          r.cell(text: 'Celestial')
        end
        t.row do |r|
          r.cell(text: 'Font')
          r.cell(text: 'Calibri')
        end
      end

      doc.save(path)
    end

    it 'creates a valid DOCX with theme' do
      expect(File.exist?(path)).to be(true)
      Zip::File.open(path) do |zip|
        expect(zip.find_entry('word/theme/theme1.xml')).not_to be_nil

        theme_xml = zip.read('word/theme/theme1.xml')
        expect(theme_xml).not_to be_empty
      end
    end

    it 'contains document content' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Celestial Theme Demo')
        expect(doc_xml).to include('Styled Content')
      end
    end

    it 'contains bullet list' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Theme-driven bullet')
        expect(doc_xml).to include('numPr')
      end
    end

    it 'contains table' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Celestial')
      end
    end
  end

  # =========================================================================
  # Example 4: Theme with Custom Colors
  # =========================================================================
  describe 'themed_custom_colors.docx' do
    let(:path) { File.join(OUTPUT_DIR, 'themed_custom_colors.docx') }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Custom Theme Colors')
      doc.author('Uniword')

      # Apply theme with custom color overrides
      doc.theme('office_theme') do |t|
        t.colors(accent1: '1F4E79', accent2: '2E75B6', accent3: '9DC3E6')
        t.fonts(major: 'Georgia', minor: 'Calibri')
      end

      doc.heading('Custom Theme', level: 1)
      doc.paragraph do |p|
        p << 'This document uses the Office theme with custom accent colors '
        p << 'and Georgia/Calibri font pairing.'
      end

      doc.heading('Color Samples', level: 2)
      doc.paragraph do |p|
        p << ::B.text('Accent 1 Color', bold: true, color: '1F4E79')
        p << ' — Dark blue'
      end
      doc.paragraph do |p|
        p << ::B.text('Accent 2 Color', bold: true, color: '2E75B6')
        p << ' — Medium blue'
      end
      doc.paragraph do |p|
        p << ::B.text('Accent 3 Color', bold: true, color: '9DC3E6')
        p << ' — Light blue'
      end

      doc.numbered_list do |l|
        l.item('First numbered item')
        l.item('Second numbered item')
        l.item('Third numbered item')
      end

      doc.save(path)
    end

    it 'creates a valid DOCX with theme' do
      expect(File.exist?(path)).to be(true)
      Zip::File.open(path) do |zip|
        expect(zip.find_entry('word/theme/theme1.xml')).not_to be_nil
      end
    end

    it 'contains custom formatted text' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('1F4E79')
        expect(doc_xml).to include('2E75B6')
        expect(doc_xml).to include('9DC3E6')
      end
    end

    it 'contains numbered list' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('numPr')
        expect(doc_xml).to include('First numbered item')
      end
    end
  end

  # =========================================================================
  # Example 5: Multi-Section Document with Sections
  # =========================================================================
  describe 'multi_section_complete.docx' do
    let(:path) { File.join(OUTPUT_DIR, 'multi_section_complete.docx') }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Multi-Section Report')
      doc.author('Uniword')

      # --- Cover Page ---
      doc.paragraph do |p|
        p.style = 'Title'
        p << 'Annual Report 2026'
      end
      doc.paragraph do |p|
        p << 'Prepared by Uniword'
      end
      doc.paragraph do |p|
        p << 'March 26, 2026'
      end

      doc.page_break

      # --- TOC ---
      doc.toc(title: 'Table of Contents')
      doc.page_break

      # --- Executive Summary ---
      doc.heading('Executive Summary', level: 1)
      doc.paragraph do |p|
        p << 'This report provides a comprehensive overview of the organization\'s '
        p << 'performance throughout 2026. Key highlights include:'
      end

      doc.bullet_list do |l|
        l.item('Revenue growth of 35% year-over-year')
        l.item('User base expanded to 25,000 active users')
        l.item('NPS score improved to 85')
        l.item('Three new product launches')
      end

      doc.page_break

      # --- Financial Section ---
      doc.heading('1. Financial Performance', level: 1)
      doc.paragraph do |p|
        p << 'The financial performance exceeded expectations across all metrics.'
      end

      doc.heading('1.1 Revenue Breakdown', level: 2)
      doc.table do |t|
        t.row do |r|
          r.cell(text: 'Category') { |c| c.shading(fill: '1F4E79', color: 'FFFFFF') }
          r.cell(text: 'Amount') { |c| c.shading(fill: '1F4E79', color: 'FFFFFF') }
          r.cell(text: '% of Total') { |c| c.shading(fill: '1F4E79', color: 'FFFFFF') }
        end
        t.row do |r|
          r.cell(text: 'Subscriptions')
          r.cell(text: '$4.2M')
          r.cell(text: '60%')
        end
        t.row do |r|
          r.cell(text: 'Enterprise')
          r.cell(text: '$2.1M')
          r.cell(text: '30%')
        end
        t.row do |r|
          r.cell(text: 'Services')
          r.cell(text: '$0.7M')
          r.cell(text: '10%')
        end
        t.row do |r|
          r.cell(text: 'Total')
          r.cell(text: '$7.0M')
          r.cell(text: '100%')
        end
      end

      doc.heading('1.2 Revenue Chart', level: 2)
      doc.chart(type: :bar) do |c|
        c.title('Revenue by Category ($M)')
        c.categories(['Subscriptions', 'Enterprise', 'Services'])
        c.series('2026 Revenue', data: [4.2, 2.1, 0.7])
      end

      doc.page_break

      # --- Product Section ---
      doc.heading('2. Product Development', level: 1)
      doc.paragraph do |p|
        p << 'Three major product launches drove growth in 2026.'
      end

      doc.numbered_list do |l|
        l.item('Uniword Pro — Professional document generation')
        l.item('Uniword Cloud — Cloud-based document processing')
        l.item('Uniword API — RESTful API for document operations')
      end

      doc.heading('2.1 User Growth', level: 2)
      doc.chart(type: :line) do |c|
        c.title('Monthly Active Users (K)')
        c.categories(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
        c.series('MAU', data: [10, 11, 12, 14, 15, 17, 18, 20, 22, 23, 24, 25])
      end

      doc.page_break

      # --- References ---
      doc.heading('3. References', level: 1)
      doc.bibliography(style: 'APA') do |bib|
        bib.book(
          tag: 'Annual2026',
          author: ['Uniword Inc.'],
          title: 'Annual Report 2026',
          year: '2026',
          publisher: 'Uniword Inc.',
          city: 'San Francisco'
        )
      end
      doc.bibliography_placeholder

      # --- Header/Footer ---
      doc.header do |h|
        h << ::B.text('Annual Report 2026', bold: true, color: '808080')
      end

      doc.footer do |f|
        f << 'Page '
        f << ::B.page_number_field
        f << ' of '
        f << ::B.total_pages_field
      end

      # --- Section Properties ---
      doc.section do |s|
        s.page_size(width: 12240, height: 15840)
        s.margins(top: 1440, bottom: 1440, left: 1440, right: 1440)
      end

      doc.save(path)
    end

    it 'creates a valid multi-section DOCX' do
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0
    end

    it 'contains all major sections' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Executive Summary')
        expect(doc_xml).to include('Financial Performance')
        expect(doc_xml).to include('Product Development')
        expect(doc_xml).to include('References')
      end
    end

    it 'contains both bullet and numbered lists' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Revenue growth')
        expect(doc_xml).to include('Uniword Pro')
      end
    end

    it 'contains table with financial data' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('$4.2M')
        expect(doc_xml).to include('$7.0M')
      end
    end

    it 'contains charts' do
      Zip::File.open(path) do |zip|
        chart_entries = zip.glob('word/charts/*')
        expect(chart_entries.size).to be >= 2
      end
    end

    it 'contains header/footer' do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry('word/header1.xml')).not_to be_nil
        expect(zip.find_entry('word/footer1.xml')).not_to be_nil

        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('headerReference')
        expect(doc_xml).to include('footerReference')
      end
    end

    it 'contains bibliography' do
      Zip::File.open(path) do |zip|
        expect(zip.find_entry('word/sources.xml')).not_to be_nil
      end
    end
  end

  # =========================================================================
  # Example 6: Document Manipulation (Load → Modify → Save)
  # =========================================================================
  describe 'manipulation_load_modify.docx' do
    let(:original_path) { File.join(OUTPUT_DIR, 'manipulation_load_modify_original.docx') }
    let(:modified_path) { File.join(OUTPUT_DIR, 'manipulation_load_modify_modified.docx') }

    before do
      # Create original document
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Original Document')
      doc.author('Original Author')
      doc.heading('Original Title', level: 1)
      doc.paragraph { |p| p << 'Original paragraph 1.' }
      doc.paragraph { |p| p << 'Original paragraph 2.' }
      doc.bullet_list do |l|
        l.item('Original bullet A')
        l.item('Original bullet B')
      end
      doc.save(original_path)

      # Load and modify
      doc2 = Uniword::Builder::DocumentBuilder.from_file(original_path)
      doc2.title('Modified Document')
      doc2.author('New Author')
      doc2.paragraph do |p|
        p << 'Appended paragraph with '
        p << ::B.text('formatted text', bold: true, color: 'FF0000')
        p << '.'
      end
      doc2.bullet_list do |l|
        l.item('New bullet 1')
        l.item('New bullet 2')
        l.item('New bullet 3')
      end
      doc2.save(modified_path)
    end

    it 'creates original and modified documents' do
      expect(File.exist?(original_path)).to be(true)
      expect(File.exist?(modified_path)).to be(true)
    end

    it 'modified document has new metadata' do
      Zip::File.open(modified_path) do |zip|
        core = zip.read('docProps/core.xml')
        expect(core).to include('Modified Document')
        expect(core).to include('New Author')
      end
    end

    it 'modified document contains original content' do
      Zip::File.open(modified_path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Original paragraph 1')
        expect(doc_xml).to include('Original paragraph 2')
        expect(doc_xml).to include('Original bullet A')
      end
    end

    it 'modified document contains appended content' do
      Zip::File.open(modified_path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Appended paragraph')
        expect(doc_xml).to include('formatted text')
        expect(doc_xml).to include('FF0000')
      end
    end

    it 'modified document contains new bullet list' do
      Zip::File.open(modified_path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('New bullet 1')
        expect(doc_xml).to include('New bullet 3')
      end
    end
  end

  # =========================================================================
  # Example 7: Styleset Application
  # =========================================================================
  describe 'styleset_formal.docx' do
    let(:path) { File.join(OUTPUT_DIR, 'styleset_formal.docx') }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Formal Styleset Document')
      doc.author('Uniword')
      doc.apply_styleset('formal')

      doc.heading('Formal Document', level: 1)
      doc.paragraph do |p|
        p << 'This document uses the formal styleset for a professional appearance. '
        p << 'The styleset defines consistent formatting for headings, paragraphs, '
        p << 'and other elements.'
      end

      doc.heading('Introduction', level: 1)
      doc.paragraph do |p|
        p << 'The formal styleset provides elegant typography and spacing suitable '
        p << 'for business documents, reports, and academic papers.'
      end

      doc.heading('Body Text', level: 2)
      doc.paragraph do |p|
        p << 'Body text in the formal styleset uses a serif font with generous '
        p << 'line spacing for optimal readability. Paragraph spacing is set to '
        p << 'provide clear visual separation between sections.'
      end

      doc.bullet_list do |l|
        l.item('Professional typography')
        l.item('Consistent spacing')
        l.item('Elegant color palette')
      end

      doc.save(path)
    end

    it 'creates a valid DOCX with styles' do
      expect(File.exist?(path)).to be(true)
      Zip::File.open(path) do |zip|
        styles_xml = zip.read('word/styles.xml')
        expect(styles_xml).not_to be_empty
      end
    end

    it 'contains document content' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Formal Document')
        expect(doc_xml).to include('Professional typography')
      end
    end

    it 'contains bullet list' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('numPr')
      end
    end
  end

  # =========================================================================
  # Example 8: Watermark Document
  # =========================================================================
  describe 'watermark.docx' do
    let(:path) { File.join(OUTPUT_DIR, 'watermark.docx') }

    before do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title('Watermark Demo')
      doc.author('Uniword')

      doc.watermark('DRAFT', font: 'Calibri', size: 72, color: 'D0D0D0', opacity: '0.3')

      doc.heading('Watermark Demo', level: 1)
      doc.paragraph do |p|
        p << 'This document has a "DRAFT" watermark applied to the header. '
        p << 'The watermark appears on every page as a semi-transparent text.'
      end

      doc.paragraph do |p|
        p << 'Watermarks are useful for indicating document status: '
        p << 'DRAFT, CONFIDENTIAL, FINAL, etc.'
      end

      doc.save(path)
    end

    it 'creates a valid DOCX with watermark' do
      expect(File.exist?(path)).to be(true)
      Zip::File.open(path) do |zip|
        expect(zip.find_entry('word/header1.xml')).not_to be_nil

        header_xml = zip.read('word/header1.xml')
        # Watermark uses VML shape inside w:pict
        expect(header_xml).to include('pict')
      end
    end

    it 'contains document content' do
      Zip::File.open(path) do |zip|
        doc_xml = zip.read('word/document.xml')
        expect(doc_xml).to include('Watermark Demo')
      end
    end
  end

  # Summary test removed — depends on file-generating examples
  # having run first, which is not guaranteed under random ordering.
end
