# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "zip"

# This file is a guard, not coverage of any one implementation. An id
# allocator was once written to solve the problem below and then reverted in
# favour of the existing deterministic scheme, which already satisfies it —
# so these examples pass both with and without that allocator, by design.
# They exist to fail if a future change reintroduces colliding ids.
#
# ECMA-376 §20.4.2.5 requires wp:docPr/@id unique inside a part. Word treats a
# duplicate as a repair-triggering error, so an id scheme that counts from 1
# collides with the ids a template already carries.
#
# The APA template ships with one drawing whose docPr id is 2, which makes it
# the cheapest fixture to catch that.
RSpec.describe "wp:docPr ids when editing a document that already has drawings" do
  let(:template) do
    File.join(__dir__, "../../fixtures/word-template-apa-style-paper",
              "word-template-apa-style-paper.docx")
  end
  let(:png) { File.join(__dir__, "../../fixtures/sample.png") }
  let(:other_png) { File.join(__dir__, "../../fixtures/docx_gem/replacement.png") }

  def doc_pr_ids(root)
    root.images
      .filter_map { |drawing| (drawing.inline || drawing.anchor)&.doc_properties&.id }
      .map(&:to_s)
  end

  it "does not reuse an id the template already spent" do
    root = Uniword.load(template)
    expect(doc_pr_ids(root)).to include("2")

    manager = Uniword::Images::ImageManager.new(root)
    manager.insert(png, description: "first")
    manager.insert(other_png, description: "second")

    ids = doc_pr_ids(root)
    expect(ids.uniq.size).to eq(ids.size)
  end

  it "gives two floating images of different files different ids" do
    root = Uniword.load(template)

    ids = [png, other_png].map do |path|
      Uniword::Builder::ImageBuilder
        .create_floating(root, path).anchor.doc_properties.id
    end

    expect(ids.uniq.size).to eq(2)
  end

  it "writes unique ids all the way to the saved package" do
    root = Uniword.load(template)
    manager = Uniword::Images::ImageManager.new(root)
    manager.insert(png, description: "first")
    manager.insert(other_png, description: "second")

    Dir.mktmpdir do |dir|
      out = File.join(dir, "edited.docx")
      Uniword::DocumentWriter.new(root).save(out, validate: false)

      xml = Zip::File.open(out) { |zip| zip.read("word/document.xml") }
      ids = xml.scan(/<wp:docPr\b[^>]*\bid="([^"]+)"/).flatten

      expect(ids.size).to be >= 3
      expect(ids.uniq.size).to eq(ids.size)
    end
  end
end
