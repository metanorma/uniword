# frozen_string_literal: true

require "spec_helper"
require "uniword/assembly/document_assembler"
require "fileutils"
require "tmpdir"
require "yaml"

RSpec.describe Uniword::Assembly::DocumentAssembler do
  let(:temp_dir) { Dir.mktmpdir }
  let(:components_dir) { File.join(temp_dir, "components") }
  let(:manifest_file) { File.join(temp_dir, "assembly.yml") }

  before do
    FileUtils.mkdir_p(components_dir)

    # Create test components
    create_component("cover_page")
    create_component("legal_notice")

    # Create manifest
    create_manifest
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  def create_component(name)
    path = File.join(components_dir, "#{name}.docx")
    TestDocx.write(path, text: "Component content with {title}")
  end

  def create_manifest(sections: nil)
    manifest_data = {
      "document" => {
        "output" => "output.docx",
        "template" => "standard",
        "variables" => {
          "title" => "Test Document",
          "version" => "1.0",
        },
        "sections" => sections || [
          { "component" => "cover_page" },
          { "component" => "legal_notice" },
        ],
      },
    }

    File.write(manifest_file, YAML.dump(manifest_data))
  end

  describe "#initialize" do
    it "creates assembler with components directory" do
      assembler = described_class.new(components_dir: components_dir)
      expect(assembler.components_dir).to eq(components_dir)
    end

    it "creates component registry" do
      assembler = described_class.new(components_dir: components_dir)
      expect(assembler.registry).to be_a(Uniword::Assembly::ComponentRegistry)
    end

    it "enables caching by default" do
      assembler = described_class.new(components_dir: components_dir)
      stats = assembler.cache_stats
      expect(stats[:enabled]).to be true
    end

    it "can disable caching" do
      assembler = described_class.new(
        components_dir: components_dir,
        cache_components: false,
      )
      stats = assembler.cache_stats
      expect(stats[:enabled]).to be false
    end
  end

  describe "#assemble" do
    let(:assembler) { described_class.new(components_dir: components_dir) }

    it "assembles document from manifest" do
      doc = assembler.assemble(manifest_file)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end

    it "applies variable substitution" do
      doc = assembler.assemble(manifest_file)

      # Check that variables were substituted
      text = doc.paragraphs.first.runs.first.text_string
      expect(text).to include("Test Document")
      expect(text).not_to include("{title}")
    end

    it "accepts variable overrides" do
      doc = assembler.assemble(
        manifest_file,
        variables: { title: "Override Title" },
      )

      text = doc.paragraphs.first.runs.first.text_string
      expect(text).to include("Override Title")
    end

    it "processes multiple sections" do
      doc = assembler.assemble(manifest_file)
      # Should have content from both components
      expect(doc.paragraphs.size).to be >= 2
    end
  end

  describe "#assemble_and_save" do
    let(:assembler) { described_class.new(components_dir: components_dir) }
    let(:output_path) { File.join(temp_dir, "output.docx") }

    it "assembles and saves the document to the output path" do
      path = assembler.assemble_and_save(
        manifest_file,
        output_path: output_path,
      )
      expect(path).to eq(output_path)
      expect(File.size(output_path)).to be > 0
    end

    it "saves a custom output path if provided" do
      custom = File.join(temp_dir, "custom.docx")

      path = assembler.assemble_and_save(
        manifest_file,
        output_path: custom,
      )
      expect(path).to eq(custom)
      expect(File.exist?(custom)).to be true
    end

    it "passes variables to assembly" do
      expect do
        assembler.assemble_and_save(
          manifest_file,
          output_path: output_path,
          variables: { custom: "value" },
        )
      end.not_to raise_error
    end
  end

  describe "#preview" do
    let(:assembler) { described_class.new(components_dir: components_dir) }

    it "returns assembly preview information" do
      preview = assembler.preview(manifest_file)

      expect(preview).to be_a(Hash)
      expect(preview).to have_key(:output_path)
      expect(preview).to have_key(:template)
      expect(preview).to have_key(:variables)
      expect(preview).to have_key(:component_count)
      expect(preview).to have_key(:components)
    end

    it "includes output path from manifest" do
      preview = assembler.preview(manifest_file)
      expect(preview[:output_path]).to eq("output.docx")
    end

    it "includes template from manifest" do
      preview = assembler.preview(manifest_file)
      expect(preview[:template]).to eq("standard")
    end

    it "includes variables from manifest" do
      preview = assembler.preview(manifest_file)
      expect(preview[:variables]["title"]).to eq("Test Document")
    end

    it "counts components" do
      preview = assembler.preview(manifest_file)
      expect(preview[:component_count]).to eq(2)
    end

    it "lists component names" do
      preview = assembler.preview(manifest_file)
      component_names = preview[:components].map { |c| c[:name] }
      expect(component_names).to include("cover_page", "legal_notice")
    end
  end

  describe "#clear_cache" do
    let(:assembler) { described_class.new(components_dir: components_dir) }

    it "clears component cache" do
      # Load a component to cache it
      assembler.registry.get("cover_page")
      expect(assembler.cache_stats[:size]).to eq(1)

      assembler.clear_cache
      expect(assembler.cache_stats[:size]).to eq(0)
    end
  end

  describe "#cache_stats" do
    let(:assembler) { described_class.new(components_dir: components_dir) }

    it "returns cache statistics" do
      stats = assembler.cache_stats
      expect(stats).to have_key(:enabled)
      expect(stats).to have_key(:size)
      expect(stats).to have_key(:components)
    end
  end

  describe "TOC component handling" do
    let(:assembler) { described_class.new(components_dir: components_dir) }

    before do
      create_manifest(sections: [
                        { "component" => "__toc__",
                          "options" => { "max_level" => 3 } },
                      ])
    end

    it "generates TOC for __toc__ component" do
      doc = assembler.assemble(manifest_file)
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end
  end

  describe "wildcard component handling" do
    let(:assembler) { described_class.new(components_dir: components_dir) }

    before do
      FileUtils.mkdir_p(File.join(components_dir, "clauses"))
      create_component("clauses/clause_1")
      create_component("clauses/clause_2")

      create_manifest(sections: [
                        { "component" => "clauses/*",
                          "order" => "alphabetical" },
                      ])
    end

    it "resolves wildcard patterns" do
      doc = assembler.assemble(manifest_file)
      expect(doc.paragraphs.size).to be >= 2
    end

    it "includes wildcard components in preview" do
      preview = assembler.preview(manifest_file)
      expect(preview[:component_count]).to be >= 2
    end
  end

  describe "error handling" do
    let(:assembler) { described_class.new(components_dir: components_dir) }

    it "raises error for invalid manifest" do
      File.write(manifest_file, "invalid: yaml: content:")

      expect do
        assembler.assemble(manifest_file)
      end.to raise_error(ArgumentError)
    end
  end
end
