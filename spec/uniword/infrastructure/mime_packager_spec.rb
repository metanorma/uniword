# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Infrastructure::MimePackager do
  let(:html_content) { '<html><body><p>Test content</p></body></html>' }
  let(:resources) { {} }
  let(:packager) { described_class.new(html_content, resources) }

  describe '#initialize' do
    it 'creates packager with HTML content' do
      expect(packager.html_content).to eq(html_content)
    end

    it 'creates packager with resources' do
      resources = { 'image.png' => 'binary_data' }
      packager = described_class.new(html_content, resources)
      expect(packager.resources).to eq(resources)
    end

    it 'creates packager with empty resources by default' do
      packager = described_class.new(html_content)
      expect(packager.resources).to eq({})
    end

    it 'generates unique boundary' do
      packager1 = described_class.new(html_content)
      packager2 = described_class.new(html_content)
      expect(packager1.boundary).not_to eq(packager2.boundary)
    end

    it 'boundary matches expected format' do
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
      packager.package(output_path)
      expect(File.exist?(output_path)).to be true
    end

    it 'raises ArgumentError for nil path' do
      expect { packager.package(nil) }.to raise_error(ArgumentError, /cannot be nil/)
    end

    it 'raises ArgumentError for empty path' do
      expect { packager.package('') }.to raise_error(ArgumentError, /cannot be empty/)
    end

    it 'writes valid MIME structure' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('MIME-Version: 1.0')
      expect(content).to include('Content-Type: multipart/related')
      expect(content).to include('boundary=')
    end

    it 'includes HTML content' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<html><body><p>Test content</p></body></html>')
      expect(content).to include('Content-Type: text/html; charset="utf-8"')
    end

    it 'includes filelist.xml' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('Content-Type: text/xml; charset="utf-8"')
      expect(content).to include('Content-Location: filelist.xml')
      expect(content).to include('<o:MainFile HRef="document.html"/>')
    end
  end

  describe 'image handling' do
    let(:output_path) { 'spec/tmp/test_with_images.doc' }
    let(:image_data) { 'fake_png_data' }
    let(:resources) { { 'image1.png' => image_data } }
    let(:html_with_image) { '<html><body><img src="image1.png"/></body></html>' }
    let(:packager) { described_class.new(html_with_image, resources) }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'includes image in MIME structure' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('Content-Type: image/png')
      expect(content).to include('Content-Location: image1.png')
      expect(content).to include('Content-Transfer-Encoding: base64')
    end

    it 'encodes image data as base64' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      encoded = Base64.strict_encode64(image_data)
      expect(content).to include(encoded)
    end

    it 'converts image src to cid: reference' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('src="cid:image1.png"')
      expect(content).not_to include('src="image1.png"')
    end

    it 'preserves data: URLs' do
      html = '<html><body><img src="data:image/png;base64,ABC123"/></body></html>'
      packager = described_class.new(html, {})
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('src="data:image/png;base64,ABC123"')
    end

    it 'preserves http: URLs' do
      html = '<html><body><img src="http://example.com/image.png"/></body></html>'
      packager = described_class.new(html, {})
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('src="http://example.com/image.png"')
    end

    it 'lists images in filelist.xml' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<o:File HRef="image1.png"/>')
    end

    it 'handles multiple images' do
      resources = {
        'image1.png' => 'data1',
        'image2.jpg' => 'data2',
        'image3.gif' => 'data3'
      }
      html = '<html><body><img src="image1.png"/><img src="image2.jpg"/></body></html>'
      packager = described_class.new(html, resources)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('Content-Type: image/png')
      expect(content).to include('Content-Type: image/jpeg')
      expect(content).to include('Content-Type: image/gif')
      expect(content).to include('<o:File HRef="image1.png"/>')
      expect(content).to include('<o:File HRef="image2.jpg"/>')
      expect(content).to include('<o:File HRef="image3.gif"/>')
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
      'page.html' => 'text/html; charset="utf-8"',
      'unknown.xyz' => 'application/octet-stream'
    }.each do |filename, expected_type|
      it "detects #{expected_type} for #{filename}" do
        resources = { filename => 'test_data' }
        packager = described_class.new(html_content, resources)
        packager.package(output_path)
        content = File.read(output_path, encoding: 'UTF-8')

        expect(content).to include("Content-Type: #{expected_type}")
      end
    end
  end

  describe 'VML image handling' do
    let(:output_path) { 'spec/tmp/test_vml.doc' }
    let(:image_data) { 'fake_image_data' }
    let(:resources) { { 'shape.png' => image_data } }
    let(:html_with_vml) do
      '<html><body><v:imagedata src="shape.png"/></body></html>'
    end
    let(:packager) { described_class.new(html_with_vml, resources) }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'converts VML imagedata src to cid: reference' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('src="cid:shape.png"')
    end
  end

  describe 'filelist.xml generation' do
    let(:output_path) { 'spec/tmp/test_filelist.doc' }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'generates valid XML structure' do
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<xml xmlns:o="urn:schemas-microsoft-com:office:office">')
      expect(content).to include('<o:MainFile HRef="document.html"/>')
      expect(content).to include('</xml>')
    end

    it 'includes all resources in filelist' do
      resources = {
        'image1.png' => 'data1',
        'image2.jpg' => 'data2',
        'style.css' => 'css_data'
      }
      packager = described_class.new(html_content, resources)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<o:File HRef="image1.png"/>')
      expect(content).to include('<o:File HRef="image2.jpg"/>')
      expect(content).to include('<o:File HRef="style.css"/>')
    end

    it 'accepts custom filelist.xml' do
      custom_filelist = '<xml><custom>content</custom></xml>'
      packager = described_class.new(html_content, {}, filelist_xml: custom_filelist)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<custom>content</custom>')
    end
  end

  describe 'base64 encoding' do
    let(:output_path) { 'spec/tmp/test_encoding.doc' }
    let(:long_data) { 'A' * 200 }
    let(:resources) { { 'large.png' => long_data } }

    before do
      FileUtils.mkdir_p('spec/tmp')
    end

    after do
      FileUtils.rm_f(output_path)
    end

    it 'wraps base64 at 76 characters' do
      packager = described_class.new(html_content, resources)
      packager.package(output_path)
      content = File.read(output_path, encoding: 'UTF-8')

      # Find the base64 encoded section
      encoded_section = content.split('Content-Transfer-Encoding: base64').last
      lines = encoded_section.split("\r\n")

      # Check that base64 lines don't exceed 76 characters
      # Start checking after Content-Location header and skip boundaries
      in_base64 = false
      lines.each do |line|
        if line.start_with?('Content-Location:')
          in_base64 = true
          next
        end
        next unless in_base64
        next if line.strip.empty?
        break if line.start_with?('--')

        # Only check actual base64 content lines (alphanumeric + / + =)
        next unless line.match?(%r{^[A-Za-z0-9+/=]+$})

        expect(line.length).to be <= 76
      end
    end
  end

  describe 'boundary uniqueness' do
    it 'generates different boundaries for different instances' do
      boundaries = 10.times.map do
        described_class.new(html_content).boundary
      end

      expect(boundaries.uniq.length).to eq(10)
    end

    it 'uses boundary consistently within document' do
      packager.package('spec/tmp/test_boundary.doc')
      content = File.read('spec/tmp/test_boundary.doc', encoding: 'UTF-8')

      boundary = packager.boundary
      expect(content.scan(/#{Regexp.escape(boundary)}/).count).to be > 3

      FileUtils.rm_f('spec/tmp/test_boundary.doc')
    end
  end
end
