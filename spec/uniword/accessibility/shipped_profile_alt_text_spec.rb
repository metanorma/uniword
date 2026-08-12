# frozen_string_literal: true

require "spec_helper"

# Alt text checked the way users actually get it: through the shipped
# wcag_2_1_aa profile (check_quality: true, require_alt_text: true,
# min_length: 10, max_length: 150) and through Quality::DocumentChecker's
# shipped rules. A rule configured by hand in a spec proves nothing about
# what ships.
templates = %w[
  word-template-apa-style-paper
  word-template-mla-style-paper
  word-template-paper-with-cover-and-toc
].freeze

RSpec.describe "image alt text through the shipped configuration" do
  def fixture(name)
    File.join(__dir__, "../../fixtures", name, "#{name}.docx")
  end

  def document(name)
    Uniword::Docx::Package.from_file(fixture(name)).document
  end

  def accessibility_image_violations(doc)
    Uniword::Accessibility::AccessibilityChecker.new
      .check(doc).violations
      .map(&:message).grep(/\AImage \d+ /)
  end

  def quality_image_violations(doc)
    Uniword::Quality::DocumentChecker.new
      .check(doc).violations
      .map(&:message).grep(/\AImage \d+ /)
  end

  # These three Microsoft templates each ship one picture whose description
  # sits in docPr/@title, with no @descr at all. Title is a caption, so the
  # image is undescribed and both checkers must say so — and say the same
  # number of times.
  templates.each do |name|
    context name do
      let(:doc) { document(name) }

      it "reports the title-only picture as missing alt text" do
        expect(accessibility_image_violations(doc))
          .to eq(["Image 1 missing alternative text"])
      end

      it "makes the quality checker agree with the accessibility checker" do
        expect(quality_image_violations(doc).size)
          .to eq(accessibility_image_violations(doc).size)
      end

      it "never calls a caption in @title generic alt text" do
        expect(accessibility_image_violations(doc))
          .to all(satisfy { |m| !m.include?("generic alt text") })
      end

      it "points the author at the title field it found the text in" do
        suggestions = Uniword::Accessibility::AccessibilityChecker.new
          .check(doc).violations
          .select { |v| v.message.to_s.start_with?("Image 1 ") }
          .map(&:suggestion)

        expect(suggestions).to all(include("title"))
      end
    end
  end

  describe "a picture that does carry a description" do
    let(:doc) do
      Uniword::Wordprocessingml::DocumentRoot.from_xml(<<~XML)
        <w:document
          xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
          xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
          <w:body>
            <w:p><w:r><w:drawing><wp:inline>
              <wp:docPr id="1" name="Picture 1"
                        descr="A leaf resting on rough tree bark"/>
            </wp:inline></w:drawing></w:r></w:p>
          </w:body>
        </w:document>
      XML
    end

    it "passes both checkers" do
      aggregate_failures do
        expect(accessibility_image_violations(doc)).to be_empty
        expect(quality_image_violations(doc)).to be_empty
      end
    end
  end

  describe "an image inside a table cell" do
    let(:doc) do
      Uniword::Wordprocessingml::DocumentRoot.from_xml(<<~XML)
        <w:document
          xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
          xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
          <w:body>
            <w:tbl><w:tr><w:tc>
              <w:p><w:r><w:drawing><wp:inline>
                <wp:docPr id="1" name="Picture 1"/>
              </wp:inline></w:drawing></w:r></w:p>
            </w:tc></w:tr></w:tbl>
          </w:body>
        </w:document>
      XML
    end

    # The renderer emits a table-nested picture, so a checker that walks only
    # top-level paragraphs reports a clean document that is not clean.
    it "is visible to both checkers" do
      aggregate_failures do
        expect(doc.images.size).to eq(1)
        expect(accessibility_image_violations(doc).size).to eq(1)
        expect(quality_image_violations(doc).size).to eq(1)
      end
    end
  end
end
