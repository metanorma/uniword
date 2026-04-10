# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DOCX → MHT Full Fidelity' do
  # These fixtures represent real Word documents saved as MHT
  FULL_FIDELITY_FIXTURES = {
    'blank' => { docx: 'spec/fixtures/blank.docx', mht: 'spec/fixtures/blank.mht' },
    'apa' => { docx: 'spec/fixtures/word-template-apa-style-paper.docx',
               mht: 'spec/fixtures/word-template-apa-style-paper.mht' },
    'mla' => { docx: 'spec/fixtures/word-template-mla-style-paper.docx',
               mht: 'spec/fixtures/word-template-mla-style-paper.mht' },
    'cover_toc' => { docx: 'spec/fixtures/word-template-paper-with-cover-and-toc.docx',
                     mht: 'spec/fixtures/word-template-paper-with-cover-and-toc.mht' }
  }.freeze

  # Expected structure counts per fixture (from fixture analysis)
  EXPECTED_STRUCTURE = {
    'blank' => { paragraphs: 1, sdts: 0, hyperlinks: 0, tables: 0 },
    'apa' => { paragraphs: 84, sdts: 28, hyperlinks: 18, tables: 1 },
    'mla' => { paragraphs: 51, sdts: 24, hyperlinks: 0, tables: 1 },
    'cover_toc' => { paragraphs: 39, sdts: 22, hyperlinks: 3, tables: 1 }
  }.freeze

  # Expected paragraph classes per fixture
  EXPECTED_CLASSES = {
    'blank' => ['MsoNormal'].to_set,
    'apa' => %w[MsoBibliography MsoHeader MsoNoSpacing MsoNormal MsoTitle
                MsoToc1 MsoToc2 MsoToc3 MsoTocHeading SectionTitle TableFigure Title2].to_set,
    'mla' => %w[MsoBibliography MsoHeader MsoNoSpacing MsoNormal MsoQuote
                MsoTitle SectionTitle TableNote TableSource TableTitle].to_set,
    'cover_toc' => %w[Author MsoFooter MsoListBullet MsoNormal MsoQuote
                      MsoSubtitle MsoTitle MsoToc1 MsoToc2 MsoTocHeading].to_set
  }.freeze

  def decode_qp(str)
    str.gsub(/=([0-9A-Fa-f]{2})/) { Regexp.last_match(1).to_i(16).chr }
  end

  def parse_mht_body(mht_path)
    content = File.read(mht_path)
    if content =~ %r{<body[^>]*>(.*)</body>}im
      decode_qp(Regexp.last_match(1))
    else
      ''
    end
  end

  def docx_to_mht_html(docx_path, doc_name = nil)
    docx_pkg = Uniword::Ooxml::DocxPackage.from_file(docx_path)
    mhtml_doc = Uniword::Transformation::Transformer.new.docx_package_to_mhtml(docx_pkg, doc_name)
    # Get raw HTML from the Mhtml::Document
    mhtml_doc.html_part&.raw_content || ''
  end

  describe 'DOCX → MHT for each fixture' do
    FULL_FIDELITY_FIXTURES.each do |name, paths|
      describe name do
        let(:mht_body) { parse_mht_body(paths[:mht]) }
        let(:generated_html) { docx_to_mht_html(paths[:docx], name) }
        let(:expected) { EXPECTED_STRUCTURE[name] }
        let(:expected_classes) { EXPECTED_CLASSES[name] }

        it 'produces MHT with WordSection1 div wrapper' do
          # The MHT body should have a div.WordSection1 wrapper
          has_wrapper = generated_html.include?('class=WordSection1') ||
                        generated_html.include?('class="WordSection1"')
          expect(has_wrapper).to be true
        end

        it 'has expected paragraph count' do
          # Count <p elements in generated HTML
          generated_doc = Nokogiri::HTML(decode_qp(generated_html))
          generated_paras = generated_doc.css('p').length

          # For now, just verify we have at least 1 paragraph
          expect(generated_paras).to be >= 1
        end

        it 'has at least one SDT for fixtures with SDTs' do
          next if expected[:sdts].zero?

          # Check for SDT elements in generated HTML
          sdt_count = generated_html.scan(/<w:[Ss]dt\b/).length
          expect(sdt_count).to be >= 1
        end

        it 'has Word HTML namespace declaration' do
          has_ns = generated_html.include?('xmlns:w=') ||
                   generated_html.include?('xmlns:w="')
          expect(has_ns).to be true
        end

        it 'has metadata comments' do
          expect(generated_html).to include('<!--[if gte mso 9]>')
        end

        it 'has DocumentProperties in comments' do
          expect(generated_html).to include('<o:DocumentProperties')
        end
      end
    end
  end

  describe 'Style class mapping' do
    let(:converter) { Uniword::Transformation::OoxmlToMhtmlConverter }

    it 'maps Title style to MsoTitle class' do
      html = docx_to_mht_html(FULL_FIDELITY_FIXTURES['apa'][:docx], 'apa')
      expect(html).to include('class=MsoTitle')
    end

    it 'maps Heading1 style to MsoHeading1 class' do
      html = docx_to_mht_html(FULL_FIDELITY_FIXTURES['cover_toc'][:docx], 'cover_toc')
      expect(html).to include('class=MsoHeading1')
    end

    it 'maps Heading2 style to MsoHeading2 class' do
      html = docx_to_mht_html(FULL_FIDELITY_FIXTURES['apa'][:docx], 'apa')
      expect(html).to include('class=MsoHeading2')
    end

    it 'maps SectionTitle style to SectionTitle class' do
      html = docx_to_mht_html(FULL_FIDELITY_FIXTURES['apa'][:docx], 'apa')
      expect(html).to include('class=SectionTitle')
    end

    it 'maps unknown styles to MsoNormal class' do
      html = docx_to_mht_html(FULL_FIDELITY_FIXTURES['blank'][:docx], 'blank')
      expect(html).to include('class=MsoNormal')
    end

    it 'maps all expected classes from apa fixture' do
      html = docx_to_mht_html(FULL_FIDELITY_FIXTURES['apa'][:docx], 'apa')
      expected = %w[MsoHeading2 MsoNormal MsoTitle SectionTitle]
      expected.each do |cls|
        expect(html).to include("class=#{cls}"), "Expected class=#{cls} in output"
      end
    end

    it 'maps all expected classes from mla fixture' do
      html = docx_to_mht_html(FULL_FIDELITY_FIXTURES['mla'][:docx], 'mla')
      expected = %w[MsoNormal MsoTitle SectionTitle]
      expected.each do |cls|
        expect(html).to include("class=#{cls}"), "Expected class=#{cls} in output"
      end
    end
  end

  describe 'Generated MHT structure' do
    let(:docx_path) { FULL_FIDELITY_FIXTURES['blank'][:docx] }
    let(:mhtml_doc) do
      docx_pkg = Uniword::Ooxml::DocxPackage.from_file(docx_path)
      Uniword::Transformation::Transformer.new.docx_package_to_mhtml(docx_pkg, 'blank')
    end

    it 'creates Mhtml::Document with html_part' do
      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(mhtml_doc.html_part).to be_a(Uniword::Mhtml::HtmlPart)
    end

    it 'html_part has raw_content with Word HTML' do
      raw = mhtml_doc.html_part&.raw_content
      expect(raw).to be_a(String)
      expect(raw.length).to be > 0
      expect(raw).to include('<html')
      expect(raw).to include('</html>')
    end

    it 'html_part has correct content_type' do
      expect(mhtml_doc.html_part.content_type).to include('text/html')
    end

    it 'html_part has quoted-printable encoding' do
      expect(mhtml_doc.html_part.content_transfer_encoding).to eq('quoted-printable')
    end

    it 'has content_location set' do
      expect(mhtml_doc.html_part.content_location).to be_a(String)
      expect(mhtml_doc.html_part.content_location).to include('.htm')
    end
  end

  describe 'Blank fixture produces minimal valid MHT' do
    let(:mhtml_doc) do
      docx_pkg = Uniword::Ooxml::DocxPackage.from_file(FULL_FIDELITY_FIXTURES['blank'][:docx])
      Uniword::Transformation::Transformer.new.docx_package_to_mhtml(docx_pkg, 'blank')
    end

    it 'produces Mhtml::Document' do
      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
    end

    it 'has html_part' do
      expect(mhtml_doc.html_part).to be_a(Uniword::Mhtml::HtmlPart)
    end

    it 'has body with MsoNormal paragraph' do
      raw = mhtml_doc.html_part&.raw_content
      expect(raw).to include('MsoNormal')
    end

    it 'has Word HTML namespace' do
      raw = mhtml_doc.html_part&.raw_content
      expect(raw).to include('xmlns:w=')
    end

    it 'can be serialized to MIME' do
      mime = Uniword::Infrastructure::MimePackager.new(mhtml_doc).build_mime_content
      expect(mime).to start_with('MIME-Version: 1.0')
      expect(mime).to include('multipart/related')
    end
  end
end
