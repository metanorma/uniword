# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::PartDefinition do
  subject(:definition) do
    described_class.new(
      key: :styles,
      kind: :override,
      path: "word/styles.xml",
      target: "styles.xml",
      content_type: "application/vnd.example+xml",
      rel_type: "http://schemas.example/relationships/styles",
      required: true,
      rels_scope: :document,
      standard: true,
    )
  end

  describe "#initialize" do
    it "exposes every field via readers" do
      expect(definition.key).to eq(:styles)
      expect(definition.kind).to eq(:override)
      expect(definition.path).to eq("word/styles.xml")
      expect(definition.target).to eq("styles.xml")
      expect(definition.content_type).to eq("application/vnd.example+xml")
      expect(definition.rel_type).to eq("http://schemas.example/relationships/styles")
      expect(definition.extension).to be_nil
      expect(definition.required).to be(true)
      expect(definition.rels_scope).to eq(:document)
      expect(definition.standard).to be(true)
    end

    it "defaults target to the package path" do
      defn = described_class.new(key: :core, kind: :override,
                                 path: "docProps/core.xml")

      expect(defn.target).to eq("docProps/core.xml")
    end

    it "defaults loader metadata to absent" do
      defn = described_class.new(key: :plain, kind: :none)

      expect([defn.loader, defn.loader_model, defn.path_resolution,
              defn.load_priority]).to all(be_nil)
    end

    it "defaults copy metadata to absent" do
      defn = described_class.new(key: :plain, kind: :none)

      expect([defn.document_attribute, defn.package_attribute,
              defn.to_package_guard, defn.to_package_type]).to all(be_nil)
    end

    it "copies to the document by default and is not loadable" do
      defn = described_class.new(key: :plain, kind: :none)

      expect([defn.copy_to_document?, defn.loadable?]).to eq([true, false])
    end
  end

  describe "loader and copy metadata" do
    subject(:loaded) do
      described_class.new(
        key: :styles, kind: :override, path: "word/styles.xml",
        loader: :xml_model,
        loader_model: Uniword::Wordprocessingml::StylesConfiguration,
        load_priority: 50, package_attribute: :styles,
        document_attribute: :styles_configuration,
        to_package_guard: :styles_loaded?,
        to_package_type: Uniword::Wordprocessingml::StylesConfiguration,
        copy_to_document: false
      )
    end

    it "exposes the loader strategy, model, and priority" do
      expect([loaded.loader, loaded.loader_model, loaded.load_priority])
        .to eq([:xml_model,
                Uniword::Wordprocessingml::StylesConfiguration, 50])
    end

    it "exposes the copy attributes, guard, and type" do
      expect([loaded.package_attribute, loaded.document_attribute,
              loaded.to_package_guard, loaded.copy_to_document?])
        .to eq([:styles, :styles_configuration, :styles_loaded?, false])
    end

    it "exposes the value type constraint" do
      expect(loaded.to_package_type)
        .to eq(Uniword::Wordprocessingml::StylesConfiguration)
    end

    it "is loadable" do
      expect(loaded).to be_loadable
    end
  end

  describe "#match_path?" do
    let(:numbered) do
      described_class.new(key: :header, kind: :override,
                          path_pattern: "word/header%<counter>d.xml")
    end

    let(:named) do
      described_class.new(key: :image, kind: :default,
                          path_pattern: "word/media/%<name>s")
    end

    it "matches a fixed path with or without a leading slash" do
      expect([definition.match_path?("word/styles.xml"),
              definition.match_path?("/word/styles.xml")]).to eq([true, true])
    end

    it "rejects other paths" do
      expect(definition.match_path?("word/settings.xml")).to be(false)
    end

    it "matches numbered paths against the pattern" do
      expect([numbered.match_path?("word/header12.xml"),
              numbered.match_path?("word/footer1.xml")]).to eq([true, false])
    end

    it "matches name placeholders against any path run" do
      expect([named.match_path?("word/media/image 1.png"),
              named.match_path?("word/embeddings/a.bin")]).to eq([true, false])
    end
  end

  describe "#pattern_prefix" do
    it "returns the static prefix up to the first placeholder" do
      media = described_class.new(
        key: :theme_media, kind: :none,
        path_pattern: "word/theme/media/%<name>s"
      )

      expect(media.pattern_prefix).to eq("word/theme/media/")
    end

    it "is nil for fixed-path definitions" do
      expect(definition.pattern_prefix).to be_nil
    end
  end

  describe "predicates" do
    it "identifies override definitions" do
      expect(definition.override?).to be(true)
      expect(definition.default?).to be(false)
    end

    it "identifies default definitions" do
      defn = described_class.new(key: :png, kind: :default,
                                 extension: "png",
                                 content_type: "image/png")

      expect(defn.default?).to be(true)
      expect(defn.override?).to be(false)
    end

    it "identifies required and standard flags" do
      expect(definition.required?).to be(true)
      expect(definition.standard?).to be(true)
    end

    it "identifies package-level relationship scope" do
      pkg = described_class.new(key: :doc, kind: :override,
                                path: "word/document.xml",
                                rels_scope: :package)

      expect(pkg.package_rel?).to be(true)
      expect(definition.package_rel?).to be(false)
    end
  end

  describe "#part_name" do
    it "returns the leading-slash Override form of the path" do
      expect(definition.part_name).to eq("/word/styles.xml")
    end

    it "is nil for pattern-only definitions" do
      defn = described_class.new(key: :header, kind: :override,
                                 path_pattern: "word/header%<counter>d.xml")

      expect(defn.part_name).to be_nil
    end
  end

  describe "path resolution for numbered parts" do
    subject(:numbered) do
      described_class.new(
        key: :header,
        kind: :override,
        path_pattern: "word/header%<counter>d.xml",
        target_pattern: "header%<counter>d.xml",
      )
    end

    it "interpolates path placeholders" do
      expect(numbered.path_for(counter: 2)).to eq("word/header2.xml")
    end

    it "interpolates part name placeholders with a leading slash" do
      expect(numbered.part_name_for(counter: 2)).to eq("/word/header2.xml")
    end

    it "interpolates target placeholders" do
      expect(numbered.target_for(counter: 2)).to eq("header2.xml")
    end

    it "returns fixed paths unchanged" do
      expect(definition.path_for).to eq("word/styles.xml")
      expect(definition.target_for).to eq("styles.xml")
    end
  end

  describe "#==" do
    it "is equal to a definition with identical fields" do
      other = described_class.new(
        key: :styles,
        kind: :override,
        path: "word/styles.xml",
        target: "styles.xml",
        content_type: "application/vnd.example+xml",
        rel_type: "http://schemas.example/relationships/styles",
        required: true,
        rels_scope: :document,
        standard: true,
      )

      expect(definition).to eq(other)
    end

    it "differs when any field differs" do
      other = described_class.new(key: :styles, kind: :override,
                                  path: "word/other.xml")

      expect(definition).not_to eq(other)
    end
  end
end
