# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Element do
  # Create a concrete test subclass for testing
  let(:test_element_class) do
    Class.new(described_class) do
      def accept(visitor)
        visitor.visit_test_element(self)
      end
    end
  end

  # Create another test subclass for inheritance testing
  let(:another_element_class) do
    Class.new(described_class) do
      def accept(visitor)
        visitor.visit_another_element(self)
      end
    end
  end

  describe ".inherited" do
    it "is called when a subclass is created" do
      expect { test_element_class }.not_to raise_error
    end

    it "allows multiple subclasses to be created" do
      expect { test_element_class }.not_to raise_error
      expect { another_element_class }.not_to raise_error
    end
  end

  describe ".abstract?" do
    it "returns true for the base Element class" do
      expect(described_class.abstract?).to be true
    end

    it "returns false for concrete subclasses" do
      expect(test_element_class.abstract?).to be false
    end
  end

  describe "#id" do
    it "allows setting an id attribute" do
      element = test_element_class.new(id: "element-123")
      expect(element.id).to eq("element-123")
    end

    it "allows updating the id" do
      element = test_element_class.new(id: "initial")
      element.id = "updated"
      expect(element.id).to eq("updated")
    end

    it "allows id to be nil" do
      element = test_element_class.new
      expect(element.id).to be_nil
    end
  end

  describe "#accept" do
    let(:recording_visitor) do
      Class.new do
        def initialize; @visits = []; end
        attr_reader :visits
        def visit_test_element(el); @visits << [:test, el]; end
        def visit_another_element(el); @visits << [:another, el]; end
        def visit_element(el); @visits << [:default, el]; end
      end.new
    end

    it "calls visitor method for the element" do
      element = test_element_class.new
      element.accept(recording_visitor)
      expect(recording_visitor.visits).to eq([[:test, element]])
    end

    context "with default accept method" do
      let(:default_class) do
        Class.new(described_class)
      end

      it "calls visit_element on visitor" do
        element = default_class.new
        element.accept(recording_visitor)
        expect(recording_visitor.visits).to eq([[:default, element]])
      end
    end
  end

  describe "#valid?" do
    it "returns true by default" do
      element = test_element_class.new
      expect(element.valid?).to be true
    end

    it "can be called multiple times" do
      element = test_element_class.new
      expect(element.valid?).to be true
      expect(element.valid?).to be true
    end
  end

  describe "inheritance from Lutaml::Model::Serializable" do
    it "inherits from Lutaml::Model::Serializable" do
      expect(described_class).to be < Lutaml::Model::Serializable
    end

    it "supports lutaml-model attributes" do
      custom_class = Class.new(described_class) do
        attribute :custom_name, :string
      end

      element = custom_class.new(custom_name: "test")
      expect(element.custom_name).to eq("test")
    end
  end
end
