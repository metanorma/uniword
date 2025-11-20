# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Formats::FormatHandlerRegistry do
  # Create test handler classes
  let(:test_handler_class) do
    Class.new(Uniword::Formats::BaseHandler) do
      def extract_content(path); end
      def deserialize(content); end
      def serialize(document); end
      def package_and_save(content, path); end

      def supported_extensions
        ['.test']
      end
    end
  end

  let(:docx_handler_class) do
    Class.new(Uniword::Formats::BaseHandler) do
      def extract_content(path); end
      def deserialize(content); end
      def serialize(document); end
      def package_and_save(content, path); end

      def supported_extensions
        ['.docx']
      end
    end
  end

  before do
    # Reset registry before each test
    described_class.reset_registry
  end

  after do
    # Clean up after tests and re-register default handlers
    described_class.reset_registry
    # Re-register default handlers for other tests
    require 'uniword/formats/docx_handler'
    require 'uniword/formats/mhtml_handler'
  end

  describe '.register' do
    it 'registers a handler for a format' do
      described_class.register(:test, test_handler_class)
      expect(described_class.registered?(:test)).to be true
    end

    it 'raises error for non-symbol format' do
      expect do
        described_class.register('test', test_handler_class)
      end.to raise_error(ArgumentError, /Format must be a Symbol/)
    end

    it 'raises error for non-class handler' do
      expect do
        described_class.register(:test, 'not a class')
      end.to raise_error(ArgumentError, /Handler must be a Class/)
    end

    it "raises error if handler doesn't inherit from BaseHandler" do
      expect do
        described_class.register(:test, String)
      end.to raise_error(ArgumentError, /must inherit from.*BaseHandler/)
    end

    it 'allows overriding existing registrations' do
      described_class.register(:test, test_handler_class)
      described_class.register(:test, docx_handler_class)

      handler = described_class.handler_for(:test)
      expect(handler).to be_a(docx_handler_class)
    end

    it 'registers multiple formats' do
      described_class.register(:test, test_handler_class)
      described_class.register(:docx, docx_handler_class)

      expect(described_class.registered?(:test)).to be true
      expect(described_class.registered?(:docx)).to be true
    end
  end

  describe '.handler_for' do
    before do
      described_class.register(:test, test_handler_class)
    end

    it 'returns an instance of the registered handler' do
      handler = described_class.handler_for(:test)
      expect(handler).to be_a(test_handler_class)
    end

    it 'returns a new instance each time' do
      handler1 = described_class.handler_for(:test)
      handler2 = described_class.handler_for(:test)

      expect(handler1).not_to be(handler2)
    end

    it 'raises error for unregistered format' do
      expect do
        described_class.handler_for(:unknown)
      end.to raise_error(ArgumentError, /No handler registered for format: unknown/)
    end

    it 'includes available formats in error message' do
      described_class.register(:docx, docx_handler_class)

      expect do
        described_class.handler_for(:pdf)
      end.to raise_error(ArgumentError, /Available formats:.*test.*docx/)
    end

    it 'raises error for non-symbol format' do
      expect do
        described_class.handler_for('test')
      end.to raise_error(ArgumentError, /Format must be a Symbol/)
    end
  end

  describe '.handler_for_file' do
    let(:temp_file) { Tempfile.new(['document', '.test']) }

    before do
      described_class.register(:test, test_handler_class)
      described_class.register(:docx, docx_handler_class)
    end

    after do
      temp_file.close
      temp_file.unlink
    end

    it 'returns handler that can handle the file' do
      handler = described_class.handler_for_file(temp_file.path)
      expect(handler).to be_a(test_handler_class)
    end

    it 'returns correct handler for .docx files' do
      docx_file = Tempfile.new(['document', '.docx'])
      begin
        handler = described_class.handler_for_file(docx_file.path)
        expect(handler).to be_a(docx_handler_class)
      ensure
        docx_file.close
        docx_file.unlink
      end
    end

    it 'raises error if no handler can handle the file' do
      txt_file = Tempfile.new(['document', '.txt'])
      begin
        expect do
          described_class.handler_for_file(txt_file.path)
        end.to raise_error(ArgumentError, /No handler found for file/)
      ensure
        txt_file.close
        txt_file.unlink
      end
    end

    it 'raises error for nil path' do
      expect do
        described_class.handler_for_file(nil)
      end.to raise_error(ArgumentError, /Path cannot be nil/)
    end

    it 'raises error for empty path' do
      expect do
        described_class.handler_for_file('')
      end.to raise_error(ArgumentError, /Path cannot be empty/)
    end

    it 'includes registered formats in error message' do
      txt_file = Tempfile.new(['document', '.txt'])
      begin
        expect do
          described_class.handler_for_file(txt_file.path)
        end.to raise_error(ArgumentError, /Registered formats:.*test.*docx/)
      ensure
        txt_file.close
        txt_file.unlink
      end
    end
  end

  describe '.registered?' do
    it 'returns true for registered format' do
      described_class.register(:test, test_handler_class)
      expect(described_class.registered?(:test)).to be true
    end

    it 'returns false for unregistered format' do
      expect(described_class.registered?(:unknown)).to be false
    end

    it 'returns false after registry reset' do
      described_class.register(:test, test_handler_class)
      described_class.reset_registry
      expect(described_class.registered?(:test)).to be false
    end
  end

  describe '.registered_formats' do
    it 'returns empty array for empty registry' do
      expect(described_class.registered_formats).to eq([])
    end

    it 'returns array of registered format symbols' do
      described_class.register(:test, test_handler_class)
      described_class.register(:docx, docx_handler_class)

      formats = described_class.registered_formats
      expect(formats).to contain_exactly(:test, :docx)
    end
  end

  describe '.registry' do
    it 'returns a hash' do
      expect(described_class.registry).to be_a(Hash)
    end

    it 'contains registered handlers' do
      described_class.register(:test, test_handler_class)

      expect(described_class.registry[:test]).to eq(test_handler_class)
    end

    it 'returns the same hash instance' do
      registry1 = described_class.registry
      registry2 = described_class.registry

      expect(registry1).to be(registry2)
    end
  end

  describe '.reset_registry' do
    it 'clears all registrations' do
      described_class.register(:test, test_handler_class)
      described_class.register(:docx, docx_handler_class)

      described_class.reset_registry

      expect(described_class.registered_formats).to be_empty
    end

    it 'allows re-registration after reset' do
      described_class.register(:test, test_handler_class)
      described_class.reset_registry
      described_class.register(:test, docx_handler_class)

      handler = described_class.handler_for(:test)
      expect(handler).to be_a(docx_handler_class)
    end
  end

  describe 'integration scenarios' do
    it 'supports multiple handlers with different extensions' do
      described_class.register(:test, test_handler_class)
      described_class.register(:docx, docx_handler_class)

      test_file = Tempfile.new(['doc', '.test'])
      docx_file = Tempfile.new(['doc', '.docx'])

      begin
        test_handler = described_class.handler_for_file(test_file.path)
        docx_handler = described_class.handler_for_file(docx_file.path)

        expect(test_handler).to be_a(test_handler_class)
        expect(docx_handler).to be_a(docx_handler_class)
      ensure
        test_file.close
        test_file.unlink
        docx_file.close
        docx_file.unlink
      end
    end

    it 'maintains isolation between different format registrations' do
      described_class.register(:format1, test_handler_class)
      described_class.register(:format2, docx_handler_class)

      handler1 = described_class.handler_for(:format1)
      handler2 = described_class.handler_for(:format2)

      expect(handler1.class).not_to eq(handler2.class)
    end
  end
end
