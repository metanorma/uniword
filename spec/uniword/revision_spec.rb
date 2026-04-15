# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Revision do
  describe "#initialize" do
    it "creates an insertion by default" do
      revision = described_class.new(
        author: "John Doe",
        text: "New text"
      )

      expect(revision.type).to eq(:insert)
      expect(revision.author).to eq("John Doe")
      expect(revision.text).to eq("New text")
    end

    it "creates a deletion" do
      revision = described_class.new(
        type: :delete,
        author: "Jane Smith",
        text: "Deleted text"
      )

      expect(revision.type).to eq(:delete)
      expect(revision.text).to eq("Deleted text")
    end

    it "creates a format change" do
      revision = described_class.new(
        type: :format_change,
        author: "Editor",
        content: "Changed to bold"
      )

      expect(revision.type).to eq(:format_change)
      expect(revision.content).to eq("Changed to bold")
    end

    it "auto-generates revision_id if not provided" do
      revision = described_class.new(author: "John")
      expect(revision.revision_id).not_to be_nil
      expect(revision.revision_id).not_to be_empty
    end

    it "uses provided revision_id" do
      revision = described_class.new(
        author: "John",
        revision_id: "rev_123"
      )
      expect(revision.revision_id).to eq("rev_123")
    end

    it "sets date to current time if not provided" do
      revision = described_class.new(author: "John")
      expect(revision.date).not_to be_nil
    end

    it "uses provided date" do
      date_str = "2024-01-15T10:30:00Z"
      revision = described_class.new(
        author: "John",
        date: date_str
      )
      expect(revision.date).to eq(date_str)
    end
  end

  describe "#insert?" do
    it "returns true for insertion" do
      revision = described_class.new(type: :insert, author: "John")
      expect(revision).to be_insert
    end

    it "returns false for non-insertion" do
      revision = described_class.new(type: :delete, author: "John")
      expect(revision).not_to be_insert
    end
  end

  describe "#delete?" do
    it "returns true for deletion" do
      revision = described_class.new(type: :delete, author: "John")
      expect(revision).to be_delete
    end

    it "returns false for non-deletion" do
      revision = described_class.new(type: :insert, author: "John")
      expect(revision).not_to be_delete
    end
  end

  describe "#format_change?" do
    it "returns true for format change" do
      revision = described_class.new(type: :format_change, author: "John")
      expect(revision).to be_format_change
    end

    it "returns false for non-format change" do
      revision = described_class.new(type: :insert, author: "John")
      expect(revision).not_to be_format_change
    end
  end

  describe "#xml_element_name" do
    it "returns correct name for insertion" do
      revision = described_class.new(type: :insert, author: "John")
      expect(revision.xml_element_name).to eq("ins")
    end

    it "returns correct name for deletion" do
      revision = described_class.new(type: :delete, author: "John")
      expect(revision.xml_element_name).to eq("del")
    end

    it "returns correct name for format change" do
      revision = described_class.new(type: :format_change, author: "John")
      expect(revision.xml_element_name).to eq("rPrChange")
    end
  end

  describe "#text" do
    it "returns text content" do
      revision = described_class.new(
        author: "John",
        text: "Content"
      )
      expect(revision.text).to eq("Content")
    end

    it "returns empty string for nil content" do
      revision = described_class.new(author: "John")
      expect(revision.text).to eq("")
    end
  end

  describe "#valid?" do
    it "returns true for valid insertion" do
      revision = described_class.new(
        type: :insert,
        author: "John Doe",
        revision_id: "1"
      )
      expect(revision).to be_valid
    end

    it "returns false without author" do
      revision = described_class.new(
        revision_id: "1"
      )
      expect(revision).not_to be_valid
    end

    it "returns false with empty author" do
      revision = described_class.new(
        author: "",
        revision_id: "1"
      )
      expect(revision).not_to be_valid
    end
  end

  describe "#accept" do
    it "calls visitor visit_revision method" do
      revision = described_class.new(author: "John")
      visited = nil
      visitor = Class.new do
        def initialize(callback)
          @callback = callback
        end

        def visit_revision(rev)
          @callback.call(rev)
        end
      end.new(->(r) { visited = r })

      revision.accept(visitor)
      expect(visited).to eq(revision)
    end
  end
end
