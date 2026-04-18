# frozen_string_literal: true

require "zip"

# Shared examples for Uniword tests
#
# Usage:
#   it_behaves_like "a round-trippable serializable", described_class,
#     { value: "hello" }, :value, "hello"
#
#   it_behaves_like "a round-trippable DOCX file",
#     original_path, roundtrip_path, "word/document.xml"
#
#   it_behaves_like "a valid DOCX package", path

# Verifies a lutaml-model class can serialize to XML and deserialize back
# with an attribute preserved.
#
# @param klass [Class] The serializable class
# @param init_attrs [Hash] Attributes for .new
# @param attr_name [Symbol, Array<Symbol>] Attribute(s) to verify
# @param expected_value [Object, Array<Object>] Expected value(s)
RSpec.shared_examples "a round-trippable serializable" do |klass, init_attrs, attr_name, expected_value|
  attrs = Array(attr_name)
  expected = Array(expected_value)

  it "round-trips through XML serialization" do
    obj = klass.new(**init_attrs)
    xml = obj.to_xml
    restored = klass.from_xml(xml)

    attrs.each_with_index do |name, i|
      actual = restored.send(name)
      expect(actual).to eq(expected[i]),
                        "Expected #{name} to be #{expected[i].inspect}, got #{actual.inspect}"
    end
  end
end

# Verifies a specific XML file within a DOCX preserves through round-trip.
#
# @param original_path [String] Path to original .docx
# @param roundtrip_path [String] Path to round-tripped .docx
# @param xml_file [String] Path within ZIP (e.g., "word/document.xml")
RSpec.shared_examples "a round-trippable DOCX file" do |original_path, roundtrip_path, xml_file|
  describe xml_file do
    it "preserves content through round-trip" do
      original = ZipHelper.extract_file(original_path, xml_file)
      roundtrip = ZipHelper.extract_file(roundtrip_path, xml_file)

      normalized_orig = XmlNormalizers.normalize_for_roundtrip(original)
      normalized_rt = XmlNormalizers.normalize_for_roundtrip(roundtrip)

      expect(normalized_rt).to be_xml_equivalent_to(normalized_orig)
    end
  end
end

# Verifies a file is a valid DOCX package with expected structure.
#
# @param path [String] Path to .docx file
# @param required_files [Array<String>] Required files in the ZIP (optional)
RSpec.shared_examples "a valid DOCX package" do |path, required_files = nil|
  it "is a valid ZIP file" do
    expect(Zip::File.open(path) { |z| z.entries.count }).to be > 0
  end

  it "contains [Content_Types].xml" do
    content = ZipHelper.extract_file(path, "[Content_Types].xml")
    expect(content).to include("Types")
  end

  it "contains _rels/.rels" do
    content = ZipHelper.extract_file(path, "_rels/.rels")
    expect(content).to include("Relationships")
  end

  it "contains word/document.xml" do
    content = ZipHelper.extract_file(path, "word/document.xml")
    expect(content).to include("document")
  end

  if required_files
    required_files.each do |file|
      it "contains #{file}" do
        content = ZipHelper.extract_file(path, file)
        expect(content).not_to be_nil
      end
    end
  end
end

# Verifies a model class has proper lutaml-model serialization support.
#
# @param klass [Class] The model class
# @param method_name [Symbol] The serialization method (:to_xml, :to_json, etc.)
RSpec.shared_examples "a serializable element" do
  it "responds to valid?" do
    expect(subject).to respond_to(:valid?)
  end

  it "responds to to_xml" do
    expect(subject).to respond_to(:to_xml)
  end
end

# Verifies namespace correctness for OOXML model classes.
#
# @param klass [Class] The model class
# @param expected_root [String] Expected XML root element name
# @param expected_ns_uri [String, nil] Expected namespace URI (optional)
RSpec.shared_examples "a namespaced OOXML element" do |klass, expected_root, expected_ns_uri = nil|
  it "has correct root element name" do
    xml = klass.new.to_xml
    doc = Nokogiri::XML(xml)
    expect(doc.root&.name).to eq(expected_root)
  end

  it "produces parseable XML" do
    xml = klass.new.to_xml
    doc = Nokogiri::XML(xml)
    expect(doc.errors).to be_empty
  end

  if expected_ns_uri
    it "uses correct namespace" do
      xml = klass.new.to_xml
      doc = Nokogiri::XML(xml)
      expect(doc.root&.namespace&.href).to eq(expected_ns_uri)
    end
  end
end

# Helpers for test file operations
module ZipHelper
  # Extract a file from a ZIP archive
  #
  # @param zip_path [String] Path to ZIP file
  # @param file_path [String] Path within ZIP
  # @return [String, nil] File content or nil if not found
  def self.extract_file(zip_path, file_path)
    Zip::File.open(zip_path) do |zip|
      entry = zip.find_entry(file_path)
      entry&.get_input_stream&.read
    end
  end
end
