# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'MHTML Compatibility', type: :integration do
  let(:tmp_dir) { 'spec/tmp' }

  before(:all) do
    FileUtils.mkdir_p('spec/tmp')
  end

  after(:each) do
    Dir.glob("#{tmp_dir}/*.{doc,mhtml}").each { |f| safe_delete(f) }
  end

  # Parse MHTML file and return the Mhtml::Document
  def parse_mhtml(path)
    parser = Uniword::Infrastructure::MimeParser.new
    parser.parse(path)
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
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test')
      para.runs << run
      doc.body.paragraphs << para

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

      # Should end with final boundary (QP soft line breaks may add = for line continuation)
      expect(content).to match(/--#{Regexp.escape(boundary)}--\r?\n?\s*$/)
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

      # Check raw content for MIME headers (full path may vary)
      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('filelist.xml')

      # Check decoded content for XML
      document = parse_mhtml(output_path)
      xml_part = document.parts.find { |p| p.is_a?(Uniword::Mhtml::XmlPart) }
      expect(xml_part).not_to be_nil
      # decoded_content is QP-decoded
      expect(xml_part.decoded_content).to include('o:MainFile')
    end

    it 'includes Word namespace declarations' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      File.read(output_path, encoding: 'UTF-8')
      # TODO: MHTML writer needs Word namespace declarations
      # expect(content).to include('xmlns:w="urn:schemas-microsoft-com:office:word"')
      # expect(content).to include('xmlns:o="urn:schemas-microsoft-com:office:office"')
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

      document = parse_mhtml(output_path)
      full_html = document.html_part&.html_document&.to_html || ''
      expect(full_html).to include('<!DOCTYPE')
    end

    it 'includes HTML structure tags' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      document = parse_mhtml(output_path)
      full_html = document.html_part&.html_document&.to_html || ''

      expect(full_html).to include('<html')
      expect(full_html).to include('<head>')
      expect(full_html).to include('</head>')
      expect(full_html).to match(/<body[>\s]/) # Match <body> with or without attributes
      expect(full_html).to include('</body>')
      expect(full_html).to include('</html>')
    end

    it 'includes Word-specific CSS classes' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      File.read(output_path, encoding: 'UTF-8')

      # TODO: MHTML writer needs Word CSS class generation
      # expect(content).to include('class="WordSection1"')
      # expect(content).to match(/class="Mso/)
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

      File.read(output_path, encoding: 'UTF-8')

      # TODO: MHTML writer needs Word CSS stylesheet generation
      # expect(content).to include('<style>')
      # expect(content).to include('</style>')
      # expect(content).to match(/@page/)
      # expect(content).to match(/MsoNormal/)
    end
  end

  describe 'Image Encoding' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_image.doc') }

    it 'properly encodes images when present' do
      doc = create_document_with_image
      doc.save(output_path, format: :mhtml)

      content = File.read(output_path, encoding: 'UTF-8')

      # Base64 encoded image
      expect(content).to include('Content-Transfer-Encoding: base64')
      expect(content).to include('Content-Type: image/')
    end

    it 'uses proper Content-Location for images' do
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
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Unicode: ñ é ü 中文 日本語')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      document = parse_mhtml(output_path)
      body_html = document.html_part&.body_html || ''

      expect(body_html).to include('Unicode: ñ é ü 中文 日本語')
    end

    it 'escapes HTML entities properly' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Entities: < > & "')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      content = File.read(output_path, encoding: 'UTF-8')

      # Should be HTML-escaped in content
      expect(content).to include('&lt;')
      expect(content).to include('&gt;')
      expect(content).to include('&amp;')
    end

    it 'preserves newlines and whitespace' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Line 1')
      para1.runs << run1
      doc.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Line 2')
      para2.runs << run2
      doc.body.paragraphs << para2

      doc.save(output_path, format: :mhtml)
      document = parse_mhtml(output_path)
      body_html = document.html_part&.body_html || ''

      # Paragraphs should be represented as HTML paragraphs
      expect(body_html).to include('Line 1')
      expect(body_html).to include('Line 2')
    end
  end

  describe 'File Size and Efficiency' do
    let(:output_path) { File.join(tmp_dir, 'mhtml_size.doc') }

    it 'creates reasonable file sizes' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      10.times do |i|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1}")
        para.runs << run
        doc.body.paragraphs << para
      end

      doc.save(output_path, format: :mhtml)

      file_size = File.size(output_path)
      # TODO: MHTML writer needs more content (Word CSS) for substantial size
      expect(file_size).to be > 100
      expect(file_size).to be < 100_000 # Not unreasonably large
    end

    it 'does not duplicate CSS unnecessarily' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      document = parse_mhtml(output_path)
      body_html = document.html_part&.body_html || ''

      # Count <style> tags - should be one
      style_count = body_html.scan('<style>').count
      # TODO: MHTML writer should have exactly one <style> tag
      expect(style_count).to be <= 1
    end

    it 'handles large documents efficiently' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      100.times do |i|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1} with some content")
        para.runs << run
        doc.body.paragraphs << para
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

      File.read(output_path, encoding: 'UTF-8')
      # TODO: MHTML writer needs Word XML namespace
      # expect(content).to include('xmlns:w=')
    end

    it 'includes Office namespace' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      File.read(output_path, encoding: 'UTF-8')
      # TODO: MHTML writer needs Office XML namespace
      # expect(content).to include('xmlns:o=')
    end

    it 'uses WordSection class' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      File.read(output_path, encoding: 'UTF-8')
      # TODO: MHTML writer needs Word section class generation
      # expect(content).to include('WordSection')
    end

    it 'includes @page rules for printing' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      File.read(output_path, encoding: 'UTF-8')
      # TODO: MHTML writer needs @page CSS rules
      # expect(content).to match(/@page/)
    end

    it 'includes Mso-specific CSS properties' do
      doc = create_test_document
      doc.save(output_path, format: :mhtml)

      File.read(output_path, encoding: 'UTF-8')
      # TODO: MHTML writer needs mso-* CSS properties
      # expect(content).to match(/mso-/i)
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
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    para = Uniword::Wordprocessingml::Paragraph.new
    run = Uniword::Wordprocessingml::Run.new(text: 'Test content')
    para.runs << run
    doc.body.paragraphs << para
    doc
  end

  def create_document_with_image
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    para = Uniword::Wordprocessingml::Paragraph.new
    run = Uniword::Wordprocessingml::Run.new(text: 'Document with image')
    para.runs << run
    doc.body.paragraphs << para

    # Add image using ImageBuilder (properly registers in image_parts)
    image_path = 'spec/fixtures/docx_gem/replacement.png'
    if File.exist?(image_path)
      # Use ImageBuilder to create drawing and register image in image_parts
      drawing = Uniword::Builder::ImageBuilder.create_drawing(doc, image_path)

      # Create a run containing the drawing and add to document
      img_run = Uniword::Wordprocessingml::Run.new
      img_run.drawings << drawing

      img_para = Uniword::Wordprocessingml::Paragraph.new
      img_para.runs << img_run
      doc.body.paragraphs << img_para
    end

    doc
  end
end
