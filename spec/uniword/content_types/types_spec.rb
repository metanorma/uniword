# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::ContentTypes::Types do
  describe "#content_type_for" do
    let(:types) do
      described_class.new(
        defaults: [
          Uniword::ContentTypes::Default.new(extension: "xml",
                                             content_type: "application/xml"),
          Uniword::ContentTypes::Default.new(extension: "rels",
                                             content_type: "application/vnd.openxmlformats-package.relationships+xml"),
        ],
        overrides: [
          Uniword::ContentTypes::Override.new(
            part_name: "/word/document.xml",
            content_type: "application/vnd.openxmlformats-officedocument" \
                          ".wordprocessingml.document.main+xml",
          ),
        ],
      )
    end

    it "returns the Override content type when one matches" do
      expect(types.content_type_for("word/document.xml"))
        .to eq("application/vnd.openxmlformats-officedocument" \
               ".wordprocessingml.document.main+xml")
    end

    it "falls back to the Default content type when no Override matches" do
      expect(types.content_type_for("word/foo.xml"))
        .to eq("application/xml")
    end

    it "returns nil when neither Override nor Default matches" do
      expect(types.content_type_for("word/foo.bin")).to be_nil
    end

    it "returns nil for a path with no extension" do
      expect(types.content_type_for("README")).to be_nil
    end

    it "returns nil on an empty Types" do
      expect(described_class.new.content_type_for("word/document.xml"))
        .to be_nil
    end
  end
end
