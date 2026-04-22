# frozen_string_literal: true

require "spec_helper"
require "uniword/headers_footers"

RSpec.describe Uniword::HeadersFooters::Manager do
  let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }
  let(:manager) { described_class.new(doc) }

  describe "#list_headers" do
    it "returns empty array when no headers" do
      expect(manager.list_headers).to eq([])
    end

    it "lists existing headers" do
      header = Uniword::Header.new(type: "default")
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Header text")
      para.runs << run
      header.paragraphs << para
      doc.headers = [header]

      result = manager.list_headers
      expect(result.size).to eq(1)
      expect(result[0][:type]).to eq("default")
      expect(result[0][:text]).to include("Header text")
    end
  end

  describe "#list_footers" do
    it "returns empty array when no footers" do
      expect(manager.list_footers).to eq([])
    end
  end

  describe "#add_header" do
    it "adds a header with text" do
      header = manager.add_header("Confidential", type: "default")
      expect(header).to be_a(Uniword::Header)
      expect(header.type).to eq("default")
      expect(manager.list_headers.size).to eq(1)
    end

    it "raises for invalid type" do
      expect do
        manager.add_header("Text", type: "invalid")
      end.to raise_error(ArgumentError, /Invalid type/)
    end
  end

  describe "#add_footer" do
    it "adds a footer with text" do
      footer = manager.add_footer("Page 1", type: "default")
      expect(footer).to be_a(Uniword::Footer)
      expect(footer.type).to eq("default")
      expect(manager.list_footers.size).to eq(1)
    end
  end

  describe "#remove_headers" do
    it "removes headers by type" do
      manager.add_header("Default", type: "default")
      manager.add_header("First", type: "first")

      count = manager.remove_headers(type: "default")
      expect(count).to eq(1)
      expect(manager.list_headers.size).to eq(1)
    end

    it "returns 0 when no matching headers" do
      count = manager.remove_headers(type: "default")
      expect(count).to eq(0)
    end
  end

  describe "#remove_footers" do
    it "removes footers by type" do
      manager.add_footer("Footer text", type: "default")

      count = manager.remove_footers(type: "default")
      expect(count).to eq(1)
      expect(manager.list_footers.size).to eq(0)
    end
  end

  describe "#clear_all" do
    it "removes all headers and footers" do
      manager.add_header("Header", type: "default")
      manager.add_footer("Footer", type: "default")

      manager.clear_all
      expect(manager.list_headers).to eq([])
      expect(manager.list_footers).to eq([])
    end
  end
end
