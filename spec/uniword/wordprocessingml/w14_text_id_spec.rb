# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::W14TextId do
  let(:paragraph_class) { Uniword::Wordprocessingml::Paragraph }

  it "accepts eight hexadecimal digits" do
    para = paragraph_class.new(text_id: "77777777")
    expect(para.text_id).to eq("77777777")
  end

  it "rejects a non-hex value at assignment" do
    expect { paragraph_class.new(text_id: "bogus") }
      .to raise_error(Lutaml::Model::Type::InvalidValueError)
  end
end
