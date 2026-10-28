# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::FindReplace::Engine do
  let(:builder) do
    b = Uniword::Builder::DocumentBuilder.new
    b.paragraph("Hello foo world")
    b.paragraph("Another foo here")
    b
  end

  let(:doc) { builder.model }

  let(:matcher) do
    Uniword::FindReplace::StringMatcher.new(pattern: "foo",
                                            replacement: "bar")
  end

  describe "default scope (:all)" do
    it "replaces matches in the body" do
      result = described_class.new(document: doc, matcher: matcher).run
      expect(result.count).to eq(2)
      expect(result.by_scope[:body]).to eq(2)
    end

    it "mutates the document" do
      described_class.new(document: doc, matcher: matcher).run
      paragraphs = doc.body.paragraphs.map(&:text)
      expect(paragraphs).to eq(["Hello bar world", "Another bar here"])
    end
  end

  describe "explicit scope" do
    it "honors :body scope" do
      result = described_class.new(document: doc, matcher: matcher,
                                   scopes: :body).run
      expect(result.by_scope.keys).to eq([:body])
    end

    it "skips body when scope excludes it" do
      result = described_class.new(document: doc, matcher: matcher,
                                   scopes: :headers).run
      expect(result.count).to eq(0)
    end
  end

  describe "with no matches" do
    it "returns an empty result" do
      matcher = Uniword::FindReplace::StringMatcher.new(pattern: "zzz",
                                                        replacement: "x")
      result = described_class.new(document: doc, matcher: matcher).run
      expect(result.empty?).to be(true)
    end
  end

  describe "regex matcher with capture" do
    it "expands capture references" do
      matcher = Uniword::FindReplace::RegexMatcher.new(pattern: /Chapter (\d+)/,
                                                       replacement: 'Ch. \1')
      b = Uniword::Builder::DocumentBuilder.new
      b.paragraph("Chapter 1 and Chapter 22")
      described_class.new(document: b.model, matcher: matcher).run
      expect(b.model.body.paragraphs.first.text).to eq("Ch. 1 and Ch. 22")
    end
  end
end
