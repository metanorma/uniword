# frozen_string_literal: true

require "spec_helper"
require "zip"

# StyleSet-application resilience harness: every bundled StyleSet
# applied to a document must save through the write-time gate and
# produce a valid styles.xml — same sweep philosophy as the theme
# apply harness (theme_apply_sweep_spec.rb).
RSpec.describe "apply every bundled StyleSet (resilience sweep)" do
  let(:output_dir) { "tmp/styleset_sweep" }

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

  Uniword::Stylesets::YamlStyleSetLoader.available_stylesets.each do |name|
    it "applies and saves '#{name}'" do
      path = File.join(output_dir, "sweep_#{name}.docx")
      doc = build_document
      doc.model.apply_styleset(name)
      doc.save(path) # raises ValidationError if the gate rejects

      styles_xml = Zip::File.open(path) { |z| z.read("word/styles.xml") }
      expect(styles_xml.size).to be > 1000
      expect(styles_xml).to include("<w:style ")
    end
  end
end
