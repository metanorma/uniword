# frozen_string_literal: true

require "spec_helper"
require "zip"

# Partial theme edits: apply_font_scheme / apply_color_scheme replace
# only the targeted theme element (Word's Design → Fonts / Colors
# galleries), leaving the rest of the theme untouched.
RSpec.describe Uniword::Wordprocessingml::DocumentRoot,
               "theme scheme switching" do
  let(:output_dir) { "tmp/theme_schemes" }

  before { FileUtils.mkdir_p(output_dir) }

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  def build_document
    described_class.new.tap do |doc|
      doc.body = Uniword::Wordprocessingml::Body.new
      doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(content: "text"),
        )],
      )
    end
  end

  describe "#apply_font_scheme" do
    it "creates the theme part when the document has none" do
      doc = build_document
      doc.apply_font_scheme("carlito_sans")

      fonts = doc.theme.theme_elements.font_scheme
      expect(fonts).not_to be_nil
      expect(fonts.major_font_obj.latin.typeface).to eq("Carlito")
      expect(fonts.minor_font_obj.latin.typeface).to eq("Carlito")
    end

    it "carries per-script fonts from the bundled scheme" do
      doc = build_document
      doc.apply_font_scheme("carlito_sans")

      scripts = doc.theme.theme_elements.font_scheme
        .major_font_obj.fonts.map(&:script)
      expect(scripts).to include("Jpan", "Arab")
    end

    it "replaces only fontScheme on a themed document" do
      doc = build_document
      doc.apply_theme("corporate")
      colors_before = doc.theme.theme_elements.clr_scheme.to_xml

      doc.apply_font_scheme("caladea")

      fonts = doc.theme.theme_elements.font_scheme
      expect(fonts.major_font_obj.latin.typeface).to eq("Caladea")
      expect(doc.theme.theme_elements.clr_scheme.to_xml)
        .to eq(colors_before)
    end

    it "raises ArgumentError for an unknown scheme" do
      doc = build_document

      expect { doc.apply_font_scheme("no_such_scheme") }
        .to raise_error(ArgumentError, /not found/)
    end
  end

  describe "#apply_color_scheme" do
    it "creates the theme part when the document has none" do
      doc = build_document
      doc.apply_color_scheme("emerald")

      colors = doc.theme.theme_elements.clr_scheme
      expect(colors).not_to be_nil
      expect(colors.accent1.srgb_clr.val).to eq("2D6A4F")
    end

    it "replaces only clrScheme on a themed document" do
      doc = build_document
      doc.apply_theme("corporate")
      fonts_before = doc.theme.theme_elements.font_scheme.to_xml

      doc.apply_color_scheme("emerald")

      expect(doc.theme.theme_elements.clr_scheme.accent1.srgb_clr.val)
        .to eq("2D6A4F")
      expect(doc.theme.theme_elements.font_scheme.to_xml)
        .to eq(fonts_before)
    end
  end

  describe "save round-trip" do
    it "writes the new scheme into theme1.xml through the gate" do
      doc = build_document
      doc.apply_font_scheme("carlito_sans")
      doc.apply_color_scheme("emerald")
      path = File.join(output_dir, "schemes.docx")
      doc.save(path)

      theme_xml = Zip::File.open(path) { |z| z.read("word/theme/theme1.xml") }
      expect(theme_xml).to include('typeface="Carlito"')
      expect(theme_xml).to include('val="2D6A4F"')
    end
  end
end
