# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::TableProperties do
  describe "#initialize" do
    it "creates properties with default values" do
      props = described_class.new
      expect(props.style).to be_nil
      expect(props.borders).to be false
      expect(props.allow_break).to be true
    end

    it "creates properties with provided attributes" do
      props = described_class.new(
        style: Uniword::Wordprocessingml::TableStyle.new(val: "TableGrid"),
        table_width: Uniword::Properties::TableWidth.new(w: 100),
        borders: true,
      )
      expect(props.style&.val).to eq("TableGrid")
      expect(props.table_width.w).to eq(100)
      expect(props.borders).to be true
    end

    it "allows mutation for test compatibility" do
      props = described_class.new
      expect(props).not_to be_frozen
    end
  end

  describe "mutability (for test compatibility)" do
    let(:props) { described_class.new }

    it "allows modification of attributes" do
      expect { props.borders = true }.not_to raise_error
      expect(props.borders).to be true
    end

    it "is not frozen" do
      expect(props.frozen?).to be false
    end
  end

  describe "boolean attributes" do
    it "defaults borders to false" do
      props = described_class.new
      expect(props.borders).to be false
    end

    it "defaults allow_break to true" do
      props = described_class.new
      expect(props.allow_break).to be true
    end

    it "allows setting boolean attributes" do
      props = described_class.new(
        borders: true,
        allow_break: false,
      )
      expect(props.borders).to be true
      expect(props.allow_break).to be false
    end
  end

  describe "inheritance" do
    it "inherits from Lutaml::Model::Serializable" do
      expect(described_class.ancestors)
        .to include(Lutaml::Model::Serializable)
    end
  end
end
