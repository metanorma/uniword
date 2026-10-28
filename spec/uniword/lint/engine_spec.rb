# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Lint::Engine do
  let(:doc) do
    b = Uniword::Builder::DocumentBuilder.new
    b.paragraph("Hello world")
    b.paragraph("This is really very long text that goes on and on " \
                "and uses banned words like basically and literally")
    b.model
  end

  it "runs each rule and aggregates findings" do
    ruleset = Uniword::Lint::Ruleset.new([
                                           Uniword::Lint::BuiltinRules::BannedWords.new(
                                             name: :banned, words: %w[basically
                                                                      literally]
                                           ),
                                         ])
    result = described_class.new(document: doc, ruleset: ruleset).run
    expect(result.count).to be > 0
    expect(result.by_rule).to have_key(:banned)
  end

  it "supports max_paragraph_length rule" do
    ruleset = Uniword::Lint::Ruleset.new([
                                           Uniword::Lint::BuiltinRules::MaxParagraphLength.new(name: :length,
                                                                                               max: 5),
                                         ])
    result = described_class.new(document: doc, ruleset: ruleset).run
    expect(result.by_rule[:length]).to be > 0
  end

  it "supports require_body rule" do
    ruleset = Uniword::Lint::Ruleset.new([
                                           Uniword::Lint::BuiltinRules::RequireBody.new(name: :body),
                                         ])
    result = described_class.new(document: doc, ruleset: ruleset).run
    expect(result.count).to eq(0)
  end

  it "reports errors when require_body fails" do
    empty_doc = Uniword::Wordprocessingml::DocumentRoot.new
    empty_doc.body = Uniword::Wordprocessingml::Body.new
    ruleset = Uniword::Lint::Ruleset.new([
                                           Uniword::Lint::BuiltinRules::RequireBody.new(name: :body,
                                                                                        severity: :error),
                                         ])
    result = described_class.new(document: empty_doc,
                                 ruleset: ruleset).run
    expect(result.errors?).to be(true)
  end
end

RSpec.describe Uniword::Lint::Ruleset do
  it "loads from a YAML hash" do
    data = {
      "rules" => [
        { "type" => "max_paragraph_length", "max" => 100 },
        { "type" => "banned_words",
          "words" => %w[foo bar] },
      ],
    }
    ruleset = described_class.from_hash(data)
    expect(ruleset.rules.length).to eq(2)
    expect(ruleset.rules.map(&:class).map(&:name))
      .to contain_exactly(
        "Uniword::Lint::BuiltinRules::MaxParagraphLength",
        "Uniword::Lint::BuiltinRules::BannedWords",
      )
  end

  it "raises for unknown rule types" do
    expect do
      described_class.from_hash("rules" => [{ "type" => "bogus" }])
    end.to raise_error(ArgumentError)
  end
end

RSpec.describe "DocumentRoot#lint" do
  it "runs a ruleset via the public API" do
    b = Uniword::Builder::DocumentBuilder.new
    b.paragraph("foo")
    ruleset = Uniword::Lint::Ruleset.new([
                                           Uniword::Lint::BuiltinRules::BannedWords.new(name: :no_foo,
                                                                                        words: ["foo"]),
                                         ])
    result = b.model.lint(ruleset: ruleset)
    expect(result).to be_a(Uniword::Lint::Result)
    expect(result.by_rule).to have_key(:no_foo)
  end
end
