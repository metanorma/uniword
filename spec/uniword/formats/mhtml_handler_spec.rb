# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Formats::MhtmlHandler do
  let(:handler) { described_class.new }
  let(:document) { Uniword::Document.new }

  describe '#supported_extensions' do
    it 'returns array of MHTML extensions' do
      expect(handler.supported_extensions).to eq(['.mhtml', '.mht'])
    end
  end

  describe '#can_handle?' do
    it 'returns true for .mhtml files' do
      temp_file = Tempfile.new(['test', '.mhtml'])
      begin
        expect(handler.can_handle?(temp_file.path)).to be true
      ensure
        temp_file.unlink
      end
    end

    it 'returns true for .mht files' do
      temp_file = Tempfile.new(['test', '.mht'])
      begin
        expect(handler.can_handle?(temp_file.path)).to be true
      ensure
        temp_file.unlink
      end
    end

    it 'returns false for non-MHTML files' do
      temp_file = Tempfile.new(['test', '.txt'])
      begin
        expect(handler.can_handle?(temp_file.path)).to be false
      ensure
        temp_file.unlink
      end
    end

    it 'returns false for non-existent files' do
      expect(handler.can_handle?('nonexistent.mhtml')).to be false
    end
  end

  describe '#read' do
    let(:mhtml_content) do
      <<~MHTML
        MIME-Version: 1.0
        Content-Type: multipart/related; boundary="----=_NextPart_000"

        ------=_NextPart_000
        Content-Type: text/html; charset="utf-8"

        <html><body><p>Test content</p></body></html>

        ------=_NextPart_000--
      MHTML
    end

    it 'reads and deserializes MHTML file' do
      temp_file = Tempfile.new(['test', '.mhtml'])
      begin
        temp_file.write(mhtml_content)
        temp_file.close

        result = handler.read(temp_file.path)

        expect(result).to be_a(Uniword::Document)
      ensure
        temp_file.unlink
      end
    end

    it 'raises ArgumentError for nil path' do
      expect { handler.read(nil) }.to raise_error(
        ArgumentError,
        'Path cannot be nil'
      )
    end

    it 'raises ArgumentError for non-existent file' do
      expect { handler.read('nonexistent.mhtml') }.to raise_error(
        ArgumentError,
        /File not found/
      )
    end
  end

  describe '#write' do
    it 'serializes and packages document to MHTML file' do
      temp_file = Tempfile.new(['output', '.mhtml'])
      begin
        handler.write(document, temp_file.path)

        expect(File.exist?(temp_file.path)).to be true
        content = File.read(temp_file.path)
        expect(content).to include('MIME-Version: 1.0')
        expect(content).to include('Content-Type: multipart/related')
      ensure
        temp_file.unlink
      end
    end

    it 'raises ArgumentError for nil document' do
      expect { handler.write(nil, 'output.mhtml') }.to raise_error(
        ArgumentError,
        'Document cannot be nil'
      )
    end

    it 'raises ArgumentError for invalid document type' do
      expect { handler.write('invalid', 'output.mhtml') }.to raise_error(
        ArgumentError,
        'Not a Document instance'
      )
    end

    it 'raises ArgumentError for nil path' do
      expect { handler.write(document, nil) }.to raise_error(
        ArgumentError,
        'Path cannot be nil'
      )
    end
  end

  describe 'integration' do
    it 'performs full read-write cycle' do
      # Create a test MHTML file
      mhtml_content = <<~MHTML
        MIME-Version: 1.0
        Content-Type: multipart/related; boundary="----=_NextPart_000"

        ------=_NextPart_000
        Content-Type: text/html; charset="utf-8"

        <html><body><p>Test content</p></body></html>

        ------=_NextPart_000--
      MHTML

      input_file = Tempfile.new(['input', '.mhtml'])
      output_file = Tempfile.new(['output', '.mhtml'])

      begin
        input_file.write(mhtml_content)
        input_file.close

        # Read document
        doc = handler.read(input_file.path)
        expect(doc).to be_a(Uniword::Document)

        # Write document
        handler.write(doc, output_file.path)
        expect(File.exist?(output_file.path)).to be true

        # Verify output has MIME structure
        content = File.read(output_file.path)
        expect(content).to include('MIME-Version: 1.0')
      ensure
        input_file.unlink
        output_file.unlink
      end
    end
  end
end
