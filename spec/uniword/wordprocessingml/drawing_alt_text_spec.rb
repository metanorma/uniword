# frozen_string_literal: true

require "spec_helper"

# One definition of "what is this image's alt text", shared by the
# accessibility rule, the quality rule, the builder and the renderer.
RSpec.describe Uniword::Wordprocessingml::Drawing do
  def drawing_xml(frame: "inline", attrs: "")
    <<~XML
      <w:drawing
        xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
        <wp:#{frame}>
          <wp:docPr id="1" name="Picture 1"#{attrs}/>
        </wp:#{frame}>
      </w:drawing>
    XML
  end

  describe "#alt_text" do
    it "reads the docPr descr attribute" do
      drawing = described_class.from_xml(
        drawing_xml(attrs: %( descr="A leaf on tree bark")),
      )
      expect(drawing.alt_text).to eq("A leaf on tree bark")
    end

    it "reads descr off an anchored drawing too" do
      drawing = described_class.from_xml(
        drawing_xml(frame: "anchor", attrs: %( descr="A floating chart")),
      )
      expect(drawing.alt_text).to eq("A floating chart")
    end

    it "strips surrounding whitespace so padding cannot pass a length check" do
      drawing = described_class.from_xml(
        drawing_xml(attrs: %( descr="   short   ")),
      )
      expect(drawing.alt_text).to eq("short")
    end

    it "treats a blank descr as absent" do
      drawing = described_class.from_xml(drawing_xml(attrs: %( descr="   ")))
      expect(drawing.alt_text).to be_nil
    end

    it "is nil when the drawing has no descr" do
      expect(described_class.from_xml(drawing_xml).alt_text).to be_nil
    end

    # ECMA-376 names descr the object's description and title its caption.
    # Word's modern Alt Text pane writes descr; the ISO publication corpus
    # carries alt text in descr with no title at all. A title is therefore
    # not a text alternative, however descriptive it reads.
    it "does not fall back to the docPr title" do
      drawing = described_class.from_xml(
        drawing_xml(attrs: %( title="Photo of a leaf on tree bark")),
      )

      aggregate_failures do
        expect(drawing.alt_text).to be_nil
        expect(drawing.alt_title).to eq("Photo of a leaf on tree bark")
      end
    end
  end

  describe "#alt_text=" do
    it "writes descr onto the drawing's frame" do
      drawing = described_class.from_xml(drawing_xml)
      drawing.alt_text = "A red square"

      aggregate_failures do
        expect(drawing.alt_text).to eq("A red square")
        expect(drawing.to_xml).to include('descr="A red square"')
      end
    end
  end
end
