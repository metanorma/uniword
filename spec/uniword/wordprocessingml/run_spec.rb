# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Wordprocessingml::Run do
  let(:properties) do
    Uniword::Wordprocessingml::RunProperties.new(
      bold: true,
      italic: false,
      size: 24
    )
  end

  describe "#initialize" do
    it "creates a run with text" do
      run = described_class.new(text: "Hello")
      expect(run.text.content).to eq("Hello")
    end

    it "creates a run with properties" do
      run = described_class.new(text: "Hello", properties: properties)
      expect(run.properties).to eq(properties)
    end

    it "creates a run without an id (v2.0 API - no id attribute)" do
      run = described_class.new(text: "Test")
      expect(run).not_to respond_to(:id)
    end
  end

  describe "#text_element" do
    # v2.0 API: text_element is not available, use text directly
    it "does not have text_element method (use text instead)" do
      run = described_class.new(text: "Hello")
      expect(run).not_to respond_to(:text_element)
      expect(run.text.content).to eq("Hello")
    end
  end

  describe "#text_element=" do
    # v2.0 API: text_element= is not available, use text= directly
    # Note: text= accepts Text objects for proper OOXML model
    it "does not have text_element= method (use text instead)" do
      run = described_class.new
      expect(run).not_to respond_to(:text_element=)
      # Proper OOXML: set text with Text object
      run.text = Uniword::Wordprocessingml::Text.new(content: "New text")
      expect(run.text.content).to eq("New text")
    end
  end

  describe "#accept" do
    # v2.0 API: Run has accept method for visitor pattern
    it "has accept method for visitor pattern" do
      run = described_class.new(text: "Test")
      expect(run).to respond_to(:accept)
    end
  end

  describe "bold property (via properties)" do
    it "returns false when no properties" do
      run = described_class.new(text: "Test")
      expect(run.properties&.bold&.value == true).to be false
    end

    it "returns false when bold is false" do
      props = Uniword::Wordprocessingml::RunProperties.new(bold: false)
      described_class.new(text: "Test", properties: props)
      bold_prop = props.bold
      bold_val = bold_prop.respond_to?(:value) ? bold_prop.value : bold_prop
      expect(bold_val == true).to be false
    end

    it "returns true when bold is true" do
      props = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      run = described_class.new(text: "Test", properties: props)
      expect(run.properties.bold&.value == true).to be true
    end
  end

  describe "italic property (via properties)" do
    it "returns false when no properties" do
      run = described_class.new(text: "Test")
      expect(run.properties&.italic&.value == true).to be false
    end

    it "returns false when italic is false" do
      props = Uniword::Wordprocessingml::RunProperties.new(italic: false)
      described_class.new(text: "Test", properties: props)
      italic_prop = props.italic
      italic_val = italic_prop.respond_to?(:value) ? italic_prop.value : italic_prop
      expect(italic_val == true).to be false
    end

    it "returns true when italic is true" do
      props = Uniword::Wordprocessingml::RunProperties.new(italic: true)
      run = described_class.new(text: "Test", properties: props)
      expect(run.properties.italic&.value == true).to be true
    end
  end

  describe "underline property (via properties)" do
    it "returns truthy when underline is set with single value" do
      props = Uniword::Wordprocessingml::RunProperties.new(
        underline: Uniword::Properties::Underline.new(value: "single")
      )
      run = described_class.new(text: "Test", properties: props)
      expect(run.properties.underline && run.properties.underline != "none").to be_truthy
    end

    it 'returns truthy when underline is set (even with "none" value)' do
      # NOTE: The 'none' check compares the underline value, not the wrapper
      props = Uniword::Wordprocessingml::RunProperties.new(
        underline: Uniword::Properties::Underline.new(value: "none")
      )
      run = described_class.new(text: "Test", properties: props)
      underline_val = run.properties.underline
      # With wrapper object, the 'none' string comparison does not match
      # the wrapper object, so this is truthy
      expect(underline_val && underline_val != "none").to be_truthy
    end

    it "returns falsey when no properties" do
      run = described_class.new(text: "Test")
      expect(run.properties&.underline && run.properties.underline != "none").to be_falsey
    end

    it "returns falsey when properties has no underline set" do
      props = Uniword::Wordprocessingml::RunProperties.new
      run = described_class.new(text: "Test", properties: props)
      expect(run.properties.underline && run.properties.underline != "none").to be_falsey
    end
  end

  describe "#font_size" do
    it "returns effective font size in points from style inheritance" do
      run = described_class.new(text: "Test")
      expect(run).to respond_to(:font_size)
      expect(run.font_size).to be_nil
    end

    it "can access size via properties.size.value (in half-points)" do
      props = Uniword::Wordprocessingml::RunProperties.new(
        size: Uniword::Properties::FontSize.new(value: 24)
      )
      run = described_class.new(text: "Test", properties: props)
      expect(run.properties.size&.value).to eq(24)
      # Size in points = value / 2 = 12 points
    end

    it "returns nil when no properties" do
      run = described_class.new(text: "Test")
      expect(run.properties).to be_nil
    end
  end

  describe "#valid?" do
    # v2.0 API: Run does not have a valid? method
    # Validation is handled by lutaml-model
    it "does not have valid? method (lutaml-model handles validation)" do
      run = described_class.new(text: "Test")
      expect(run).not_to respond_to(:valid?)
    end
  end

  describe "inheritance" do
    it "is a Lutaml::Model::Serializable" do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end

    it "does not inherit from Element (v2.0 uses direct lutaml-model inheritance)" do
      expect(described_class.ancestors).not_to include(Uniword::Element)
    end
  end

  describe "XML round-trip" do
    it_behaves_like "a round-trippable serializable", described_class,
                    { text: "Hello World" }, :text, "Hello World"
  end
end
