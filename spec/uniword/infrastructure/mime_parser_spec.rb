# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Infrastructure::MimeParser do
  let(:parser) { described_class.new }

  describe '#parse' do
    context 'with invalid input' do
      it 'raises error when path is nil' do
        expect { parser.parse(nil) }.to raise_error(ArgumentError, /Path cannot be nil/)
      end

      it 'raises error when file does not exist' do
        expect { parser.parse('nonexistent.mhtml') }.to raise_error(ArgumentError, /File not found/)
      end
    end

    context 'with valid MHTML content' do
      let(:mhtml_content) do
        <<~MHTML
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="----=_NextPart_test"

          ------=_NextPart_test
          Content-Location: file:///C:/test.htm
          Content-Type: text/html; charset="utf-8"

          <html><body><p>Test content</p></body></html>

          ------=_NextPart_test
          Content-Location: file:///C:/filelist.xml
          Content-Type: text/xml

          <xml><o:File HRef="test.png"/></xml>

          ------=_NextPart_test--
        MHTML
      end

      it 'extracts HTML content' do
        result = parser.parse_content(mhtml_content)
        expect(result).to be_a(Uniword::Mhtml::Document)
        expect(result.raw_html).to include('<html><body><p>Test content</p></body></html>')
      end

      it 'extracts filelist content' do
        result = parser.parse_content(mhtml_content)
        expect(result.filelist_xml).to include('<o:File HRef="test.png"/>')
      end

      it 'returns images hash' do
        result = parser.parse_content(mhtml_content)
        expect(result.images).to be_a(Hash)
      end
    end

    context 'with base64 encoded images' do
      let(:mhtml_with_image) do
        <<~MHTML
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="----=_NextPart_img"

          ------=_NextPart_img
          Content-Type: text/html

          <html><body><img src="cid:test.png"/></body></html>

          ------=_NextPart_img
          Content-Location: file:///C:/test.png
          Content-Type: image/png
          Content-Transfer-Encoding: base64

          iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==

          ------=_NextPart_img--
        MHTML
      end

      it 'decodes base64 images' do
        result = parser.parse_content(mhtml_with_image)
        images = result.images
        expect(images).to have_key('test.png')
        expect(images['test.png']).to be_a(String)
        expect(images['test.png'].encoding).to eq(Encoding::ASCII_8BIT)
      end
    end

    context 'with quoted-printable encoding' do
      let(:mhtml_qp) do
        <<~MHTML
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="----=_NextPart_qp"

          ------=_NextPart_qp
          Content-Type: text/html
          Content-Transfer-Encoding: quoted-printable

          <html>=0D=0A<body>=0D=0A<p>Test</p>=0D=0A</body>=0D=0A</html>

          ------=_NextPart_qp--
        MHTML
      end

      it 'decodes quoted-printable content' do
        result = parser.parse_content(mhtml_qp)
        expect(result.raw_html).to include('<html>')
        expect(result.raw_html).to include('<p>Test</p>')
      end
    end

    context 'boundary extraction' do
      it 'extracts boundary with quotes' do
        content = 'Content-Type: multipart/related; boundary="----=_Test_123"'
        result = parser.parse_content("#{content}\n\n------=_Test_123\n\n------=_Test_123--")
        expect { result }.not_to raise_error
      end

      it 'extracts boundary without quotes' do
        content = 'Content-Type: multipart/related; boundary=----=_Test_456'
        result = parser.parse_content("#{content}\n\n------=_Test_456\n\n------=_Test_456--")
        expect { result }.not_to raise_error
      end

      it 'raises error when no boundary found' do
        expect { parser.parse_content('No boundary here') }.to raise_error(/No MIME boundary found/)
      end
    end

    context 'filename extraction' do
      let(:mhtml_filenames) do
        <<~MHTML
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="----=_NextPart_fn"

          ------=_NextPart_fn
          Content-Location: file:///C:/path/to/image1.png
          Content-Type: image/png

          data1

          ------=_NextPart_fn
          Content-Location: cid:image2.jpg
          Content-Type: image/jpeg

          data2

          ------=_NextPart_fn
          Content-Location: image3.gif
          Content-Type: image/gif

          data3

          ------=_NextPart_fn--
        MHTML
      end

      it 'extracts filenames from various location formats' do
        result = parser.parse_content(mhtml_filenames)
        images = result.images
        expect(images).to have_key('image1.png')
        expect(images).to have_key('image2.jpg')
        expect(images).to have_key('image3.gif')
      end
    end
  end

  describe '#parse_content' do
    it 'returns Mhtml::Document with expected parts' do
      content = <<~MHTML
        Content-Type: multipart/related; boundary="test"

        --test
        Content-Type: text/html

        <html></html>
        --test--
      MHTML

      result = parser.parse_content(content)
      expect(result).to be_a(Uniword::Mhtml::Document)
      expect(result.html_part).to be_a(Uniword::Mhtml::HtmlPart)
      expect(result.images).to be_a(Hash)
    end

    it 'handles empty parts gracefully' do
      content = <<~MHTML
        Content-Type: multipart/related; boundary="empty"

        --empty

        --empty--
      MHTML

      result = parser.parse_content(content)
      expect(result).to be_a(Uniword::Mhtml::Document)
      expect(result.html_part).to be_nil
      expect(result.images).to eq({})
    end
  end
end
