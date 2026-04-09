# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'MHTML Document Model Round-Trip', type: :integration do
  MHTML_FIXTURES = {
    'blank' => 'spec/fixtures/blank.mht',
    'apa' => 'spec/fixtures/word-template-apa-style-paper.mht',
    'mla' => 'spec/fixtures/word-template-mla-style-paper.mht',
    'cover_toc' => 'spec/fixtures/word-template-paper-with-cover-and-toc.mht'
  }.freeze

  # Shared helper to parse an MHTML fixture
  def parse_fixture(name)
    path = MHTML_FIXTURES[name]
    skip "Fixture not found: #{path}" unless File.exist?(path)

    Uniword::Infrastructure::MimeParser.new.parse(path)
  end

  # Shared helper to round-trip a document
  def round_trip(doc)
    packager = Uniword::Infrastructure::MimePackager.new(doc)
    output = packager.build_mime_content
    Uniword::Infrastructure::MimeParser.new.parse_content(output)
  end

  describe 'MimeParser' do
    describe 'blank.mht' do
      let(:doc) { parse_fixture('blank') }

      it 'parses without error' do
        expect(doc).to be_a(Uniword::Mhtml::Document)
      end

      it 'extracts boundary' do
        expect(doc.boundary).to include('NextPart')
      end

      it 'has HTML part' do
        expect(doc.html_part).to be_a(Uniword::Mhtml::HtmlPart)
        expect(doc.html_part.content_type).to include('text/html')
      end

      it 'extracts body HTML' do
        expect(doc.body_html).to include('WordSection1')
        expect(doc.body_html).to include('MsoNormal')
      end

      it 'extracts DocumentProperties' do
        expect(doc.document_properties).to be_a(Uniword::Mhtml::Metadata::DocumentProperties)
        expect(doc.document_properties.author).to eq('Ronald Tse')
        expect(doc.document_properties.created).to eq('2025-11-28T22:23:00Z')
        expect(doc.document_properties.pages).to eq('1')
      end

      it 'extracts WordDocument settings' do
        expect(doc.word_document_settings).to be_a(Uniword::Mhtml::Metadata::WordDocumentSettings)
        expect(doc.word_document_settings.track_moves).to eq('false')
        expect(doc.word_document_settings.lid_theme_other).to eq('EN-US')
      end

      it 'has theme part' do
        expect(doc.theme_part).to be_a(Uniword::Mhtml::ThemePart)
      end

      it 'has filelist XML' do
        expect(doc.filelist_xml).to include('MainFile')
        expect(doc.filelist_xml).to include('themedata.thmx')
      end

      it 'has color scheme mapping' do
        expect(doc.color_scheme_mapping_xml).to include('clrMap')
      end

      it 'has correct part count' do
        expect(doc.parts.length).to eq(4)
      end
    end

    describe 'word-template-apa-style-paper.mht' do
      let(:doc) { parse_fixture('apa') }

      it 'parses without error' do
        expect(doc).to be_a(Uniword::Mhtml::Document)
      end

      it 'has images' do
        expect(doc.image_parts.length).to eq(1)
        expect(doc.image_parts.first.content_type).to include('image/png')
      end

      it 'has header/footer parts' do
        expect(doc.header_footer_parts.length).to be >= 1
      end

      it 'extracts DocumentProperties' do
        expect(doc.document_properties.author).to eq('Ronald Tse')
      end

      it 'has substantial body HTML' do
        expect(doc.body_html.length).to be > 100_000
      end

      it 'contains Word-specific CSS classes' do
        expect(doc.body_html).to include('MsoTitle')
        expect(doc.body_html).to include('MsoNormal')
      end

      it 'contains SDT elements' do
        # Nokogiri lowercases tag names, so check for w:sdt (lowercase)
        expect(doc.body_html).to include('w:sdt')
      end

      it 'has correct part count' do
        expect(doc.parts.length).to eq(9)
      end
    end

    describe 'word-template-mla-style-paper.mht' do
      let(:doc) { parse_fixture('mla') }

      it 'parses without error' do
        expect(doc).to be_a(Uniword::Mhtml::Document)
      end

      it 'has images' do
        expect(doc.image_parts.length).to eq(1)
      end

      it 'extracts DocumentProperties' do
        expect(doc.document_properties.author).to eq('Ronald Tse')
      end

      it 'has correct part count' do
        expect(doc.parts.length).to eq(11)
      end
    end

    describe 'word-template-paper-with-cover-and-toc.mht' do
      let(:doc) { parse_fixture('cover_toc') }

      it 'parses without error' do
        expect(doc).to be_a(Uniword::Mhtml::Document)
      end

      it 'has images' do
        expect(doc.image_parts.length).to eq(1)
      end

      it 'has more XML parts (props, etc.)' do
        expect(doc.xml_parts.length).to be >= 10
      end

      it 'extracts DocumentProperties' do
        expect(doc.document_properties.author).to eq('Ronald Tse')
      end

      it 'has correct part count' do
        expect(doc.parts.length).to eq(17)
      end
    end
  end

  describe 'MimePackager round-trip' do
    MHTML_FIXTURES.each do |name, path|
      describe name do
        let(:doc) { parse_fixture(name) }
        let(:round_tripped) { round_trip(doc) }

        it 'preserves part count' do
          expect(round_tripped.parts.length).to eq(doc.parts.length)
        end

        it 'preserves body HTML exactly' do
          expect(round_tripped.body_html).to eq(doc.body_html)
        end

        it 'preserves DocumentProperties' do
          expect(round_tripped.document_properties.author).to eq(doc.document_properties.author)
          expect(round_tripped.document_properties.created).to eq(doc.document_properties.created)
        end

        it 'preserves filelist XML' do
          expect(round_tripped.filelist_xml).to eq(doc.filelist_xml)
        end

        it 'preserves color scheme mapping' do
          expect(round_tripped.color_scheme_mapping_xml).to eq(doc.color_scheme_mapping_xml)
        end

        it 'preserves image count' do
          expect(round_tripped.image_parts.length).to eq(doc.image_parts.length)
        end

        it 'preserves theme data' do
          expect(round_tripped.theme_part&.decoded_content).to eq(doc.theme_part&.decoded_content)
        end

        it 'produces valid MIME structure' do
          packager = Uniword::Infrastructure::MimePackager.new(doc)
          output = packager.build_mime_content

          expect(output).to start_with("MIME-Version: 1.0\r\n")
          expect(output).to include("Content-Type: multipart/related")
          expect(output).to include("--#{packager.boundary}--")
        end
      end
    end
  end

  describe 'Mhtml::Document API' do
    let(:doc) { parse_fixture('blank') }

    it 'provides text content' do
      expect(doc.text).to be_a(String)
    end

    it 'provides css_styles' do
      expect(doc.css_styles).to be_a(String)
    end

    it 'provides images hash' do
      expect(doc.images).to be_a(Hash)
    end

    it 'returns nil for missing parts' do
      expect(doc.header_html).to be_nil
      expect(doc.footer_html).to be_nil
    end

    it 'returns inspect string' do
      expect(doc.inspect).to include('Uniword::Mhtml::Document')
    end
  end

  describe 'Mhtml::Metadata models' do
    describe 'DocumentProperties' do
      it 'round-trips via lutaml-model' do
        xml = '<o:DocumentProperties xmlns:o="urn:schemas-microsoft-com:office:office">' \
              '<o:Author>Test Author</o:Author>' \
              '<o:Created>2025-01-01T00:00:00Z</o:Created>' \
              '<o:Pages>5</o:Pages>' \
              '</o:DocumentProperties>'

        props = Uniword::Mhtml::Metadata::DocumentProperties.from_xml(xml)
        expect(props.author).to eq('Test Author')
        expect(props.created).to eq('2025-01-01T00:00:00Z')
        expect(props.pages).to eq('5')

        xml_out = props.to_xml
        expect(xml_out).to include('<o:Author>Test Author</o:Author>')
        expect(xml_out).to include('<o:Created>2025-01-01T00:00:00Z</o:Created>')
      end
    end

    describe 'WordDocumentSettings' do
      it 'round-trips via lutaml-model' do
        xml = '<w:WordDocument xmlns:w="urn:schemas-microsoft-com:office:word">' \
              '<w:TrackMoves>false</w:TrackMoves>' \
              '<w:LidThemeOther>EN-US</w:LidThemeOther>' \
              '</w:WordDocument>'

        settings = Uniword::Mhtml::Metadata::WordDocumentSettings.from_xml(xml)
        expect(settings.track_moves).to eq('false')
        expect(settings.lid_theme_other).to eq('EN-US')

        xml_out = settings.to_xml
        expect(xml_out).to include('<w:TrackMoves>false</w:TrackMoves>')
      end
    end
  end

  describe 'MimePart types' do
    it 'creates HtmlPart for text/html' do
      part = Uniword::Mhtml::HtmlPart.new
      part.content_type = 'text/html'
      expect(part.html_content?).to be true
      expect(part.text_content?).to be true
    end

    it 'creates ImagePart for image/*' do
      part = Uniword::Mhtml::ImagePart.new
      part.content_type = 'image/png'
      part.content_location = 'cid:image001.png'
      expect(part.image_content?).to be true
      expect(part.image_format).to eq(:png)
      expect(part.filename).to eq('image001.png')
    end

    it 'creates ThemePart for officetheme' do
      part = Uniword::Mhtml::ThemePart.new
      part.content_type = 'application/vnd.ms-officetheme'
      expect(part.theme_content?).to be true
    end
  end
end
