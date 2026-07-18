# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::Reconciler::FixCodes do
  let(:code_values) do
    described_class.constants.map { |name| described_class.const_get(name) }
  end

  it "assigns one unique code per concern" do
    expect(code_values.uniq.size).to eq(code_values.size)
  end

  it "keeps historic wire codes for the original concerns" do
    expect(described_class::MC_IGNORABLE).to eq("R1")
    expect(described_class::NOTE_DEFINITION_CREATED).to eq("R10")
    expect(described_class::NOTE_DUPLICATE_ID_REMOVED).to eq("R16")
  end

  it "uses self-describing codes for referential repairs" do
    expect(described_class::DANGLING_DRAWING_REMOVED).to eq("R23")
    expect(described_class::DANGLING_NOTE_REFERENCE_REMOVED).to eq("R18")
  end
end
