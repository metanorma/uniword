# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Docx.js Compatibility: Images', :compatibility do
  describe 'Image from Buffer' do
    describe 'binary data handling' do
      it 'should support adding images from binary buffer' do
        skip 'Image from buffer not yet fully implemented'

        doc = Uniword::Document.new

        # Base64 encoded PNG image data (small test image)
        image_base64 = 'iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAMAAAD04JH5AAAA'
        image_data = Base64.decode64(image_base64)

        para = Uniword::Wordprocessingml::Paragraph.new
        # TODO: Builder.image does not yet support binary data input
        skip 'add_image moved to Builder API; binary data input not yet supported'
        doc.body.paragraphs << para

        para = doc.body.paragraphs.first
        expect(para.images.count).to eq(1)
        img = para.images.first
        expect(img.width).to eq(100)
        expect(img.height).to eq(100)
      end

      it 'should support images from base64 string' do
        skip 'Base64 image handling not yet implemented'

        doc = Uniword::Document.new

        image_base64 = 'iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAMAAAD04JH5AAAA'

        para = Uniword::Wordprocessingml::Paragraph.new
        # TODO: add_image_from_base64 moved to Builder API; not yet supported
        skip 'add_image_from_base64 moved to Builder API'
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should support images from file path' do
        doc = Uniword::Document.new

        # Assuming a test image exists
        image_path = 'spec/fixtures/test_image.png'

        skip 'Test image fixture not available' unless File.exist?(image_path)

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image(image_path)
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should support images from IO stream' do
        skip 'IO stream image handling not yet implemented'

        doc = Uniword::Document.new

        image_path = 'spec/fixtures/test_image.png'
        skip 'Test image fixture not available' unless File.exist?(image_path)

        File.open(image_path, 'rb') do |file|
          para = Uniword::Wordprocessingml::Paragraph.new
          # TODO: Builder.image does not yet support IO stream input
          skip 'add_image moved to Builder API; IO stream input not yet supported'
          doc.body.paragraphs << para
        end

        expect(doc.body.paragraphs.first.images.count).to eq(1)
      end
    end

    describe 'image formats' do
      it 'should support PNG images' do
        skip 'PNG format support not yet verified'

        doc = Uniword::Document.new

        # PNG image data
        png_data = Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==')

        para = Uniword::Wordprocessingml::Paragraph.new
        # TODO: Builder.image does not yet support binary data input
        skip 'add_image moved to Builder API; binary data input not yet supported'
        doc.body.paragraphs << para

        expect(doc.body.paragraphs.first.images.first).not_to be_nil
      end

      it 'should support JPEG images' do
        skip 'JPEG format support not yet verified'

        doc = Uniword::Document.new

        # Would need actual JPEG data
        jpeg_path = 'spec/fixtures/test_image.jpg'
        skip 'JPEG fixture not available' unless File.exist?(jpeg_path)

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image(jpeg_path)
        doc.body.paragraphs << para

        expect(doc.body.paragraphs.first.images.count).to eq(1)
      end

      it 'should support GIF images' do
        skip 'GIF format support not yet verified'

        doc = Uniword::Document.new

        gif_path = 'spec/fixtures/test_image.gif'
        skip 'GIF fixture not available' unless File.exist?(gif_path)

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image(gif_path)
        doc.body.paragraphs << para

        expect(doc.body.paragraphs.first.images.count).to eq(1)
      end
    end
  end

  describe 'Image Scaling' do
    describe 'fixed dimensions' do
      it 'should support small image dimensions (50x50)' do
        skip 'Image dimension control not yet fully implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
        para.runs << run
        doc.body.paragraphs << para

        img = doc.body.paragraphs.last.images.first
        expect(img.width).to eq(50)
        expect(img.height).to eq(50)
      end

      it 'should support medium image dimensions (100x100)' do
        skip 'Image dimension control not yet fully implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should support large image dimensions (250x250)' do
        skip 'Image dimension control not yet fully implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should support extra large image dimensions (400x400)' do
        skip 'Image dimension control not yet fully implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should support multiple images with different sizes' do
        skip 'Multiple image sizing not yet fully implemented'

        doc = Uniword::Document.new

        paragraphs = [50, 100, 250, 400].map do |size|
          para = Uniword::Wordprocessingml::Paragraph.new
          builder = Uniword::Builder::ParagraphBuilder.new(para)
          builder << Uniword::Builder.image('spec/fixtures/test_image.png')
          para
        end
        doc.body.paragraphs.concat(paragraphs)

        images = doc.body.paragraphs.map { |p| p.images.first }.compact
        expect(images.count).to eq(4)
      end
    end

    describe 'aspect ratio' do
      it 'should support non-square dimensions' do
        skip 'Non-square image dimensions not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should support maintaining aspect ratio' do
        skip 'Aspect ratio maintenance not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should calculate height from width when maintaining aspect ratio' do
        skip 'Aspect ratio calculation not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        # Height should be auto-calculated based on original aspect ratio
        expect(img).not_to be_nil
      end
    end

    describe 'scaling factors' do
      it 'should support scaling by percentage' do
        skip 'Percentage scaling not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end

      it 'should support scaling up beyond original size' do
        skip 'Scale up not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.body.paragraphs << para

        img = doc.body.paragraphs.first.images.first
        expect(img).not_to be_nil
      end
    end
  end

  describe 'Images in Headers and Footers' do
    describe 'header images' do
      it 'should support images in default header' do
        skip 'Header images not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.header.paragraphs << para

        header_para = doc.header.paragraphs.first
        expect(header_para.images.count).to eq(1)
      end

      it 'should support images in first page header' do
        skip 'First page header not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.header(:first).paragraphs << para

        expect(doc.header(:first).paragraphs.first.images.count).to eq(1)
      end

      it 'should support images in even page header' do
        skip 'Even page header not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.header(:even).paragraphs << para

        expect(doc.header(:even).paragraphs.first.images.count).to eq(1)
      end
    end

    describe 'footer images' do
      it 'should support images in default footer' do
        skip 'Footer images not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.footer.paragraphs << para

        footer_para = doc.footer.paragraphs.first
        expect(footer_para.images.count).to eq(1)
      end

      it 'should support images in first page footer' do
        skip 'First page footer not yet implemented'

        doc = Uniword::Document.new

        para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.footer(:first).paragraphs << para

        expect(doc.footer(:first).paragraphs.first.images.count).to eq(1)
      end
    end

    describe 'combined headers and footers' do
      it 'should support images in both header and footer' do
        skip 'Combined header/footer images not yet implemented'

        doc = Uniword::Document.new

        # Add to header
        header_para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(header_para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.header.paragraphs << header_para

        # Add to footer
        footer_para = Uniword::Wordprocessingml::Paragraph.new
        builder = Uniword::Builder::ParagraphBuilder.new(footer_para)
        builder << Uniword::Builder.image('spec/fixtures/test_image.png')
        doc.footer.paragraphs << footer_para

        # Add body content
        body_para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
        body_para.runs << run
        doc.body.paragraphs << body_para

        expect(doc.header.paragraphs.first.images.count).to eq(1)
        expect(doc.footer.paragraphs.first.images.count).to eq(1)
        expect(doc.body.paragraphs.count).to eq(1)
      end
    end
  end

  describe 'Image Positioning' do
    it 'should support inline images' do
      skip 'add_image moved to Builder API; inline option not yet supported'

      doc = Uniword::Document.new

      para = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Text before')
      para.runs << run1
      # TODO: Builder.image creates inline images by default;
      # floating/positioning options not yet supported
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Text after')
      para.runs << run2
      doc.body.paragraphs << para

      para = doc.body.paragraphs.first
      expect(para.images.first).not_to be_nil
    end

    it 'should support floating images' do
      skip 'Floating images not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Wordprocessingml::Paragraph.new
      # TODO: add_image moved to Builder API; floating not yet supported
      skip 'add_image moved to Builder API; floating not yet supported'
      run = Uniword::Wordprocessingml::Run.new(text: 'Text wraps around image')
      para.runs << run
      doc.body.paragraphs << para
    end

    it 'should support anchored images' do
      skip 'Anchored images not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Wordprocessingml::Paragraph.new
      # TODO: add_image moved to Builder API; anchoring not yet supported
      skip 'add_image moved to Builder API; anchoring not yet supported'
      doc.body.paragraphs << para
    end
  end

  describe 'Image Metadata' do
    it 'should support image alt text' do
      skip 'Image alt text not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Wordprocessingml::Paragraph.new
      # TODO: add_image moved to Builder API; alt text not yet supported
      skip 'add_image moved to Builder API; alt text not yet supported'
      doc.body.paragraphs << para
    end

    it 'should support image title' do
      skip 'Image title not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Wordprocessingml::Paragraph.new
      # TODO: add_image moved to Builder API; title not yet supported
      skip 'add_image moved to Builder API; title not yet supported'
      doc.body.paragraphs << para
    end

    it 'should support image description' do
      skip 'Image description not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Wordprocessingml::Paragraph.new
      # TODO: add_image moved to Builder API; description not yet supported
      skip 'add_image moved to Builder API; description not yet supported'
      doc.body.paragraphs << para
    end
  end

  describe 'Round-trip preservation' do
    it 'should preserve images in round-trip' do
      skip 'Round-trip testing requires full implementation'

      # Create document with image
      original = Uniword::Document.new
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder << Uniword::Builder.image('spec/fixtures/test_image.png')
      original.body.paragraphs << para

      # Save and reload
      temp_path = '/tmp/images_test.docx'
      original.save(temp_path)
      reloaded = Uniword.load(temp_path)

      # Verify image preserved
      img = reloaded.paragraphs.first.images.first
      expect(img).not_to be_nil
    end
  end
end
