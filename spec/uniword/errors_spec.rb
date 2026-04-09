# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword do
  describe 'custom errors' do
    describe Uniword::FileNotFoundError do
      it 'has a message with the path' do
        error = described_class.new('/path/to/file.docx')
        expect(error.message).to eq('File not found: /path/to/file.docx')
        expect(error.path).to eq('/path/to/file.docx')
      end
    end

    describe Uniword::InvalidFormatError do
      it 'has a message with path and format' do
        error = described_class.new('/path/to/file.doc', :unknown)
        expect(error.message).to include('unknown')
        expect(error.message).to include('/path/to/file.doc')
        expect(error.path).to eq('/path/to/file.doc')
        expect(error.format).to eq(:unknown)
      end
    end

    describe Uniword::CorruptedFileError do
      it 'has a message with path and reason' do
        error = described_class.new('/path/to/file.docx', 'Invalid ZIP')
        expect(error.message).to include('Invalid ZIP')
        expect(error.message).to include('/path/to/file.docx')
        expect(error.path).to eq('/path/to/file.docx')
        expect(error.reason).to eq('Invalid ZIP')
      end
    end

    describe Uniword::ValidationError do
      it 'has a message with element name and errors' do
        para = Uniword::Wordprocessingml::Paragraph.new
        errors = ['ID is required', 'Text cannot be empty']
        error = described_class.new(para, errors)

        expect(error.message).to include('Paragraph')
        expect(error.message).to include('ID is required')
        expect(error.message).to include('Text cannot be empty')
        expect(error.element).to eq(para)
        expect(error.errors).to eq(errors)
      end
    end

    describe Uniword::ConversionError do
      it 'has a message with formats and reason' do
        error = described_class.new(:doc, :docx, 'DOC format not yet supported')
        expect(error.message).to include('doc')
        expect(error.message).to include('docx')
        expect(error.message).to include('not yet supported')
        expect(error.from_format).to eq(:doc)
        expect(error.to_format).to eq(:docx)
        expect(error.reason).to eq('DOC format not yet supported')
      end
    end
  end
end

RSpec.describe Uniword::DocumentFactory do
  describe '.from_file' do
    context 'with non-existent file' do
      it 'raises FileNotFoundError' do
        expect do
          described_class.from_file('nonexistent.docx')
        end.to raise_error(Uniword::FileNotFoundError, /nonexistent\.docx/)
      end
    end

    context 'with nil path' do
      it 'raises ArgumentError' do
        expect do
          described_class.from_file(nil)
        end.to raise_error(ArgumentError, /cannot be nil/)
      end
    end

    context 'with empty path' do
      it 'raises ArgumentError' do
        expect do
          described_class.from_file('')
        end.to raise_error(ArgumentError, /cannot be empty/)
      end
    end
  end
end
