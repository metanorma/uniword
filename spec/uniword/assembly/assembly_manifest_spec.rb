# frozen_string_literal: true

require "spec_helper"
require "uniword/assembly/assembly_manifest"
require "tempfile"
require "yaml"

RSpec.describe Uniword::Assembly::AssemblyManifest do
  let(:valid_manifest_data) do
    {
      "document" => {
        "output" => "output.docx",
        "template" => "standard",
        "variables" => {
          "title" => "Test Document",
          "version" => "1.0",
        },
        "sections" => [
          { "component" => "cover" },
          { "component" => "content",
            "options" => { "style" => "ceremonial" } },
        ],
      },
    }
  end

  let(:manifest_file) do
    file = Tempfile.new(["manifest", ".yml"])
    file.write(YAML.dump(valid_manifest_data))
    file.close
    file
  end

  after do
    manifest_file&.unlink
  end

  describe "#initialize" do
    it "loads valid manifest file" do
      manifest = described_class.new(manifest_file.path)

      expect(manifest.output_path).to eq("output.docx")
      expect(manifest.template_name).to eq("standard")
      expect(manifest.variables["title"]).to eq("Test Document")
    end

    it "raises error for non-existent file" do
      expect do
        described_class.new("nonexistent.yml")
      end.to raise_error(ArgumentError, /not found/)
    end

    it "raises error for invalid YAML" do
      file = Tempfile.new(["invalid", ".yml"])
      file.write("invalid: yaml: content:")
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /Invalid YAML/)

      file.unlink
    end

    it "raises error for non-hash manifest" do
      file = Tempfile.new(["manifest", ".yml"])
      file.write("- item1\n- item2")
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /must be a Hash/)

      file.unlink
    end

    it "raises error for missing document key" do
      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump({ "invalid" => "data" }))
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /must have 'document' key/)

      file.unlink
    end

    it "raises error for missing output" do
      data = valid_manifest_data.dup
      data["document"].delete("output")

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /must specify 'output'/)

      file.unlink
    end

    it "raises error for missing sections" do
      data = valid_manifest_data.dup
      data["document"].delete("sections")

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /must have 'sections' array/)

      file.unlink
    end

    it "applies variable overrides" do
      manifest = described_class.new(
        manifest_file.path,
        override_variables: { "version" => "2.0", "new_var" => "value" },
      )

      expect(manifest.variables["version"]).to eq("2.0")
      expect(manifest.variables["new_var"]).to eq("value")
      expect(manifest.variables["title"]).to eq("Test Document")
    end
  end

  describe "#template?" do
    it "returns true when template is specified" do
      manifest = described_class.new(manifest_file.path)
      expect(manifest.template?).to be true
    end

    it "returns false when template is not specified" do
      data = valid_manifest_data.dup
      data["document"].delete("template")

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      manifest = described_class.new(file.path)
      expect(manifest.template?).to be false

      file.unlink
    end
  end

  describe "#section_list" do
    it "returns array of section configurations" do
      manifest = described_class.new(manifest_file.path)
      sections = manifest.section_list

      expect(sections).to be_an(Array)
      expect(sections.size).to eq(2)
      expect(sections[0]["component"]).to eq("cover")
      expect(sections[1]["component"]).to eq("content")
    end

    it "includes section options" do
      manifest = described_class.new(manifest_file.path)
      sections = manifest.section_list

      expect(sections[1]["options"]).to eq({ "style" => "ceremonial" })
    end

    it "returns copy of sections array" do
      manifest = described_class.new(manifest_file.path)
      sections1 = manifest.section_list
      sections2 = manifest.section_list

      expect(sections1).not_to be(sections2)
    end
  end

  describe "#variable" do
    it "returns variable value by string key" do
      manifest = described_class.new(manifest_file.path)
      expect(manifest.variable("title")).to eq("Test Document")
    end

    it "returns variable value by symbol key" do
      manifest = described_class.new(manifest_file.path)
      expect(manifest.variable(:title)).to eq("Test Document")
    end

    it "returns nil for non-existent variable" do
      manifest = described_class.new(manifest_file.path)
      expect(manifest.variable("nonexistent")).to be_nil
    end
  end

  describe "#variable?" do
    it "returns true for existing variable" do
      manifest = described_class.new(manifest_file.path)
      expect(manifest.variable?("title")).to be true
    end

    it "returns false for non-existent variable" do
      manifest = described_class.new(manifest_file.path)
      expect(manifest.variable?("nonexistent")).to be false
    end

    it "works with symbol keys" do
      manifest = described_class.new(manifest_file.path)
      expect(manifest.variable?(:title)).to be true
    end
  end

  describe "section validation" do
    it "raises error for non-hash section" do
      data = valid_manifest_data.dup
      data["document"]["sections"] = ["invalid"]

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /Section at index 0 must be a Hash/)

      file.unlink
    end

    it "raises error for section without component" do
      data = valid_manifest_data.dup
      data["document"]["sections"] = [{ "options" => {} }]

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /must have 'component' key/)

      file.unlink
    end

    it "handles sections with order specification" do
      data = valid_manifest_data.dup
      data["document"]["sections"] = [
        { "component" => "clauses/*", "order" => "alphabetical" },
      ]

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      manifest = described_class.new(file.path)
      sections = manifest.section_list

      expect(sections[0]["order"]).to eq("alphabetical")

      file.unlink
    end
  end

  describe "variable handling" do
    it "handles nil variables" do
      data = valid_manifest_data.dup
      data["document"].delete("variables")

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      manifest = described_class.new(file.path)
      expect(manifest.variables).to eq({})

      file.unlink
    end

    it "raises error for non-hash variables" do
      data = valid_manifest_data.dup
      data["document"]["variables"] = "invalid"

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      expect do
        described_class.new(file.path)
      end.to raise_error(ArgumentError, /Variables must be a Hash/)

      file.unlink
    end

    it "converts variable keys to strings" do
      data = valid_manifest_data.dup
      data["document"]["variables"] = { title: "Test", version: "1.0" }

      file = Tempfile.new(["manifest", ".yml"])
      file.write(YAML.dump(data))
      file.close

      manifest = described_class.new(file.path)
      expect(manifest.variables.keys).to all(be_a(String))

      file.unlink
    end
  end
end
