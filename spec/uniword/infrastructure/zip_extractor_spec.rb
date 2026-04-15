# frozen_string_literal: true

require "spec_helper"
require "zip"
require "tempfile"

RSpec.describe Uniword::Infrastructure::ZipExtractor do
  let(:extractor) { described_class.new }

  # Helper to create a temporary ZIP file on disk, properly handling Windows file locking.
  # On Windows, Tempfile keeps a handle open which conflicts with Zip::File::CREATE's
  # atomic rename. This helper closes and deletes the tempfile first, and suppresses
  # the Tempfile finalizer to prevent EACCES errors when rubyzip locks files.
  def create_temp_zip
    temp_zip = Tempfile.new(["test", ".zip"])
    temp_zip.close
    safe_delete(temp_zip.path)
    # Suppress finalizer - we handle cleanup manually via safe_delete
    begin
      Tempfile.send(:remove_instance_variable, :@finalizer)
    rescue StandardError
      nil
    end
    temp_zip
  end

  describe "#extract" do
    context "with valid ZIP file" do
      it "extracts all files from ZIP archive" do
        # Create a temporary ZIP file
        # On Windows, Tempfile keeps a handle open which conflicts with Zip::File::CREATE's
        # atomic rename. Close and delete the file first.
        temp_zip = Tempfile.new(["test", ".zip"])
        temp_zip.close
        safe_delete(temp_zip.path)
        # Suppress finalizer - we handle cleanup manually via ensure block
        temp_zip.instance_variable_set(:@finalizer, proc {})
        begin
          Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip_file|
            zip_file.get_output_stream("file1.txt") { |f| f.write("Content 1") }
            zip_file.get_output_stream("dir/file2.txt") { |f| f.write("Content 2") }
          end

          result = extractor.extract(temp_zip.path)

          expect(result).to be_a(Hash)
          expect(result).to have_key("file1.txt")
          expect(result).to have_key("dir/file2.txt")
          expect(result["file1.txt"]).to eq("Content 1")
          expect(result["dir/file2.txt"]).to eq("Content 2")
        ensure
          temp_zip.unlink
        end
      end

      it "skips directories" do
        temp_zip = Tempfile.new(["test", ".zip"])
        temp_zip.close
        safe_delete(temp_zip.path)
        # Suppress finalizer - we handle cleanup manually via ensure block
        temp_zip.instance_variable_set(:@finalizer, proc {})
        begin
          Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip_file|
            zip_file.mkdir("empty_dir")
            zip_file.get_output_stream("file.txt") { |f| f.write("Content") }
          end

          result = extractor.extract(temp_zip.path)

          expect(result.keys).not_to include("empty_dir")
          expect(result).to have_key("file.txt")
        ensure
          temp_zip.unlink
        end
      end

      it "returns empty hash for empty ZIP" do
        temp_zip = Tempfile.new(["test", ".zip"])
        temp_zip.close
        safe_delete(temp_zip.path)
        # Suppress finalizer - we handle cleanup manually via ensure block
        temp_zip.instance_variable_set(:@finalizer, proc {})
        begin
          Zip::File.open(temp_zip.path, Zip::File::CREATE) { |_zip_file| }

          result = extractor.extract(temp_zip.path)

          expect(result).to eq({})
        ensure
          temp_zip.unlink
        end
      end
    end

    context "with invalid arguments" do
      it "raises ArgumentError when path is nil" do
        expect { extractor.extract(nil) }.to raise_error(
          ArgumentError,
          "Path cannot be nil"
        )
      end

      it "raises ArgumentError when path is empty" do
        expect { extractor.extract("") }.to raise_error(
          ArgumentError,
          "Path cannot be empty"
        )
      end

      it "raises ArgumentError when file does not exist" do
        expect { extractor.extract("nonexistent.zip") }.to raise_error(
          ArgumentError,
          /File not found/
        )
      end

      it "raises ArgumentError when path is a directory" do
        Dir.mktmpdir do |dir|
          expect { extractor.extract(dir) }.to raise_error(
            ArgumentError,
            /Path is a directory/
          )
        end
      end
    end
  end

  describe "#extract_file" do
    let(:temp_zip) do
      tf = Tempfile.new(["test", ".zip"])
      tf.close
      safe_delete(tf.path)
      # Suppress finalizer - we handle cleanup manually via after block
      tf.instance_variable_set(:@finalizer, proc {})
      tf
    end

    before do
      Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip_file|
        zip_file.get_output_stream("document.xml") { |f| f.write("<doc>Test</doc>") }
        zip_file.get_output_stream("styles.xml") { |f| f.write("<styles/>") }
      end
    end

    after do
      temp_zip.unlink
    end

    context "when file exists" do
      it "extracts specific file" do
        result = extractor.extract_file(temp_zip.path, "document.xml")

        expect(result).to eq("<doc>Test</doc>")
      end

      it "extracts different file" do
        result = extractor.extract_file(temp_zip.path, "styles.xml")

        expect(result).to eq("<styles/>")
      end
    end

    context "when file does not exist" do
      it "returns nil" do
        result = extractor.extract_file(temp_zip.path, "nonexistent.xml")

        expect(result).to be_nil
      end
    end

    context "with invalid arguments" do
      it "raises ArgumentError when path is nil" do
        expect { extractor.extract_file(nil, "file.txt") }.to raise_error(
          ArgumentError,
          "Path cannot be nil"
        )
      end
    end
  end

  describe "#list_files" do
    let(:temp_zip) do
      tf = Tempfile.new(["test", ".zip"])
      tf.close
      safe_delete(tf.path)
      # Suppress finalizer - we handle cleanup manually via after block
      tf.instance_variable_set(:@finalizer, proc {})
      tf
    end

    before do
      Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip_file|
        zip_file.get_output_stream("file1.txt") { |f| f.write("Content 1") }
        zip_file.get_output_stream("dir/file2.txt") { |f| f.write("Content 2") }
        zip_file.mkdir("empty_dir")
      end
    end

    after do
      temp_zip.unlink
    end

    it "returns array of file paths" do
      result = extractor.list_files(temp_zip.path)

      expect(result).to be_an(Array)
      expect(result).to include("file1.txt")
      expect(result).to include("dir/file2.txt")
    end

    it "excludes directories" do
      result = extractor.list_files(temp_zip.path)

      expect(result).not_to include("empty_dir")
    end

    it "returns empty array for empty ZIP" do
      temp_empty = Tempfile.new(["empty", ".zip"])
      temp_empty.close
      safe_delete(temp_empty.path)
      # Suppress finalizer - we handle cleanup manually via ensure block
      temp_empty.instance_variable_set(:@finalizer, proc {})
      begin
        Zip::File.open(temp_empty.path, Zip::File::CREATE) { |_zip_file| }

        result = extractor.list_files(temp_empty.path)

        expect(result).to eq([])
      ensure
        temp_empty.unlink
      end
    end

    context "with invalid arguments" do
      it "raises ArgumentError when path is nil" do
        expect { extractor.list_files(nil) }.to raise_error(
          ArgumentError,
          "Path cannot be nil"
        )
      end
    end
  end
end
