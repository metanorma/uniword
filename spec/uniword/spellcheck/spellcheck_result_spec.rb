# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Uniword::Spellcheck::SpellcheckResult do
  let(:result) { described_class.new }

  describe "#clean?" do
    it "returns true when no issues" do
      expect(result.clean?).to be true
    end

    it "returns false with misspellings" do
      result.add_misspelling(
        word: "teh", position: 0, suggestions: ["the"]
      )
      expect(result.clean?).to be false
    end

    it "returns false with grammar issues" do
      result.add_grammar_issue(
        message: "Double space", position: 5
      )
      expect(result.clean?).to be false
    end
  end

  describe "#issue_count" do
    it "returns 0 when empty" do
      expect(result.issue_count).to eq(0)
    end

    it "counts misspellings and grammar issues" do
      result.add_misspelling(
        word: "teh", position: 0, suggestions: ["the"]
      )
      result.add_misspelling(
        word: "wrold", position: 10, suggestions: ["world"]
      )
      result.add_grammar_issue(
        message: "Double space", position: 5
      )
      expect(result.issue_count).to eq(3)
    end
  end

  describe "#misspellings" do
    it "stores misspelling details" do
      result.add_misspelling(
        word: "teh",
        position: 4,
        suggestions: ["the", "tea"]
      )
      expect(result.misspellings.size).to eq(1)
      m = result.misspellings.first
      expect(m[:word]).to eq("teh")
      expect(m[:position]).to eq(4)
      expect(m[:suggestions]).to eq(["the", "tea"])
    end
  end

  describe "#grammar_issues" do
    it "stores grammar issue details" do
      result.add_grammar_issue(
        message: "Double space detected",
        position: 8,
        context: "is  a"
      )
      expect(result.grammar_issues.size).to eq(1)
      g = result.grammar_issues.first
      expect(g[:message]).to eq("Double space detected")
      expect(g[:position]).to eq(8)
      expect(g[:context]).to eq("is  a")
    end
  end

  describe "#to_json" do
    it "produces valid JSON" do
      result.add_misspelling(
        word: "teh", position: 0, suggestions: ["the"]
      )
      parsed = JSON.parse(result.to_json)
      expect(parsed["misspellings"].size).to eq(1)
      expect(parsed["issue_count"]).to eq(1)
      expect(parsed["clean"]).to be false
    end
  end
end
