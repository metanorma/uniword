# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Boolean formatting (BooleanValSetter + BooleanElement)" do
  # Use Bold as representative boolean element
  let(:bold_class) { Uniword::Properties::Bold }

  describe "BooleanValSetter val= normalization" do
    it "normalizes true to nil (absent val = true)" do
      bold = bold_class.new
      bold.val = true
      expect(bold.val).to be_nil
    end

    it "normalizes false to 'false'" do
      bold = bold_class.new
      bold.val = false
      expect(bold.val).to eq("false")
    end

    it "normalizes 'true' to nil" do
      bold = bold_class.new
      bold.val = "true"
      expect(bold.val).to be_nil
    end

    it "normalizes 'false' to 'false'" do
      bold = bold_class.new
      bold.val = "false"
      expect(bold.val).to eq("false")
    end

    it "normalizes nil to nil" do
      bold = bold_class.new
      bold.val = nil
      expect(bold.val).to be_nil
    end

    it "passes through other string values unchanged" do
      bold = bold_class.new
      bold.val = "something"
      expect(bold.val).to eq("something")
    end

    it "marks val as explicitly set for true (nil val)" do
      bold = bold_class.new
      bold.val = true
      expect(bold.using_default?(:val)).to be false
    end

    it "marks val as explicitly set for false" do
      bold = bold_class.new
      bold.val = false
      expect(bold.using_default?(:val)).to be false
    end
  end

  describe "BooleanElement value getter" do
    it "returns true when val is nil (absent val)" do
      bold = bold_class.new
      bold.val = true
      expect(bold.value).to be true
    end

    it "returns false when val is 'false'" do
      bold = bold_class.new
      bold.val = false
      expect(bold.value).to be false
    end

    it "returns true by default (new instance)" do
      bold = bold_class.new
      expect(bold.value).to be true
    end
  end

  describe "XML serialization" do
    it "serializes true as empty element (no val attribute)" do
      bold = bold_class.new
      bold.val = true
      xml = bold.to_xml
      expect(xml).not_to include("w:val")
    end

    it "serializes false as element with val='false'" do
      bold = bold_class.new
      bold.val = false
      xml = bold.to_xml
      expect(xml).to include('w:val="false"')
    end

    it "serializes default instance as empty element" do
      bold = bold_class.new
      xml = bold.to_xml
      expect(xml).not_to include("w:val")
    end
  end

  describe "XML round-trip" do
    it "round-trips true (empty val) through parse/serialize" do
      xml = '<w:b xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'
      bold = bold_class.from_xml(xml)
      expect(bold.value).to be true
      expect(bold.to_xml).not_to include("w:val")
    end

    it "round-trips false through parse/serialize" do
      xml = '<w:b xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" w:val="false"/>'
      bold = bold_class.from_xml(xml)
      expect(bold.value).to be false
      expect(bold.to_xml).to include('w:val="false"')
    end

    it "round-trips val='true' to empty val (normalized)" do
      xml = '<w:b xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" w:val="true"/>'
      bold = bold_class.from_xml(xml)
      expect(bold.value).to be true
      expect(bold.to_xml).not_to include("w:val")
    end
  end

  describe "multiple boolean element types" do
    {
      "Italic" => ["w:i", Uniword::Properties::Italic],
      "Strike" => ["w:strike", Uniword::Properties::Strike],
      "SmallCaps" => ["w:smallCaps", Uniword::Properties::SmallCaps],
    }.each do |name, (_element, klass)|
      it "#{name} serializes true without val attribute" do
        obj = klass.new
        obj.val = true
        expect(obj.to_xml).not_to include("w:val")
      end

      it "#{name} serializes false with val='false'" do
        obj = klass.new
        obj.val = false
        expect(obj.to_xml).to include('w:val="false"')
      end
    end
  end
end
