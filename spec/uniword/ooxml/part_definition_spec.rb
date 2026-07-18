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
