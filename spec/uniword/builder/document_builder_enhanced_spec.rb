# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Builder::DocumentBuilder, '#page_break' do
  it 'inserts a page break paragraph' do
    doc = described_class.new
    doc.paragraph { |p| p << 'Page 1' }
    doc.page_break
    doc.paragraph { |p| p << 'Page 2' }

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(3)

    # Middle paragraph has a page break
    break_run = paragraphs[1].runs.first
    expect(break_run.break).not_to be_nil
    expect(break_run.break.type).to eq('page')
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#toc' do
  it 'inserts TOC paragraphs' do
    doc = described_class.new
    doc.toc(title: 'Contents')

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to be >= 2

    # First paragraph is the title
    expect(paragraphs.first.text).to eq('Contents')

    # Second paragraph has field characters (TOC field)
    toc_para = paragraphs[1]
    expect(toc_para.field_chars.size).to be >= 3
    expect(toc_para.instr_text.size).to be >= 1
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#list' do
  it 'creates a bullet list' do
    doc = described_class.new
    doc.bullet_list do |l|
      l.item('First')
      l.item('Second')
      l.item('Third')
    end

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(3)

    # All paragraphs have numbering
    paragraphs.each do |p|
      expect(p.properties&.numbering_properties).not_to be_nil
    end
  end

  it 'creates a numbered list' do
    doc = described_class.new
    doc.numbered_list do |l|
      l.item('Step 1')
      l.item('Step 2')
      l.item('Step 3')
    end

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(3)
    paragraphs.each do |p|
      expect(p.properties&.numbering_properties).not_to be_nil
    end
  end

  it 'supports nested list levels' do
    doc = described_class.new
    doc.numbered_list do |l|
      l.item('Item 1')
      l.item('Sub-item', level: 1)
      l.item('Sub-item 2', level: 1)
      l.item('Item 2')
    end

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(4)

    # First and last are level 0, middle two are level 1
    expect(paragraphs[0].properties&.numbering_properties&.ilvl&.value).to eq(0)
    expect(paragraphs[1].properties&.numbering_properties&.ilvl&.value).to eq(1)
    expect(paragraphs[2].properties&.numbering_properties&.ilvl&.value).to eq(1)
    expect(paragraphs[3].properties&.numbering_properties&.ilvl&.value).to eq(0)
  end

  it 'supports rich formatting in list items' do
    doc = described_class.new
    doc.bullet_list do |l|
      l.item('Plain')
      l.item do |p|
        p << Uniword::Builder.text('Bold', bold: true)
        p << ' and normal'
      end
    end

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(2)

    # Second item has bold run
    second_runs = paragraphs[1].runs
    expect(second_runs.size).to be >= 2
    expect(second_runs.first.properties&.bold&.value).to eq(true)
  end

  it 'supports :roman list type' do
    doc = described_class.new
    doc.list(type: :roman) do |l|
      l.item('I')
      l.item('II')
    end

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(2)
    expect(paragraphs[0].properties&.numbering_properties).not_to be_nil
  end

  it 'supports :letter list type' do
    doc = described_class.new
    doc.list(type: :letter) do |l|
      l.item('A')
      l.item('B')
    end

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(2)
    expect(paragraphs[0].properties&.numbering_properties).not_to be_nil
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#bookmark' do
  it 'creates a bookmark around content' do
    doc = described_class.new
    doc.bookmark('intro') { |p| p << 'Introduction text' }

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(1)

    para = paragraphs.first
    expect(para.bookmark_starts.size).to eq(1)
    expect(para.bookmark_ends.size).to eq(1)
    expect(para.bookmark_starts.first.name).to eq('intro')
    expect(para.bookmark_starts.first.id).to eq(para.bookmark_ends.first.id)
    expect(para.text).to eq('Introduction text')
  end

  it 'assigns unique IDs to multiple bookmarks' do
    doc = described_class.new
    doc.bookmark('a') { |p| p << 'A' }
    doc.bookmark('b') { |p| p << 'B' }

    starts = doc.model.body.paragraphs.flat_map(&:bookmark_starts)
    ids = starts.map(&:id)
    expect(ids.uniq.size).to eq(2)
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#theme' do
  it 'applies a bundled theme by name' do
    doc = described_class.new
    doc.theme('atlas')

    expect(doc.model.theme).not_to be_nil
  end

  it 'accepts a block for customization' do
    doc = described_class.new
    result = doc.theme('atlas') { |t| t.available }

    expect(result).to be_a(Uniword::Builder::ThemeBuilder)
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, 'metadata methods' do
  it 'sets title' do
    doc = described_class.new
    doc.title('My Document')
    expect(doc.model.core_properties.title).to eq('My Document')
  end

  it 'sets author' do
    doc = described_class.new
    doc.author('John Doe')
    expect(doc.model.core_properties.creator).to eq('John Doe')
  end

  it 'sets subject' do
    doc = described_class.new
    doc.subject('Test Subject')
    expect(doc.model.core_properties.subject).to eq('Test Subject')
  end

  it 'sets keywords' do
    doc = described_class.new
    doc.keywords('ruby, docx, builder')
    expect(doc.model.core_properties.keywords).to eq('ruby, docx, builder')
  end

  it 'chains metadata methods' do
    doc = described_class.new
    result = doc.title('T').author('A').subject('S')
    expect(result).to eq(doc)
    expect(doc.model.core_properties.title).to eq('T')
    expect(doc.model.core_properties.creator).to eq('A')
    expect(doc.model.core_properties.subject).to eq('S')
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#section with type' do
  it 'sets section break type' do
    doc = described_class.new
    doc.section(type: 'continuous') do |s|
      s.margins(top: 720)
    end

    expect(doc.model.body.section_properties.type).to eq('continuous')
  end

  it 'sets page numbering on section' do
    doc = described_class.new
    doc.section do |s|
      s.page_numbering(start: 1, format: 'lowerRoman')
    end

    pn = doc.model.body.section_properties.page_numbering
    expect(pn.start).to eq(1)
    expect(pn.format).to eq('lowerRoman')
  end
end

RSpec.describe Uniword::Builder, 'field factories' do
  describe '.page_number_field' do
    it 'creates a paragraph with PAGE field' do
      para = described_class.page_number_field
      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(para.field_chars.size).to eq(3)
      expect(para.field_chars[0].fldCharType).to eq('begin')
      expect(para.field_chars[1].fldCharType).to eq('separate')
      expect(para.field_chars[2].fldCharType).to eq('end')

      instruction = para.instr_text.first
      expect(instruction.text).to include('PAGE')
    end
  end

  describe '.total_pages_field' do
    it 'creates a paragraph with NUMPAGES field' do
      para = described_class.total_pages_field
      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      instruction = para.instr_text.first
      expect(instruction.text).to include('NUMPAGES')
    end
  end

  describe '.date_field' do
    it 'creates a paragraph with DATE field' do
      para = described_class.date_field(format: 'yyyy-MM-dd')
      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      instruction = para.instr_text.first
      expect(instruction.text).to include('DATE')
      expect(instruction.text).to include('yyyy-MM-dd')
    end
  end

  describe '.time_field' do
    it 'creates a paragraph with TIME field' do
      para = described_class.time_field
      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      instruction = para.instr_text.first
      expect(instruction.text).to include('TIME')
    end
  end
end

RSpec.describe Uniword::Builder::ThemeBuilder do
  describe '#apply' do
    it 'applies a bundled theme' do
      doc = Uniword::Builder::DocumentBuilder.new
      tb = described_class.new(doc)
      tb.apply('atlas')
      expect(doc.model.theme).not_to be_nil
    end

    it 'raises on unknown theme' do
      doc = Uniword::Builder::DocumentBuilder.new
      tb = described_class.new(doc)
      expect { tb.apply('nonexistent') }.to raise_error(ArgumentError)
    end
  end

  describe '#colors' do
    it 'overrides theme colors' do
      doc = Uniword::Builder::DocumentBuilder.new
      tb = described_class.new(doc)
      tb.apply('atlas')
      tb.colors(accent1: 'FF0000')

      expect(doc.model.theme.color(:accent1)).to eq('FF0000')
    end
  end

  describe '#fonts' do
    it 'overrides theme fonts' do
      doc = Uniword::Builder::DocumentBuilder.new
      tb = described_class.new(doc)
      tb.apply('atlas')
      tb.fonts(major: 'Georgia', minor: 'Calibri')

      fs = doc.model.theme.theme_elements.font_scheme
      expect(fs.major_font).to eq('Georgia')
      expect(fs.minor_font).to eq('Calibri')
    end
  end

  describe '#available' do
    it 'lists available themes' do
      doc = Uniword::Builder::DocumentBuilder.new
      tb = described_class.new(doc)
      themes = tb.available
      expect(themes).to be_an(Array)
      expect(themes).to include('atlas')
    end
  end
end

RSpec.describe Uniword::Builder::ListBuilder do
  let(:doc) { Uniword::Builder::DocumentBuilder.new }

  it 'returns the num_id' do
    lb = described_class.new(doc, type: :bullet)
    lb.item('Test')
    expect(lb.num_id).not_to be_nil
  end

  it 'registers numbering on the document' do
    lb = described_class.new(doc, type: :bullet)
    lb.item('Test')

    nc = doc.model.numbering_configuration
    expect(nc.definitions.size).to be >= 1
    expect(nc.instances.size).to be >= 1
  end
end

RSpec.describe Uniword::Builder::SectionBuilder, '#page_numbering' do
  it 'sets start and format' do
    sec = described_class.new
    sec.page_numbering(start: 5, format: 'upperRoman')

    pn = sec.model.page_numbering
    expect(pn.start).to eq(5)
    expect(pn.format).to eq('upperRoman')
  end

  it 'sets only start' do
    sec = described_class.new
    sec.page_numbering(start: 1)

    expect(sec.model.page_numbering.start).to eq(1)
  end
end
