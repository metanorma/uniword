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
        expect {
          cli.invoke(:convert, ['nonexistent.docx', 'output.docx'])
        }.to raise_error(SystemExit)
      end
    end

    context 'with verbose option' do
      it 'shows detailed output' do
        skip 'Requires fixture files'
        # This would test verbose output
        # expect { cli.invoke(:convert, [input_path, output_path], verbose: true) }
        #   .to output(/Converting/).to_stdout
      end
    end
  end

  describe '#info' do
    context 'with non-existent file' do
      it 'exits with error message' do
        expect {
          cli.invoke(:info, ['nonexistent.docx'])
        }.to raise_error(SystemExit)
      end
    end

    context 'with verbose option' do
      it 'shows detailed information' do
        skip 'Requires fixture files'
        # This would test verbose info output
      end
    end
  end

  describe '#validate' do
    context 'with non-existent file' do
      it 'exits with error message' do
        expect {
          cli.invoke(:validate, ['nonexistent.docx'])
        }.to raise_error(SystemExit)
      end
    end

    context 'with verbose option' do
      it 'shows detailed validation results' do
        skip 'Requires fixture files'
        # This would test verbose validation output
      end
    end
  end
end