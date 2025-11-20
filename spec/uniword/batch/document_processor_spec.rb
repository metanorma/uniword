# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/uniword/batch/document_processor'
require_relative '../../../lib/uniword/batch/processing_stage'
require_relative '../../../lib/uniword/document'
require 'tempfile'
require 'fileutils'

RSpec.describe Uniword::Batch::DocumentProcessor do
  let(:processor) { described_class.new }

  # Test stage for specs
  class TestProcessingStage < Uniword::Batch::ProcessingStage
    attr_reader :processed_documents

    def initialize(options = {})
      super(options)
      @processed_documents = []
    end

    def process(document, context = {})
      @processed_documents << { document: document, context: context }
      document
    end
  end

  describe '#initialize' do
    it 'initializes with default configuration' do
      expect(processor.stages).to be_an(Array)
      expect(processor.config).to be_a(Hash)
    end

    it 'loads configuration from file when provided' do
      config_file = 'config/pipeline.yml'
      processor = described_class.new(pipeline_config: config_file)
      expect(processor.config).to be_a(Hash)
    end

    it 'accepts direct configuration' do
      config = { pipeline: { default: { stages: [] } } }
      processor = described_class.new(config: config)
      expect(processor.config).to eq(config)
    end

    it 'handles missing configuration file gracefully' do
      processor = described_class.new(pipeline_config: 'nonexistent.yml')
      expect(processor.config).to be_a(Hash)
      expect(processor.stages).to be_an(Array)
    end
  end

  describe '#add_stage' do
    it 'adds a custom stage' do
      stage = TestProcessingStage.new
      expect(processor.add_stage(stage)).to eq(processor)
      expect(processor.enabled_stages).to include('test_processing')
    end

    it 'raises error for non-stage objects' do
      expect { processor.add_stage("not a stage") }.to raise_error(ArgumentError)
    end
  end

  describe '#enabled_stages' do
    it 'returns list of enabled stage names' do
      processor.add_stage(TestProcessingStage.new(enabled: true))
      expect(processor.enabled_stages).to include('test_processing')
    end

    it 'excludes disabled stages' do
      processor.add_stage(TestProcessingStage.new(enabled: false))
      expect(processor.enabled_stages).not_to include('test_processing')
    end
  end

  describe '#disabled_stages' do
    it 'returns list of disabled stage names' do
      processor.add_stage(TestProcessingStage.new(enabled: false))
      expect(processor.disabled_stages).to include('test_processing')
    end
  end

  describe '#process_file' do
    let(:input_file) { Tempfile.new(['input', '.docx']) }
    let(:output_file) { Tempfile.new(['output', '.docx']) }

    before do
      # Create a minimal DOCX structure for testing
      allow(Uniword::DocumentFactory).to receive(:from_file).and_return(Uniword::Document.new)
    end

    after do
      input_file.close
      input_file.unlink
      output_file.close
      output_file.unlink
    end

    it 'processes a single file' do
      result = processor.process_file(input_file.path, output_file.path)

      expect(result).to be_a(Uniword::Batch::BatchResult)
      expect(result.total_count).to eq(1)
    end

    it 'executes enabled stages' do
      stage = TestProcessingStage.new
      processor.add_stage(stage)

      processor.process_file(input_file.path, output_file.path)

      expect(stage.processed_documents.size).to eq(1)
    end

    it 'skips disabled stages' do
      stage = TestProcessingStage.new(enabled: false)
      processor.add_stage(stage)

      processor.process_file(input_file.path, output_file.path)

      expect(stage.processed_documents).to be_empty
    end

    it 'records success when processing completes' do
      result = processor.process_file(input_file.path, output_file.path)

      expect(result.success_count).to eq(1)
      expect(result.failure_count).to eq(0)
    end

    it 'records failure when error occurs' do
      allow(Uniword::DocumentFactory).to receive(:from_file).and_raise(StandardError, "Test error")

      result = processor.process_file(input_file.path, output_file.path)

      expect(result.success_count).to eq(0)
      expect(result.failure_count).to eq(1)
    end
  end

  describe '#process_batch' do
    let(:temp_dir) { Dir.mktmpdir }
    let(:input_dir) { File.join(temp_dir, 'input') }
    let(:output_dir) { File.join(temp_dir, 'output') }

    before do
      FileUtils.mkdir_p(input_dir)
      # Create test files
      FileUtils.touch(File.join(input_dir, 'test1.docx'))
      FileUtils.touch(File.join(input_dir, 'test2.docx'))

      allow(Uniword::DocumentFactory).to receive(:from_file).and_return(Uniword::Document.new)
    end

    after do
      FileUtils.rm_rf(temp_dir)
    end

    it 'processes batch of documents' do
      result = processor.process_batch(input_dir: input_dir, output_dir: output_dir)

      expect(result).to be_a(Uniword::Batch::BatchResult)
      expect(result.total_count).to eq(2)
    end

    it 'creates output directory if needed' do
      processor.process_batch(input_dir: input_dir, output_dir: output_dir)

      expect(Dir.exist?(output_dir)).to be true
    end

    it 'raises error when input directory does not exist' do
      expect {
        processor.process_batch(input_dir: 'nonexistent', output_dir: output_dir)
      }.to raise_error(ArgumentError, /does not exist/)
    end

    it 'processes files matching pattern' do
      FileUtils.touch(File.join(input_dir, 'test.txt'))

      result = processor.process_batch(
        input_dir: input_dir,
        output_dir: output_dir,
        pattern: '*.docx'
      )

      # Should process only .docx files, not .txt
      expect(result.total_count).to eq(2)
    end
  end
end