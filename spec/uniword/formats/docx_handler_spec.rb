# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Formats::DocxHandler do
  let(:handler) { described_class.new }
  let(:document) { Uniword::Document.new }
  let(:temp_file) { Tempfile.new(['test', '.docx']) }
  let(:temp_path) { temp_file.path }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe 'inheritance' do
    it 'inherits from BaseHandler' do
      expect(described_class).to be < Uniword::Formats::BaseHandler
    end
  end

  describe '#supported_extensions' do
    it 'returns .docx extension' do
      expect(handler.supported_extensions).to eq(['.docx'])
    end
  end

  describe '#can_handle?' do
    it 'returns true for .docx files' do
      expect(handler.can_handle?(temp_path)).to be true
    end

    it 'returns true for uppercase .DOCX files' do
      uppercase_file = Tempfile.new(['test', '.DOCX'])
      begin
        expect(handler.can_handle?(uppercase_file.path)).to be true
      ensure
        uppercase_file.close
        uppercase_file.unlink
      end
    end

    it 'returns false for non-.docx files' do
      txt_file = Tempfile.new(['test', '.txt'])
      begin
        expect(handler.can_handle?(txt_file.path)).to be false
      ensure
        txt_file.close
        txt_file.unlink
      end
    end
  end

  describe '#extract_content' do
    it 'delegates to ZipExtractor' do
      zip_extractor = instance_double(Uniword::Infrastructure::ZipExtractor)
      allow(Uniword::Infrastructure::ZipExtractor).to receive(:new).and_return(zip_extractor)

      expected_content = { 'word/document.xml' => '<xml/>' }
      expect(zip_extractor).to receive(:extract).with(temp_path).and_return(expected_content)

      result = handler.send(:extract_content, temp_path)
      expect(result).to eq(expected_content)
    end

    it 'reuses the same ZipExtractor instance' do
      expect(Uniword::Infrastructure::ZipExtractor).to receive(:new).once.and_call_original

      handler.send(:zip_extractor)
      handler.send(:zip_extractor)
    end
  end

  describe '#deserialize' do
    it 'delegates to OoxmlDeserializer' do
      deserializer = instance_double(Uniword::Serialization::OoxmlDeserializer)
      allow(Uniword::Serialization::OoxmlDeserializer).to receive(:new).and_return(deserializer)

      content = { 'word/document.xml' => '<xml/>' }
      expect(deserializer).to receive(:deserialize).with(content).and_return(document)

      result = handler.send(:deserialize, content)
      expect(result).to eq(document)
    end

    it 'reuses the same OoxmlDeserializer instance' do
      expect(Uniword::Serialization::OoxmlDeserializer).to receive(:new).once.and_call_original

      handler.send(:ooxml_deserializer)
      handler.send(:ooxml_deserializer)
    end
  end

  describe '#serialize' do
    it 'delegates to OoxmlSerializer' do
      serializer = instance_double(Uniword::Serialization::OoxmlSerializer)
      allow(Uniword::Serialization::OoxmlSerializer).to receive(:new).and_return(serializer)

      expected_content = { 'word/document.xml' => '<xml/>' }
      expect(serializer).to receive(:serialize_package).with(document).and_return(expected_content)

      result = handler.send(:serialize, document)
      expect(result).to eq(expected_content)
    end

    it 'reuses the same OoxmlSerializer instance' do
      expect(Uniword::Serialization::OoxmlSerializer).to receive(:new).once.and_call_original

      handler.send(:ooxml_serializer)
      handler.send(:ooxml_serializer)
    end
  end

  describe '#package_and_save' do
    let(:output_path) { File.join(Dir.tmpdir, 'output.docx') }

    after do
      FileUtils.rm_f(output_path)
    end

    it 'delegates to ZipPackager' do
      packager = instance_double(Uniword::Infrastructure::ZipPackager)
      allow(Uniword::Infrastructure::ZipPackager).to receive(:new).and_return(packager)

      content = { 'word/document.xml' => '<xml/>' }
      expect(packager).to receive(:package).with(content, output_path)

      handler.send(:package_and_save, content, output_path)
    end

    it 'reuses the same ZipPackager instance' do
      expect(Uniword::Infrastructure::ZipPackager).to receive(:new).once.and_call_original

      handler.send(:zip_packager)
      handler.send(:zip_packager)
    end
  end

  describe 'integration with FormatHandlerRegistry' do
    it 'is registered for :docx format' do
      registry_handler = Uniword::Formats::FormatHandlerRegistry.handler_for(:docx)
      expect(registry_handler).to be_a(described_class)
    end

    it 'can be retrieved by file extension' do
      registry_handler = Uniword::Formats::FormatHandlerRegistry.handler_for_file(temp_path)
      expect(registry_handler).to be_a(described_class)
    end
  end

  describe 'end-to-end workflow' do
    let(:output_path) { File.join(Dir.tmpdir, 'output.docx') }

    after do
      FileUtils.rm_f(output_path)
    end

    it 'can write a document using the full pipeline' do
      # This tests that all the infrastructure is properly wired together
      handler.write(document, output_path)

      expect(File.exist?(output_path)).to be true
      expect(File.size(output_path)).to be > 0
    end

    it 'validates document before writing' do
      invalid_doc = 'not a document'

      expect do
        handler.write(invalid_doc, output_path)
      end.to raise_error(ArgumentError, /Not a Document/)
    end
  end

  describe 'dependency injection' do
    it 'allows custom ZipExtractor' do
      custom_extractor = instance_double(Uniword::Infrastructure::ZipExtractor)
      handler.instance_variable_set(:@zip_extractor, custom_extractor)

      expect(custom_extractor).to receive(:extract).with(temp_path)
      handler.send(:extract_content, temp_path)
    end

    it 'allows custom ZipPackager' do
      output_path = File.join(Dir.tmpdir, 'output.docx')
      custom_packager = instance_double(Uniword::Infrastructure::ZipPackager)
      handler.instance_variable_set(:@zip_packager, custom_packager)

      content = { 'word/document.xml' => '<xml/>' }
      expect(custom_packager).to receive(:package).with(content, output_path)
      handler.send(:package_and_save, content, output_path)
    end

    it 'allows custom OoxmlDeserializer' do
      custom_deserializer = instance_double(Uniword::Serialization::OoxmlDeserializer)
      handler.instance_variable_set(:@ooxml_deserializer, custom_deserializer)

      content = { 'word/document.xml' => '<xml/>' }
      expect(custom_deserializer).to receive(:deserialize).with(content)
      handler.send(:deserialize, content)
    end

    it 'allows custom OoxmlSerializer' do
      custom_serializer = instance_double(Uniword::Serialization::OoxmlSerializer)
      handler.instance_variable_set(:@ooxml_serializer, custom_serializer)

      expect(custom_serializer).to receive(:serialize_package).with(document)
      handler.send(:serialize, document)
    end
  end
end
