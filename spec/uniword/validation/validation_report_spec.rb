# frozen_string_literal: true

require 'spec_helper'
require 'uniword/validation/validation_report'
require 'uniword/validation/validation_result'
require 'uniword/wordprocessingml/hyperlink'

RSpec.describe Uniword::Validation::ValidationReport do
  let(:external_link) { Uniword::Wordprocessingml::Hyperlink.new(id: 'https://example.com') }
  let(:anchor_link) { Uniword::Wordprocessingml::Hyperlink.new(anchor: 'section1') }
  let(:broken_link) { Uniword::Wordprocessingml::Hyperlink.new(id: 'https://broken.com') }

  let(:success_result) do
    Uniword::Validation::ValidationResult.success(external_link)
  end

  let(:failure_result) do
    Uniword::Validation::ValidationResult.failure(broken_link, 'Not found')
  end

  let(:warning_result) do
    Uniword::Validation::ValidationResult.warning(anchor_link, 'Redirect')
  end

  describe '#add_result' do
    it 'adds a validation result' do
      report = described_class.new
      report.add_result(success_result)

      expect(report.results).to contain_exactly(success_result)
    end

    it 'returns self for chaining' do
      report = described_class.new
      result = report.add_result(success_result)

      expect(result).to eq(report)
    end

    it 'raises error for non-ValidationResult' do
      report = described_class.new

      expect do
        report.add_result('not a result')
      end.to raise_error(ArgumentError, /Expected ValidationResult/)
    end
  end

  describe '#valid?' do
    it 'returns true when all results are successful' do
      report = described_class.new
      report.add_result(success_result)

      expect(report.valid?).to be true
    end

    it 'returns false when any result failed' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)

      expect(report.valid?).to be false
    end

    it 'returns true for empty report' do
      report = described_class.new

      expect(report.valid?).to be true
    end
  end

  describe '#successes' do
    it 'returns only successful results' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)
      report.add_result(warning_result)

      expect(report.successes).to contain_exactly(success_result)
    end
  end

  describe '#failures' do
    it 'returns only failed results' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)

      expect(report.failures).to contain_exactly(failure_result)
    end
  end

  describe '#warnings' do
    it 'returns only warning results' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(warning_result)

      expect(report.warnings).to contain_exactly(warning_result)
    end
  end

  describe 'count methods' do
    let(:report) do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)
      report.add_result(warning_result)
      report
    end

    it '#success_count returns count of successes' do
      expect(report.success_count).to eq(1)
    end

    it '#failure_count returns count of failures' do
      expect(report.failure_count).to eq(1)
    end

    it '#warning_count returns count of warnings' do
      expect(report.warning_count).to eq(1)
    end

    it '#total_count returns total count' do
      expect(report.total_count).to eq(3)
    end
  end

  describe '#summary' do
    it 'returns summary statistics' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)

      summary = report.summary

      expect(summary[:total]).to eq(2)
      expect(summary[:successes]).to eq(1)
      expect(summary[:failures]).to eq(1)
      expect(summary[:valid]).to be false
    end
  end

  describe '#group_by_type' do
    it 'groups results by link type' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)

      grouped = report.group_by_type

      expect(grouped[:external]).to include(success_result, failure_result)
    end
  end

  describe '#to_h' do
    it 'converts report to hash' do
      report = described_class.new
      report.add_result(success_result)

      hash = report.to_h

      expect(hash).to have_key(:summary)
      expect(hash).to have_key(:results)
      expect(hash).to have_key(:by_type)
    end
  end

  describe '#to_s' do
    it 'formats report as string' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)

      output = report.to_s

      expect(output).to include('Link Validation Report')
      expect(output).to include('Total: 2')
      expect(output).to include('Successes: 1')
      expect(output).to include('Failures: 1')
      expect(output).to include('Failed Links:')
    end
  end

  describe 'export methods' do
    let(:report) do
      report = described_class.new
      report.add_result(success_result)
      report
    end

    describe '#export_json' do
      it 'exports report to JSON file' do
        file_path = 'tmp/test_report.json'
        FileUtils.mkdir_p('tmp')

        report.export_json(file_path)

        expect(File.exist?(file_path)).to be true
        content = JSON.parse(File.read(file_path))
        expect(content['summary']).to be_a(Hash)

        FileUtils.rm_f(file_path)
      end
    end

    describe '#export_yaml' do
      it 'exports report to YAML file' do
        file_path = 'tmp/test_report.yml'
        FileUtils.mkdir_p('tmp')

        report.export_yaml(file_path)

        expect(File.exist?(file_path)).to be true
        content = YAML.load_file(file_path, aliases: true)
        expect(content[:summary]).to be_a(Hash)

        FileUtils.rm_f(file_path)
      end
    end

    describe '#export_html' do
      it 'exports report to HTML file' do
        file_path = 'tmp/test_report.html'
        FileUtils.mkdir_p('tmp')

        report.export_html(file_path)

        expect(File.exist?(file_path)).to be true
        content = File.read(file_path)
        expect(content).to include('<!DOCTYPE html>')
        expect(content).to include('Link Validation Report')

        FileUtils.rm_f(file_path)
      end
    end
  end

  describe '#to_json' do
    it 'converts report to JSON string' do
      report = described_class.new
      report.add_result(success_result)

      json = report.to_json

      expect(json).to be_a(String)
      parsed = JSON.parse(json)
      expect(parsed['summary']).to be_a(Hash)
    end
  end

  describe '#to_html' do
    it 'converts report to HTML string' do
      report = described_class.new
      report.add_result(success_result)
      report.add_result(failure_result)

      html = report.to_html

      expect(html).to include('<!DOCTYPE html>')
      expect(html).to include('Link Validation Report')
      expect(html).to include('<table>')
    end
  end
end
