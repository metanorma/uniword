# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Docx.js Compatibility: Page Setup', :compatibility do
  describe 'Page Margins' do
    describe 'zero margins' do
      it 'should support setting all margins to zero' do
        doc = Uniword::Document.new

        doc.sections.first.page_margins = {
          top: 0,
          right: 0,
          bottom: 0,
          left: 0
        }

        margins = doc.sections.first.page_margins
        expect(margins[:top]).to eq(0)
        expect(margins[:right]).to eq(0)
        expect(margins[:bottom]).to eq(0)
        expect(margins[:left]).to eq(0)
      end

      it 'should allow content with zero margins' do
        doc = Uniword::Document.new

        doc.sections.first.page_margins = {
          top: 0,
          right: 0,
          bottom: 0,
          left: 0
        }

        doc.add_paragraph('Hello World')
        doc.add_paragraph('Foo bar', bold: true)
        doc.add_paragraph('Github is the best')

        expect(doc.paragraphs.count).to eq(3)
        expect(doc.sections.first.page_margins[:top]).to eq(0)
      end
    end

    describe 'custom margins' do
      it 'should support setting custom margins in twips' do
        skip 'Custom margin values not yet fully implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_margins = {
          top: 1440,     # 1 inch
          right: 720,    # 0.5 inch
          bottom: 1440,  # 1 inch
          left: 720      # 0.5 inch
        }

        margins = doc.sections.first.page_margins
        expect(margins[:top]).to eq(1440)
        expect(margins[:right]).to eq(720)
        expect(margins[:bottom]).to eq(1440)
        expect(margins[:left]).to eq(720)
      end

      it 'should support setting gutter margin' do
        skip 'Gutter margins not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_margins = {
          top: 1440,
          right: 1440,
          bottom: 1440,
          left: 1440,
          gutter: 720 # Additional left margin for binding
        }

        expect(doc.sections.first.page_margins[:gutter]).to eq(720)
      end
    end
  end

  describe 'Page Borders' do
    describe 'border configuration' do
      it 'should support page borders' do
        skip 'Page borders not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_borders = {
          top: { style: 'single', size: 24, color: '000000' },
          right: { style: 'single', size: 24, color: '000000' },
          bottom: { style: 'single', size: 24, color: '000000' },
          left: { style: 'single', size: 24, color: '000000' }
        }

        borders = doc.sections.first.page_borders
        expect(borders[:top]).not_to be_nil
        expect(borders[:right]).not_to be_nil
        expect(borders[:bottom]).not_to be_nil
        expect(borders[:left]).not_to be_nil
      end

      it 'should support different border styles' do
        skip 'Border styles not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_borders = {
          top: { style: 'double', size: 12 },
          bottom: { style: 'dashed', size: 6 }
        }

        borders = doc.sections.first.page_borders
        expect(borders[:top][:style]).to eq('double')
        expect(borders[:bottom][:style]).to eq('dashed')
      end

      it 'should support border colors' do
        skip 'Border colors not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_borders = {
          top: { style: 'single', color: 'FF0000' },    # Red
          bottom: { style: 'single', color: '0000FF' }  # Blue
        }

        borders = doc.sections.first.page_borders
        expect(borders[:top][:color]).to eq('FF0000')
        expect(borders[:bottom][:color]).to eq('0000FF')
      end

      it 'should support border sizes' do
        skip 'Border sizing not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_borders = {
          top: { style: 'single', size: 48 },    # Thick
          bottom: { style: 'single', size: 6 }   # Thin
        }

        borders = doc.sections.first.page_borders
        expect(borders[:top][:size]).to eq(48)
        expect(borders[:bottom][:size]).to eq(6)
      end
    end

    describe 'partial borders' do
      it 'should support top border only' do
        skip 'Partial borders not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_borders = {
          top: { style: 'single', size: 24 }
        }

        borders = doc.sections.first.page_borders
        expect(borders[:top]).not_to be_nil
        expect(borders[:bottom]).to be_nil
      end

      it 'should support left and right borders only' do
        skip 'Partial borders not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_borders = {
          left: { style: 'single', size: 24 },
          right: { style: 'single', size: 24 }
        }

        borders = doc.sections.first.page_borders
        expect(borders[:left]).not_to be_nil
        expect(borders[:right]).not_to be_nil
        expect(borders[:top]).to be_nil
        expect(borders[:bottom]).to be_nil
      end
    end

    describe 'border offsets' do
      it 'should support border offset from page edge' do
        skip 'Border offsets not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_borders = {
          top: { style: 'single', size: 24, offset: 48 }
        }

        border = doc.sections.first.page_borders[:top]
        expect(border[:offset]).to eq(48)
      end
    end
  end

  describe 'Page Size' do
    describe 'standard page sizes' do
      it 'should support letter size (default)' do
        skip 'Page size configuration not yet implemented'

        doc = Uniword::Document.new

        # Default should be letter size
        page = doc.sections.first.page_size
        expect(page[:width]).to eq(12_240)   # 8.5 inches in twips
        expect(page[:height]).to eq(15_840)  # 11 inches in twips
      end

      it 'should support A4 size' do
        skip 'Page size configuration not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_size = {
          width: 11_906,   # A4 width in twips
          height: 16_838   # A4 height in twips
        }

        page = doc.sections.first.page_size
        expect(page[:width]).to eq(11_906)
        expect(page[:height]).to eq(16_838)
      end

      it 'should support legal size' do
        skip 'Page size configuration not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_size = {
          width: 12_240,   # 8.5 inches
          height: 20_160   # 14 inches
        }

        page = doc.sections.first.page_size
        expect(page[:height]).to eq(20_160)
      end
    end

    describe 'custom page sizes' do
      it 'should support custom page dimensions' do
        skip 'Custom page sizes not yet implemented'

        doc = Uniword::Document.new

        doc.sections.first.page_size = {
          width: 10_000,
          height: 15_000
        }

        page = doc.sections.first.page_size
        expect(page[:width]).to eq(10_000)
        expect(page[:height]).to eq(15_000)
      end
    end
  end

  describe 'Page Orientation' do
    it 'should support portrait orientation (default)' do
      skip 'Page orientation not yet implemented'

      doc = Uniword::Document.new

      expect(doc.sections.first.orientation).to eq(:portrait)
    end

    it 'should support landscape orientation' do
      skip 'Page orientation not yet implemented'

      doc = Uniword::Document.new

      doc.sections.first.orientation = :landscape

      expect(doc.sections.first.orientation).to eq(:landscape)

      # In landscape, width and height are swapped
      page = doc.sections.first.page_size
      expect(page[:width]).to be > page[:height]
    end
  end

  describe 'Page Columns' do
    it 'should support single column (default)' do
      skip 'Column configuration not yet implemented'

      doc = Uniword::Document.new

      expect(doc.sections.first.columns).to eq(1)
    end

    it 'should support multiple columns' do
      skip 'Column configuration not yet implemented'

      doc = Uniword::Document.new

      doc.sections.first.columns = 2

      expect(doc.sections.first.columns).to eq(2)
    end

    it 'should support column spacing' do
      skip 'Column spacing not yet implemented'

      doc = Uniword::Document.new

      doc.sections.first.columns = {
        count: 2,
        spacing: 720 # 0.5 inch between columns
      }

      expect(doc.sections.first.columns[:count]).to eq(2)
      expect(doc.sections.first.columns[:spacing]).to eq(720)
    end
  end

  describe 'Integration with content' do
    it 'should apply page setup to content correctly' do
      doc = Uniword::Document.new

      # Configure page
      doc.sections.first.page_margins = {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
      }

      # Add various content types
      doc.add_paragraph('Hello World')
      doc.add_paragraph('Foo bar') do |para|
        para.add_run('Foo bar', bold: true)
      end
      doc.add_paragraph('Github is the best', heading: :heading_1)

      expect(doc.paragraphs.count).to eq(3)
      expect(doc.sections.first.page_margins[:top]).to eq(0)
    end

    it 'should support tabs with zero margins' do
      skip 'Tab support not yet fully implemented'

      doc = Uniword::Document.new

      doc.sections.first.page_margins = {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
      }

      doc.add_paragraph do |para|
        para.add_run('Hello World')
        para.add_run do |run|
          run.add_tab
          run.add_text('Github is the best')
          run.bold = true
        end
      end

      para = doc.paragraphs.first
      expect(para.runs.count).to be > 0
    end
  end

  describe 'Multiple sections' do
    it 'should support different page setup per section' do
      skip 'Multiple sections not yet fully implemented'

      doc = Uniword::Document.new

      # First section with zero margins
      doc.sections[0].page_margins = {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
      }

      # Add new section with normal margins
      doc.add_section do |section|
        section.page_margins = {
          top: 1440,
          right: 1440,
          bottom: 1440,
          left: 1440
        }
      end

      expect(doc.sections.count).to eq(2)
      expect(doc.sections[0].page_margins[:top]).to eq(0)
      expect(doc.sections[1].page_margins[:top]).to eq(1440)
    end
  end

  describe 'Round-trip preservation' do
    it 'should preserve page margins in round-trip' do
      skip 'Round-trip testing requires full implementation'

      # Create document with custom margins
      original = Uniword::Document.new
      original.sections.first.page_margins = {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
      }
      original.add_paragraph('Test content')

      # Save and reload
      temp_path = '/tmp/page_setup_test.docx'
      original.save(temp_path)
      reloaded = Uniword.load(temp_path)

      # Verify margins preserved
      margins = reloaded.sections.first.page_margins
      expect(margins[:top]).to eq(0)
      expect(margins[:right]).to eq(0)
      expect(margins[:bottom]).to eq(0)
      expect(margins[:left]).to eq(0)
    end
  end
end
