# frozen_string_literal: true

require "spec_helper"
require "zip"

# Theme-application resilience harness: every bundled theme applied to
# a document must save through the write-time gate and produce a
# schema-complete theme1.xml (fillStyleLst/bgFillStyleLst with real
# fills). Locks in the Theme#dup fmt_scheme fix — a regression here is
# exactly what made Word reject themed documents.
RSpec.describe "apply every bundled theme (resilience sweep)" do
  let(:output_dir) { "tmp/theme_sweep" }

  before { FileUtils.mkdir_p(output_dir) }

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  def build_document
    Uniword::Builder::DocumentBuilder.new.tap do |doc|
      doc.heading("Sweep", level: 1)
      doc.paragraph { |p| p << "body" }
    end
  end

  Uniword::Themes::Theme.available_themes.each do |name|
    it "applies and saves '#{name}' with complete fills" do
      path = File.join(output_dir, "sweep_#{name}.docx")
      doc = build_document
      doc.model.apply_theme(name)
      doc.save(path) # raises ValidationError if the gate rejects

      theme_xml = Zip::File.open(path) { |z| z.read("word/theme/theme1.xml") }
      fills = theme_xml[/<a:fillStyleLst>.*<\/a:fillStyleLst>/m]
      bg_fills = theme_xml[/<a:bgFillStyleLst>.*<\/a:bgFillStyleLst>/m]

      expect(fills).to match(/schemeClr|srgbClr|sysClr/)
      expect(fills).not_to include("<a:solidFill/>")
      expect(bg_fills).not_to include("<a:solidFill/>")
    end
  end
end
