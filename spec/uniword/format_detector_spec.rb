# frozen_string_literal: true

require "spec_helper"
require "securerandom"

RSpec.describe Uniword::FormatDetector do
  let(:detector) { described_class.new }

  describe "#detect" do
    context "with DOCX file" do
      it "detects DOCX by ZIP signature" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
        begin
          # Create a ZIP file (DOCX is a ZIP archive)
          packager = Uniword::Infrastructure::ZipPackager.new
          packager.package({ "test.xml" => "<test/>" }, temp_path)

          format = detector.detect(temp_path)

          expect(format).to eq(:docx)
        ensure
          safe_delete(temp_path)
        end
      end

      it "detects DOCX by extension when signature missing" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
        begin
          # Write non-ZIP content
          File.binwrite(temp_path, "Not a ZIP file")

          format = detector.detect(temp_path)

          expect(format).to eq(:docx)
        ensure
          safe_delete(temp_path)
        end
      end
    end

    context "with MHTML file" do
      it "detects MHTML by MIME header" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mhtml")
        begin
          content = <<~MHTML
            MIME-Version: 1.0
            Content-Type: multipart/related

            <html><body>Test</body></html>
          MHTML
          File.write(temp_path, content)

          format = detector.detect(temp_path)

          expect(format).to eq(:mhtml)
        ensure
          safe_delete(temp_path)
        end
      end

      it "detects MHTML by .mhtml extension" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mhtml")
        begin
          File.write(temp_path, "Some content")

          format = detector.detect(temp_path)

          expect(format).to eq(:mhtml)
        ensure
          safe_delete(temp_path)
        end
      end

      it "detects MHTML by .mht extension" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mht")
        begin
          File.write(temp_path, "Some content")

          format = detector.detect(temp_path)

          expect(format).to eq(:mhtml)
        ensure
          safe_delete(temp_path)
        end
      end
    end

    context "with unsupported file" do
      it "raises ArgumentError for unknown extension" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.txt")
        begin
          File.write(temp_path, "Text content")

          expect { detector.detect(temp_path) }.to raise_error(
            ArgumentError,
            /Unsupported file extension/
          )
        ensure
          safe_delete(temp_path)
        end
      end

      it "raises ArgumentError for .pdf extension" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.pdf")
        begin
          File.write(temp_path, "PDF content")

          expect { detector.detect(temp_path) }.to raise_error(
            ArgumentError,
            /Unsupported file extension/
          )
        ensure
          safe_delete(temp_path)
        end
      end
    end

    context "with invalid arguments" do
      it "raises ArgumentError when path is nil" do
        expect { detector.detect(nil) }.to raise_error(
          ArgumentError,
          "Path cannot be nil"
        )
      end

      it "raises ArgumentError when path is empty" do
        expect { detector.detect("") }.to raise_error(
          ArgumentError,
          "Path cannot be empty"
        )
      end

      it "raises ArgumentError when file does not exist" do
        expect { detector.detect("nonexistent.docx") }.to raise_error(
          ArgumentError,
          /File not found/
        )
      end

      it "raises ArgumentError when path is a directory" do
        Dir.mktmpdir do |dir|
          expect { detector.detect(dir) }.to raise_error(
            ArgumentError,
            /Path is a directory/
          )
        end
      end
    end

    context "with empty file" do
      it "falls back to extension detection" do
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.docx")
        begin
          # Create empty file
          File.write(temp_path, "")

          format = detector.detect(temp_path)

          expect(format).to eq(:docx)
        ensure
          safe_delete(temp_path)
        end
      end
    end

    context "signature detection priority" do
      it "prefers signature over extension" do
        # Create a ZIP file with wrong extension
        temp_path = File.join(Dir.tmpdir, "uniword_test_#{SecureRandom.uuid}.mhtml")
        begin
          packager = Uniword::Infrastructure::ZipPackager.new
          packager.package({ "test.xml" => "<test/>" }, temp_path)

          # Should detect as DOCX based on ZIP signature
          format = detector.detect(temp_path)

          expect(format).to eq(:docx)
        ensure
          safe_delete(temp_path)
        end
      end
    end
  end
end
