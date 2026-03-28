# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Docx.js Compatibility: Hyperlinks', :compatibility do
  describe 'External Hyperlinks' do
    describe 'basic hyperlink creation' do
      it 'should support adding hyperlinks to text' do
        skip 'Run hyperlink= setter removed in Builder API migration'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Anchor Text')
        run.hyperlink = 'http://www.example.com'
        para.runs << run
        doc.body.paragraphs << para

        para = doc.paragraphs.first
        run = para.runs.first
        expect(run.hyperlink).to eq('http://www.example.com')
        expect(run.text).to eq('Anchor Text')
      end

      it 'should support hyperlinks with custom text style' do
        skip 'Hyperlink style customization not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Styled Link')
        run.hyperlink = 'http://www.example.com'
        run.style = 'Hyperlink'
        para.runs << run
        doc.body.paragraphs << para

        run = doc.paragraphs.first.runs.first
        expect(run.style).to eq('Hyperlink')
      end

      it 'should support multiple hyperlinks in one paragraph' do
        skip 'Run hyperlink= setter removed in Builder API migration'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Visit ')
        para.runs << run1

        run2 = Uniword::Wordprocessingml::Run.new(text: 'Example')
        run2.hyperlink = 'http://www.example.com'
        para.runs << run2

        run3 = Uniword::Wordprocessingml::Run.new(text: ' or ')
        para.runs << run3

        run4 = Uniword::Wordprocessingml::Run.new(text: 'BBC News')
        run4.hyperlink = 'https://www.bbc.co.uk/news'
        para.runs << run4

        doc.body.paragraphs << para

        para = doc.paragraphs.first
        hyperlink_runs = para.runs.select(&:hyperlink)
        expect(hyperlink_runs.count).to eq(2)
        expect(hyperlink_runs[0].hyperlink).to eq('http://www.example.com')
        expect(hyperlink_runs[1].hyperlink).to eq('https://www.bbc.co.uk/news')
      end
    end

    describe 'hyperlinks with formatting' do
      it 'should support formatted text within hyperlinks' do
        skip 'Formatted hyperlinks not yet fully implemented'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'This is a hyperlink with formatting: ')
        para.runs << run

        # Hyperlink with multiple formatted runs
        link_run1 = Uniword::Wordprocessingml::Run.new(text: 'A ')
        para.runs << link_run1

        link_run2 = Uniword::Builder::RunBuilder.new
          .text('single ')
          .bold
          .build
        para.runs << link_run2

        link_run3 = Uniword::Builder::RunBuilder.new
          .text('link')
          .double_strike
          .build
        para.runs << link_run3

        link_run4 = Uniword::Builder::RunBuilder.new
          .text('1')
          .superscript
          .build
        para.runs << link_run4

        link_run5 = Uniword::Wordprocessingml::Run.new(text: '!')
        para.runs << link_run5

        doc.body.paragraphs << para

        para = doc.paragraphs.first
        # Verify hyperlink contains formatted content
        expect(para.runs.any?(&:hyperlink)).to be true
      end

      it 'should support bold hyperlinks' do
        skip 'Run hyperlink= setter removed in Builder API migration'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new
          .text('Bold Link')
          .bold
          .build
        run.hyperlink = 'http://www.example.com'
        para.runs << run
        doc.body.paragraphs << para

        run = doc.paragraphs.first.runs.first
        expect(run.properties&.bold&.value == true).to be true
        expect(run.hyperlink).to eq('http://www.example.com')
      end

      it 'should support underlined hyperlinks' do
        skip 'Underline customization for hyperlinks not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new
          .text('Underlined Link')
          .underline('single')
          .build
        run.hyperlink = 'http://www.example.com'
        para.runs << run
        doc.body.paragraphs << para

        run = doc.paragraphs.first.runs.first
        expect(run.properties&.underline).to be_truthy
      end
    end

    describe 'hyperlinks in headers and footers' do
      it 'should support hyperlinks in headers' do
        skip 'Headers and footers not yet fully implemented'

        doc = Uniword::Document.new

        header_para = Uniword::Wordprocessingml::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Click here for the ')
        header_para.runs << run1

        run2 = Uniword::Wordprocessingml::Run.new(text: 'Header external hyperlink')
        run2.hyperlink = 'http://www.google.com'
        run2.style = 'Hyperlink'
        header_para.runs << run2

        doc.header.paragraphs << header_para

        header_para = doc.header.paragraphs.first
        hyperlink_run = header_para.runs.find(&:hyperlink)
        expect(hyperlink_run).not_to be_nil
        expect(hyperlink_run.hyperlink).to eq('http://www.google.com')
      end

      it 'should support hyperlinks in footers' do
        skip 'Headers and footers not yet fully implemented'

        doc = Uniword::Document.new

        footer_para = Uniword::Wordprocessingml::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Click here for the ')
        footer_para.runs << run1

        run2 = Uniword::Wordprocessingml::Run.new(text: 'Footer external hyperlink')
        run2.hyperlink = 'http://www.example.com'
        run2.style = 'Hyperlink'
        footer_para.runs << run2

        doc.footer.paragraphs << footer_para

        footer_para = doc.footer.paragraphs.first
        hyperlink_run = footer_para.runs.find(&:hyperlink)
        expect(hyperlink_run).not_to be_nil
        expect(hyperlink_run.hyperlink).to eq('http://www.example.com')
      end
    end

    describe 'hyperlinks with images' do
      it 'should support image hyperlinks' do
        skip 'Image hyperlinks not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        para.add_image('path/to/image.jpeg') do |img|
            img.hyperlink = 'http://www.google.com'
            img.width = 100
            img.height = 100
          end
        doc.body.paragraphs << para

        para = doc.paragraphs.first
        img = para.images.first
        expect(img.hyperlink).to eq('http://www.google.com')
      end
    end

    describe 'hyperlinks in footnotes' do
      it 'should support hyperlinks within footnotes' do
        skip 'Footnotes not yet fully implemented'

        doc = Uniword::Document.new

        # Add footnote with hyperlink
        footnote = Uniword::Wordprocessingml::Footnote.new(id: 1)
        para = Uniword::Wordprocessingml::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Click here for the ')
        para.runs << run1

        run2 = Uniword::Wordprocessingml::Run.new(text: 'Footnotes external hyperlink')
        run2.hyperlink = 'http://www.example.com'
        run2.style = 'Hyperlink'
        para.runs << run2

        footnote.paragraphs << para
        doc.footnotes[1] = footnote

        # Add paragraph with footnote reference
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'See footnote ')
        para.runs << run
        para.add_footnote_reference(1)
        doc.body.paragraphs << para

        footnote = doc.footnotes[1]
        expect(footnote).not_to be_nil
        hyperlink_run = footnote.paragraphs.first.runs.find(&:hyperlink)
        expect(hyperlink_run.hyperlink).to eq('http://www.example.com')
      end
    end

    describe 'hyperlink style configuration' do
      it 'should support custom hyperlink style colors' do
        skip 'Custom hyperlink styles not yet implemented'

        doc = Uniword::Document.new do |d|
          d.styles.hyperlink do |style|
            style.color = 'FF0000' # Red
            style.underline_color = '0000FF' # Blue underline
          end
        end

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Red Link')
        run.hyperlink = 'http://www.example.com'
        run.style = 'Hyperlink'
        para.runs << run
        doc.body.paragraphs << para

        # Verify style was configured
        expect(doc.styles.hyperlink.color).to eq('FF0000')
      end
    end
  end

  describe 'Internal Hyperlinks' do
    describe 'bookmark linking' do
      it 'should support internal bookmarks' do
        skip 'Bookmark hyperlinks not yet implemented'

        doc = Uniword::Document.new

        # Create a bookmark
        para1 = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Section 1')
        para1.runs << run
        para1.bookmark = 'section1'
        doc.body.paragraphs << para1

        # Link to the bookmark
        para2 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Go to ')
        para2.runs << run1

        run2 = Uniword::Wordprocessingml::Run.new(text: 'Section 1')
        run2.internal_link = '#section1'
        para2.runs << run2

        doc.body.paragraphs << para2

        bookmark_para = doc.paragraphs.first
        link_para = doc.paragraphs.last

        expect(bookmark_para.bookmark).to eq('section1')
        link_run = link_para.runs.find(&:internal_link)
        expect(link_run.internal_link).to eq('#section1')
      end
    end

    describe 'cross-references' do
      it 'should support heading cross-references' do
        skip 'Cross-references not yet implemented'

        doc = Uniword::Document.new

        heading_para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Introduction')
        heading_para.runs << run
        doc.body.paragraphs << heading_para

        ref_para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'See ')
        ref_para.runs << run
        ref_para.add_cross_reference(type: :heading, target: 'Introduction')
        doc.body.paragraphs << ref_para

        # Verify cross-reference
        para = doc.paragraphs.last
        expect(para.cross_references).not_to be_empty
      end
    end
  end

  describe 'Round-trip preservation' do
    it 'should preserve hyperlinks when reading and writing' do
      skip 'Round-trip testing requires full implementation'

      # Create document with hyperlink
      original = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Link')
      run.hyperlink = 'http://www.example.com'
      para.runs << run
      original.body.paragraphs << para

      # Save and reload
      temp_path = '/tmp/hyperlink_test.docx'
      original.save(temp_path)
      reloaded = Uniword.load(temp_path)

      # Verify hyperlink preserved
      run = reloaded.paragraphs.first.runs.first
      expect(run.hyperlink).to eq('http://www.example.com')
    end
  end

  describe 'URL validation' do
    it 'should accept valid HTTP URLs' do
      skip 'Run hyperlink= setter removed in Builder API migration'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Link')
      run.hyperlink = 'http://www.example.com'
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.paragraphs.first.runs.first.hyperlink).to match(%r{^http://})
    end

    it 'should accept valid HTTPS URLs' do
      skip 'Run hyperlink= setter removed in Builder API migration'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Secure Link')
      run.hyperlink = 'https://www.example.com'
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.paragraphs.first.runs.first.hyperlink).to match(%r{^https://})
    end

    it 'should accept mailto links' do
      skip 'Mailto links validation not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Email')
      run.hyperlink = 'mailto:user@example.com'
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.paragraphs.first.runs.first.hyperlink).to match(/^mailto:/)
    end
  end
end
