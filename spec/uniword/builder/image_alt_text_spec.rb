# frozen_string_literal: true

require "spec_helper"

# The writing side of alt text. ImageBuilder took an alt_text: argument and
# threw it away, so every picture the builder produced was undescribed.
RSpec.describe "building an image with alt text" do
  let(:png) { File.join(__dir__, "../../fixtures/sample.png") }
  let(:builder) { Uniword::Builder::DocumentBuilder.new }

  def drawing(alt_text: nil, floating: false)
    if floating
      Uniword::Builder::ImageBuilder.create_floating(
        builder, png, alt_text: alt_text
      )
    else
      Uniword::Builder::ImageBuilder.create_drawing(
        builder, png, alt_text: alt_text
      )
    end
  end

  describe "an inline image" do
    it "carries the alt text into docPr/@descr" do
      d = drawing(alt_text: "A red square on white")

      aggregate_failures do
        expect(d.alt_text).to eq("A red square on white")
        expect(d.to_xml).to include('descr="A red square on white"')
      end
    end

    it "writes no descr when no alt text was given" do
      d = drawing

      aggregate_failures do
        expect(d.alt_text).to be_nil
        expect(d.to_xml).not_to include("descr=")
      end
    end
  end

  describe "a floating image" do
    it "carries the alt text into docPr/@descr" do
      d = drawing(alt_text: "A floating logo", floating: true)

      aggregate_failures do
        expect(d.alt_text).to eq("A floating logo")
        expect(d.to_xml).to include('descr="A floating logo"')
      end
    end
  end

  describe "DocumentBuilder#image and #floating_image" do
    it "passes alt text through to the drawing" do
      builder.image(png, alt_text: "Inline described")
      builder.floating_image(png, alt_text: "Floating described")

      expect(builder.model.images.map(&:alt_text))
        .to eq(["Inline described", "Floating described"])
    end
  end
end
