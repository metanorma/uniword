# frozen_string_literal: true

require 'spec_helper'
require 'uniword/cli'

RSpec.describe Uniword::CLI do
  let(:cli) { described_class.new }

  describe '#version' do
    it 'displays the version' do
      expect { cli.version }.to output(/Uniword version/).to_stdout
    end
  end

  describe '#convert' do
    let(:input_path) { 'spec/fixtures/test.docx' }
    let(:output_path) { 'spec/fixtures/output.docx' }

    context 'with non-existent file' do
      it 'exits with error message' do
        expect do
          cli.invoke(:convert, ['nonexistent.docx', 'output.docx'])
        end.to raise_error(SystemExit)
      end
    end

    context 'with verbose option' do
      let(:fixture_path) { 'spec/fixtures/docx_gem/styles.docx' }

      it 'shows detailed output' do
        skip 'fixture not available' unless File.exist?(fixture_path)

        output_path = File.join(Dir.tmpdir, "cli_convert_#{Time.now.to_i}.docx")
        begin
          expect do
            cli.invoke(:convert, [fixture_path, output_path], verbose: true)
          end.to output(/Converting|Paragraphs|complete/).to_stdout
        ensure
          safe_delete(output_path)
        end
      end
    end
  end

  describe '#info' do
    context 'with non-existent file' do
      it 'exits with error message' do
        expect do
          cli.invoke(:info, ['nonexistent.docx'])
        end.to raise_error(SystemExit)
      end
    end

    context 'with verbose option' do
      let(:fixture_path) { 'spec/fixtures/docx_gem/styles.docx' }

      it 'shows detailed information' do
        expect do
          cli.invoke(:info, [fixture_path], verbose: true)
        end.to output(/Statistics|Paragraphs|Analysis/).to_stdout
      end
    end
  end

  describe '#validate' do
    context 'with non-existent file' do
      it 'exits with error message' do
        expect do
          cli.invoke(:validate, ['nonexistent.docx'])
        end.to raise_error(SystemExit)
      end
    end

    context 'with verbose option' do
      let(:fixture_path) { 'spec/fixtures/docx_gem/styles.docx' }

      it 'shows detailed validation results' do
        skip 'fixture not available' unless File.exist?(fixture_path)

        expect do
          cli.invoke(:validate, [fixture_path], verbose: true)
        end.to output(/Validating|valid|complete/).to_stdout
      end
    end
  end
end
