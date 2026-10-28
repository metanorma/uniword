# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::FindReplace::StringMatcher do
  describe "#apply" do
    it "replaces every non-overlapping literal occurrence" do
      matcher = described_class.new(pattern: "foo", replacement: "bar")
      new_text, count = matcher.apply("a foo and another foo")
      expect(new_text).to eq("a bar and another bar")
      expect(count).to eq(2)
    end

    it "returns zero count when nothing matches" do
      matcher = described_class.new(pattern: "foo", replacement: "bar")
      _new_text, count = matcher.apply("nothing here")
      expect(count).to eq(0)
    end

    it "supports case-insensitive match" do
      matcher = described_class.new(pattern: "Foo",
                                    replacement: "bar",
                                    ignore_case: true)
      new_text, count = matcher.apply("FOO Foo fOo")
      expect(new_text).to eq("bar bar bar")
      expect(count).to eq(3)
    end

    it "raises ArgumentError for empty pattern" do
      expect do
        described_class.new(pattern: "", replacement: "x")
      end.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe Uniword::FindReplace::RegexMatcher do
  describe "#apply" do
    it "replaces every regex match" do
      matcher = described_class.new(pattern: /\d+/,
                                    replacement: "N")
      new_text, count = matcher.apply("Chapter 1, Section 22, Page 333")
      expect(new_text).to eq("Chapter N, Section N, Page N")
      expect(count).to eq(3)
    end

    it "supports capture-group references" do
      matcher = described_class.new(pattern: /Chapter (\d+)/,
                                    replacement: "Ch. \\1")
      new_text, _count = matcher.apply("Chapter 1 starts here")
      expect(new_text).to eq("Ch. 1 starts here")
    end

    it "accepts string pattern with ignore_case" do
      matcher = described_class.new(pattern: "foo",
                                    replacement: "bar",
                                    ignore_case: true)
      new_text, count = matcher.apply("FOO foo")
      expect(new_text).to eq("bar bar")
      expect(count).to eq(2)
    end

    it "returns zero count for no matches" do
      matcher = described_class.new(pattern: /zzz/, replacement: "x")
      _new_text, count = matcher.apply("hello world")
      expect(count).to eq(0)
    end
  end
end
