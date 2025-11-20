# frozen_string_literal: true

require 'spec_helper'
require 'zip'
require 'tempfile'

RSpec.describe Uniword::Infrastructure::ZipPackager do
  let(:packager) { described_class.new }

  describe '#package' do
    let(:content) do
      {
        'file1.txt' => 'Content 1',
        'dir/file2.txt' => 'Content 2'
      }
    end

    context 'with valid arguments' do
      it 'creates ZIP file with content' do
        temp_zip = Tempfile.new(['output', '.zip'])
        begin
          packager.package(content, temp_zip.path)

          expect(File.exist?(temp_zip.path)).to be true

          # Verify content
          Zip::File.open(temp_zip.path) do |zip_file|
            expect(zip_file.find_entry('file1.txt')).not_to be_nil
            expect(zip_file.find_entry('dir/file2.txt')).not_to be_nil
            expect(zip_file.read('file1.txt')).to eq('Content 1')
            expect(zip_file.read('dir/file2.txt')).to eq('Content 2')
          end
        ensure
          temp_zip.unlink
        end
      end

      it 'creates output directory if it does not exist' do
        Dir.mktmpdir do |tmpdir|
          output_path = File.join(tmpdir, 'subdir', 'output.zip')

          packager.package(content, output_path)

          expect(File.exist?(output_path)).to be true
          expect(File.directory?(File.dirname(output_path))).to be true
        ensure
          FileUtils.rm_f(output_path)
        end
      end

      it 'overwrites existing file' do
        temp_zip = Tempfile.new(['output', '.zip'])
        begin
          # Create initial file
          packager.package({ 'old.txt' => 'Old content' }, temp_zip.path)

          # Delete and recreate with new content
          File.delete(temp_zip.path)
          packager.package(content, temp_zip.path)

          Zip::File.open(temp_zip.path) do |zip_file|
            expect(zip_file.find_entry('old.txt')).to be_nil
            expect(zip_file.find_entry('file1.txt')).not_to be_nil
          end
        ensure
          temp_zip.unlink if File.exist?(temp_zip.path)
        end
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when content is nil' do
        expect { packager.package(nil, 'output.zip') }.to raise_error(
          ArgumentError,
          'Content cannot be nil'
        )
      end

      it 'raises ArgumentError when content is not a Hash' do
        expect { packager.package('invalid', 'output.zip') }.to raise_error(
          ArgumentError,
          'Content must be a Hash'
        )
      end

      it 'raises ArgumentError when content is empty' do
        expect { packager.package({}, 'output.zip') }.to raise_error(
          ArgumentError,
          'Content cannot be empty'
        )
      end

      it 'raises ArgumentError when entry path is nil' do
        invalid_content = { nil => 'content' }
        expect { packager.package(invalid_content, 'output.zip') }.to raise_error(
          ArgumentError,
          'Entry path cannot be nil'
        )
      end

      it 'raises ArgumentError when entry path is empty' do
        invalid_content = { '' => 'content' }
        expect { packager.package(invalid_content, 'output.zip') }.to raise_error(
          ArgumentError,
          'Entry path cannot be empty'
        )
      end

      it 'raises ArgumentError when entry content is nil' do
        invalid_content = { 'file.txt' => nil }
        expect { packager.package(invalid_content, 'output.zip') }.to raise_error(
          ArgumentError,
          /Entry content cannot be nil/
        )
      end

      it 'raises ArgumentError when output path is nil' do
        expect { packager.package(content, nil) }.to raise_error(
          ArgumentError,
          'Output path cannot be nil'
        )
      end

      it 'raises ArgumentError when output path is empty' do
        expect { packager.package(content, '') }.to raise_error(
          ArgumentError,
          'Output path cannot be empty'
        )
      end
    end
  end

  describe '#add_file' do
    let(:temp_zip) { Tempfile.new(['test', '.zip']) }

    before do
      Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip_file|
        zip_file.get_output_stream('existing.txt') { |f| f.write('Existing') }
      end
    end

    after do
      temp_zip.unlink
    end

    context 'with valid arguments' do
      it 'adds file to existing ZIP' do
        packager.add_file(temp_zip.path, 'new.txt', 'New content')

        Zip::File.open(temp_zip.path) do |zip_file|
          expect(zip_file.find_entry('existing.txt')).not_to be_nil
          expect(zip_file.find_entry('new.txt')).not_to be_nil
          expect(zip_file.read('new.txt')).to eq('New content')
        end
      end

      it 'overwrites existing entry with same path' do
        packager.add_file(temp_zip.path, 'existing.txt', 'Updated content')

        Zip::File.open(temp_zip.path) do |zip_file|
          expect(zip_file.read('existing.txt')).to eq('Updated content')
        end
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when zip_path is nil' do
        expect do
          packager.add_file(nil, 'file.txt', 'content')
        end.to raise_error(ArgumentError, 'ZIP path cannot be nil')
      end

      it 'raises ArgumentError when entry_path is nil' do
        expect do
          packager.add_file(temp_zip.path, nil, 'content')
        end.to raise_error(ArgumentError, 'Entry path cannot be nil')
      end

      it 'raises ArgumentError when entry_path is empty' do
        expect do
          packager.add_file(temp_zip.path, '', 'content')
        end.to raise_error(ArgumentError, 'Entry path cannot be empty')
      end
    end
  end

  describe '#remove_file' do
    let(:temp_zip) { Tempfile.new(['test', '.zip']) }

    before do
      Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip_file|
        zip_file.get_output_stream('file1.txt') { |f| f.write('Content 1') }
        zip_file.get_output_stream('file2.txt') { |f| f.write('Content 2') }
      end
    end

    after do
      temp_zip.unlink
    end

    context 'when file exists' do
      it 'removes file from ZIP' do
        result = packager.remove_file(temp_zip.path, 'file1.txt')

        expect(result).to be true

        Zip::File.open(temp_zip.path) do |zip_file|
          expect(zip_file.find_entry('file1.txt')).to be_nil
          expect(zip_file.find_entry('file2.txt')).not_to be_nil
        end
      end

      it 'returns true' do
        result = packager.remove_file(temp_zip.path, 'file1.txt')

        expect(result).to be true
      end
    end

    context 'when file does not exist' do
      it 'returns false' do
        result = packager.remove_file(temp_zip.path, 'nonexistent.txt')

        expect(result).to be false
      end

      it 'does not modify other files' do
        packager.remove_file(temp_zip.path, 'nonexistent.txt')

        Zip::File.open(temp_zip.path) do |zip_file|
          expect(zip_file.find_entry('file1.txt')).not_to be_nil
          expect(zip_file.find_entry('file2.txt')).not_to be_nil
        end
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError when zip_path is nil' do
        expect do
          packager.remove_file(nil, 'file.txt')
        end.to raise_error(ArgumentError, 'ZIP path cannot be nil')
      end
    end
  end
end
