# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::RunUtils do
  let(:run_class) { Uniword::Wordprocessingml::Run }
  let(:text_class) { Uniword::Wordprocessingml::Text }

  describe ".empty_run?" do
    it "returns true for a run with no content" do
      run = run_class.new
      expect(described_class.empty_run?(run)).to be true
    end

    it "returns false for a run with text" do
      run = run_class.new(text: "Hello")
      expect(described_class.empty_run?(run)).to be false
    end

    it "returns false for a run with a break" do
      run = run_class.new
      run.break = Uniword::Wordprocessingml::Break.new
      expect(described_class.empty_run?(run)).to be false
    end

    it "returns false for a run with a tab" do
      run = run_class.new
      run.tab = Uniword::Wordprocessingml::Tab.new
      expect(described_class.empty_run?(run)).to be false
    end

    it "returns false for a run with a field_char" do
      run = run_class.new
      run.field_char = Uniword::Wordprocessingml::FieldChar.new
      expect(described_class.empty_run?(run)).to be false
    end

    it "returns false for a run with instr_text" do
      run = run_class.new
      run.instr_text = Uniword::Wordprocessingml::InstrText.new
      expect(described_class.empty_run?(run)).to be false
    end

    it "returns false for a run with a footnote_reference" do
      run = run_class.new
      run.footnote_reference = Uniword::Wordprocessingml::FootnoteReference.new(id: "1")
      expect(described_class.empty_run?(run)).to be false
    end

    it "returns false for a run with position_tab" do
      run = run_class.new
      run.position_tab = Uniword::Wordprocessingml::PositionTab.new
      expect(described_class.empty_run?(run)).to be false
    end
  end

  describe ".text_only_run?" do
    it "returns true for a run with only text" do
      run = run_class.new(text: "Hello")
      expect(described_class.text_only_run?(run)).to be true
    end

    it "returns false for a run with a break" do
      run = run_class.new(text: "Hello")
      run.break = Uniword::Wordprocessingml::Break.new
      expect(described_class.text_only_run?(run)).to be false
    end

    it "returns false for a run with a tab" do
      run = run_class.new(text: "Hello")
      run.tab = Uniword::Wordprocessingml::Tab.new
      expect(described_class.text_only_run?(run)).to be false
    end

    it "returns false for a run with field_char" do
      run = run_class.new
      run.field_char = Uniword::Wordprocessingml::FieldChar.new
      expect(described_class.text_only_run?(run)).to be false
    end

    it "returns false for a run with instr_text" do
      run = run_class.new
      run.instr_text = Uniword::Wordprocessingml::InstrText.new
      expect(described_class.text_only_run?(run)).to be false
    end

    it "returns true for an empty run with no structural elements" do
      run = run_class.new
      expect(described_class.text_only_run?(run)).to be true
    end
  end

  describe ".properties_match?" do
    it "returns true when both runs have no properties" do
      a = run_class.new
      b = run_class.new
      expect(described_class.properties_match?(a, b)).to be true
    end

    it "returns false when one has properties and the other doesn't" do
      a = run_class.new
      b = run_class.new
      b.properties = Uniword::Wordprocessingml::RunProperties.new(
        bold: Uniword::Properties::Bold.new(val: true)
      )
      expect(described_class.properties_match?(a, b)).to be false
    end

    it "returns true when both have identical properties" do
      props = Uniword::Wordprocessingml::RunProperties.new(
        bold: Uniword::Properties::Bold.new(val: true)
      )
      a = run_class.new
      a.properties = props
      b = run_class.new
      b.properties = Uniword::Wordprocessingml::RunProperties.new(
        bold: Uniword::Properties::Bold.new(val: true)
      )
      expect(described_class.properties_match?(a, b)).to be true
    end
  end

  describe ".mergeable?" do
    it "returns true for text-only runs with matching properties" do
      a = run_class.new(text: "Hello ")
      b = run_class.new(text: "World")
      expect(described_class.mergeable?(a, b)).to be true
    end

    it "returns false for a non-text-only run" do
      a = run_class.new(text: "Hello ")
      a.break = Uniword::Wordprocessingml::Break.new
      b = run_class.new(text: "World")
      expect(described_class.mergeable?(a, b)).to be false
    end

    it "returns false when incoming run has no text" do
      a = run_class.new(text: "Hello")
      b = run_class.new
      expect(described_class.mergeable?(a, b)).to be false
    end

    it "returns false when properties differ" do
      a = run_class.new(text: "Hello")
      b = run_class.new(text: "World")
      b.properties = Uniword::Wordprocessingml::RunProperties.new(
        bold: Uniword::Properties::Bold.new(val: true)
      )
      expect(described_class.mergeable?(a, b)).to be false
    end
  end

  describe ".merge_text" do
    it "combines text from source into target" do
      target = run_class.new(text: "Hello ")
      source = run_class.new(text: "World")

      described_class.merge_text(target, source)

      expect(target.text.to_s).to eq("Hello World")
    end

    it "sets xml_space to preserve when combined text has leading whitespace" do
      target = run_class.new(text: " Hello")
      source = run_class.new(text: " World")

      described_class.merge_text(target, source)

      expect(target.text.xml_space).to eq("preserve")
    end

    it "does not modify target when source has no text" do
      target = run_class.new(text: "Hello")
      source = run_class.new

      described_class.merge_text(target, source)

      expect(target.text.to_s).to eq("Hello")
    end
  end
end
