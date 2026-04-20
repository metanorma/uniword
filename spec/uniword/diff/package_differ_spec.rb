# frozen_string_literal: true

require "spec_helper"
require "uniword/diff/package_differ"

RSpec.describe Uniword::Diff::PackageDiffer do
  let(:bad_path) { "spec/fixtures/hello-world-bad.docx" }
  let(:repaired_path) { "spec/fixtures/hello-world-repaired.docx" }

  describe "#diff" do
    subject(:result) do
      described_class.new(bad_path, repaired_path).diff
    end

    it "returns a PackageDiffResult" do
      expect(result).to be_a(Uniword::Diff::PackageDiffResult)
    end

    it "is not empty" do
      expect(result.empty?).to be false
    end

    it "stores the file paths" do
      expect(result.old_path).to eq(bad_path)
      expect(result.new_path).to eq(repaired_path)
    end

    describe "added parts" do
      it "detects word/theme/theme1.xml was added" do
        expect(result.added_parts).to include("word/theme/theme1.xml")
      end
    end

    describe "removed parts" do
      it "finds no removed parts" do
        expect(result.removed_parts).to be_empty
      end
    end

    describe "modified parts" do
      it "detects word/document.xml as modified" do
        names = result.modified_parts.map(&:name)
        expect(names).to include("word/document.xml")
      end

      it "detects word/styles.xml as modified" do
        names = result.modified_parts.map(&:name)
        expect(names).to include("word/styles.xml")
      end

      it "detects word/settings.xml as modified" do
        names = result.modified_parts.map(&:name)
        expect(names).to include("word/settings.xml")
      end

      it "tracks size changes" do
        doc_change = result.modified_parts.find { |p| p.name == "word/document.xml" }
        expect(doc_change.old_size).to be < doc_change.new_size
      end
    end

    describe "unchanged parts" do
      it "tracks the count of unchanged parts" do
        expect(result.unchanged_parts.size).to be >= 0
      end
    end

    describe "XML changes" do
      it "detects namespace additions in document.xml" do
        ns_changes = result.xml_changes.select do |c|
          c.part == "word/document.xml" && c.category == :namespace
        end
        expect(ns_changes).not_to be_empty
      end

      it "detects attribute changes in document.xml" do
        attr_changes = result.xml_changes.select do |c|
          c.part == "word/document.xml" && c.category == :attribute
        end
        expect(attr_changes).not_to be_empty
      end
    end

    describe "summary" do
      it "includes added parts count" do
        expect(result.summary).to include("part(s) added")
      end

      it "includes modified parts count" do
        expect(result.summary).to include("part(s) modified")
      end
    end

    describe "serialization" do
      it "serializes to JSON" do
        json = result.to_json
        parsed = JSON.parse(json)
        expect(parsed["added_parts"]).to include("word/theme/theme1.xml")
        expect(parsed["modified_parts"]).to be_an(Array)
      end

      it "serializes to Hash" do
        h = result.to_h
        expect(h[:old_path]).to eq(bad_path)
        expect(h[:added_parts]).to include("word/theme/theme1.xml")
      end
    end
  end

  describe "comparing identical files" do
    it "returns an empty result" do
      result = described_class.new(bad_path, bad_path).diff
      expect(result.empty?).to be true
      expect(result.total_changes).to eq(0)
      expect(result.summary).to eq("No differences found.")
    end
  end
end
