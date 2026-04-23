# frozen_string_literal: true

require "spec_helper"
require "uniword/diff"

RSpec.describe Uniword::Diff::Formatter do
  let(:formatter) { described_class.new }

  describe "#terminal" do
    it "shows no differences for empty result" do
      result = Uniword::Diff::DiffResult.new
      output = formatter.terminal(result)
      expect(output).to include("No differences found")
    end

    it "shows summary for non-empty result" do
      result = Uniword::Diff::DiffResult.new(
        text_changes: [{ type: :text, change: :added, new: "hello",
                         old: nil, position: 0 }],
      )
      output = formatter.terminal(result)
      expect(output).to include("1 text change")
    end

    it "shows detailed changes when verbose" do
      result = Uniword::Diff::DiffResult.new(
        text_changes: [{ type: :text, change: :added, new: "hello",
                         old: nil, position: 0 }],
        structure_changes: [{ type: :structure, change: :paragraph_count,
                              old_count: 1, new_count: 2 }],
      )
      output = formatter.terminal(result, verbose: true)
      expect(output).to include("hello")
      expect(output).to include("paragraph_count")
    end
  end

  describe "#json" do
    it "produces valid JSON" do
      require "json"
      result = Uniword::Diff::DiffResult.new(
        text_changes: [{ change: :added }],
      )
      parsed = JSON.parse(formatter.json(result))
      expect(parsed["text_changes"].length).to eq(1)
    end
  end
end
