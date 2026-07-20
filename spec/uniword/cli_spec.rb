# frozen_string_literal: true

require "spec_helper"
require "uniword"

RSpec.describe Uniword::CLI do
  let(:cli) { described_class.new }

  describe "#version" do
    it "displays the version" do
      expect { cli.version }.to output(/Uniword version/).to_stdout
    end
  end

  describe "#convert" do
    let(:input_path) { "spec/fixtures/test.docx" }
    let(:output_path) { "spec/fixtures/output.docx" }

    context "with non-existent file" do
      it "exits with error message" do
        expect do
          cli.invoke(:convert, ["nonexistent.docx", "output.docx"])
        end.to raise_error(SystemExit)
      end
    end

    context "with verbose option" do
      let(:fixture_path) { "spec/fixtures/docx_gem/styles.docx" }

      it "shows detailed output" do
        skip "fixture not available" unless File.exist?(fixture_path)

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

  describe "#info" do
    context "with non-existent file" do
      it "exits with error message" do
        expect do
          cli.invoke(:info, ["nonexistent.docx"])
        end.to raise_error(SystemExit)
      end
    end

    context "with verbose option" do
      let(:fixture_path) { "spec/fixtures/docx_gem/styles.docx" }

      it "shows detailed information" do
        expect do
          cli.invoke(:info, [fixture_path], verbose: true)
        end.to output(/Statistics|Paragraphs|Analysis/).to_stdout
      end
    end
  end

  describe "#validate" do
    # Invoke `uniword validate` and return the exit status
    # (0 when the command completes without calling exit).
    def validate_status(path)
      cli.invoke(:validate, [path])
      0
    rescue SystemExit => e
      e.status
    end

    context "with non-existent file" do
      it "exits with error message" do
        expect do
          cli.invoke(:validate, ["nonexistent.docx"])
        end.to raise_error(SystemExit)
      end
    end

    context "with a valid document" do
      let(:fixture_path) { "spec/fixtures/docx_gem/basic.docx" }

      it "exits zero" do
        expect(validate_status(fixture_path)).to eq(0)
      end
    end

    context "with a table missing tblGrid" do
      let(:bad_path) { File.join(Dir.tmpdir, "uniword_validate_bad.docx") }

      before do
        # The save-time reconciler repairs tables, so strip tblGrid and
        # tblPr from the package after saving. Replace via delete+write
        # with retries (the ZipPackager pattern): rubyzip's rename-based
        # commit and plain renames are denied by the transient
        # indexer/Defender lock on freshly-created files on Windows.
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        doc.body.tables << Uniword::Wordprocessingml::Table.new
        doc.to_file(bad_path)

        entries = {}
        Zip::File.open(bad_path) do |zip|
          zip.each { |e| entries[e.name] = e.get_input_stream.read }
        end
        entries["word/document.xml"] =
          entries["word/document.xml"]
            .gsub(%r{<w:tblPr>.*?</w:tblPr>}m, "")
            .gsub("<w:tblGrid/>", "")

        stripped_path = "#{bad_path}.stripped"
        Zip::File.open(stripped_path, create: true) do |zip|
          entries.each do |name, data|
            zip.get_output_stream(name) { |f| f.write(data) }
          end
        end

        retries = 5
        begin
          FileUtils.rm_f(bad_path)
          sleep(0.5)
          File.binwrite(bad_path, File.binread(stripped_path))
          FileUtils.rm_f(stripped_path)
        rescue Errno::EACCES
          retries -= 1
          retry if retries.positive?
          raise
        end
      end

      after { safe_delete(bad_path) }

      it "exits with status 1" do
        expect(validate_status(bad_path)).to eq(1)
      end

      it "reports the tblGrid error" do
        expect { validate_status(bad_path) }.to output(/DOC-204/).to_stdout
      end
    end

    context "with verbose option" do
      let(:fixture_path) { "spec/fixtures/docx_gem/styles.docx" }

      it "shows detailed validation results" do
        skip "fixture not available" unless File.exist?(fixture_path)

        expect do
          cli.invoke(:validate, [fixture_path], verbose: true)
        end.to output(/Validating|valid|complete/).to_stdout
      end
    end
  end
end
