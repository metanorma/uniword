# frozen_string_literal: true

require "spec_helper"
require "uniword/model_attribute_access"

RSpec.describe Uniword::ModelAttributeAccess do
  let(:model_class) do
    klass = Class.new do
      include Uniword::ModelAttributeAccess

      def self.attributes
        { name: nil, age: nil }
      end

      attr_accessor :name, :age
    end
    klass
  end

  let(:model) { model_class.new }

  describe "#read_attribute" do
    it "reads a declared attribute value" do
      model.name = "Test"
      expect(model.read_attribute(:name)).to eq("Test")
    end

    it "returns nil for an unset attribute" do
      expect(model.read_attribute(:age)).to be_nil
    end
  end

  describe "#write_attribute" do
    it "sets a declared attribute value" do
      model.write_attribute(:name, "Hello")
      expect(model.name).to eq("Hello")
    end

    it "overwrites an existing value" do
      model.age = 10
      model.write_attribute(:age, 20)
      expect(model.age).to eq(20)
    end
  end

  describe "with real RunProperties" do
    let(:rpr) { Uniword::Wordprocessingml::RunProperties.new }

    it "reads a declared attribute" do
      expect(rpr.read_attribute(:bold)).to be_nil
    end

    it "writes a declared attribute" do
      bold = Uniword::Properties::Bold.new(val: true)
      rpr.write_attribute(:bold, bold)
      expect(rpr.bold).to eq(bold)
    end
  end
end
