# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Uniword::DocumentWriter do
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }
  let(:writer) { described_class.new(document) }

  describe '#initialize' do
    it 'creates writer with document' do
      expect(writer.document).to eq(document)
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when document is nil' do
        expect { described_class.new(nil) }.to raise_error(
          ArgumentError,
          'Document cannot be nil'
        )
      end

      it 'raises ArgumentError when not a Document instance' do
        expect { described_class.new('invalid') }.to raise_error(
          ArgumentError,
          'Must be a Document instance'
        )
      end
    end
  end

  describe '#save' do
    context 'with DOCX format' do
      it 'saves document as DOCX with auto format' do
        temp_file = Tempfile.new(['output', '.docx'])
        begin
          writer.save(temp_file.path)

          expect(File.exist?(temp_file.path)).to be true
        ensure
          temp_file.unlink
        end
      end

      it 'saves document with explicit DOCX format' do
        temp_file = Tempfile.new(['output', '.docx'])
        begin
          writer.save(temp_file.path, format: :docx)

          expect(File.exist?(temp_file.path)).to be true
        ensure
          temp_file.unlink
        end
      end
    end

    context 'with MHTML format' do
      it 'saves document as MHTML with auto format' do
        temp_file = Tempfile.new(['output', '.mhtml'])
        begin
          writer.save(temp_file.path)

          expect(File.exist?(temp_file.path)).to be true
          content = File.read(temp_file.path)
          expect(content).to include('MIME-Version: 1.0')
        ensure
          temp_file.unlink
        end
      end

      it 'saves document with explicit MHTML format' do
        temp_file = Tempfile.new(['output', '.mht'])
        begin
          writer.save(temp_file.path, format: :mhtml)

          expect(File.exist?(temp_file.path)).to be true
        ensure
          temp_file.unlink
        end
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when path is nil' do
        expect { writer.save(nil) }.to raise_error(
          ArgumentError,
          'Path cannot be nil'
        )
      end

      it 'raises ArgumentError when path is empty' do
        expect { writer.save('') }.to raise_error(
          ArgumentError,
          'Path cannot be empty'
        )
      end

      it 'raises ArgumentError when format is not supported' do
        expect do
          writer.save('output.docx', format: :invalid)
        end.to raise_error(ArgumentError, /No handler registered/)
      end
    end
  end

  describe '#infer_format' do
    it 'infers DOCX format from .docx extension' do
      format = writer.infer_format('document.docx')

      expect(format).to eq(:docx)
    end

    it 'infers MHTML format from .mhtml extension' do
      format = writer.infer_format('document.mhtml')

      expect(format).to eq(:mhtml)
    end

    it 'infers MHTML format from .mht extension' do
      format = writer.infer_format('document.mht')

      expect(format).to eq(:mhtml)
    end

    it 'is case-insensitive' do
      expect(writer.infer_format('document.DOCX')).to eq(:docx)
      expect(writer.infer_format('document.MHTML')).to eq(:mhtml)
    end

    context 'with unsupported extension' do
      it 'raises ArgumentError for .txt extension' do
        expect do
          writer.infer_format('document.txt')
        end.to raise_error(ArgumentError, /Cannot infer format/)
      end

      it 'raises ArgumentError for .pdf extension' do
        expect do
          writer.infer_format('document.pdf')
        end.to raise_error(ArgumentError, /Cannot infer format/)
      end

      it 'raises ArgumentError for no extension' do
        expect do
          writer.infer_format('document')
        end.to raise_error(ArgumentError, /Cannot infer format/)
      end
    end
  end

  describe 'integration' do
    it 'performs full write-read cycle for DOCX' do
      temp_file = Tempfile.new(['test', '.docx'])
      begin
        # Write document
        writer.save(temp_file.path)

        # Read it back - returns DocxPackage with document accessor
        loaded_doc = Uniword::DocumentFactory.from_file(temp_file.path)

        expect(loaded_doc).to be_a(Uniword::Ooxml::DocxPackage)
        expect(loaded_doc.document).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      ensure
        temp_file.unlink
      end
    end

    it 'performs full write-read cycle for MHTML' do
      temp_file = Tempfile.new(['test', '.mhtml'])
      begin
        # Write document
        writer.save(temp_file.path)

        # Read it back
        loaded_doc = Uniword::DocumentFactory.from_file(temp_file.path)

        # MHTML files return Mhtml::Document
        expect(loaded_doc).to be_a(Uniword::Mhtml::Document)
      ensure
        temp_file.unlink
      end
    end
  end
end
