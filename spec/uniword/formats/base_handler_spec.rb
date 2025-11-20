# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Formats::BaseHandler do
  # Create a concrete test handler for testing
  let(:test_handler_class) do
    Class.new(described_class) do
      attr_reader :extracted_content, :deserialized_doc, :serialized_content

      def extract_content(path)
        @extracted_content = "content from #{path}"
      end

      def deserialize(_content)
        @deserialized_doc = Uniword::Document.new
        @deserialized_doc
      end

      def serialize(document)
        @serialized_content = "serialized: #{document.class}"
        @serialized_content
      end

      def package_and_save(content, path)
        File.write(path, content)
      end

      def supported_extensions
        ['.test', '.tst']
      end
    end
  end

  let(:handler) { test_handler_class.new }
  let(:valid_document) { Uniword::Document.new }
  let(:temp_file) { Tempfile.new(['test', '.test']) }
  let(:temp_path) { temp_file.path }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe 'abstract class behavior' do
    it 'raises NotImplementedError for extract_content' do
      base_handler = described_class.new
      expect do
        base_handler.send(:extract_content, 'path')
      end.to raise_error(described_class::NotImplementedError, /must implement extract_content/)
    end

    it 'raises NotImplementedError for deserialize' do
      base_handler = described_class.new
      expect do
        base_handler.send(:deserialize, 'content')
      end.to raise_error(described_class::NotImplementedError, /must implement deserialize/)
    end

    it 'raises NotImplementedError for serialize' do
      base_handler = described_class.new
      expect do
        base_handler.send(:serialize, valid_document)
      end.to raise_error(described_class::NotImplementedError, /must implement serialize/)
    end

    it 'raises NotImplementedError for package_and_save' do
      base_handler = described_class.new
      expect do
        base_handler.send(:package_and_save, 'content', 'path')
      end.to raise_error(described_class::NotImplementedError, /must implement package_and_save/)
    end
  end

  describe '#read' do
    it 'implements the template method pattern' do
      result = handler.read(temp_path)

      expect(handler.extracted_content).to eq("content from #{temp_path}")
      expect(result).to be_a(Uniword::Document)
      expect(result).to eq(handler.deserialized_doc)
    end

    it 'validates path before extraction' do
      expect do
        handler.read('/nonexistent/file.test')
      end.to raise_error(ArgumentError, /File not found/)
    end

    it 'raises error for nil path' do
      expect do
        handler.read(nil)
      end.to raise_error(ArgumentError, /Path cannot be nil/)
    end

    it 'raises error for empty path' do
      expect do
        handler.read('')
      end.to raise_error(ArgumentError, /Path cannot be empty/)
    end

    it 'raises error for directory path' do
      dir = Dir.mktmpdir
      begin
        expect do
          handler.read(dir)
        end.to raise_error(ArgumentError, /Path is a directory/)
      ensure
        Dir.rmdir(dir)
      end
    end
  end

  describe '#write' do
    let(:output_path) { File.join(Dir.tmpdir, 'test_output.test') }

    after do
      FileUtils.rm_f(output_path)
    end

    it 'implements the template method pattern' do
      handler.write(valid_document, output_path)

      expect(handler.serialized_content).to eq('serialized: Uniword::Document')
      expect(File.exist?(output_path)).to be true
      expect(File.read(output_path)).to eq(handler.serialized_content)
    end

    it 'validates document before serialization' do
      expect do
        handler.write(nil, output_path)
      end.to raise_error(ArgumentError, /Document cannot be nil/)
    end

    it 'raises error for non-Document object' do
      expect do
        handler.write('not a document', output_path)
      end.to raise_error(ArgumentError, /Not a Document instance/)
    end

    it 'raises error for invalid document' do
      invalid_doc = Uniword::Document.new
      allow(invalid_doc).to receive(:valid?).and_return(false)

      expect do
        handler.write(invalid_doc, output_path)
      end.to raise_error(ArgumentError, /Document is invalid/)
    end
  end

  describe '#can_handle?' do
    it 'returns true for supported extensions' do
      File.write(temp_path, 'test')
      expect(handler.can_handle?(temp_path)).to be true
    end

    it 'returns true for uppercase extensions' do
      uppercase_file = Tempfile.new(['test', '.TEST'])
      begin
        expect(handler.can_handle?(uppercase_file.path)).to be true
      ensure
        uppercase_file.close
        uppercase_file.unlink
      end
    end

    it 'returns false for unsupported extensions' do
      other_file = Tempfile.new(['test', '.txt'])
      begin
        expect(handler.can_handle?(other_file.path)).to be false
      ensure
        other_file.close
        other_file.unlink
      end
    end

    it 'returns false for non-existent files' do
      expect(handler.can_handle?('/nonexistent/file.test')).to be false
    end

    it 'returns false when no extensions are supported' do
      minimal_handler = Class.new(described_class).new
      expect(minimal_handler.can_handle?(temp_path)).to be false
    end
  end

  describe '#supported_extensions' do
    it 'returns empty array by default' do
      base_handler = described_class.new
      expect(base_handler.supported_extensions).to eq([])
    end

    it 'can be overridden by subclasses' do
      expect(handler.supported_extensions).to eq(['.test', '.tst'])
    end
  end

  describe 'validation methods' do
    describe '#validate_read_path' do
      it 'accepts valid file path' do
        expect do
          handler.send(:validate_read_path, temp_path)
        end.not_to raise_error
      end

      it 'raises error for nil path' do
        expect do
          handler.send(:validate_read_path, nil)
        end.to raise_error(ArgumentError, /Path cannot be nil/)
      end

      it 'raises error for empty path' do
        expect do
          handler.send(:validate_read_path, '')
        end.to raise_error(ArgumentError, /Path cannot be empty/)
      end

      it 'raises error for non-existent file' do
        expect do
          handler.send(:validate_read_path, '/nonexistent/file.txt')
        end.to raise_error(ArgumentError, /File not found/)
      end

      it 'raises error for directory' do
        dir = Dir.mktmpdir
        begin
          expect do
            handler.send(:validate_read_path, dir)
          end.to raise_error(ArgumentError, /Path is a directory/)
        ensure
          Dir.rmdir(dir)
        end
      end
    end

    describe '#validate_document' do
      it 'accepts valid document' do
        expect do
          handler.send(:validate_document, valid_document)
        end.not_to raise_error
      end

      it 'raises error for nil document' do
        expect do
          handler.send(:validate_document, nil)
        end.to raise_error(ArgumentError, /Document cannot be nil/)
      end

      it 'raises error for non-Document object' do
        expect do
          handler.send(:validate_document, 'not a document')
        end.to raise_error(ArgumentError, /Not a Document instance/)
      end

      it 'raises error for invalid document' do
        invalid_doc = Uniword::Document.new
        allow(invalid_doc).to receive(:valid?).and_return(false)

        expect do
          handler.send(:validate_document, invalid_doc)
        end.to raise_error(ArgumentError, /Document is invalid/)
      end
    end

    describe '#validate_write_path' do
      it 'accepts valid write path' do
        path = File.join(Dir.tmpdir, 'test.txt')
        expect do
          handler.send(:validate_write_path, path)
        end.not_to raise_error
      end

      it 'raises error for nil path' do
        expect do
          handler.send(:validate_write_path, nil)
        end.to raise_error(ArgumentError, /Path cannot be nil/)
      end

      it 'raises error for empty path' do
        expect do
          handler.send(:validate_write_path, '')
        end.to raise_error(ArgumentError, /Path cannot be empty/)
      end

      it 'raises error for non-existent directory' do
        expect do
          handler.send(:validate_write_path, '/nonexistent/dir/file.txt')
        end.to raise_error(ArgumentError, /Directory not found/)
      end
    end
  end

  describe 'error classes' do
    it 'defines NotImplementedError' do
      expect(described_class::NotImplementedError).to be < StandardError
    end

    it 'defines InvalidFormatError' do
      expect(described_class::InvalidFormatError).to be < StandardError
    end
  end
end
