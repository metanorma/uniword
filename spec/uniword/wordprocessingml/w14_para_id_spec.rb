# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::W14ParaId do
  let(:paragraph_class) { Uniword::Wordprocessingml::Paragraph }

  let(:para_xml) do
    '<w:p xmlns:w="http://schemas.openxmlformats.org/' \
      'wordprocessingml/2006/main" ' \
      'xmlns:w14="http://schemas.microsoft.com/office/word/2010/' \
      'wordml" w14:paraId="7EDC644E"/>'
  end

  it "accepts eight hexadecimal digits" do
    para = paragraph_class.new(para_id: "1A2B3C4D")
    expect(para.para_id).to eq("1A2B3C4D")
  end

  it "accepts lowercase hexadecimal digits" do
    para = paragraph_class.new(para_id: "1a2b3c4d")
    expect(para.para_id).to eq("1a2b3c4d")
  end

  it "rejects a non-hex value at assignment" do
    expect { paragraph_class.new(para_id: "not-a-id") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end

  it "rejects a value shorter than eight digits at assignment" do
    expect { paragraph_class.new(para_id: "ABC123") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end

  it "parses a paraId unchanged" do
    para = paragraph_class.from_xml(para_xml)
    expect(para.para_id).to eq("7EDC644E")
  end

  it "serializes a parsed paraId unchanged" do
    para = paragraph_class.from_xml(para_xml)
    expect(para.to_xml).to include("7EDC644E")
  end
end
