# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Uniword::FormatDetector do
  let(:detector) { described_class.new }

  describe '#detect' do
    context 'with DOCX file' do
      it 'detects DOCX by ZIP signature' do
        temp_file = Tempfile.new(['test', '.docx'])
        begin
          # Create a ZIP file (DOCX is a ZIP archive)
          packager = Uniword::Infrastructure::ZipPackager.new
          packager.package({ 'test.xml' => '<test/>' }, temp_file.path)

          format = detector.detect(temp_file.path)

          expect(format).to eq(:docx)
        ensure
          temp_file.unlink
        end
      end

      it 'detects DOCX by extension when signature missing' do
        temp_file = Tempfile.new(['test', '.docx'])
        begin
          # Write non-ZIP content
          File.write(temp_file.path, 'Not a ZIP file')

          format = detector.detect(temp_file.path)

          expect(format).to eq(:docx)
        ensure
          temp_file.unlink
        end
      end
    end

    context 'with MHTML file' do
      it 'detects MHTML by MIME header' do
        temp_file = Tempfile.new(['test', '.mhtml'])
        begin
          content = <<~MHTML
            MIME-Version: 1.0
            Content-Type: multipart/related

            <html><body>Test</body></html>
          MHTML
          File.write(temp_file.path, content)

          format = detector.detect(temp_file.path)

          expect(format).to eq(:mhtml)
        ensure
          temp_file.unlink
        end
      end

      it 'detects MHTML by .mhtml extension' do
        temp_file = Tempfile.new(['test', '.mhtml'])
        begin
          File.write(temp_file.path, 'Some content')

          format = detector.detect(temp_file.path)

          expect(format).to eq(:mhtml)
        ensure
          temp_file.unlink
        end
      end

      it 'detects MHTML by .mht extension' do
        temp_file = Tempfile.new(['test', '.mht'])
        begin
          File.write(temp_file.path, 'Some content')

          format = detector.detect(temp_file.path)

          expect(format).to eq(:mhtml)
        ensure
          temp_file.unlink
        end
      end
    end

    context 'with unsupported file' do
      it 'raises ArgumentError for unknown extension' do
        temp_file = Tempfile.new(['test', '.txt'])
        begin
          File.write(temp_file.path, 'Text content')

          expect { detector.detect(temp_file.path) }.to raise_error(
            ArgumentError,
            /Unsupported file extension/
          )
        ensure
          temp_file.unlink
        end
      end

      it 'raises ArgumentError for .pdf extension' do
        temp_file = Tempfile.new(['test', '.pdf'])
        begin
          File.write(temp_file.path, 'PDF content')

          expect { detector.detect(temp_file.path) }.to raise_error(
            ArgumentError,
            /Unsupported file extension/
          )
        ensure
          temp_file.unlink
        end
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when path is nil' do
        expect { detector.detect(nil) }.to raise_error(
          ArgumentError,
          'Path cannot be nil'
        )
      end

      it 'raises ArgumentError when path is empty' do
        expect { detector.detect('') }.to raise_error(
          ArgumentError,
          'Path cannot be empty'
        )
      end

      it 'raises ArgumentError when file does not exist' do
        expect { detector.detect('nonexistent.docx') }.to raise_error(
          ArgumentError,
          /File not found/
        )
      end

      it 'raises ArgumentError when path is a directory' do
        Dir.mktmpdir do |dir|
          expect { detector.detect(dir) }.to raise_error(
            ArgumentError,
            /Path is a directory/
          )
        end
      end
    end

    context 'with empty file' do
      it 'falls back to extension detection' do
        temp_file = Tempfile.new(['empty', '.docx'])
        begin
          # Empty file - no signature
          format = detector.detect(temp_file.path)

          expect(format).to eq(:docx)
        ensure
          temp_file.unlink
        end
      end
    end

    context 'signature detection priority' do
      it 'prefers signature over extension' do
        # Create a ZIP file with wrong extension
        temp_file = Tempfile.new(['test', '.mhtml'])
        begin
          packager = Uniword::Infrastructure::ZipPackager.new
          packager.package({ 'test.xml' => '<test/>' }, temp_file.path)

          # Should detect as DOCX based on ZIP signature
          format = detector.detect(temp_file.path)

          expect(format).to eq(:docx)
        ensure
          temp_file.unlink
        end
      end
    end
  end
end
