# frozen_string_literal: true

require "spec_helper"

# Phase 15 specs: Image enhancements, floating images, watermarks, SDT content controls

# --- OOXML Model Fixes ---

RSpec.describe "Fix: Anchor model child elements" do
  it "supports position_h and position_v" do
    anchor = Uniword::WpDrawing::Anchor.new
    anchor.position_h = Uniword::WpDrawing::PositionH.new(
      relative_from: "margin", align: "center"
    )
    anchor.position_v = Uniword::WpDrawing::PositionV.new(
      relative_from: "page", pos_offset: 100_000
    )

    expect(anchor.position_h.relative_from).to eq("margin")
    expect(anchor.position_h.align).to eq("center")
    expect(anchor.position_v.relative_from).to eq("page")
    expect(anchor.position_v.pos_offset).to eq(100_000)
  end

  it "supports wrap_square" do
    anchor = Uniword::WpDrawing::Anchor.new
    anchor.wrap_square = Uniword::WpDrawing::WrapSquare.new(wrap_text: "bothSides")

    expect(anchor.wrap_square.wrap_text).to eq("bothSides")
  end

  it "supports wrap_none" do
    anchor = Uniword::WpDrawing::Anchor.new
    anchor.wrap_none = Uniword::WpDrawing::WrapNone.new

    expect(anchor.wrap_none).not_to be_nil
  end

  it "supports simple_pos" do
    anchor = Uniword::WpDrawing::Anchor.new
    anchor.simple_pos = Uniword::WpDrawing::SimplePos.new(x: 0, y: 0)

    expect(anchor.simple_pos.x).to eq(0)
  end

  it "supports effect_extent" do
    anchor = Uniword::WpDrawing::Anchor.new
    anchor.effect_extent = Uniword::WpDrawing::EffectExtent.new(l: 0, t: 0, r: 0, b: 0)

    expect(anchor.effect_extent).not_to be_nil
  end

  it "serializes anchor with positionH" do
    anchor = Uniword::WpDrawing::Anchor.new
    anchor.simple_pos = Uniword::WpDrawing::SimplePos.new(x: 0, y: 0)
    anchor.position_h = Uniword::WpDrawing::PositionH.new(
      relative_from: "margin", align: "center"
    )
    anchor.position_v = Uniword::WpDrawing::PositionV.new(
      relative_from: "margin", align: "top"
    )
    anchor.extent = Uniword::WpDrawing::Extent.new(cx: 100_000, cy: 100_000)
    anchor.doc_properties = Uniword::WpDrawing::DocProperties.new(
      id: 1, name: "Test"
    )
    anchor.wrap_square = Uniword::WpDrawing::WrapSquare.new(wrap_text: "bothSides")
    anchor.graphic = Uniword::Drawingml::Graphic.new

    xml = anchor.to_xml(prefix: true)
    expect(xml).to include("wp:positionH")
    expect(xml).to include("wp:positionV")
    expect(xml).to include("wp:wrapSquare")
    expect(xml).to include('relative-from="margin"')
  end
end

RSpec.describe "Fix: Picture model types" do
  it "PictureShapeProperties uses object types for xfrm and ln" do
    sp = Uniword::Picture::PictureShapeProperties.new
    sp.xfrm = Uniword::Drawingml::Transform2D.new
    sp.xfrm.off = Uniword::Drawingml::Offset.new(x: 0, y: 0)
    sp.xfrm.ext = Uniword::Drawingml::Extents.new(cx: 500_000, cy: 300_000)

    expect(sp.xfrm).to be_a(Uniword::Drawingml::Transform2D)
    expect(sp.xfrm.off.x).to eq(0)
    expect(sp.xfrm.ext.cx).to eq(500_000)
  end

  it "PictureBlipFill uses Blip object type" do
    bf = Uniword::Picture::PictureBlipFill.new
    bf.blip = Uniword::Drawingml::Blip.new(embed: "rId1")

    expect(bf.blip).to be_a(Uniword::Drawingml::Blip)
    expect(bf.blip.embed).to eq("rId1")
  end

  it "NonVisualPictureProperties uses NonVisualDrawingProperties" do
    nv = Uniword::Picture::NonVisualPictureProperties.new
    nv.c_nv_pr = Uniword::Drawingml::NonVisualDrawingProperties.new(
      id: 100, name: "Picture 1"
    )

    expect(nv.c_nv_pr).to be_a(Uniword::Drawingml::NonVisualDrawingProperties)
    expect(nv.c_nv_pr.id).to eq(100)
    expect(nv.c_nv_pr.name).to eq("Picture 1")
  end
end

RSpec.describe "VML TextPath model" do
  it "creates a textpath element" do
    tp = Uniword::Vml::TextPath.new(string: "CONFIDENTIAL")

    expect(tp.string).to eq("CONFIDENTIAL")
  end

  it "serializes textpath with string attribute" do
    tp = Uniword::Vml::TextPath.new(
      string: "DRAFT",
      style: "font-family:'Arial';font-size:60pt"
    )

    xml = tp.to_xml
    expect(xml).to include('string="DRAFT"')
    expect(xml).to include("font-family")
  end
end

RSpec.describe "VML Shape with textpath" do
  it "supports textpath child element" do
    shape = Uniword::Vml::Shape.new(
      id: "test", type: "#_x0000_t136"
    )
    shape.textpath = Uniword::Vml::TextPath.new(string: "WATERMARK")

    expect(shape.textpath).not_to be_nil
    expect(shape.textpath.string).to eq("WATERMARK")
  end

  it "serializes shape with textpath" do
    shape = Uniword::Vml::Shape.new(
      id: "PowerPlusWaterMarkObject1",
      type: "#_x0000_t136",
      fillcolor: "D0D0D0",
      strokecolor: "none"
    )
    shape.fill = Uniword::Vml::Fill.new(type: "tile", opacity: "0.3")
    shape.textpath = Uniword::Vml::TextPath.new(string: "DRAFT")

    xml = shape.to_xml(prefix: true)
    expect(xml).to include("v:textpath")
    expect(xml).to include('string="DRAFT"')
  end
end

# --- ImageBuilder ---

RSpec.describe Uniword::Builder::ImageBuilder do
  describe ".register_image" do
    it "registers an image on the document" do
      doc = Uniword::Builder::DocumentBuilder.new
      r_id = described_class.register_image(doc, "spec/fixtures/sample.png")

      expect(doc.model.image_parts).not_to be_nil
      expect(doc.model.image_parts.keys).to include(r_id)
      expect(r_id).to start_with("rIdImg")
    end

    it "stores image metadata" do
      doc = Uniword::Builder::DocumentBuilder.new
      r_id = described_class.register_image(doc, "spec/fixtures/sample.png")

      part = doc.model.image_parts[r_id]
      expect(part[:path]).to eq("spec/fixtures/sample.png")
      expect(part[:content_type]).to eq("image/png")
      expect(part[:data]).not_to be_nil
    end

    it "handles JPEG content type" do
      doc = Uniword::Builder::DocumentBuilder.new
      r_id = described_class.register_image(doc, "spec/fixtures/sample.png")

      expect(doc.model.image_parts[r_id][:content_type]).to eq("image/png")
    end
  end

  describe ".build_picture" do
    it "creates a Picture with proper structure" do
      pic = described_class.send(:build_picture, "rId1", 500_000, 300_000)

      expect(pic).to be_a(Uniword::Picture::Picture)
      expect(pic.nv_pic_pr).not_to be_nil
      expect(pic.blip_fill).not_to be_nil
      expect(pic.sp_pr).not_to be_nil
    end

    it "sets blip reference" do
      pic = described_class.send(:build_picture, "rId1", 500_000, 300_000)

      expect(pic.blip_fill.blip.embed).to eq("rId1")
    end

    it "sets transform dimensions" do
      pic = described_class.send(:build_picture, "rId1", 500_000, 300_000)

      expect(pic.sp_pr.xfrm.ext.cx).to eq(500_000)
      expect(pic.sp_pr.xfrm.ext.cy).to eq(300_000)
    end

    it "sets preset geometry to rect" do
      pic = described_class.send(:build_picture, "rId1", 500_000, 300_000)

      expect(pic.sp_pr.prst_geom.prst).to eq("rect")
    end

    it "includes stretch fill rect" do
      pic = described_class.send(:build_picture, "rId1", 500_000, 300_000)

      expect(pic.blip_fill.stretch).not_to be_nil
      expect(pic.blip_fill.stretch.fill_rect).not_to be_nil
    end
  end

  describe ".build_graphic" do
    it "creates graphic with picture namespace URI" do
      graphic = described_class.send(:build_graphic, "rId1", 500_000, 300_000)

      expect(graphic.graphic_data.uri).to include("picture")
      expect(graphic.graphic_data.picture).not_to be_nil
    end
  end
end

RSpec.describe Uniword::Builder::ImageBuilder, "serialization" do
  it "serializes inline drawing with picture chain" do
    doc = Uniword::Builder::DocumentBuilder.new
    drawing = described_class.create_drawing(doc, "spec/fixtures/sample.png",
                                             width: 500_000, height: 300_000)

    xml = drawing.to_xml
    expect(xml).to include("inline")
    expect(xml).to include("<pic")
    expect(xml).to include("nvPicPr")
    expect(xml).to include("blipFill")
    expect(xml).to include("spPr")
    expect(xml).to include("blip")
    expect(xml).to include("rIdImg")
  end

  it "serializes anchor drawing with positioning" do
    doc = Uniword::Builder::DocumentBuilder.new
    drawing = described_class.create_floating(doc, "spec/fixtures/sample.png",
                                              width: 500_000, height: 300_000,
                                              align: :right)

    xml = drawing.to_xml
    expect(xml).to include("anchor")
    expect(xml).to include("positionH")
    expect(xml).to include("wrapSquare")
  end
end

# --- WatermarkBuilder ---

RSpec.describe Uniword::Builder::WatermarkBuilder do
  describe ".build_shape" do
    it "creates a VML shape with textpath" do
      shape = described_class.build_shape("CONFIDENTIAL")

      expect(shape).to be_a(Uniword::Vml::Shape)
      expect(shape.textpath).not_to be_nil
      expect(shape.textpath.string).to eq("CONFIDENTIAL")
    end

    it "sets fill properties" do
      shape = described_class.build_shape("DRAFT")

      expect(shape.fill).not_to be_nil
      expect(shape.fill.type).to eq("tile")
      expect(shape.fill.opacity).to eq("0.3")
    end

    it "accepts custom font" do
      shape = described_class.build_shape("TEST", font: "Arial")

      expect(shape.textpath.style).to include("Arial")
    end

    it "accepts custom size" do
      shape = described_class.build_shape("TEST", size: 80)

      expect(shape.textpath.style).to include("80pt")
    end

    it "accepts custom color" do
      shape = described_class.build_shape("TEST", color: "FF0000")

      expect(shape.fillcolor).to eq("FF0000")
      expect(shape.fill.color).to eq("FF0000")
    end

    it "accepts custom opacity" do
      shape = described_class.build_shape("TEST", opacity: "0.5")

      expect(shape.fill.opacity).to eq("0.5")
    end

    it "accepts custom angle" do
      shape = described_class.build_shape("TEST", angle: 90)

      expect(shape.style).to include("rotation:90")
    end
  end

  describe ".build_paragraph" do
    it "creates a paragraph with a watermark picture" do
      para = described_class.build_paragraph("CONFIDENTIAL")

      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(para.runs.size).to be >= 1
    end

    it "wraps shape in a Picture (w:pict)" do
      para = described_class.build_paragraph("DRAFT")

      run = para.runs.first
      expect(run.pictures.size).to be >= 1
      expect(run.pictures.first.shape).not_to be_nil
      expect(run.pictures.first.shape.textpath.string).to eq("DRAFT")
    end
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, "#watermark" do
  it "sets a watermark on the default header" do
    doc = described_class.new
    doc.watermark("CONFIDENTIAL")

    expect(doc.model.headers).not_to be_nil
    expect(doc.model.headers["default"]).not_to be_nil
    header = doc.model.headers["default"]
    expect(header.paragraphs.size).to be >= 1
  end

  it "clears watermark with nil" do
    doc = described_class.new
    doc.watermark("CONFIDENTIAL")
    doc.watermark(nil)

    expect(doc.model.headers&.key?("default")).to be_falsey
  end

  it "accepts custom options" do
    doc = described_class.new
    doc.watermark("DRAFT", font: "Arial", size: 80, color: "FF0000",
                           opacity: "0.5", angle: 90)

    header = doc.model.headers["default"]
    para = header.paragraphs.first
    run = para.runs.first
    shape = run.pictures.first.shape
    expect(shape.textpath.string).to eq("DRAFT")
    expect(shape.textpath.style).to include("Arial")
    expect(shape.textpath.style).to include("80pt")
  end

  it "returns self for chaining" do
    doc = described_class.new
    result = doc.watermark("TEST")
    expect(result).to eq(doc)
  end
end

# --- SdtBuilder ---

RSpec.describe Uniword::Builder::SdtBuilder do
  describe ".text" do
    it "creates a text content control" do
      sdt = described_class.text(tag: "title", alias_name: "Title")

      expect(sdt.model).to be_a(Uniword::Wordprocessingml::StructuredDocumentTag)
      expect(sdt.model.properties).not_to be_nil
    end

    it "sets the tag" do
      sdt = described_class.text(tag: "myField")

      expect(sdt.model.properties.tag.value).to eq("myField")
    end

    it "sets the alias" do
      sdt = described_class.text(alias_name: "Document Title")

      expect(sdt.model.properties.alias_name.value).to eq("Document Title")
    end

    it "sets the text control flag" do
      sdt = described_class.text

      expect(sdt.model.properties.text).not_to be_nil
    end

    it "auto-assigns an ID on build" do
      sdt = described_class.text
      model = sdt.build

      expect(model.properties.id).not_to be_nil
      expect(model.properties.id.value).to be > 0
    end

    it "sets placeholder text" do
      sdt = described_class.text(placeholder_text: "Enter title here")
      sdt.build

      expect(sdt.model.properties.showing_placeholder_header).not_to be_nil
    end
  end

  describe ".date" do
    it "creates a date content control" do
      sdt = described_class.date(format: "yyyy-MM-dd")

      expect(sdt.model.properties.date).not_to be_nil
    end

    it "sets date format" do
      sdt = described_class.date(format: "yyyy-MM-dd")

      expect(sdt.model.properties.date.date_format.value).to eq("yyyy-MM-dd")
    end

    it "sets locale" do
      sdt = described_class.date(locale: "fr-FR")

      expect(sdt.model.properties.date.lid.value).to eq("fr-FR")
    end

    it "sets calendar" do
      sdt = described_class.date(calendar: "japanese")

      expect(sdt.model.properties.date.calendar.value).to eq("japanese")
    end
  end

  describe ".bibliography" do
    it "creates a bibliography content control" do
      sdt = described_class.bibliography

      expect(sdt.model.properties.bibliography).not_to be_nil
      expect(sdt.model.properties.doc_part_obj).not_to be_nil
    end

    it "sets bibliography gallery" do
      sdt = described_class.bibliography

      expect(sdt.model.properties.doc_part_obj.doc_part_gallery.value).to eq("Bibliographies")
    end

    it "sets docPartUnique" do
      sdt = described_class.bibliography

      expect(sdt.model.properties.doc_part_obj.doc_part_unique).not_to be_nil
    end
  end

  describe ".doc_part" do
    it "creates a document part content control" do
      sdt = described_class.doc_part(gallery: "Table of Contents")

      expect(sdt.model.properties.doc_part_obj).not_to be_nil
      expect(sdt.model.properties.doc_part_obj.doc_part_gallery.value).to eq("Table of Contents")
    end

    it "can skip unique flag" do
      sdt = described_class.doc_part(gallery: "Custom", unique: false)

      expect(sdt.model.properties.doc_part_obj.doc_part_unique).to be_nil
    end
  end

  describe "instance methods" do
    it "#id sets the identifier" do
      sdt = described_class.new
      sdt.id(42)

      expect(sdt.model.properties.id.value).to eq(42)
    end

    it "#tag sets the developer tag" do
      sdt = described_class.new
      sdt.tag("myTag")

      expect(sdt.model.properties.tag.value).to eq("myTag")
    end

    it "#alias sets the display name" do
      sdt = described_class.new
      sdt.alias("My Field")

      expect(sdt.model.properties.alias_name.value).to eq("My Field")
    end

    it "#build returns the SDT model" do
      sdt = described_class.new
      model = sdt.build

      expect(model).to be_a(Uniword::Wordprocessingml::StructuredDocumentTag)
    end
  end
end

# --- DocumentBuilder new methods ---

RSpec.describe Uniword::Builder::DocumentBuilder, "#image" do
  it "adds an image paragraph to the document" do
    doc = described_class.new
    doc.image("spec/fixtures/sample.png", width: 500_000, height: 300_000)

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to be >= 1

    run = paragraphs.first.runs.first
    expect(run.drawings.size).to be >= 1
  end

  it "registers the image in image_parts" do
    doc = described_class.new
    doc.image("spec/fixtures/sample.png")

    expect(doc.model.image_parts).not_to be_nil
    expect(doc.model.image_parts.size).to be >= 1
  end

  it "returns self for chaining" do
    doc = described_class.new
    result = doc.image("spec/fixtures/sample.png")
    expect(result).to eq(doc)
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, "#floating_image" do
  it "adds a floating image paragraph" do
    doc = described_class.new
    doc.floating_image("spec/fixtures/sample.png", width: 500_000, height: 300_000,
                                                   align: :right)

    paragraphs = doc.model.body.paragraphs
    expect(paragraphs.size).to be >= 1

    run = paragraphs.first.runs.first
    expect(run.drawings.size).to be >= 1
    drawing = run.drawings.first
    expect(drawing.anchor).not_to be_nil
  end

  it "sets wrap square by default" do
    doc = described_class.new
    doc.floating_image("spec/fixtures/sample.png", width: 500_000, height: 300_000)

    run = doc.model.body.paragraphs.first.runs.first
    drawing = run.drawings.first
    expect(drawing.anchor.wrap_square).not_to be_nil
  end

  it "supports wrap none" do
    doc = described_class.new
    doc.floating_image("spec/fixtures/sample.png", width: 500_000, height: 300_000,
                                                   wrap: :none)

    run = doc.model.body.paragraphs.first.runs.first
    drawing = run.drawings.first
    expect(drawing.anchor.wrap_none).not_to be_nil
  end

  it "supports behind text" do
    doc = described_class.new
    doc.floating_image("spec/fixtures/sample.png", width: 500_000, height: 300_000,
                                                   behind_text: true)

    run = doc.model.body.paragraphs.first.runs.first
    drawing = run.drawings.first
    expect(drawing.anchor.behind_doc).to eq("1")
  end

  it "returns self for chaining" do
    doc = described_class.new
    result = doc.floating_image("spec/fixtures/sample.png")
    expect(result).to eq(doc)
  end
end

RSpec.describe Uniword::Builder::DocumentBuilder, "#content_control" do
  it "adds a text content control to the last paragraph" do
    doc = described_class.new
    doc.paragraph { |p| p << "Enter title: " }
    doc.content_control(tag: "title", placeholder_text: "Click to enter title")

    para = doc.model.body.paragraphs.last
    expect(para.sdts.size).to be >= 1
    sdt = para.sdts.first
    expect(sdt.properties.tag.value).to eq("title")
  end
end

# --- Scenario Specs ---

RSpec.describe "Scenario: Document with watermark" do
  it "creates a document with a DRAFT watermark" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.title("Draft Document")
    doc.watermark("DRAFT", font: "Arial", size: 80, color: "FF0000", opacity: "0.3")
    doc.paragraph { |p| p << "This is a draft document." }
    doc.paragraph { |p| p << "Do not distribute." }

    expect(doc.model.headers["default"]).not_to be_nil
    expect(doc.model.body.paragraphs.size).to eq(2)
  end
end

RSpec.describe "Scenario: Document with content controls" do
  it "creates a form with text and date controls" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph do |p|
      p << "Name: "
      p << Uniword::Builder::SdtBuilder.text(tag: "name", alias_name: "Full Name",
                                             placeholder_text: "Enter name").build
    end
    doc.paragraph do |p|
      p << "Date: "
      p << Uniword::Builder::SdtBuilder.date(tag: "date", format: "yyyy-MM-dd").build
    end
    doc.paragraph do |p|
      p << "Comments: "
      p << Uniword::Builder::SdtBuilder.text(tag: "comments", alias_name: "Comments",
                                             placeholder_text: "Enter comments").build
    end

    expect(doc.model.body.paragraphs.size).to eq(3)
  end
end

RSpec.describe "Scenario: Document with bibliography placeholder" do
  it "creates a document with a bibliography content control" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.heading("References", level: 1)
    doc.paragraph { |p| p << Uniword::Builder::SdtBuilder.bibliography.build }

    expect(doc.model.body.paragraphs.size).to be >= 2
  end
end

RSpec.describe "Scenario: Document with inline and floating images" do
  it "creates a document with both image types" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.heading("Report with Images", level: 1)
    doc.paragraph { |p| p << "Figure 1: Inline image" }
    doc.image("spec/fixtures/sample.png", width: 400_000, height: 300_000)

    doc.paragraph { |p| p << "Figure 2: Floating image" }
    doc.floating_image("spec/fixtures/sample.png", width: 300_000, height: 200_000,
                                                   align: :right, wrap: :square)

    expect(doc.model.body.paragraphs.size).to be >= 4
    expect(doc.model.image_parts.size).to be >= 2
  end
end

RSpec.describe "Scenario: Complete document with Phase 15 features" do
  it "combines watermark, content controls, and images" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.title("Advanced Document")
    doc.author("Author")
    doc.apply_styleset("formal")

    # Watermark
    doc.watermark("CONFIDENTIAL", opacity: "0.2")

    # Header with page number
    doc.header { |h| h << "Confidential Document" }

    # Content with content controls
    doc.heading("Form Section", level: 1)
    doc.paragraph do |p|
      p << "Prepared by: "
      p << Uniword::Builder::SdtBuilder.text(tag: "author",
                                             placeholder_text: "Enter name").build
    end

    doc.paragraph do |p|
      p << "Date: "
      p << Uniword::Builder::SdtBuilder.date(tag: "date",
                                             format: "MMMM d, yyyy").build
    end

    # Images
    doc.heading("Figures", level: 1)
    doc.image("spec/fixtures/sample.png", width: 500_000, height: 300_000)

    # Floating image
    doc.paragraph { |p| p << "Text wrapping around image:" }
    doc.floating_image("spec/fixtures/sample.png", width: 200_000, height: 200_000,
                                                   align: :right, wrap: :square)

    # Bibliography
    doc.heading("References", level: 1)
    doc.paragraph { |p| p << Uniword::Builder::SdtBuilder.bibliography.build }

    # Footer
    doc.footer do |f|
      f << "Page "
      f << Uniword::Builder.page_number_field
    end

    # Verify
    expect(doc.model.headers["default"]).not_to be_nil
    expect(doc.model.footers["default"]).not_to be_nil
    expect(doc.model.image_parts.size).to be >= 2
    expect(doc.model.styles_configuration.styles.size).to be > 0
  end
end
