# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe Uniword::Schema::ModelGenerator do
  let(:output_dir) { "tmp/model_generator_spec" }
  let(:generator) do
    described_class.new("shared_types", output_dir: output_dir)
  end
  let(:pattern_schema) do
    {
      "class_name" => "Stub",
      "description" => "stub",
      "attributes" => [
        { "name" => "val", "type" => ":string",
          "pattern" => '\A[0-9A-Fa-f]{8}\z',
          "xml_name" => "val", "xml_attribute" => true },
      ],
    }
  end

  after { FileUtils.rm_rf(output_dir) }

  def generated_attribute(element_name)
    path = generator.generate_element_class(element_name)
    File.read(path)[/^ *attribute .*$/].strip
  end

  it "emits a custom constrained type carried by the YAML" do
    expect(generated_attribute("twips_measure")).to eq(
      "attribute :val, Uniword::Ooxml::Types::UnsignedDecimalNumber",
    )
  end

  it "emits values: when the YAML carries an enumeration" do
    expect(generated_attribute("text_alignment")).to eq(
      "attribute :val, :string, " \
      "values: %w[top center baseline bottom auto]",
    )
  end

  it "emits pattern: when the YAML carries a pattern" do
    code = generator.generate_class_code("stub", pattern_schema)
    expect(code).to include(
      'attribute :val, :string, pattern: /\A[0-9A-Fa-f]{8}\z/',
    )
  end

  it "emits plain primitive types unchanged" do
    expect(generated_attribute("decimal_number")).to eq(
      "attribute :val, :integer",
    )
  end
end
