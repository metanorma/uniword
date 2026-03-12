# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'MHTML Compatibility', type: :integration do
  let(:tmp_dir) { 'spec/tmp' }

  before(:all) do
    FileUtils.mkdir_p('spec/tmp')
  end

  after(:each) do
    Dir.glob("#{tmp_dir}/*.{doc,mhtml}").each { |f| File.delete(f) }
  end

  describe 'MIME Structure Validation' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_compat.doc') }

    it 'generates valid MIME structure' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Verify MIME headers
      expect(content).to include('MIME-Version: 1.0')
      expect(content).to include('Content-Type: multipart/related')
      expect(content).to match(/boundary="----=_NextPart_/)
    end

    it 'includes proper MIME version header' do
      doc = Uniword::Document.new
      doc.add_paragraph('Test')

      doc.save(output_path, format: :mhtml)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to match(/^MIME-Version: 1\.0/)
    end

    it 'includes multipart/related content type' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('Content-Type: multipart/related')
    end

    it 'uses consistent boundary markers' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Extract boundary from header
      boundary_match = content.match(/boundary="([^"]+)"/)
      expect(boundary_match).not_to be_nil

      boundary = boundary_match[1]

      # Verify boundary is used in content
      expect(content).to include("--#{boundary}")
      expect(content).to include("--#{boundary}--")
    end

    it 'properly terminates MIME parts' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Extract boundary
      boundary_match = content.match(/boundary="([^"]+)"/)
      boundary = boundary_match[1]

      # Should end with final boundary
      expect(content).to end_with("--#{boundary}--\n")
    end
  end

  describe 'Required MIME Parts' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_parts.doc') }

    it 'includes HTML content part' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # HTML content type
      expect(content).to include('Content-Type: text/html')
      expect(content).to include('<html')
      expect(content).to include('</html>')
    end

    it 'includes charset declaration' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('charset=')
    end

    it 'includes filelist.xml' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Filelist part
      expect(content).to include('Content-Location: filelist.xml')
      expect(content).to include('<o:MainFile')
    end

    it 'includes Word namespace declarations' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('xmlns:w="urn:schemas-microsoft-com:office:word"')
      expect(content).to include('xmlns:o="urn:schemas-microsoft-com:office:office"')
    end

    it 'includes Content-Transfer-Encoding for text parts' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to match(/Content-Transfer-Encoding:\s*(quoted-printable|7bit|8bit)/)
    end
  end

  describe 'HTML Content Structure' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_html.doc') }

    it 'includes DOCTYPE declaration' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('<!DOCTYPE')
    end

    it 'includes HTML structure tags' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<html')
      expect(content).to include('<head>')
      expect(content).to include('</head>')
      expect(content).to match(/<body[>\s]/) # Match <body> with or without attributes
      expect(content).to include('</body>')
      expect(content).to include('</html>')
    end

    it 'includes Word-specific CSS classes' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Word-specific classes
      expect(content).to include('class="WordSection1"')
      expect(content).to match(/class="Mso/)
    end

    it 'includes proper meta tags' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<meta')
      expect(content).to match(/<meta[^>]*charset/)
    end

    it 'includes Word styles in head section' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('<style>')
      expect(content).to include('</style>')
      expect(content).to match(/@page/)
      expect(content).to match(/MsoNormal/)
    end
  end

  describe 'Image Encoding' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_image.doc') }

    it 'properly encodes images when present' do
      # Skip if no image support yet
      skip 'Image support not yet implemented' unless defined?(Uniword::Image)

      doc = create_document_with_image
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Base64 encoded image
      expect(content).to include('Content-Transfer-Encoding: base64')
      expect(content).to include('Content-Type: image/')
    end

    it 'uses proper Content-Location for images' do
      # Skip if no image support yet
      skip 'Image support not yet implemented' unless defined?(Uniword::Image)

      doc = create_document_with_image
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to match(/Content-Location:.*\.(png|jpg|jpeg|gif)/)
    end
  end

  describe 'Character Encoding' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_encoding.doc') }

    it 'declares UTF-8 encoding' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to match(/charset="?utf-8"?/i)
    end

    it 'handles Unicode characters correctly' do
      doc = Uniword::Document.new
      doc.add_paragraph('Unicode: ñ é ü 中文 日本語')

      doc.save(output_path, format: :mhtml)
      content = File.read(output_path, encoding: 'UTF-8')

      expect(content).to include('Unicode: ñ é ü 中文 日本語')
    end

    it 'escapes HTML entities properly' do
      doc = Uniword::Document.new
      doc.add_paragraph('Entities: < > & "')

      doc.save(output_path, format: :mhtml)
      content = File.read(output_path, encoding: 'UTF-8')

      # Should be HTML-escaped in content
      expect(content).to include('&lt;')
      expect(content).to include('&gt;')
      expect(content).to include('&amp;')
    end

    it 'preserves newlines and whitespace' do
      doc = Uniword::Document.new
      doc.add_paragraph('Line 1')
      doc.add_paragraph('Line 2')

      doc.save(output_path, format: :mhtml)
      content = File.read(output_path, encoding: 'UTF-8')

      # Paragraphs should be represented as HTML paragraphs
      expect(content).to include('Line 1')
      expect(content).to include('Line 2')
    end
  end

  describe 'File Size and Efficiency' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_size.doc') }

    it 'creates reasonable file sizes' do
      doc = Uniword::Document.new

      10.times do |i|
        doc.add_paragraph("Paragraph #{i + 1}")
      end

      doc.save(output_path, format: :mhtml)

      file_size = File.size(output_path)
      expect(file_size).to be > 1000 # Has substantial content
      expect(file_size).to be < 100_000 # Not unreasonably large
    end

    it 'does not duplicate CSS unnecessarily' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Count <style> tags - should only be one
      style_count = content.scan('<style>').count
      expect(style_count).to eq(1)
    end

    it 'handles large documents efficiently' do
      doc = Uniword::Document.new

      100.times do |i|
        doc.add_paragraph("Paragraph #{i + 1} with some content")
      end

      doc.save(output_path, format: :mhtml)

      expect(File.exist?(output_path)).to be true
      file_size = File.size(output_path)
      expect(file_size).to be < 1_000_000 # Should be under 1MB
    end
  end

  describe 'Word Compatibility Features' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_word.doc') }

    it 'includes Word XML namespace' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('xmlns:w=')
    end

    it 'includes Office namespace' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('xmlns:o=')
    end

    it 'uses WordSection class' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('WordSection')
    end

    it 'includes @page rules for printing' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to match(/@page/)
    end

    it 'includes Mso-specific CSS properties' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to match(/mso-/i)
    end
  end

  describe 'Format Detection' do
    it 'detects .doc extension as MHTML' do
      doc = create_test_document
      doc_path = File.join(tmp_dir, 'test.doc')

      doc.save(doc_path)

      content = File.read(doc_path, encoding: 'UTF-8')
      expect(content).to include('MIME-Version')
      expect(content).to include('multipart/related')
    end

    it 'detects .mhtml extension as MHTML' do
      doc = create_test_document
      mhtml_path = File.join(tmp_dir, 'test.mhtml')

      doc.save(mhtml_path)

      content = File.read(mhtml_path, encoding: 'UTF-8')
      expect(content).to include('MIME-Version')
    end

    it 'detects .mht extension as MHTML' do
      doc = create_test_document
      mht_path = File.join(tmp_dir, 'test.mht')

      doc.save(mht_path)

      content = File.read(mht_path, encoding: 'UTF-8')
      expect(content).to include('MIME-Version')
    end
  end

  # Helper methods
  private

  def create_test_document
    doc = Uniword::Document.new
    doc.add_paragraph('Test content')
    doc
  end

  def create_document_with_image
    doc = Uniword::Document.new
    doc.add_paragraph('Document with image')

    # Add image if supported
    if defined?(Uniword::Image)
      # Load test image data
      image_path = 'spec/fixtures/docx_gem/replacement.png'
      if File.exist?(image_path)
        image_data = File.binread(image_path)
        image = Uniword::Image.from_data(
          image_data,
          width: 100 * 9525, # 100 pixels in EMUs
          height: 100 * 9525,
          alt_text: 'Test Image',
          title: 'Test Image'
        )
        image.filename = 'replacement.png'

        # Add image to a new paragraph
        img_para = Uniword::Paragraph.new
        img_para.add_run(image)
        doc.body&.paragraphs&.<<(img_para)
      end
    end

    doc
  end
end
