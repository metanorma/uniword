# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Validation::Engine do
  let(:rules) { Uniword::Validation::Rules }

  describe ".run with an in-memory model context" do
    let(:document) do
      Uniword::Wordprocessingml::DocumentRoot.new.tap do |doc|
        doc.body.tables << Uniword::Wordprocessingml::Table.new
      end
    end
    let(:context) { rules::ModelContext.new(document) }

    it "runs model-level rules" do
      issues = described_class.run(context)
      expect(issues.map(&:code)).to include("DOC-204")
    end

    it "does not run package-level rules" do
      issues = described_class.run(context)
      expect(issues.map(&:code)).to all(start_with("DOC-2"))
    end

    it "returns ValidationIssue objects" do
      issues = described_class.run(context)
      expect(issues).to all(
        be_a(Uniword::Validation::Report::ValidationIssue),
      )
    end
  end

  describe ".run with an on-disk document context" do
    let(:context) do
      rules::DocumentContext.new("spec/fixtures/docx_gem/basic.docx")
    end

    after { context.close }

    it "runs package-level rules only" do
      issues = described_class.run(context)
      model_codes = %w[DOC-200 DOC-201 DOC-202 DOC-203 DOC-204 DOC-205]
      expect(issues.map(&:code)).not_to include(*model_codes)
    end
  end
end
