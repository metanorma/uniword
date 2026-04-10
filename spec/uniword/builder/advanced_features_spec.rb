# frozen_string_literal: true

require 'spec_helper'

# Phase 12-14 specs: Bug fixes, horizontal_rule, page number shorthands,
# section-specific headers/footers, styleset loading

RSpec.describe 'Bug fix: SectionBuilder columns' do
  it 'sets columns.num (not columns.count)' do
    sec = Uniword::Builder::SectionBuilder.new
    sec.columns(count: 2, spacing: 500)

    expect(sec.model.columns.num).to eq(2)
    expect(sec.model.columns.space).to eq(500)
  end
end

RSpec.describe 'Bug fix: SectionProperties header/footer references' do
  it 'stores multiple header references' do
    sect = Uniword::Wordprocessingml::SectionProperties.new
    sect.header_references <<
      Uniword::Wordprocessingml::HeaderReference.new(type: 'default', r_id: 'rId1')
    sect.header_references <<
      Uniword::Wordprocessingml::HeaderReference.new(type: 'first', r_id: 'rId2')

    expect(sect.header_references.size).to eq(2)
    expect(sect.header_references[0].type).to eq('default')
    expect(sect.header_references[1].type).to eq('first')
  end

  it 'stores multiple footer references' do
    sect = Uniword::Wordprocessingml::SectionProperties.new
    sect.footer_references <<
      Uniword::Wordprocessingml::FooterReference.new(type: 'default', r_id: 'rId3')
    sect.footer_references <<
      Uniword::Wordprocessingml::FooterReference.new(type: 'even', r_id: 'rId4')

    expect(sect.footer_references.size).to eq(2)
  end
end

RSpec.describe 'Bug fix: HeaderReference r:id namespace' do
  it 'serializes id as r:id' do
    ref = Uniword::Wordprocessingml::HeaderReference.new(
      type: 'default', r_id: 'rId1'
    )
    xml = ref.to_xml(prefix: true)

    expect(xml).to include('r:id="rId1"')
    expect(xml).to include('w:type="default"')
  end
end

RSpec.describe 'Bug fix: FooterReference r:id namespace' do
  it 'serializes id as r:id' do
    ref = Uniword::Wordprocessingml::FooterReference.new(
      type: 'default', r_id: 'rId1'
    )
    xml = ref.to_xml(prefix: true)

    expect(xml).to include('r:id="rId1"')
    expect(xml).to include('w:type="default"')
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#horizontal_rule' do
  it 'inserts a paragraph with bottom border' do
    doc = described_class.new
    doc.paragraph { |p| p << 'Above' }
    doc.horizontal_rule
    doc.paragraph { |p| p << 'Below' }

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(3)

    hr = paragraphs[1]
    expect(hr.properties).not_to be_nil
    expect(hr.properties.borders).not_to be_nil
    expect(hr.properties.borders.bottom).not_to be_nil
  end

  it 'accepts custom border options' do
    doc = described_class.new
    doc.horizontal_rule(style: 'double', color: 'FF0000', size: 12)

    hr = doc.model.body.paragraphs.first
    border = hr.properties.borders.bottom
    expect(border.style).to eq('double')
    expect(border.color).to eq('FF0000')
    expect(border.size).to eq(12)
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#page_number' do
  it 'inserts a page number paragraph' do
    doc = described_class.new
    doc.page_number

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(1)
    expect(paragraphs.first.field_chars.size).to be >= 3

    instruction = paragraphs.first.instr_text.first
    expect(instruction.text).to include('PAGE')
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#total_pages' do
  it 'inserts a total pages paragraph' do
    doc = described_class.new
    doc.total_pages

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(1)

    instruction = paragraphs.first.instr_text.first
    expect(instruction.text).to include('NUMPAGES')
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#date_field' do
  it 'inserts a date field paragraph' do
    doc = described_class.new
    doc.date_field(format: 'yyyy-MM-dd')

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(1)

    instruction = paragraphs.first.instr_text.first
    expect(instruction.text).to include('DATE')
    expect(instruction.text).to include('yyyy-MM-dd')
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#time_field' do
  it 'inserts a time field paragraph' do
    doc = described_class.new
    doc.time_field

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(1)

    instruction = paragraphs.first.instr_text.first
    expect(instruction.text).to include('TIME')
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, '#apply_styleset' do
  it 'applies a bundled styleset' do
    doc = described_class.new
    result = doc.apply_styleset('formal')

    expect(result).to eq(doc)
    # Verify styles were added to configuration
    styles = doc.model.styles_configuration
    expect(styles.styles.size).to be > 0
  end

  it 'accepts strategy option' do
    doc = described_class.new
    doc.apply_styleset('modern', strategy: :replace)
    # Should not raise
    expect(doc.model.styles_configuration.styles.size).to be > 0
  end
end

RSpec.describe Uniword::Builder::SectionBuilder, '#header' do
  it 'creates a header reference on the section' do
    sec = described_class.new
    sec.header(type: 'default') { |h| h << 'Section Header' }

    expect(sec.model.header_references.size).to eq(1)
    expect(sec.model.header_references.first.type).to eq('default')
    expect(sec.model.header_references.first.r_id).to eq('rIdHdrdefault')
  end

  it 'supports first-page header' do
    sec = described_class.new
    sec.header(type: 'first') { |h| h << 'First Page Header' }

    expect(sec.model.header_references.first.type).to eq('first')
    expect(sec.model.header_references.first.r_id).to eq('rIdHdrfirst')
  end

  it 'supports multiple header types' do
    sec = described_class.new
    sec.header(type: 'default') { |h| h << 'Default' }
    sec.header(type: 'first') { |h| h << 'First' }
    sec.header(type: 'even') { |h| h << 'Even' }

    expect(sec.model.header_references.size).to eq(3)
    types = sec.model.header_references.map(&:type)
    expect(types).to contain_exactly('default', 'first', 'even')
  end
end

RSpec.describe Uniword::Builder::SectionBuilder, '#footer' do
  it 'creates a footer reference on the section' do
    sec = described_class.new
    sec.footer(type: 'default') { |f| f << 'Section Footer' }

    expect(sec.model.footer_references.size).to eq(1)
    expect(sec.model.footer_references.first.type).to eq('default')
    expect(sec.model.footer_references.first.r_id).to eq('rIdFtrdefault')
  end

  it 'supports first-page footer' do
    sec = described_class.new
    sec.footer(type: 'first') { |f| f << 'First Page Footer' }

    expect(sec.model.footer_references.first.type).to eq('first')
  end

  it 'supports multiple footer types' do
    sec = described_class.new
    sec.footer(type: 'default') { |f| f << 'Default' }
    sec.footer(type: 'even') { |f| f << 'Even' }

    expect(sec.model.footer_references.size).to eq(2)
  end
end

RSpec.describe 'Scenario: Document with section-specific headers' do
  it 'creates a document with first-page and default headers' do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.title('Multi-Header Document')

    doc.section do |s|
      s.header(type: 'default') { |h| h << 'Default Header' }
      s.header(type: 'first') { |h| h << 'First Page Header' }
      s.footer(type: 'default') do |f|
        f << 'Page '
        f << Uniword::Builder.page_number_field
      end
    end

    doc.paragraph { |p| p << 'Page 1 content' }
    doc.page_break
    doc.paragraph { |p| p << 'Page 2 content' }

    sect = doc.model.body.section_properties
    expect(sect.header_references.size).to eq(2)
    expect(sect.footer_references.size).to eq(1)
    expect(sect.header_references[0].type).to eq('default')
    expect(sect.header_references[1].type).to eq('first')
  end
end

RSpec.describe 'Scenario: Document with horizontal rules' do
  it 'creates a document with section dividers' do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.heading('Section 1', level: 1)
    doc.paragraph { |p| p << 'Content' }
    doc.horizontal_rule
    doc.heading('Section 2', level: 1)
    doc.paragraph { |p| p << 'More content' }

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to eq(5) # 2 headings + 2 paragraphs + 1 hr

    hr = paragraphs[2]
    expect(hr.properties&.borders&.bottom).not_to be_nil
  end
end

RSpec.describe 'Scenario: Document with page numbers via shorthand' do
  it 'uses page_number and total_pages shorthands' do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.footer do |f|
      f << 'Page '
      f << Uniword::Builder.page_number_field
      f << ' of '
      f << Uniword::Builder.total_pages_field
    end
    doc.paragraph { |p| p << 'Content' }

    footer = doc.model.footers['default']
    expect(footer).not_to be_nil
    # 'Page ' (string→paragraph), page_number_field (paragraph),
    # ' of ' (string→paragraph), total_pages_field (paragraph)
    expect(footer.paragraphs.size).to eq(4)
  end
end

RSpec.describe 'Scenario: Document with styleset' do
  it 'applies formal styleset' do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.apply_styleset('formal')
    doc.heading('Styled Heading', level: 1)
    doc.paragraph { |p| p << 'Styled paragraph' }

    expect(doc.model.styles_configuration.styles.size).to be > 0
    expect(doc.model.body.paragraphs.size).to eq(2)
  end
end

RSpec.describe 'Scenario: Multi-column document' do
  it 'creates a two-column section' do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.heading('Two Column Section', level: 1)
    doc.section(type: 'continuous') do |s|
      s.columns(count: 2, spacing: 720)
    end
    doc.paragraph { |p| p << 'Left column content...' }
    doc.paragraph { |p| p << 'Right column content...' }

    sect = doc.model.body.section_properties
    expect(sect.columns.num).to eq(2)
    expect(sect.columns.space).to eq(720)
  end
end

RSpec.describe 'Scenario: Complete document with all Phase 12-14 features' do
  it 'combines horizontal rules, page numbers, stylesets, section headers' do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.title('Advanced Document')
    doc.author('Author')
    doc.apply_styleset('formal')
    doc.theme('atlas')

    # Section with headers/footers
    doc.section do |s|
      s.header(type: 'default') { |h| h << 'Default Header' }
      s.header(type: 'first') { |h| h << 'First Page Header' }
      s.footer(type: 'default') { |f| f << Uniword::Builder.page_number_field }
      s.margins(top: 1440, bottom: 1440)
      s.columns(count: 1)
    end

    doc.heading('Introduction', level: 1)
    doc.paragraph { |p| p << 'Content here.' }

    doc.horizontal_rule

    doc.heading('Details', level: 2)
    doc.paragraph { |p| p << 'More details.' }

    doc.page_break

    # Second section with different columns
    doc.section(type: 'nextPage') do |s|
      s.columns(count: 2, spacing: 720)
      s.page_numbering(start: 1)
    end

    doc.heading('Appendix', level: 1)
    doc.paragraph { |p| p << 'Two-column content.' }

    # Verify — first section's properties are kept (||= semantics)
    sect = doc.model.body.section_properties
    expect(sect.header_references.size).to eq(2)
    expect(sect.footer_references.size).to eq(1)
    expect(sect.columns.num).to eq(1) # from first section
  end
end
