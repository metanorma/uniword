# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'json'
require 'yaml'
require 'csv'

RSpec.describe Uniword::Batch::BatchResult do
  let(:result) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty results' do
      expect(result.successes).to be_empty
      expect(result.failures).to be_empty
      expect(result.start_time).to be_a(Time)
      expect(result.end_time).to be_nil
    end
  end

  describe '#add_success' do
    it 'adds a successful result' do
      result.add_success(file: 'test.docx', duration: 1.5)
      expect(result.successes.size).to eq(1)
      expect(result.successes.first[:file]).to eq('test.docx')
      expect(result.successes.first[:duration]).to eq(1.5)
    end

    it 'accepts stages and metadata' do
      result.add_success(
        file: 'test.docx',
        duration: 1.0,
        stages: %w[normalize validate],
        metadata: { custom: 'data' }
      )

      success = result.successes.first
      expect(success[:stages]).to eq(%w[normalize validate])
      expect(success[:metadata]).to eq({ custom: 'data' })
    end

    it 'returns self for chaining' do
      expect(result.add_success(file: 'test.docx')).to eq(result)
    end
  end

  describe '#add_failure' do
    it 'adds a failed result with string error' do
      result.add_failure(file: 'test.docx', error: 'Invalid format')
      expect(result.failures.size).to eq(1)
      expect(result.failures.first[:file]).to eq('test.docx')
      expect(result.failures.first[:error]).to eq('Invalid format')
    end

    it 'adds a failed result with exception' do
      error = StandardError.new('Test error')
      result.add_failure(file: 'test.docx', error: error)

      failure = result.failures.first
      expect(failure[:error]).to eq('Test error')
      expect(failure[:error_class]).to eq('StandardError')
    end

    it 'accepts stage and metadata' do
      result.add_failure(
        file: 'test.docx',
        error: 'Error',
        stage: 'validate',
        metadata: { info: 'test' }
      )

      failure = result.failures.first
      expect(failure[:stage]).to eq('validate')
      expect(failure[:metadata]).to eq({ info: 'test' })
    end

    it 'returns self for chaining' do
      expect(result.add_failure(file: 'test.docx', error: 'Error')).to eq(result)
    end
  end

  describe '#complete!' do
    it 'sets end time' do
      expect(result.end_time).to be_nil
      result.complete!
      expect(result.end_time).to be_a(Time)
    end

    it 'returns self' do
      expect(result.complete!).to eq(result)
    end
  end

  describe '#total_count' do
    it 'returns zero when empty' do
      expect(result.total_count).to eq(0)
    end

    it 'counts successes and failures' do
      result.add_success(file: 'test1.docx')
      result.add_success(file: 'test2.docx')
      result.add_failure(file: 'test3.docx', error: 'Error')

      expect(result.total_count).to eq(3)
    end
  end

  describe '#success_count' do
    it 'returns number of successes' do
      result.add_success(file: 'test1.docx')
      result.add_success(file: 'test2.docx')
      expect(result.success_count).to eq(2)
    end
  end

  describe '#failure_count' do
    it 'returns number of failures' do
      result.add_failure(file: 'test1.docx', error: 'Error')
      result.add_failure(file: 'test2.docx', error: 'Error')
      expect(result.failure_count).to eq(2)
    end
  end

  describe '#success_rate' do
    it 'returns 0 when no files processed' do
      expect(result.success_rate).to eq(0.0)
    end

    it 'returns 100 when all successful' do
      result.add_success(file: 'test1.docx')
      result.add_success(file: 'test2.docx')
      expect(result.success_rate).to eq(100.0)
    end

    it 'calculates percentage correctly' do
      result.add_success(file: 'test1.docx')
      result.add_success(file: 'test2.docx')
      result.add_failure(file: 'test3.docx', error: 'Error')

      expect(result.success_rate).to eq(66.67)
    end
  end

  describe '#elapsed_time' do
    it 'calculates elapsed time' do
      expect(result.elapsed_time).to be >= 0
    end

    it 'uses end_time when completed' do
      result.complete!
      expect(result.elapsed_time).to be_a(Float)
    end
  end

  describe '#average_duration' do
    it 'returns 0 when no successes' do
      expect(result.average_duration).to eq(0.0)
    end

    it 'calculates average duration' do
      result.add_success(file: 'test1.docx', duration: 1.0)
      result.add_success(file: 'test2.docx', duration: 3.0)
      expect(result.average_duration).to eq(2.0)
    end
  end

  describe '#success?' do
    it 'returns true when no failures' do
      result.add_success(file: 'test.docx')
      expect(result.success?).to be true
    end

    it 'returns false when failures exist' do
      result.add_failure(file: 'test.docx', error: 'Error')
      expect(result.success?).to be false
    end
  end

  describe '#summary' do
    it 'returns summary hash' do
      result.add_success(file: 'test1.docx', duration: 1.0)
      result.add_failure(file: 'test2.docx', error: 'Error')

      summary = result.summary
      expect(summary[:total]).to eq(2)
      expect(summary[:successes]).to eq(1)
      expect(summary[:failures]).to eq(1)
      expect(summary[:success_rate]).to eq(50.0)
      expect(summary).to have_key(:elapsed_time)
      expect(summary).to have_key(:average_duration)
    end
  end

  describe '#summary_text' do
    it 'returns formatted summary' do
      result.add_success(file: 'test.docx', duration: 1.0)
      text = result.summary_text

      expect(text).to include('Batch Processing Results')
      expect(text).to include('Total files:')
      expect(text).to include('Successful:')
      expect(text).to include('Failed:')
    end
  end

  describe '#export_json' do
    it 'exports results to JSON file' do
      result.add_success(file: 'test.docx')

      Tempfile.create(['batch_result', '.json']) do |file|
        result.export_json(file.path)

        data = JSON.parse(File.read(file.path))
        expect(data['summary']).to be_a(Hash)
        expect(data['successes']).to be_an(Array)
        expect(data['failures']).to be_an(Array)
      end
    end
  end

  describe '#export_yaml' do
    it 'exports results to YAML file' do
      result.add_success(file: 'test.docx')

      Tempfile.create(['batch_result', '.yml']) do |file|
        result.export_yaml(file.path)

        data = YAML.load_file(file.path, permitted_classes: [Time, Symbol])
        expect(data['summary']).to be_a(Hash)
        expect(data['successes']).to be_an(Array)
        expect(data['failures']).to be_an(Array)
      end
    end
  end

  describe '#export_csv' do
    it 'exports results to CSV file' do
      result.add_success(file: 'test1.docx', duration: 1.0, stages: ['normalize'])
      result.add_failure(file: 'test2.docx', error: 'Error', stage: 'validate')

      Tempfile.create(['batch_result', '.csv']) do |file|
        result.export_csv(file.path)

        rows = CSV.read(file.path)
        expect(rows[0]).to eq(%w[File Status Duration Error Stage])
        expect(rows[1][0]).to eq('test1.docx')
        expect(rows[1][1]).to eq('SUCCESS')
        expect(rows[2][0]).to eq('test2.docx')
        expect(rows[2][1]).to eq('FAILURE')
      end
    end
  end
end
