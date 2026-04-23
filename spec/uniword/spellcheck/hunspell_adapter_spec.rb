# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Spellcheck::HunspellAdapter do
  describe "#initialize" do
    it "raises DependencyError when hunspell is not found" do
      skip "hunspell is installed" if hunspell_available?

      expect { described_class.new }
        .to raise_error(Uniword::DependencyError)
    end
  end

  describe "with hunspell available", if: hunspell_available? do
    before do
      skip "en_US dictionary not installed" unless dict_available?
    end

    let(:adapter) { described_class.new(language: "en_US") }

    describe "#check" do
      it "returns true for correct words" do
        expect(adapter.check("hello")).to be true
      end

      it "returns false for misspelled words" do
        expect(adapter.check("qzxjkv")).to be false
      end

      it "returns true for empty input" do
        expect(adapter.check("")).to be true
      end
    end

    describe "#suggest" do
      it "returns suggestions for misspelled words" do
        suggestions = adapter.suggest("teh")
        expect(suggestions).to be_an(Array)
      end

      it "returns empty array for empty input" do
        expect(adapter.suggest("")).to eq([])
      end
    end

    def dict_available?
      _stdout, _stderr, status = Open3.capture3(
        "hunspell", "-d", "en_US", "-l",
        stdin_data: "qzxjkv\n"
      )
      status.success?
    end
  end
end
