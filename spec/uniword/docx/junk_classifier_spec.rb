# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::JunkClassifier do
  let(:types) do
    Uniword::ContentTypes::Types.new(
      defaults: [
        Uniword::ContentTypes::Default.new(extension: "xml",
                                           content_type: "application/xml"),
        Uniword::ContentTypes::Default.new(extension: "rels",
                                           content_type: "application/vnd.openxmlformats-package.relationships+xml"),
      ],
      overrides: [
        Uniword::ContentTypes::Override.new(
          part_name: "/docProps/meta.xml",
          content_type: "application/xml",
        ),
      ],
    )
  end

  let(:rels_by_path) { { "word/target.bin" => [] } }

  let(:classifier) do
    described_class.new(content_types: types,
                        relationships_by_path: rels_by_path)
  end

  describe "legitimate parts (not junk)" do
    it "returns nil for a path with a matching Override" do
      expect(classifier.reason("docProps/meta.xml")).to be_nil
    end

    it "returns nil for a path whose extension has a Default" do
      expect(classifier.reason("word/document.xml")).to be_nil
    end

    it "returns nil for a path targeted by a relationship even with no content type" do
      expect(classifier.reason("word/target.bin")).to be_nil
    end
  end

  describe "undeclared parts (no content type, no relationship)" do
    it "returns the undeclared reason for an unknown extension" do
      expect(classifier.reason("[trash]/0000.dat"))
        .to eq("No content type declaration and no referencing relationship")
    end

    it "returns the undeclared reason for a path with no extension" do
      expect(classifier.reason("license"))
        .to eq("No content type declaration and no referencing relationship")
    end
  end

  describe "OS/tooling artifacts (always junk)" do
    it "classifies __MACOSX/ entries as junk even with a matching Default" do
      classifier = described_class.new(
        content_types: macos_xml_types,
        relationships_by_path: {},
      )

      expect(classifier.reason("__MACOSX/._foo.xml"))
        .to eq("OS or tooling artifact")
    end

    it "classifies .DS_Store as junk" do
      expect(classifier.reason(".DS_Store")).to eq("OS or tooling artifact")
    end

    it "classifies Thumbs.db as junk" do
      expect(classifier.reason("Thumbs.db")).to eq("OS or tooling artifact")
    end

    it "classifies ._ AppleDouble entries as junk" do
      expect(classifier.reason("._resource"))
        .to eq("OS or tooling artifact")
    end

    it "classifies Office lock files (~$ prefix) as junk" do
      expect(classifier.reason("~$document.docx"))
        .to eq("OS or tooling artifact")
    end
  end

  describe "#junk?" do
    it "returns true when reason is non-nil" do
      expect(classifier.junk?("[trash]/0000.dat")).to be(true)
    end

    it "returns false when reason is nil" do
      expect(classifier.junk?("docProps/meta.xml")).to be(false)
    end
  end

  describe "with nil inputs" do
    it "treats nil content types as 'every path is undeclared'" do
      classifier = described_class.new(content_types: nil,
                                       relationships_by_path: {})

      expect(classifier.reason("anything.dat"))
        .to eq("No content type declaration and no referencing relationship")
    end

    it "treats nil relationships_by_path as 'no relationships'" do
      classifier = described_class.new(content_types: types,
                                       relationships_by_path: nil)

      expect(classifier.reason("[trash]/0000.dat"))
        .to eq("No content type declaration and no referencing relationship")
    end
  end

  def macos_xml_types
    # __MACOSX/._foo.xml has extension .xml; Default exists. The OS
    # pattern still wins because it is checked first.
    Uniword::ContentTypes::Types.new(
      defaults: [
        Uniword::ContentTypes::Default.new(extension: "xml",
                                           content_type: "application/xml"),
      ],
    )
  end
end
