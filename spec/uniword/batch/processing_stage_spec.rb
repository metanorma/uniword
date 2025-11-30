# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/uniword/batch/processing_stage'

RSpec.describe Uniword::Batch::ProcessingStage do
  # Create a test stage implementation
  class TestStage < Uniword::Batch::ProcessingStage
    attr_reader :process_called

    def process(document, _context = {})
      @process_called = true
      document
    end
  end

  describe '#initialize' do
    it 'initializes with default options' do
      stage = TestStage.new
      expect(stage.options).to eq({})
      expect(stage.enabled?).to be true
    end

    it 'initializes with custom options' do
      options = { enabled: false, custom: 'value' }
      stage = TestStage.new(options)
      expect(stage.options).to eq(options)
      expect(stage.enabled?).to be false
    end

    it 'defaults enabled to true when not specified' do
      stage = TestStage.new(other: 'option')
      expect(stage.enabled?).to be true
    end
  end

  describe '#enabled?' do
    it 'returns true when enabled' do
      stage = TestStage.new(enabled: true)
      expect(stage.enabled?).to be true
    end

    it 'returns false when disabled' do
      stage = TestStage.new(enabled: false)
      expect(stage.enabled?).to be false
    end
  end

  describe '#process' do
    it 'must be implemented by subclasses' do
      stage = described_class.new
      expect { stage.process(nil) }.to raise_error(NotImplementedError)
    end

    it 'is called when implemented' do
      stage = TestStage.new
      document = double('Document')
      result = stage.process(document)
      expect(stage.process_called).to be true
      expect(result).to eq(document)
    end
  end

  describe '#name' do
    it 'derives name from class name' do
      stage = TestStage.new
      expect(stage.name).to eq('test')
    end

    it 'handles multi-word class names' do
      class MultiWordTestStage < Uniword::Batch::ProcessingStage
        def process(document, _context = {})
          document
        end
      end

      stage = MultiWordTestStage.new
      expect(stage.name).to eq('multi_word_test')
    end

    it 'removes Stage suffix' do
      class CustomProcessingStage < Uniword::Batch::ProcessingStage
        def process(document, _context = {})
          document
        end
      end

      stage = CustomProcessingStage.new
      expect(stage.name).to eq('custom_processing')
    end
  end

  describe '#description' do
    it 'provides default description' do
      stage = TestStage.new
      expect(stage.description).to eq('test stage')
    end
  end
end
