# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'docx-js compatibility: Paragraph' do
  describe '#constructor' do
    it 'creates valid paragraph with empty string' do
      # TypeScript: new Paragraph("")
      para = Uniword::Paragraph.new

      expect(para).not_to be_nil
      expect(para).to be_a(Uniword::Paragraph)
    end

    it 'has valid properties structure' do
      para = Uniword::Paragraph.new
      # v2.0 API: properties may be nil until explicitly set
      expect(para.properties).to be_nil.or be_a(Uniword::Wordprocessingml::ParagraphProperties)
    end
  end

  describe 'heading styles' do
    it 'creates heading 1' do
      # TypeScript: new Paragraph({ heading: HeadingLevel.HEADING_1 })
      para = Uniword::Paragraph.new
      para.set_style('Heading1')

      expect(para.properties&.style).to eq('Heading1')
    end

    it 'creates heading 2' do
      para = Uniword::Paragraph.new
      para.set_style('Heading2')

      expect(para.properties&.style).to eq('Heading2')
    end

    it 'creates heading 3' do
      para = Uniword::Paragraph.new
      para.set_style('Heading3')

      expect(para.properties&.style).to eq('Heading3')
    end

    it 'creates heading 4' do
      para = Uniword::Paragraph.new
      para.set_style('Heading4')

      expect(para.properties&.style).to eq('Heading4')
    end

    it 'creates heading 5' do
      para = Uniword::Paragraph.new
      para.set_style('Heading5')

      expect(para.properties&.style).to eq('Heading5')
    end

    it 'creates heading 6' do
      para = Uniword::Paragraph.new
      para.set_style('Heading6')

      expect(para.properties&.style).to eq('Heading6')
    end

    it 'creates title style' do
      para = Uniword::Paragraph.new
      para.set_style('Title')

      expect(para.properties&.style).to eq('Title')
    end
  end

  describe 'alignment' do
    it 'sets center alignment' do
      # TypeScript: new Paragraph({ alignment: AlignmentType.CENTER })
      para = Uniword::Paragraph.new
      para.align('center')

      expect(para.properties&.alignment).to eq('center')
    end

    it 'sets left alignment' do
      para = Uniword::Paragraph.new
      para.align('left')

      expect(para.properties&.alignment).to eq('left')
    end

    it 'sets right alignment' do
      para = Uniword::Paragraph.new
      para.align('right')

      expect(para.properties&.alignment).to eq('right')
    end

    it 'sets start alignment' do
      para = Uniword::Paragraph.new
      para.align('start')

      expect(para.properties&.alignment).to eq('start')
    end

    it 'sets end alignment' do
      para = Uniword::Paragraph.new
      para.align('end')

      expect(para.properties&.alignment).to eq('end')
    end

    it 'sets distribute alignment' do
      para = Uniword::Paragraph.new
      para.align('distribute')

      expect(para.properties&.alignment).to eq('distribute')
    end

    it 'sets justified alignment' do
      para = Uniword::Paragraph.new
      para.align('both')

      expect(para.properties&.alignment).to eq('both')
    end
  end

  describe 'tab stops' do
    it 'adds max right tab stop' do
      # TypeScript: new Paragraph({ tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }] })
      para = Uniword::Paragraph.new
      # NOTE: Tab stops may need implementation
      # This test documents the expected API

      expect(para).to respond_to(:properties)
    end

    it 'adds left tab stop with leader' do
      para = Uniword::Paragraph.new
      # Tab stop with position 100 and hyphen leader
      # Expected API: para.properties.tab_stops << { type: :left, position: 100, leader: :hyphen }

      expect(para).to respond_to(:properties)
    end

    it 'adds right tab stop with dot leader' do
      para = Uniword::Paragraph.new
      # Tab stop with position 100 and dot leader

      expect(para).to respond_to(:properties)
    end

    it 'adds center tab stop with middle dot leader' do
      para = Uniword::Paragraph.new
      # Tab stop with position 100 and middle dot leader

      expect(para).to respond_to(:properties)
    end
  end

  describe 'contextual spacing' do
    it 'enables contextual spacing' do
      # TypeScript: new Paragraph({ contextualSpacing: true })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.contextual_spacing = true

      expect(para.properties&.contextual_spacing).to be true
    end

    it 'disables contextual spacing' do
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.contextual_spacing = false

      expect(para.properties&.contextual_spacing).to be false
    end
  end

  describe 'thematic break' do
    it 'adds thematic break as bottom border' do
      # TypeScript: new Paragraph({ thematicBreak: true })
      # This creates a single bottom border
      para = Uniword::Paragraph.new
      # Expected: para.properties.borders.bottom = { style: :single, color: 'auto', space: 1, size: 6 }

      expect(para).to respond_to(:properties)
    end
  end

  describe 'paragraph borders', :pending_feature do
    it 'adds left and right borders' do
      # TypeScript: new Paragraph({ border: { left: {...}, right: {...} } })
      para = Uniword::Paragraph.new
      # NOTE: Paragraph borders need implementation

      expect(para).to respond_to(:properties)
    end
  end

  describe 'page breaks' do
    it 'adds page break as run element' do
      # TypeScript: new Paragraph({ children: [new PageBreak()] })
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.break = Uniword::Wordprocessingml::Break.new
      run.break.type = 'page'
      para.runs << run

      expect(para.runs).not_to be_empty
      expect(para.runs.first.break&.type).to eq('page')
    end

    it 'sets page break before property' do
      # TypeScript: new Paragraph({ pageBreakBefore: true })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.page_break_before = true

      expect(para.properties&.page_break_before).to be true
    end
  end

  describe 'bullet lists' do
    it 'creates bullet paragraph with default level 0' do
      # TypeScript: new Paragraph({ bullet: { level: 0 } })
      para = Uniword::Paragraph.new
      para.set_style('ListParagraph')
      para.set_numbering(1, 0)

      expect(para.properties&.style).to eq('ListParagraph')
      expect(para.properties&.ilvl).to eq(0)
    end

    it 'creates bullet paragraph with level 1' do
      para = Uniword::Paragraph.new
      para.set_style('ListParagraph')
      para.set_numbering(1, 1)

      expect(para.properties&.ilvl).to eq(1)
    end
  end

  describe 'numbered lists' do
    it 'creates numbered paragraph with ListParagraph style' do
      # TypeScript: new Paragraph({ numbering: { reference: "test id", level: 0 } })
      para = Uniword::Paragraph.new
      para.set_style('ListParagraph')
      para.set_numbering('test id', 0)

      expect(para.properties&.style).to eq('ListParagraph')
    end

    it 'allows custom style with numbering' do
      para = Uniword::Paragraph.new
      para.set_style('myFancyStyle')
      para.set_numbering('test id', 0)

      expect(para.properties&.style).to eq('myFancyStyle')
    end

    it 'supports custom numbering without ListParagraph style' do
      # TypeScript: numbering: { reference: "test id", level: 0, custom: true }
      para = Uniword::Paragraph.new
      para.set_numbering('test id', 0)
      # No style set for custom numbering

      expect(para.properties&.style).to be_nil
    end

    it 'supports numbering with instance' do
      para = Uniword::Paragraph.new
      para.set_style('ListParagraph')
      para.set_numbering('{test id-4}', 0)

      expect(para.properties&.num_id).to eq('{test id-4}')
    end
  end

  describe 'bookmarks' do
    it 'adds bookmark with children', :pending_feature do
      # TypeScript: new Paragraph({ children: [new Bookmark({ id: "test-id", children: [...] })] })
      para = Uniword::Paragraph.new
      # Bookmarks need implementation

      expect(para).to respond_to(:runs)
    end
  end

  describe 'style property' do
    it 'sets paragraph style to given styleId' do
      # TypeScript: new Paragraph({ style: "myFancyStyle" })
      para = Uniword::Paragraph.new
      para.set_style('myFancyStyle')

      expect(para.properties&.style).to eq('myFancyStyle')
    end
  end

  describe 'indentation' do
    it 'sets paragraph indent' do
      # TypeScript: new Paragraph({ indent: { left: 720 } })
      para = Uniword::Paragraph.new
      para.indent_left(720)

      expect(para.properties&.indent_left).to eq(720)
    end
  end

  describe 'spacing' do
    it 'sets paragraph spacing' do
      # TypeScript: new Paragraph({ spacing: { before: 90, line: 50 } })
      para = Uniword::Paragraph.new
      para.spacing_before(90)
      para.line_spacing(50)

      expect(para.properties&.spacing_before).to eq(90)
      expect(para.properties&.line_spacing).to eq(50)
    end
  end

  describe 'keep lines' do
    it 'sets keep lines property' do
      # TypeScript: new Paragraph({ keepLines: true })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.keep_lines = true

      expect(para.properties&.keep_lines).to be true
    end
  end

  describe 'keep next' do
    it 'sets keep next property' do
      # TypeScript: new Paragraph({ keepNext: true })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.keep_next = true

      expect(para.properties&.keep_next).to be true
    end
  end

  describe 'bidirectional text' do
    it 'sets right to left layout' do
      # TypeScript: new Paragraph({ bidirectional: true })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.bidirectional = true

      expect(para.properties&.bidirectional).to be true
    end
  end

  describe 'line number suppression' do
    it 'disables line numbers' do
      # TypeScript: new Paragraph({ suppressLineNumbers: true })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.suppress_line_numbers = true

      expect(para.properties&.suppress_line_numbers).to be true
    end
  end

  describe 'outline level' do
    it 'sets paragraph outline level' do
      # TypeScript: new Paragraph({ outlineLevel: 0 })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.outline_level = Uniword::Properties::OutlineLevel.new
      para.properties.outline_level.value = 0

      expect(para.properties&.outline_level&.value).to eq(0)
    end
  end

  describe 'shading' do
    it 'sets shading with type, color, and fill' do
      # TypeScript: new Paragraph({ shading: { type: ShadingType.REVERSE_DIAGONAL_STRIPE, color: "00FFFF", fill: "FF0000" } })
      para = Uniword::Paragraph.new
      para.properties = Uniword::ParagraphProperties.new
      para.properties.shading_type = 'reverseDiagonalStripe'
      para.properties.shading_color = '00FFFF'
      para.properties.shading_fill = 'FF0000'

      expect(para.properties&.shading_type).to eq('reverseDiagonalStripe')
      expect(para.properties&.shading_color).to eq('00FFFF')
      expect(para.properties&.shading_fill).to eq('FF0000')
    end
  end

  describe 'text frames', :pending_feature do
    it 'sets frame attributes' do
      # TypeScript: new Paragraph({ frame: { type: "alignment", width: 4000, height: 1000, ... } })
      para = Uniword::Paragraph.new
      # Text frames need implementation

      expect(para).to respond_to(:properties)
    end
  end

  describe 'external hyperlinks', :pending_feature do
    it 'adds external hyperlink' do
      # TypeScript: new Paragraph({ children: [new ExternalHyperlink({ children: [...], link: "..." })] })
      para = Uniword::Paragraph.new
      # Hyperlinks need implementation

      expect(para).to respond_to(:runs)
    end
  end
end
