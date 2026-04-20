# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Spellcheck::SpellChecker do
  let(:document) { Uniword::Wordprocessingml::DocumentRoot.new }

  describe "#check" do
    let(:fake_adapter) do
      instance_double(
        Uniword::Spellcheck::HunspellAdapter
      )
    end

    before do
      allow(fake_adapter).to receive(:check) do |word|
        # Simple fake: "correct" and common words are OK
        ["correct", "hello", "world", "the", "test", "document",
         "This", "is", "a", "has", "word", "some", "with"].include?(word)
      end
      allow(fake_adapter).to receive(:suggest) do |word|
        case word
        when "mispelled"
          ["misspelled", "misspelt"]
        when "wrold"
          ["world", "wold"]
        else
          []
        end
      end
    end

    it "returns a SpellcheckResult" do
      checker = described_class.new(
        spell_adapter: fake_adapter
      )
      result = checker.check(document)
      expect(result).to be_a(
        Uniword::Spellcheck::SpellcheckResult
      )
    end

    it "detects misspelled words in paragraphs" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(
        text: "This is a mispelled wrold test"
      )
      para.runs << run
      document.body.paragraphs << para

      checker = described_class.new(
        spell_adapter: fake_adapter
      )
      result = checker.check(document)

      words = result.misspellings.map { |m| m[:word] }
      expect(words).to include("mispelled")
      expect(words).to include("wrold")
    end

    it "detects grammar issues" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(
        text: "This is  a test with  double spaces"
      )
      para.runs << run
      document.body.paragraphs << para

      checker = described_class.new(
        spell_adapter: fake_adapter
      )
      result = checker.check(document)

      expect(result.grammar_issues).not_to be_empty
      messages = result.grammar_issues.map { |g| g[:message] }
      expect(messages).to include(match(/Double space/))
    end

    it "detects repeated words" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(
        text: "This is the the test"
      )
      para.runs << run
      document.body.paragraphs << para

      checker = described_class.new(
        spell_adapter: fake_adapter
      )
      result = checker.check(document)

      messages = result.grammar_issues.map { |g| g[:message] }
      expect(messages).to include(match(/Repeated word.*the/))
    end

    it "extracts text from tables" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(
        text: "mispelled in table"
      )
      para.runs << run

      cell = Uniword::Wordprocessingml::TableCell.new
      cell.paragraphs << para

      row = Uniword::Wordprocessingml::TableRow.new
      row.cells << cell

      table = Uniword::Wordprocessingml::Table.new
      table.rows << row
      document.body.tables << table

      checker = described_class.new(
        spell_adapter: fake_adapter
      )
      result = checker.check(document)

      words = result.misspellings.map { |m| m[:word] }
      expect(words).to include("mispelled")
    end

    it "returns clean result for correct text" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(
        text: "This is correct"
      )
      para.runs << run
      document.body.paragraphs << para

      checker = described_class.new(
        spell_adapter: fake_adapter
      )
      result = checker.check(document)

      expect(result.clean?).to be true
      expect(result.issue_count).to eq(0)
    end
  end
end
