# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Docx.js Compatibility: Footnotes', :compatibility do
  describe 'Basic Footnotes' do
    describe 'footnote creation' do
      it 'should support creating footnotes' do
        skip 'Footnotes not yet fully implemented'

        doc = Uniword::Document.new

        # Add footnotes directly to model
        footnote1 = Uniword::Wordprocessingml::Footnote.new(id: 1)
        p1 = Uniword::Wordprocessingml::Paragraph.new
        p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Foo')
        footnote1.paragraphs << p1
        p2 = Uniword::Wordprocessingml::Paragraph.new
        p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Bar')
        footnote1.paragraphs << p2
        doc.footnotes[1] = footnote1

        footnote2 = Uniword::Wordprocessingml::Footnote.new(id: 2)
        p3 = Uniword::Wordprocessingml::Paragraph.new
        p3.runs << Uniword::Wordprocessingml::Run.new(text: 'Test')
        footnote2.paragraphs << p3
        doc.footnotes[2] = footnote2

        footnote3 = Uniword::Wordprocessingml::Footnote.new(id: 3)
        p4 = Uniword::Wordprocessingml::Paragraph.new
        p4.runs << Uniword::Wordprocessingml::Run.new(text: 'My amazing reference')
        footnote3.paragraphs << p4
        doc.footnotes[3] = footnote3

        expect(doc.footnotes.count).to eq(3)
        expect(doc.footnotes[1]).not_to be_nil
        expect(doc.footnotes[2]).not_to be_nil
        expect(doc.footnotes[3]).not_to be_nil
      end

      it 'should support multi-paragraph footnotes' do
        skip 'Multi-paragraph footnotes not yet implemented'

        doc = Uniword::Document.new

        footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
        p1 = Uniword::Wordprocessingml::Paragraph.new
        p1.runs << Uniword::Wordprocessingml::Run.new(text: 'First paragraph')
        footnote.paragraphs << p1
        p2 = Uniword::Wordprocessingml::Paragraph.new
        p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Second paragraph')
        footnote.paragraphs << p2
        doc.footnotes[1] = footnote

        fn = doc.footnotes[1]
        expect(fn.paragraphs.count).to eq(2)
        expect(fn.paragraphs[0].text).to eq('First paragraph')
        expect(fn.paragraphs[1].text).to eq('Second paragraph')
      end

      it 'should support single-paragraph footnotes' do
        skip 'Single-paragraph footnotes not yet implemented'

        doc = Uniword::Document.new

        footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
        p1 = Uniword::Wordprocessingml::Paragraph.new
        p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Simple footnote')
        footnote.paragraphs << p1
        doc.footnotes[1] = footnote

        fn = doc.footnotes[1]
        expect(fn.paragraphs.count).to eq(1)
        expect(fn.paragraphs.first.text).to eq('Simple footnote')
      end
    end

    describe 'footnote references' do
      it 'should support adding footnote references inline' do
        skip 'Footnote references not yet implemented'

        doc = Uniword::Document.new

        # Create footnote
        footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
        p1 = Uniword::Wordprocessingml::Paragraph.new
        p1.runs << Uniword::Wordprocessingml::Run.new(text: 'This is footnote 1')
        footnote.paragraphs << p1
        doc.footnotes[1] = footnote

        # Add paragraph with footnote reference
        para = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Hello')
        para.runs << run1
        para.add_footnote_reference(1)
        run2 = Uniword::Wordprocessingml::Run.new(text: ' World!')
        para.runs << run2
        doc.body.paragraphs << para

        para = doc.paragraphs.first
        expect(para.footnote_references).to include(1)
      end

      it 'should support multiple footnote references in one paragraph' do
        skip 'Multiple footnote references not yet implemented'

        doc = Uniword::Document.new

        # Create footnotes
        fn1 = Uniword::Wordprocessingml::Footnote.new(id: 1)
        p1 = Uniword::Wordprocessingml::Paragraph.new
        p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Footnote 1')
        fn1.paragraphs << p1
        doc.footnotes[1] = fn1

        fn2 = Uniword::Wordprocessingml::Footnote.new(id: 2)
        p2 = Uniword::Wordprocessingml::Paragraph.new
        p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Footnote 2')
        fn2.paragraphs << p2
        doc.footnotes[2] = fn2

        # Add paragraph with multiple references
        para = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Hello')
        para.runs << run1
        para.add_footnote_reference(1)
        run2 = Uniword::Wordprocessingml::Run.new(text: ' World!')
        para.runs << run2
        para.add_footnote_reference(2)
        run3 = Uniword::Wordprocessingml::Run.new(text: ' GitHub!')
        para.runs << run3
        doc.body.paragraphs << para

        para = doc.paragraphs.first
        expect(para.footnote_references).to include(1, 2)
      end

      it 'should support footnote references between text runs' do
        skip 'Footnote references between runs not yet implemented'

        doc = Uniword::Document.new

        footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
        p1 = Uniword::Wordprocessingml::Paragraph.new
        p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Reference')
        footnote.paragraphs << p1
        doc.footnotes[1] = footnote

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
        para.runs << run
        para.add_footnote_reference(1)
        doc.body.paragraphs << para

        para = doc.paragraphs.first
        expect(para.runs.count).to be >= 1
        expect(para.footnote_references).to include(1)
      end
    end
  end

  describe 'Multiple Sections with Footnotes' do
    it 'should support footnotes across multiple sections' do
      skip 'Multi-section footnotes not yet implemented'

      doc = Uniword::Document.new

      # First section footnotes
      [1, 2, 3].each do |i|
        fn = Uniword::Wordprocessingml::Footnote.new(id: i)
        p = Uniword::Wordprocessingml::Paragraph.new
        p.runs << Uniword::Wordprocessingml::Run.new(text: "Foo#{i}")
        fn.paragraphs << p
        doc.footnotes[i] = fn
      end

      # First section content
      para = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Hello')
      para.runs << run1
      para.add_footnote_reference(1)
      run2 = Uniword::Wordprocessingml::Run.new(text: ' World!')
      para.runs << run2
      para.add_footnote_reference(2)
      doc.body.paragraphs << para

      # Add new section
      doc.add_section

      # Second section footnotes
      [4, 5, 6].each do |i|
        fn = Uniword::Wordprocessingml::Footnote.new(id: i)
        p = Uniword::Wordprocessingml::Paragraph.new
        p.runs << Uniword::Wordprocessingml::Run.new(text: "Foo#{i}")
        fn.paragraphs << p
        doc.footnotes[i] = fn
      end

      # Second section content
      para = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Hello')
      para.runs << run1
      para.add_footnote_reference(4)
      run2 = Uniword::Wordprocessingml::Run.new(text: ' World!')
      para.runs << run2
      para.add_footnote_reference(5)
      doc.body.paragraphs << para

      expect(doc.footnotes.count).to eq(6)
      expect(doc.sections.count).to eq(2)
    end
  end

  describe 'Footnote Numbering' do
    it 'should support sequential footnote numbering' do
      skip 'Footnote numbering not yet implemented'

      doc = Uniword::Document.new

      # Add footnotes in order
      (1..5).each do |i|
        fn = Uniword::Wordprocessingml::Footnote.new(id: i)
        p = Uniword::Wordprocessingml::Paragraph.new
        p.runs << Uniword::Wordprocessingml::Run.new(text: "Footnote #{i}")
        fn.paragraphs << p
        doc.footnotes[i] = fn

        # Add references
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Text #{i}")
        para.runs << run
        para.add_footnote_reference(i)
        doc.body.paragraphs << para
      end

      expect(doc.footnotes.keys.sort).to eq([1, 2, 3, 4, 5])
    end

    it 'should support non-sequential footnote IDs' do
      skip 'Non-sequential footnote IDs not yet implemented'

      doc = Uniword::Document.new

      # Add footnotes with gaps
      fn1 = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p1 = Uniword::Wordprocessingml::Paragraph.new
      p1.runs << Uniword::Wordprocessingml::Run.new(text: 'First')
      fn1.paragraphs << p1
      doc.footnotes[1] = fn1

      fn5 = Uniword::Wordprocessingml::Footnote.new(id: 5)
      p5 = Uniword::Wordprocessingml::Paragraph.new
      p5.runs << Uniword::Wordprocessingml::Run.new(text: 'Fifth')
      fn5.paragraphs << p5
      doc.footnotes[5] = fn5

      fn10 = Uniword::Wordprocessingml::Footnote.new(id: 10)
      p10 = Uniword::Wordprocessingml::Paragraph.new
      p10.runs << Uniword::Wordprocessingml::Run.new(text: 'Tenth')
      fn10.paragraphs << p10
      doc.footnotes[10] = fn10

      expect(doc.footnotes.keys.sort).to eq([1, 5, 10])
    end

    it 'should support automatic footnote numbering' do
        skip 'Auto-numbering footnotes not yet implemented'

        doc = Uniword::Document.new

        # Add footnotes without specifying ID
        fn1 = Uniword::Wordprocessingml::Footnote.new
        p1 = Uniword::Wordprocessingml::Paragraph.new
        p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Auto 1')
        fn1.paragraphs << p1
        fn2 = Uniword::Wordprocessingml::Footnote.new
        p2 = Uniword::Wordprocessingml::Paragraph.new
        p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Auto 2')
        fn2.paragraphs << p2
        fn3 = Uniword::Wordprocessingml::Footnote.new
        p3 = Uniword::Wordprocessingml::Paragraph.new
        p3.runs << Uniword::Wordprocessingml::Run.new(text: 'Auto 3')
        fn3.paragraphs << p3

        expect(fn1.id).to eq(1)
        expect(fn2.id).to eq(2)
        expect(fn3.id).to eq(3)
      end
  end

  describe 'Footnote Formatting' do
    it 'should support formatted text in footnotes' do
      skip 'Formatted footnote text not yet implemented'

      doc = Uniword::Document.new

      footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
      para = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Builder::RunBuilder.new.text('Bold').bold.build
      para.runs << run1
      run2 = Uniword::Wordprocessingml::Run.new(text: ' and ')
      para.runs << run2
      run3 = Uniword::Builder::RunBuilder.new.text('Italic').italic.build
      para.runs << run3
      footnote.paragraphs << para
      doc.footnotes[1] = footnote

      fn = doc.footnotes[1]
      p = fn.paragraphs.first
      expect(p.runs[0].properties&.bold&.value == true).to be true
      expect(p.runs[2].properties&.italic&.value == true).to be true
    end

    it 'should support paragraph styles in footnotes' do
      skip 'Footnote paragraph styles not yet implemented'

      doc = Uniword::Document.new

      footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p1 = Uniword::Wordprocessingml::Paragraph.new
      p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Heading')
      footnote.paragraphs << p1
      p2 = Uniword::Wordprocessingml::Paragraph.new
      p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Body text')
      footnote.paragraphs << p2
      doc.footnotes[1] = footnote

      fn = doc.footnotes[1]
      expect(fn.paragraphs[0].heading_level).to eq(:heading_3)
      expect(fn.paragraphs[1].heading_level).to be_nil
    end

    it 'should support hyperlinks in footnotes' do
      skip 'Hyperlinks in footnotes not yet implemented'

      doc = Uniword::Document.new

      footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
      para = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'See ')
      para.runs << run1
      run2 = Uniword::Wordprocessingml::Run.new(text: 'example.com')
      run2.hyperlink = 'http://www.example.com'
      para.runs << run2
      footnote.paragraphs << para
      doc.footnotes[1] = footnote

      fn = doc.footnotes[1]
      p = fn.paragraphs.first
      link_run = p.runs.find(&:hyperlink)
      expect(link_run).not_to be_nil
    end
  end

  describe 'Footnote Positioning' do
    it 'should support footnotes at bottom of page' do
      skip 'Footnote positioning not yet implemented'

      doc = Uniword::Document.new

      doc.footnote_position = :page_bottom

      fn = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p = Uniword::Wordprocessingml::Paragraph.new
      p.runs << Uniword::Wordprocessingml::Run.new(text: 'At bottom of page')
      fn.paragraphs << p
      doc.footnotes[1] = fn

      expect(doc.footnote_position).to eq(:page_bottom)
    end

    it 'should support footnotes at end of section' do
      skip 'Footnote positioning not yet implemented'

      doc = Uniword::Document.new

      doc.footnote_position = :section_end

      fn = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p = Uniword::Wordprocessingml::Paragraph.new
      p.runs << Uniword::Wordprocessingml::Run.new(text: 'At end of section')
      fn.paragraphs << p
      doc.footnotes[1] = fn

      expect(doc.footnote_position).to eq(:section_end)
    end

    it 'should support footnotes at end of document' do
      skip 'Footnote positioning not yet implemented'

      doc = Uniword::Document.new

      doc.footnote_position = :document_end

      fn = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p = Uniword::Wordprocessingml::Paragraph.new
      p.runs << Uniword::Wordprocessingml::Run.new(text: 'At end of document')
      fn.paragraphs << p
      doc.footnotes[1] = fn

      expect(doc.footnote_position).to eq(:document_end)
    end
  end

  describe 'Footnote Separators' do
    it 'should support custom footnote separators' do
      skip 'Custom footnote separators not yet implemented'

      doc = Uniword::Document.new

      doc.footnote_separator = :line

      fn = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p = Uniword::Wordprocessingml::Paragraph.new
      p.runs << Uniword::Wordprocessingml::Run.new(text: 'Footnote')
      fn.paragraphs << p
      doc.footnotes[1] = fn

      expect(doc.footnote_separator).to eq(:line)
    end

    it 'should support no separator' do
      skip 'No separator option not yet implemented'

      doc = Uniword::Document.new

      doc.footnote_separator = :none

      expect(doc.footnote_separator).to eq(:none)
    end
  end

  describe 'Endnotes' do
    it 'should support endnotes as alternative to footnotes' do
      skip 'Endnotes not yet implemented'

      doc = Uniword::Document.new

      en1 = Uniword::Wordprocessingml::Endnote.new(id: 1)
      p1 = Uniword::Wordprocessingml::Paragraph.new
      p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Endnote 1')
      en1.paragraphs << p1
      doc.endnotes[1] = en1

      en2 = Uniword::Wordprocessingml::Endnote.new(id: 2)
      p2 = Uniword::Wordprocessingml::Paragraph.new
      p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Endnote 2')
      en2.paragraphs << p2
      doc.endnotes[2] = en2

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Text')
      para.runs << run
      para.add_endnote_reference(1)
      doc.body.paragraphs << para

      expect(doc.endnotes.count).to eq(2)
    end

    it 'should support mixing footnotes and endnotes' do
      skip 'Mixed notes not yet implemented'

      doc = Uniword::Document.new

      fn = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p1 = Uniword::Wordprocessingml::Paragraph.new
      p1.runs << Uniword::Wordprocessingml::Run.new(text: 'Footnote')
      fn.paragraphs << p1
      doc.footnotes[1] = fn

      en = Uniword::Wordprocessingml::Endnote.new(id: 1)
      p2 = Uniword::Wordprocessingml::Paragraph.new
      p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Endnote')
      en.paragraphs << p2
      doc.endnotes[1] = en

      expect(doc.footnotes.count).to eq(1)
      expect(doc.endnotes.count).to eq(1)
    end
  end

  describe 'Round-trip preservation' do
    it 'should preserve footnotes in round-trip' do
      skip 'Round-trip testing requires full implementation'

      # Create document with footnotes
      original = Uniword::Document.new
      fn = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p = Uniword::Wordprocessingml::Paragraph.new
      p.runs << Uniword::Wordprocessingml::Run.new(text: 'Test footnote')
      fn.paragraphs << p
      original.footnotes[1] = fn

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Text')
      para.runs << run
      para.add_footnote_reference(1)
      original.body.paragraphs << para

      # Save and reload
      temp_path = '/tmp/footnotes_test.docx'
      original.save(temp_path)
      reloaded = Uniword.load(temp_path)

      # Verify footnote preserved
      expect(reloaded.footnotes.count).to eq(1)
      expect(reloaded.footnotes[1]).not_to be_nil
    end
  end

  describe 'Footnote Validation' do
    it 'should validate footnote IDs are unique' do
      skip 'Footnote validation not yet implemented'

      doc = Uniword::Document.new

      fn = Uniword::Wordprocessingml::Footnote.new(id: 1)
      p = Uniword::Wordprocessingml::Paragraph.new
      p.runs << Uniword::Wordprocessingml::Run.new(text: 'First')
      fn.paragraphs << p
      doc.footnotes[1] = fn

      expect do
        fn_dup = Uniword::Wordprocessingml::Footnote.new(id: 1)
        p_dup = Uniword::Wordprocessingml::Paragraph.new
        p_dup.runs << Uniword::Wordprocessingml::Run.new(text: 'Duplicate')
        fn_dup.paragraphs << p_dup
        doc.footnotes[1] = fn_dup
      end.to raise_error(/duplicate footnote id/i)
    end

    it 'should validate footnote references exist' do
      skip 'Reference validation not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Text')
      para.runs << run
      expect do
        para.add_footnote_reference(99) # Non-existent
      end.to raise_error(/footnote.*not found/i)
      doc.body.paragraphs << para
    end
  end
end
