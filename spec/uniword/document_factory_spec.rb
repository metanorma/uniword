# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Uniword::DocumentFactory do
  describe '.create' do
    it 'creates a new empty document' do
      document = described_class.create

      expect(document).to be_a(Uniword::Document)
      expect(document.paragraphs).to be_empty
    end

    it 'creates documents with independent state' do
      doc1 = described_class.create
      doc2 = described_class.create

      expect(doc1).not_to equal(doc2)
    end
  end

  describe '.from_file' do
    context 'with DOCX file' do
      let(:docx_file) { Tempfile.new(['test', '.docx']) }

      before do
        # Create a minimal DOCX file
        packager = Uniword::Infrastructure::ZipPackager.new
        content = {
          'word/document.xml' => '<document></document>',
          '[Content_Types].xml' => '<Types></Types>'
        }
        packager.package(content, docx_file.path)
      end

      after do
        docx_file.unlink
      end

      it 'loads DOCX file with auto format detection' do
        document = described_class.from_file(docx_file.path)

        expect(document).to be_a(Uniword::Document)
      end

      it 'loads DOCX file with explicit format' do
        document = described_class.from_file(docx_file.path, format: :docx)

        expect(document).to be_a(Uniword::Document)
      end
    end

    context 'with MHTML file' do
      let(:mhtml_file) { Tempfile.new(['test', '.mhtml']) }

      before do
        content = <<~MHTML
          MIME-Version: 1.0
          Content-Type: multipart/related; boundary="----=_NextPart_000"

          ------=_NextPart_000
          Content-Type: text/html
          Content-Location: file:///test.html

          <html><body><p>Test</p></body></html>
          ------=_NextPart_000--
        MHTML
        File.write(mhtml_file.path, content)
      end

      after do
        mhtml_file.unlink
      end

      it 'loads MHTML file with auto format detection' do
        document = described_class.from_file(mhtml_file.path)

        expect(document).to be_a(Uniword::Mhtml::Document)
      end

      it 'loads MHTML file with explicit format' do
        document = described_class.from_file(mhtml_file.path, format: :mhtml)

        expect(document).to be_a(Uniword::Mhtml::Document)
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when path is nil' do
        expect { described_class.from_file(nil) }.to raise_error(
          ArgumentError,
          'Path cannot be nil'
        )
      end

      it 'raises ArgumentError when path is empty' do
        expect { described_class.from_file('') }.to raise_error(
          ArgumentError,
          'Path cannot be empty'
        )
      end

      it 'raises FileNotFoundError when file does not exist' do
        expect { described_class.from_file('nonexistent.docx') }.to raise_error(
          Uniword::FileNotFoundError,
          /File not found/
        )
      end

      it 'raises ArgumentError when format is not supported' do
        temp_file = Tempfile.new(['test', '.docx'])
        begin
          expect do
            described_class.from_file(temp_file.path, format: :invalid)
          end.to raise_error(ArgumentError, /Unsupported format/)
        ensure
          temp_file.unlink
        end
      end
    end
  end

  describe '.detect_format' do
    context 'with DOCX file' do
      it 'detects DOCX format' do
        docx_file = Tempfile.new(['test', '.docx'])
        begin
          packager = Uniword::Infrastructure::ZipPackager.new
          packager.package({ 'test.xml' => '<test/>' }, docx_file.path)

          format = described_class.detect_format(docx_file.path)

          expect(format).to eq(:docx)
        ensure
          docx_file.unlink
        end
      end
    end

    context 'with MHTML file' do
      it 'detects MHTML format' do
        mhtml_file = Tempfile.new(['test', '.mhtml'])
        begin
          File.write(mhtml_file.path, 'MIME-Version: 1.0')

          format = described_class.detect_format(mhtml_file.path)

          expect(format).to eq(:mhtml)
        ensure
          mhtml_file.unlink
        end
      end

      it 'detects MHT format' do
        mht_file = Tempfile.new(['test', '.mht'])
        begin
          File.write(mht_file.path, 'MIME-Version: 1.0')

          format = described_class.detect_format(mht_file.path)

          expect(format).to eq(:mhtml)
        ensure
          mht_file.unlink
        end
      end
    end

    context 'with unsupported file' do
      it 'raises ArgumentError for unknown format' do
        txt_file = Tempfile.new(['test', '.txt'])
        begin
          File.write(txt_file.path, 'test content')

          expect do
            described_class.detect_format(txt_file.path)
          end.to raise_error(ArgumentError, /Unsupported file extension/)
        ensure
          txt_file.unlink
        end
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when path is nil' do
        expect { described_class.detect_format(nil) }.to raise_error(
          ArgumentError,
          /Path cannot be nil/
        )
      end

      it 'raises ArgumentError when file does not exist' do
        expect do
          described_class.detect_format('nonexistent.docx')
        end.to raise_error(ArgumentError, /File not found/)
      end
    end
  end
end
