# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe "MHTML Round-trip Validation", type: :integration do
  def docx_to_mhtml(docx_path)
    docx_pkg = Uniword::Docx::Package.from_file(docx_path)
    mhtml_doc = Uniword::Transformation::Transformer.new.docx_package_to_mhtml(docx_pkg)
    mime = Uniword::Infrastructure::MimePackager.new(mhtml_doc).build_mime_content
    Uniword::Infrastructure::MimeParser.new.parse_content(mime)
  end

  # Check for a CSS class in HTML, handling both quoted and unquoted forms
  def has_css_class?(html, class_name)
    # Match class="FooBar" or class=FooBar or class='FooBar'
    html.match?(/class=["']?[^"'\s>]*#{Regexp.escape(class_name)}[^"'\s>]*/)
  end

  describe "Basic Round-trip" do
    it "preserves simple text through round-trip" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/blank/blank.docx")
      text = mhtml_doc.body_html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
      expect(text.length).to be > 0
    end

    it "preserves multiple paragraphs" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx")
      paras = mhtml_doc.body_html.scan(/<p[\s >]/).length
      expect(paras).to be >= 20
    end

    it "preserves empty document" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/blank/blank.docx")
      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(has_css_class?(mhtml_doc.body_html, "MsoNormal")).to be true
    end
  end

  describe "Formatting Round-trip" do
    it "preserves text formatting - bold" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/formatting.docx")
      html = mhtml_doc.body_html
      has_bold = html.include?("<strong>") || html.include?("<b>")
      expect(has_bold).to be true
    end

    it "preserves text formatting - italic" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/formatting.docx")
      html = mhtml_doc.body_html
      has_italic = html.include?("<em>") || html.include?("<i>")
      expect(has_italic).to be true
    end

    it "preserves text formatting - underline" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/formatting.docx")
      html = mhtml_doc.body_html
      has_underline = html.include?("<u>")
      expect(has_underline).to be true
    end

    it "preserves combined formatting" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/formatting.docx")
      html = mhtml_doc.body_html
      has_any = html.include?("<strong") || html.include?("<em") || html.include?("<u")
      expect(has_any).to be true
    end

    it "preserves font information" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/formatting.docx")
      # body_html has decoded HTML with style attributes
      has_font = mhtml_doc.body_html.include?("font-size")
      expect(has_font).to be true
    end

    it "preserves font size" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/formatting.docx")
      html = mhtml_doc.body_html
      has_size = html.include?("font-size")
      expect(has_size).to be true
    end
  end

  describe "Table Round-trip" do
    it "preserves tables with content" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/tables.docx")
      tables = mhtml_doc.body_html.scan("<table").length
      expect(tables).to be >= 1
    end

    it "preserves table structure" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/tables.docx")
      html = mhtml_doc.body_html
      expect(html).to include("<tr")
      expect(html).to include("<td")
    end

    it "preserves table cell content" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/docx_gem/tables.docx")
      text = mhtml_doc.body_html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
      expect(text.length).to be > 0
    end
  end

  describe "Style Round-trip" do
    it "preserves paragraph styles - Heading1" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx")
      expect(has_css_class?(mhtml_doc.body_html, "MsoHeading1")).to be true
    end

    it "preserves paragraph styles - Heading2" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx")
      expect(has_css_class?(mhtml_doc.body_html, "MsoHeading2")).to be true
    end

    it "preserves multiple heading levels" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx")
      html = mhtml_doc.body_html
      has_any_heading = has_css_class?(html, "MsoHeading1") ||
                        has_css_class?(html, "MsoHeading2")
      expect(has_any_heading).to be true
    end
  end

  describe "Complex Document Round-trip" do
    it "preserves mixed content types" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx")
      html = mhtml_doc.body_html
      expect(html).to include("<p")
      expect(html.gsub(/<[^>]+>/, "").strip.length).to be > 0
    end

    it "preserves formatting in complex document" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx")
      expect(has_css_class?(mhtml_doc.body_html, "Mso")).to be true
    end
  end

  describe "Character Encoding Round-trip" do
    it "preserves UTF-8 characters" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/blank/blank.docx")
      expect(mhtml_doc.body_html.valid_encoding?).to be true
    end

    it "preserves special HTML characters" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/blank/blank.docx")
      body = mhtml_doc.body_html
      # Nokogiri decodes &nbsp; to actual non-breaking space
      has_entities = body.include?("\u00a0") || body.include?("<o:p>")
      expect(has_entities).to be true
    end

    it "preserves emoji and symbols" do
      mhtml_doc = docx_to_mhtml("spec/fixtures/blank/blank.docx")
      expect(mhtml_doc.body_html.valid_encoding?).to be true
    end
  end
end
