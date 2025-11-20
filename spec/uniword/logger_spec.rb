# frozen_string_literal: true

require 'spec_helper'
require 'uniword/logger'

RSpec.describe Uniword do
  describe '.logger' do
    it 'returns a Logger instance' do
      expect(Uniword.logger).to be_a(Logger)
    end

    it 'uses WARN level by default' do
      # Reset to default
      Uniword.logger = nil
      expect(Uniword.logger.level).to eq(Logger::WARN)
    end
  end

  describe '.debug?' do
    it 'returns true when debug level is set' do
      Uniword.logger.level = Logger::DEBUG
      expect(Uniword.debug?).to be true
    end

    it 'returns false when not debug level' do
      Uniword.logger.level = Logger::WARN
      expect(Uniword.debug?).to be false
    end
  end

  describe '.enable_debug_logging' do
    it 'sets logger to DEBUG level' do
      Uniword.enable_debug_logging
      expect(Uniword.logger.level).to eq(Logger::DEBUG)
    end
  end

  describe '.disable_debug_logging' do
    it 'sets logger to WARN level' do
      Uniword.disable_debug_logging
      expect(Uniword.logger.level).to eq(Logger::WARN)
    end
  end

  describe 'custom logger' do
    it 'allows setting a custom logger' do
      custom_logger = Logger.new(StringIO.new)
      Uniword.logger = custom_logger
      expect(Uniword.logger).to eq(custom_logger)
    end
  end
end

RSpec.describe Uniword::Loggable do
  let(:test_class) do
    Class.new do
      include Uniword::Loggable

      def test_logging
        log_debug('Debug message')
        log_info('Info message')
        log_warn('Warning message')
        log_error('Error message')
      end
    end
  end

  let(:instance) { test_class.new }

  describe '#logger' do
    it 'returns the Uniword logger' do
      expect(instance.logger).to eq(Uniword.logger)
    end
  end

  describe 'logging methods' do
    let(:string_io) { StringIO.new }
    let(:test_logger) { Logger.new(string_io) }

    before do
      Uniword.logger = test_logger
      Uniword.logger.level = Logger::DEBUG
    end

    it 'logs debug messages' do
      instance.log_debug('Test debug')
      expect(string_io.string).to include('DEBUG')
      expect(string_io.string).to include('Test debug')
    end

    it 'logs info messages' do
      instance.log_info('Test info')
      expect(string_io.string).to include('INFO')
      expect(string_io.string).to include('Test info')
    end

    it 'logs warning messages' do
      instance.log_warn('Test warning')
      expect(string_io.string).to include('WARN')
      expect(string_io.string).to include('Test warning')
    end

    it 'logs error messages' do
      instance.log_error('Test error')
      expect(string_io.string).to include('ERROR')
      expect(string_io.string).to include('Test error')
    end
  end
end

RSpec.describe 'Inspection helpers' do
  describe Uniword::Document do
    let(:doc) { Uniword::Document.new }

    it 'provides readable inspect output' do
      para = Uniword::Paragraph.new
      para.add_text('Test')
      doc.add_element(para)
      expect(doc.inspect).to include('Uniword::Document')
      expect(doc.inspect).to include('@body=...')
    end
  end

  describe Uniword::Paragraph do
    let(:para) { Uniword::Paragraph.new }

    it 'provides readable inspect output' do
      para.add_text('Hello World')
      expect(para.inspect).to include('Uniword::Paragraph')
      expect(para.inspect).to include('runs=1')
      expect(para.inspect).to include('Hello World')
    end

    it 'truncates long text' do
      para.add_text('A' * 100)
      expect(para.inspect).to include('...')
      expect(para.inspect.length).to be < 200
    end
  end

  describe Uniword::Run do
    let(:run) { Uniword::Run.new(text: 'Test text') }

    it 'provides readable inspect output' do
      expect(run.inspect).to include('Uniword::Run')
      expect(run.inspect).to include('Test text')
    end

    it 'shows formatting flags' do
      run.properties = Uniword::Properties::RunProperties.new(bold: true, italic: true)
      expect(run.inspect).to include('bold')
      expect(run.inspect).to include('italic')
    end

    it 'truncates long text' do
      run.text = 'A' * 100
      expect(run.inspect).to include('...')
      expect(run.inspect.length).to be < 150
    end
  end
end