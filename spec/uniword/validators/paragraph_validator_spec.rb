# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Validators::ParagraphValidator do
  let(:validator) { described_class.new }

  describe "inheritance" do
    it "inherits from ElementValidator" do
      expect(described_class).to be < Uniword::Validators::ElementValidator
    end
  end

  describe "#valid?" do
    it "returns false for nil" do
      expect(validator.valid?(nil)).to be false
    end

    it "returns false for non-Paragraph element" do
      run = Uniword::Wordprocessingml::Run.new(text: "test")
      expect(validator.valid?(run)).to be false
    end

    it "returns true for empty paragraph" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      expect(validator.valid?(paragraph)).to be true
    end

    it "returns true for paragraph with valid runs" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Hello")
      paragraph.runs << run1
      run2 = Uniword::Wordprocessingml::Run.new(text: "World")
      paragraph.runs << run2

      expect(validator.valid?(paragraph)).to be true
    end

    it "returns true for paragraph with valid properties" do
      properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        alignment: "center"
      )
      paragraph = Uniword::Wordprocessingml::Paragraph.new(properties: properties)
      run = Uniword::Wordprocessingml::Run.new(text: "Centered text")
      paragraph.runs << run

      expect(validator.valid?(paragraph)).to be true
    end

    it "returns false for paragraph with invalid run" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      paragraph.runs << "not a run" # Invalid: should be Run instance

      expect(validator.valid?(paragraph)).to be false
    end

    it "returns false for paragraph with invalid properties" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      # Using reflection to set invalid properties
      paragraph.instance_variable_set(:@properties, "not properties")

      expect(validator.valid?(paragraph)).to be false
    end
  end

  describe "#errors" do
    it "returns element error for nil" do
      errors = validator.errors(nil)
      expect(errors).to include("Element is nil")
    end

    it "returns type error for non-Paragraph element" do
      run = Uniword::Wordprocessingml::Run.new(text: "test")
      errors = validator.errors(run)
      expect(errors).to include("Element must be a Paragraph")
    end

    it "returns empty array for valid paragraph" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      paragraph.runs << run

      errors = validator.errors(paragraph)
      expect(errors).to be_empty
    end

    it "returns run errors for invalid runs" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      paragraph.runs << "not a run"
      paragraph.runs << Uniword::Wordprocessingml::Run.new(text: "valid")
      paragraph.runs << 123

      errors = validator.errors(paragraph)
      expect(errors).to include("Run at index 0 must be a Run instance")
      expect(errors).to include("Run at index 2 must be a Run instance")
      expect(errors.size).to eq(2)
    end

    it "returns property error for invalid properties" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      paragraph.instance_variable_set(:@properties, "invalid")

      errors = validator.errors(paragraph)
      expect(errors).to include("Properties must be a ParagraphProperties instance")
    end

    it "returns multiple errors for multiple issues" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      paragraph.runs << "invalid run"
      paragraph.instance_variable_set(:@properties, "invalid properties")

      errors = validator.errors(paragraph)
      expect(errors.size).to eq(2)
      expect(errors).to include("Run at index 0 must be a Run instance")
      expect(errors).to include("Properties must be a ParagraphProperties instance")
    end
  end

  describe "integration with ElementValidator.for" do
    it "is returned when requesting validator for Paragraph class" do
      validator = Uniword::Validators::ElementValidator.for(Uniword::Wordprocessingml::Paragraph)
      expect(validator).to be_a(described_class)
    end

    it "validates paragraphs through the registry" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      paragraph.runs << run

      validator = Uniword::Validators::ElementValidator.for(Uniword::Wordprocessingml::Paragraph)
      expect(validator.valid?(paragraph)).to be true
    end
  end

  describe "edge cases" do
    it "handles paragraph with nil runs array" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      paragraph.instance_variable_set(:@runs, nil)

      expect(validator.valid?(paragraph)).to be true
    end

    it "handles paragraph with empty runs array" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      expect(validator.valid?(paragraph)).to be true
    end

    it "handles paragraph with nil properties" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      paragraph.runs << run

      expect(validator.valid?(paragraph)).to be true
      expect(validator.errors(paragraph)).to be_empty
    end
  end

  describe "realistic scenarios" do
    it "validates a complex paragraph with multiple runs and properties" do
      properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        alignment: "justify",
        style: "Heading1"
      )
      paragraph = Uniword::Wordprocessingml::Paragraph.new(properties: properties)

      run1 = Uniword::Wordprocessingml::Run.new(text: "This is ")
      paragraph.runs << run1
      run2 = Uniword::Wordprocessingml::Run.new(text: "a complex ")
      paragraph.runs << run2
      run3 = Uniword::Wordprocessingml::Run.new(text: "paragraph.")
      paragraph.runs << run3

      expect(validator.valid?(paragraph)).to be true
      expect(validator.errors(paragraph)).to be_empty
    end

    it "detects mixed valid and invalid runs" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Valid run")
      paragraph.runs << run1
      paragraph.runs << "Invalid run"
      run3 = Uniword::Wordprocessingml::Run.new(text: "Another valid run")
      paragraph.runs << run3

      expect(validator.valid?(paragraph)).to be false
      errors = validator.errors(paragraph)
      expect(errors).to include("Run at index 1 must be a Run instance")
    end
  end
end
