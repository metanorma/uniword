# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "uniword/template_manager"

RSpec.describe Uniword::TemplateManager do
  let(:tmpdir) { Dir.mktmpdir("uniword_tm_") }
  let(:template_dir) { File.join(tmpdir, "templates") }
  let(:fixture_docx) { "spec/fixtures/docx_gem/basic.docx" }

  after do
    FileUtils.rm_rf(tmpdir)
  end

  describe ".create" do
    context "when source file exists" do
      it "copies the docx into the template directory" do
        skip "fixture not available" unless File.exist?(fixture_docx)

        metadata = described_class.create(
          "test_report", fixture_docx, template_dir
        )

        dest = File.join(template_dir, "test_report.docx")
        expect(File.exist?(dest)).to be true
        expect(metadata).to be_a(Hash)
      end

      it "writes sidecar metadata" do
        skip "fixture not available" unless File.exist?(fixture_docx)

        described_class.create("test_report", fixture_docx, template_dir)

        meta_path = File.join(template_dir, "test_report.uniword.json")
        expect(File.exist?(meta_path)).to be true

        metadata = JSON.parse(File.read(meta_path))
        expect(metadata["name"]).to eq("test_report")
        expect(metadata).to have_key("created_at")
        expect(metadata).to have_key("updated_at")
      end

      it "stores the description when provided" do
        skip "fixture not available" unless File.exist?(fixture_docx)

        metadata = described_class.create(
          "desc_report", fixture_docx, template_dir,
          description: "Annual report template"
        )

        expect(metadata[:description]).to eq("Annual report template")
      end

      it "creates the output directory if it does not exist" do
        skip "fixture not available" unless File.exist?(fixture_docx)

        new_dir = File.join(tmpdir, "new_templates")
        described_class.create("report", fixture_docx, new_dir)

        expect(Dir.exist?(new_dir)).to be true
        expect(File.exist?(File.join(new_dir, "report.docx"))).to be true
      end

      it "stores the source basename" do
        skip "fixture not available" unless File.exist?(fixture_docx)

        metadata = described_class.create(
          "report", fixture_docx, template_dir
        )

        expect(metadata[:source]).to eq("basic.docx")
      end
    end

    context "when source file does not exist" do
      it "raises ArgumentError" do
        expect do
          described_class.create("bad", "nonexistent.docx", template_dir)
        end.to raise_error(ArgumentError, /Source file not found/)
      end
    end
  end

  describe ".list" do
    context "when directory is empty" do
      it "returns an empty array" do
        FileUtils.mkdir_p(template_dir)
        result = described_class.list(template_dir)
        expect(result).to eq([])
      end
    end

    context "when directory does not exist" do
      it "returns an empty array" do
        result = described_class.list("/nonexistent/path")
        expect(result).to eq([])
      end
    end

    context "when templates exist" do
      before do
        skip "fixture not available" unless File.exist?(fixture_docx)

        described_class.create("alpha", fixture_docx, template_dir,
                               description: "Alpha template")
        described_class.create("beta", fixture_docx, template_dir,
                               description: "Beta template")
      end

      it "returns an array of template info hashes" do
        result = described_class.list(template_dir)

        expect(result).to be_an(Array)
        expect(result.count).to eq(2)
      end

      it "includes name, path, and description for each template" do
        result = described_class.list(template_dir)
        alpha = result.find { |t| t[:name] == "alpha" }

        expect(alpha[:name]).to eq("alpha")
        expect(alpha[:path]).to eq(File.join(template_dir, "alpha.docx"))
        expect(alpha[:description]).to eq("Alpha template")
      end

      it "returns templates sorted alphabetically by name" do
        result = described_class.list(template_dir)
        names = result.map { |t| t[:name] }
        expect(names).to eq(%w[alpha beta])
      end

      it "includes metadata timestamps" do
        result = described_class.list(template_dir)

        result.each do |t|
          expect(t[:created_at]).to be_a(String)
          expect(t[:updated_at]).to be_a(String)
        end
      end
    end

    context "when docx exists without sidecar metadata" do
      before do
        FileUtils.mkdir_p(template_dir)
        FileUtils.cp(fixture_docx, File.join(template_dir, "orphan.docx"))
      end

      it "returns the template with nil metadata fields" do
        skip "fixture not available" unless File.exist?(fixture_docx)

        result = described_class.list(template_dir)

        expect(result.count).to eq(1)
        orphan = result.first
        expect(orphan[:name]).to eq("orphan")
        expect(orphan[:description]).to be_nil
        expect(orphan[:source]).to be_nil
      end
    end
  end

  describe ".apply" do
    before do
      skip "fixture not available" unless File.exist?(fixture_docx)

      described_class.create("report", fixture_docx, template_dir)
    end

    it "generates an output document" do
      output_path = File.join(tmpdir, "output.docx")

      described_class.apply(
        "report", { title: "Q1 Report" }, output_path,
        template_dir: template_dir
      )

      expect(File.exist?(output_path)).to be true
      expect(File.size(output_path)).to be > 0
    end

    it "raises ArgumentError when template is not found" do
      output_path = File.join(tmpdir, "output.docx")

      expect do
        described_class.apply(
          "nonexistent", {}, output_path,
          template_dir: template_dir
        )
      end.to raise_error(ArgumentError, /not found/)
    end

    it "produces a valid docx that can be re-loaded" do
      output_path = File.join(tmpdir, "roundtrip.docx")

      described_class.apply(
        "report", {}, output_path,
        template_dir: template_dir
      )

      doc = Uniword::DocumentFactory.from_file(output_path)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end
  end
end
