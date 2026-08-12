# frozen_string_literal: true

require "spec_helper"

# Alt text has to survive every hop: docPr/@descr -> Drawing#alt_text ->
# the rendered <img>.
RSpec.describe "alt text in rendered output" do
  templates = {
    "word-template-apa-style-paper" => nil,
    "word-template-mla-style-paper" => nil,
    "word-template-paper-with-cover-and-toc" => nil,
  }.freeze

  def package(name)
    Uniword::Docx::Package.from_file(
      File.join(__dir__, "../../fixtures", name, "#{name}.docx"),
    )
  end

  def html_for(pkg)
    Uniword::Transformation::Transformer.new
      .docx_package_to_mhtml(pkg, "doc").raw_html.to_s
  end

  describe "a real .docx whose pictures carry only a title" do
    templates.each_key do |name|
      it "renders #{name} images with no alt attribute" do
        html = html_for(package(name))
        imgs = html.scan(/<img [^>]*>/)

        aggregate_failures do
          expect(imgs).not_to be_empty
          # An empty alt claims the image is decorative. We have no grounds
          # for that claim, so the attribute stays off entirely.
          expect(imgs).to all(satisfy { |tag| !tag.include?("alt=") })
        end
      end
    end
  end

  describe "a built document with alt text" do
    let(:png) { File.join(__dir__, "../../fixtures/sample.png") }

    it "carries the description into the rendered img tag" do
      builder = Uniword::Builder::DocumentBuilder.new
      builder.image(png, alt_text: %(A "red" square & a leaf))

      drawing = builder.model.images.first
      renderer = Uniword::Transformation::MhtmlElementRenderer.new(
        nil, builder.model.image_parts
      )
      tag = renderer.drawing_to_html(drawing)

      aggregate_failures do
        expect(drawing.alt_text).to eq(%(A "red" square & a leaf))
        expect(tag).to include("alt=")
        expect(tag).to include("&amp;")
        expect(tag).to include("&quot;")
      end
    end
  end
end
