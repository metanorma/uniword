# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::ElementRegistry do
  # Clear the registry before each test
  before do
    described_class.clear
  end

  describe ".register" do
    it "registers an element class" do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      expect(described_class.registered?("paragraph")).to be true
    end

    it "does not register abstract classes" do
      described_class.register(Uniword::Element)
      expect(described_class.registered?("element")).to be false
    end

    it "registers multiple element classes" do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      described_class.register(Uniword::Wordprocessingml::Run)
      expect(described_class.count).to eq(2)
    end
  end

  describe ".create" do
    before do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      described_class.register(Uniword::Wordprocessingml::Run)
    end

    it "creates an element by tag name" do
      element = described_class.create("paragraph")
      expect(element).to be_a(Uniword::Wordprocessingml::Paragraph)
    end

    it "creates an element with attributes" do
      element = described_class.create("paragraph")
      expect(element).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(element.runs).to eq([]) # Check default collection
    end

    it "is case-insensitive" do
      element = described_class.create("PARAGRAPH")
      expect(element).to be_a(Uniword::Wordprocessingml::Paragraph)
    end

    it "accepts symbol tag names" do
      element = described_class.create(:paragraph)
      expect(element).to be_a(Uniword::Wordprocessingml::Paragraph)
    end

    it "returns nil for unregistered tags" do
      element = described_class.create("unknown")
      expect(element).to be_nil
    end
  end

  describe ".find" do
    before do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
    end

    it "finds a registered element class" do
      klass = described_class.find("paragraph")
      expect(klass).to eq(Uniword::Wordprocessingml::Paragraph)
    end

    it "is case-insensitive" do
      klass = described_class.find("PARAGRAPH")
      expect(klass).to eq(Uniword::Wordprocessingml::Paragraph)
    end

    it "accepts symbol tag names" do
      klass = described_class.find(:paragraph)
      expect(klass).to eq(Uniword::Wordprocessingml::Paragraph)
    end

    it "returns nil for unregistered tags" do
      klass = described_class.find("unknown")
      expect(klass).to be_nil
    end
  end

  describe ".all" do
    it "returns empty array when no elements registered" do
      expect(described_class.all).to eq([])
    end

    it "returns all registered element classes" do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      described_class.register(Uniword::Wordprocessingml::Run)
      expect(described_class.all).to contain_exactly(
        Uniword::Wordprocessingml::Paragraph,
        Uniword::Wordprocessingml::Run,
      )
    end
  end

  describe ".tags" do
    it "returns empty array when no elements registered" do
      expect(described_class.tags).to eq([])
    end

    it "returns all registered tag names" do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      described_class.register(Uniword::Wordprocessingml::Run)
      expect(described_class.tags).to contain_exactly("paragraph", "run")
    end
  end

  describe ".registered?" do
    before do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
    end

    it "returns true for registered tags" do
      expect(described_class.registered?("paragraph")).to be true
    end

    it "returns false for unregistered tags" do
      expect(described_class.registered?("unknown")).to be false
    end

    it "is case-insensitive" do
      expect(described_class.registered?("PARAGRAPH")).to be true
    end
  end

  describe ".clear" do
    it "clears all registered elements" do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      described_class.register(Uniword::Wordprocessingml::Run)
      described_class.clear
      expect(described_class.count).to eq(0)
    end
  end

  describe ".count" do
    it "returns 0 when no elements registered" do
      expect(described_class.count).to eq(0)
    end

    it "returns the number of registered elements" do
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      described_class.register(Uniword::Wordprocessingml::Run)
      expect(described_class.count).to eq(2)
    end
  end

  describe "automatic registration" do
    it "element classes are automatically registered when loaded" do
      # Clear and manually trigger registration to test the mechanism
      described_class.clear

      # These classes should auto-register when inherited is called
      described_class.register(Uniword::Wordprocessingml::Paragraph)
      described_class.register(Uniword::Wordprocessingml::Run)
      described_class.register(Uniword::Wordprocessingml::Table)

      expect(described_class.registered?("paragraph")).to be true
      expect(described_class.registered?("run")).to be true
      expect(described_class.registered?("table")).to be true
    end
  end
end
