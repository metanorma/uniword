# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::RunBuilder do
  describe "#initialize" do
    it "creates a builder with a new Run model" do
      builder = described_class.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::Run)
    end

    it "wraps an existing Run model" do
      run = Uniword::Wordprocessingml::Run.new(text: "Hello")
      builder = described_class.new(run)
      expect(builder.model).to eq(run)
      expect(builder.model.text.to_s).to eq("Hello")
    end
  end

  describe ".from_model" do
    it "creates a builder from an existing Run" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      builder = described_class.from_model(run)
      expect(builder.model).to eq(run)
    end
  end

  describe "#build" do
    it "returns the underlying Run model" do
      builder = described_class.new
      builder.text("Hello")
      model = builder.build
      expect(model).to be_a(Uniword::Wordprocessingml::Run)
      expect(model.text.to_s).to eq("Hello")
    end
  end

  describe "formatting methods (chainable)" do
    it "sets bold" do
      builder = described_class.new.text("Bold text").bold
      expect(builder.model.properties.bold).to be_a(Uniword::Properties::Bold)
    end

    it "sets italic" do
      builder = described_class.new.italic(true)
      expect(builder.model.properties.italic).to be_a(Uniword::Properties::Italic)
    end

    it "sets underline" do
      builder = described_class.new.underline("single")
      expect(builder.model.properties.underline).to be_a(Uniword::Properties::Underline)
    end

    it "sets color" do
      builder = described_class.new.color("FF0000")
      expect(builder.model.properties.color).to be_a(Uniword::Properties::ColorValue)
    end

    it "sets font" do
      builder = described_class.new.font("Arial")
      expect(builder.model.properties.font).to eq("Arial")
    end

    it "sets size in points (converts to half-points)" do
      builder = described_class.new.size(12)
      expect(builder.model.properties.size).to be_a(Uniword::Properties::FontSize)
      expect(builder.model.properties.size.value).to eq(24) # 12 * 2
    end

    it "sets highlight" do
      builder = described_class.new.highlight("yellow")
      expect(builder.model.properties.highlight).to be_a(Uniword::Properties::Highlight)
    end

    it "sets strike" do
      builder = described_class.new.strike(true)
      expect(builder.model.properties.strike).to be_a(Uniword::Properties::Strike)
    end

    it "sets small_caps" do
      builder = described_class.new.small_caps(true)
      expect(builder.model.properties.small_caps).to be_a(Uniword::Properties::SmallCaps)
    end

    it "sets caps" do
      builder = described_class.new.caps(true)
      expect(builder.model.properties.caps).to be_a(Uniword::Properties::Caps)
    end

    it "sets superscript" do
      builder = described_class.new.superscript
      expect(builder.model.properties.vertical_align).to be_a(Uniword::Properties::VerticalAlign)
    end

    it "sets subscript" do
      builder = described_class.new.subscript
      expect(builder.model.properties.vertical_align).to be_a(Uniword::Properties::VerticalAlign)
    end

    it "chains multiple formatting calls" do
      builder = described_class.new
                               .text("Styled")
                               .bold
                               .italic
                               .color("0000FF")
                               .size(14)

      expect(builder.model.text.to_s).to eq("Styled")
      expect(builder.model.properties.bold).not_to be_nil
      expect(builder.model.properties.italic).not_to be_nil
      expect(builder.model.properties.color).not_to be_nil
      expect(builder.model.properties.size).not_to be_nil
    end
  end

  describe "#shading" do
    it "sets run shading" do
      builder = described_class.new.shading(fill: "FFFF00", color: "FF0000")
      expect(builder.model.properties.shading).to be_a(Uniword::Properties::Shading)
    end
  end

  describe "#text" do
    it "sets text content" do
      builder = described_class.new.text("Hello")
      expect(builder.model.text.to_s).to eq("Hello")
    end
  end

  describe "#drawing" do
    it "adds a drawing to the run" do
      builder = described_class.new
      # Use a minimal mock that responds to the right class check
      drawing = Uniword::Wordprocessingml::Drawing.new
      builder.drawing(drawing)
      drawings = builder.model.instance_variable_get(:@drawings)
      expect(drawings).not_to be_empty
    end
  end
end
