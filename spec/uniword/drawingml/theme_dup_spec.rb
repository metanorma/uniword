# frozen_string_literal: true

require "spec_helper"
require "zip"

# Regression: Drawingml::Theme#dup used to drop fmt_scheme (fill/line/
# effect lists), and the reconciler's fill repair used a nonexistent
# attribute kwarg — together producing theme1.xml with empty
# fillStyleLst that Word rejects as "unreadable content".
RSpec.describe Uniword::Drawingml::Theme, "#dup" do
  let(:word_theme) do
    friendly = Uniword::Themes::Theme.load("botanical")
    Uniword::Themes::ThemeTransformation.new.to_word(friendly)
  end

  it "preserves the format scheme fill lists" do
    copy = word_theme.dup

    fills = copy.theme_elements.fmt_scheme.fill_style_lst
    expect(fills.solid_fills.size).to eq(1)
    expect(fills.gradient_fills.size).to eq(2)
    expect(fills.gradient_fills.first.gs_lst.gradient_stops.size).to be > 0
  end

  it "preserves color and font schemes" do
    copy = word_theme.dup

    expect(copy.theme_elements.clr_scheme.name).to eq("Botanical")
    fonts = copy.theme_elements.font_scheme
    expect(fonts.major_font_obj.latin.typeface).to eq("EB Garamond")
  end

  it "produces an independent copy" do
    copy = word_theme.dup

    copy.theme_elements.fmt_scheme.fill_style_lst
      .solid_fills.first.scheme_clr.val = "accent5"

    original = word_theme.theme_elements.fmt_scheme.fill_style_lst
    expect(original.solid_fills.first.scheme_clr.val).not_to eq("accent5")
  end
end

RSpec.describe "theme apply fill-list regression" do
  let(:output_dir) { "tmp/theme_dup_regression" }
  let(:path) { File.join(output_dir, "themed.docx") }

  before { FileUtils.mkdir_p(output_dir) }

  after { Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) } }

  it "emits schema-complete fillStyleLst through apply + save" do
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph { |p| p << "themed" }
    doc.model.apply_theme("botanical")
    doc.save(path)

    theme_xml = Zip::File.open(path) { |z| z.read("word/theme/theme1.xml") }
    fills = theme_xml[/<a:fillStyleLst>.*<\/a:fillStyleLst>/m]
    expect(fills).to include("gradFill")
    expect(fills).to include("schemeClr")
    expect(fills).not_to include("<a:solidFill/>")
  end
end

RSpec.describe "theme fill repair carries colors" do
  it "tops up solid fills with schemeClr children" do
    package = Uniword::Docx::Package.new
    package.document = Uniword::Wordprocessingml::DocumentRoot.new
    package.document.body = Uniword::Wordprocessingml::Body.new
    package.document.body.paragraphs <<
      Uniword::Wordprocessingml::Paragraph.new
    theme = Uniword::Drawingml::Theme.new
    theme.theme_elements.fmt_scheme.fill_style_lst =
      Uniword::Drawingml::FillStyleList.new
    package.theme = theme

    Uniword::Docx::Reconciler.new(package).reconcile

    fills = theme.theme_elements.fmt_scheme.fill_style_lst.solid_fills
    expect(fills.size).to be >= 2
    expect(fills.map { |f| f.scheme_clr&.val }).to all(match(/\Aaccent\d\z/))
  end
end
