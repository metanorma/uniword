# frozen_string_literal: true

require "spec_helper"
require "uniword/validation/schema_registry"

RSpec.describe Uniword::Validation::SchemaRegistry do
  let(:registry) { described_class.new }

  describe "#detect_namespaces" do
    it "detects WordprocessingML namespace" do
      xml = <<~XML
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body/>
        </w:document>
      XML

      ns_uris = registry.detect_namespaces(xml)
      expect(ns_uris).to include(
        "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
      )
    end

    it "detects multiple namespaces" do
      xml = <<~XML
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <w:body/>
        </w:document>
      XML

      ns_uris = registry.detect_namespaces(xml)
      expect(ns_uris.size).to be >= 2
    end

    it "returns empty array for invalid XML" do
      ns_uris = registry.detect_namespaces("not xml at all")
      expect(ns_uris).to eq([])
    end
  end

  describe "#primary_schema_for_part" do
    it "maps document.xml to wml-2010.xsd" do
      schema = registry.primary_schema_for_part("word/document.xml")
      expect(schema).to eq("microsoft/wml-2010.xsd")
    end

    it "maps styles.xml to wml-2010.xsd" do
      schema = registry.primary_schema_for_part("word/styles.xml")
      expect(schema).to eq("microsoft/wml-2010.xsd")
    end

    it "maps Content_Types.xml to opc schema" do
      schema = registry.primary_schema_for_part("[Content_Types].xml")
      expect(schema).to eq("ecma/opc-contentTypes.xsd")
    end

    it "maps _rels/.rels to relationships schema" do
      schema = registry.primary_schema_for_part("_rels/.rels")
      expect(schema).to eq("ecma/opc-relationships.xsd")
    end

    it "maps header parts to wml schema" do
      schema = registry.primary_schema_for_part("word/header1.xml")
      expect(schema).to eq("microsoft/wml-2010.xsd")
    end

    it "maps theme parts to dml schema" do
      schema = registry.primary_schema_for_part("word/theme/theme1.xml")
      expect(schema).to eq("iso/dml-main.xsd")
    end

    it "returns nil for unknown parts" do
      schema = registry.primary_schema_for_part("custom/unknown.bin")
      expect(schema).to be_nil
    end
  end

  describe "#known_namespace?" do
    it "knows WordprocessingML namespace" do
      expect(registry.known_namespace?(
               "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
             )).to be true
    end

    it "knows relationships namespace" do
      expect(registry.known_namespace?(
               "http://schemas.openxmlformats.org/package/2006/relationships",
             )).to be true
    end

    it "does not know arbitrary namespace" do
      expect(registry.known_namespace?("http://example.com/unknown")).to be false
    end
  end

  describe "#unknown_namespaces" do
    it "filters out known namespaces" do
      ns_uris = [
        "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
        "http://example.com/unknown",
      ]

      unknown = registry.unknown_namespaces(ns_uris)
      expect(unknown).to eq(["http://example.com/unknown"])
    end
  end

  describe "#load_schema" do
    it "loads and caches a schema" do
      schema = registry.load_schema("ecma/opc-contentTypes.xsd")
      expect(schema).to be_a(Nokogiri::XML::Schema)

      # Should be cached
      schema2 = registry.load_schema("ecma/opc-contentTypes.xsd")
      expect(schema2).to equal(schema)
    end

    it "raises for non-existent schema" do
      expect do
        registry.load_schema("nonexistent.xsd")
      end.to raise_error(ArgumentError)
    end
  end
end
