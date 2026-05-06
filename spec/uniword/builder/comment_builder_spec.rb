# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::CommentBuilder do
  describe "#initialize" do
    it "creates a Comment with author" do
      cb = described_class.new(author: "Editor")
      expect(cb.model).to be_a(Uniword::Comment)
      expect(cb.model.author).to eq("Editor")
    end
  end

  describe "#<<" do
    it "appends a string as a paragraph" do
      cb = described_class.new(author: "Editor")
      cb << "Review needed"
      expect(cb.model.paragraphs.size).to eq(1)
      expect(cb.model.paragraphs.first.runs.first.text.to_s).to eq("Review needed")
    end

    it "appends a Paragraph directly" do
      cb = described_class.new(author: "Editor")
      para = Uniword::Wordprocessingml::Paragraph.new
      cb << para
      expect(cb.model.paragraphs).to include(para)
    end

    it "raises for unsupported types" do
      cb = described_class.new(author: "Editor")
      expect { cb << 42 }.to raise_error(ArgumentError)
    end
  end

  describe "#build" do
    it "returns the underlying Comment model" do
      cb = described_class.new(author: "Editor")
      expect(cb.build).to eq(cb.model)
    end
  end

  describe ".from_model" do
    it "wraps an existing Comment model" do
      comment = Uniword::Comment.new(author: "A")
      cb = described_class.from_model(comment)
      expect(cb.model).to eq(comment)
    end
  end
end
