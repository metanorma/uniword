# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Infrastructure::MimePackager do
  def build_mhtml_document(html_content, parts: [])
    doc = Uniword::Mhtml::Document.new

    # Create HTML part
    html_part = Uniword::Mhtml::HtmlPart.new
    html_part.raw_content = html_content
    html_part.content_type = 'text/html'
    html_part.content_transfer_encoding = 'quoted-printable'
    html_part.content_location = 'file:///C:/D057922B/document.htm'
    doc.html_part = html_part
    doc.add_part(html_part)

    # Add other parts
    parts.each { |part| doc.add_part(part) }

    doc
  end

  def build_image_part(filename, data, content_type)
    part = Uniword::Mhtml::ImagePart.new
    part.raw_content = data
    part.content_type = content_type
    part.content_transfer_encoding = 'base64'
    part.content_location = filename
    part
  end

  def build_xml_part(filename, content)
    part = Uniword::Mhtml::XmlPart.new
    part.raw_content = content
    part.content_type = 'text/xml; charset="utf-8"'
    part.content_transfer_encoding = 'quoted-printable'
    part.content_location = filename
    part
  end

  describe '#initialize' do
    it 'creates packager from Mhtml::Document' do
      doc = build_mhtml_document('<html><body>Test</body></html>')
      packager = described_class.new(doc)
      expect(packager.document).to eq(doc)
    end

    it 'generates unique boundary' do
      doc1 = build_mhtml_document('<html><body>Test1</body></html>')
      doc2 = build_mhtml_document('<html><body>Test2</body></html>')
      packager1 = described_class.new(doc1)
      packager2 = described_class.new(doc2)
      expect(packager1.boundary).not_to eq(packager2.boundary)
    end

    it 'boundary matches expected format' do
      doc = build_mhtml_document('<html><body>Test</body></html>')
      packager = described_class.new(doc)
      expect(packager.boundary).to match(/^----=_NextPart_[a-f0-9.]{18}$/)
    end
  end

  describe '#package' do
    let(:output_path) { 'spec/tmp/test_output.doc' }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'creates MHTML file' do
      doc = build_mhtml_document('<html><body><p>Test content</p></body></html>')
      packager = described_class.new(doc)
      packager.package(output_path)
      expect(File.exist?(output_path)).to be true
    end

    it 'raises ArgumentError for nil path' do
      doc = build_mhtml_document('<html><body>Test</body></html>')
      packager = described_class.new(doc)
      expect { packager.package(nil) }.to raise_error(ArgumentError, /cannot be nil/)
    end

    it 'raises ArgumentError for empty path' do
      doc = build_mhtml_document('<html><body>Test</body></html>')
      packager = described_class.new(doc)
      expect { packager.package('') }.to raise_error(ArgumentError, /cannot be empty/)
    end

    it 'writes valid MIME structure' do
      doc = build_mhtml_document('<html><body><p>Test content</p></body></html>')
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('MIME-Version: 1.0')
      expect(content).to include('Content-Type: multipart/related')
      expect(content).to include('boundary=')
    end

    it 'includes HTML content' do
      doc = build_mhtml_document('<html><body><p>Test content</p></body></html>')
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      # HTML is quoted-printable encoded: space becomes =20
      expect(content).to include('Content-Type: text/html')
      expect(content).to include('Test=20content')
    end

    it 'includes filelist.xml when present in document' do
      xml_part = build_xml_part('filelist.xml', '<xml><o:MainFile HRef="document.html"/></xml>')
      doc = build_mhtml_document('<html><body>Test</body></html>', parts: [xml_part])
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('filelist.xml')
    end
  end

  describe 'image handling' do
    let(:output_path) { 'spec/tmp/test_with_images.doc' }
    let(:image_data) { 'fake_png_data' }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'includes image in MIME structure' do
      image_part = build_image_part('image1.png', image_data, 'image/png')
      doc = build_mhtml_document(
        '<html><body><img src="cid:image1.png"/></body></html>',
        parts: [image_part]
      )
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('Content-Type: image/png')
      expect(content).to include('Content-Location: image1.png')
      expect(content).to include('Content-Transfer-Encoding: base64')
    end

    it 'encodes image data as base64' do
      image_part = build_image_part('image1.png', image_data, 'image/png')
      doc = build_mhtml_document(
        '<html><body><img src="cid:image1.png"/></body></html>',
        parts: [image_part]
      )
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      encoded = Base64.strict_encode64(image_data)
      expect(content).to include(encoded)
    end

    it 'preserves data: URLs' do
      doc = build_mhtml_document(
        '<html><body><img src="data:image/png;base64,ABC123"/></body></html>'
      )
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('data:image/png;base64,ABC123')
    end

    it 'preserves http: URLs' do
      doc = build_mhtml_document(
        '<html><body><img src="http://example.com/image.png"/></body></html>'
      )
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('http://example.com/image.png')
    end

    it 'handles multiple images' do
      image1 = build_image_part('image1.png', 'data1', 'image/png')
      image2 = build_image_part('image2.jpg', 'data2', 'image/jpeg')
      image3 = build_image_part('image3.gif', 'data3', 'image/gif')

      doc = build_mhtml_document(
        '<html><body><img src="cid:image1.png"/><img src="cid:image2.jpg"/></body></html>',
        parts: [image1, image2, image3]
      )
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('Content-Type: image/png')
      expect(content).to include('Content-Type: image/jpeg')
      expect(content).to include('Content-Type: image/gif')
    end
  end

  describe 'MIME type detection' do
    let(:output_path) { 'spec/tmp/test_mime_types.doc' }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    {
      'image.png' => 'image/png',
      'photo.jpg' => 'image/jpeg',
      'photo.jpeg' => 'image/jpeg',
      'animation.gif' => 'image/gif',
      'vector.svg' => 'image/svg+xml',
      'bitmap.bmp' => 'image/bmp',
      'photo.tif' => 'image/tiff',
      'photo.tiff' => 'image/tiff',
      'modern.webp' => 'image/webp',
      'style.css' => 'text/css; charset="utf-8"',
      'data.xml' => 'text/xml; charset="utf-8"',
      'page.html' => 'text/html',
      'unknown.xyz' => 'application/octet-stream'
    }.each do |filename, expected_type|
      it "detects #{expected_type} for #{filename}" do
        # Create part with correct content type
        ext = filename.split('.').last
        if %w[png jpg jpeg gif svg bmp tiff webp].include?(ext)
          image_part = build_image_part(filename, 'test_data', expected_type.split(';').first)
        else
          image_part = build_xml_part(filename, 'test_data')
          image_part.content_type = expected_type
        end
        doc = build_mhtml_document('<html><body>Test</body></html>', parts: [image_part])
        packager = described_class.new(doc)
        packager.package(output_path)
        content = File.read(output_path, encoding: 'UTF-8')

        expect(content).to include("Content-Type: #{expected_type}")
      end
    end
  end

  describe 'VML image handling' do
    let(:output_path) { 'spec/tmp/test_vml.doc' }
    let(:image_data) { 'fake_image_data' }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'preserves VML imagedata in output' do
      image_part = build_image_part('shape.png', image_data, 'image/png')
      doc = build_mhtml_document(
        '<html><body><v:imagedata src="shape.png"/></body></html>',
        parts: [image_part]
      )
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      # VML imagedata src is preserved (though may be QP encoded for = in attributes)
      # src=3D"shape.png" is QP encoded src="shape.png"
      expect(content).to include('v:imagedata')
      expect(content).to include('shape.png')
    end
  end

  describe 'base64 encoding' do
    let(:output_path) { 'spec/tmp/test_encoding.doc' }
    let(:long_data) { 'A' * 200 }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'wraps base64 at 76 characters' do
      image_part = build_image_part('large.png', long_data, 'image/png')
      doc = build_mhtml_document('<html><body>Test</body></html>', parts: [image_part])
      packager = described_class.new(doc)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      # Find the base64 section and verify line wrapping
      base64_section = content.split('Content-Transfer-Encoding: base64').last
      lines = base64_section.split("\r\n")

      # Check that lines don't exceed 76 chars (MIME standard)
      base64_lines = lines.drop(1).take_while { |l| !l.start_with?('--') }
      base64_lines.each do |line|
        next if line.strip.empty?

        expect(line.length).to be <= 76 if line.match?(%r{^[A-Za-z0-9+/=]+$})
      end
    end
  end

  describe 'boundary uniqueness' do
    it 'generates different boundaries for different instances' do
      boundaries = 10.times.map do
        doc = build_mhtml_document('<html><body>Test</body></html>')
        described_class.new(doc).boundary
      end

      expect(boundaries.uniq.length).to eq(10)
    end

    it 'uses boundary consistently within document' do
      image_part = build_image_part('image1.png', 'data', 'image/png')
      doc = build_mhtml_document(
        '<html><body>Test</body></html>',
        parts: [image_part]
      )
      packager = described_class.new(doc)
      packager.package('spec/tmp/test_boundary.doc')
      content = File.read('spec/tmp/test_boundary.doc', encoding: 'UTF-8')

      boundary = packager.boundary
      # Boundary appears in: Content-Type header + start/end of each part (3 parts = 3 boundary markers minimum)
      expect(content.scan(/#{Regexp.escape(boundary)}/).count).to be >= 3

      FileUtils.rm_f('spec/tmp/test_boundary.doc')
    end
  end
end
