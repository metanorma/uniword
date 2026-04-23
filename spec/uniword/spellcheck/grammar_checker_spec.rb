# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Spellcheck::GrammarChecker do
  let(:checker) { described_class.new }

  describe "#check" do
    it "returns empty array for empty text" do
      expect(checker.check("")).to eq([])
    end

    it "returns empty array for nil text" do
      expect(checker.check(nil)).to eq([])
    end

    it "returns empty array for clean text" do
      issues = checker.check(
        "This is a sentence. This is another.",
      )
      expect(issues).to be_empty
    end

    it "detects double spaces" do
      issues = checker.check("This is  a test")
      expect(issues.size).to be >= 1
      expect(issues.first[:message]).to match(/Double space/)
      expect(issues.first[:position]).to be_a(Integer)
      expect(issues.first[:context]).to be_a(String)
    end

    it "detects repeated words" do
      issues = checker.check("I went to the the store")
      expect(issues.size).to be >= 1
      expect(issues.first[:message]).to match(
        /Repeated word.*the/,
      )
    end

    it "detects repeated words case-insensitively" do
      issues = checker.check("The the dog ran")
      expect(issues.size).to be >= 1
      expect(issues.first[:message]).to match(
        /Repeated word.*the/i,
      )
    end

    it "detects missing capitalization after period" do
      issues = checker.check("First sentence. second one.")
      expect(issues.size).to be >= 1
      expect(issues.any? do |i|
        i[:message].include?("capitalization")
      end).to be true
    end

    it "reports position for each issue" do
      issues = checker.check("A  test  here")
      issues.each do |issue|
        expect(issue).to have_key(:position)
        expect(issue[:position]).to be >= 0
      end
    end

    it "reports context for each issue" do
      issues = checker.check("A  test  here")
      issues.each do |issue|
        expect(issue).to have_key(:context)
        expect(issue[:context]).to be_a(String)
      end
    end

    it "finds multiple issues in the same text" do
      issues = checker.check(
        "First  sentence. second  one the the end",
      )
      expect(issues.size).to be >= 3
    end
  end
end
