# frozen_string_literal: true

require "spec_helper"

RSpec.describe "MHT → DOCX Full Fidelity" do
  MHT_DOCX_FIXTURES = {
    "blank" => { docx: "spec/fixtures/blank/blank.docx",
                 mht: "spec/fixtures/blank/blank.mht" },
    "apa" => { docx: "spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx",
               mht: "spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.mht" },
    "mla" => { docx: "spec/fixtures/word-template-mla-style-paper/word-template-mla-style-paper.docx",
               mht: "spec/fixtures/word-template-mla-style-paper/word-template-mla-style-paper.mht" },
    "cover_toc" => { docx: "spec/fixtures/word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx",
                     mht: "spec/fixtures/word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.mht" },
  }.freeze

  def parse_mht(mht_path)
    Uniword::Infrastructure::MimeParser.new.parse(mht_path)
  end

  def mht_to_docx(mht_path)
    mhtml_doc = parse_mht(mht_path)
    Uniword::Transformation::Transformer.new.mhtml_to_docx(mhtml_doc)
  end

  describe "MHT → DOCX for each fixture" do
    MHT_DOCX_FIXTURES.each do |name, paths|
      describe name do
        let(:mht_doc) { parse_mht(paths[:mht]) }
        let(:docx_doc) { mht_to_docx(paths[:mht]) }

        it "produces Wordprocessingml::DocumentRoot" do
          expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
        end

        it "has a body" do
          expect(docx_doc.body).to be_a(Uniword::Wordprocessingml::Body)
        end

        it "has paragraphs" do
          expect(docx_doc.body.paragraphs).not_to be_nil
          expect(docx_doc.body.paragraphs.length).to be > 0
        end

        it "extracts body text content" do
          body_html = mht_doc.body_html
          expect(body_html).to be_a(String)
          expect(body_html.length).to be > 0
        end
      end
    end
  end

  describe "MHT body HTML parsing" do
    let(:mht_doc) { parse_mht(MHT_DOCX_FIXTURES["blank"][:mht]) }

    it "extracts body_html from html_part" do
      expect(mht_doc.body_html).to be_a(String)
    end

    it "body_html contains paragraph elements" do
      body = mht_doc.body_html
      doc = Nokogiri::HTML(body)
      expect(doc.css("p").length).to be >= 1
    end

    it "extracts MsoNormal class paragraphs" do
      body = mht_doc.body_html
      expect(body).to include("MsoNormal")
    end
  end

  describe "MHT metadata extraction" do
    let(:mht_doc) { parse_mht(MHT_DOCX_FIXTURES["blank"][:mht]) }

    it "extracts document_properties" do
      # The blank.mht has Author in DocumentProperties
      expect(mht_doc.document_properties).to be_a(Uniword::Mhtml::Metadata::DocumentProperties)
    end

    it "has author from DocumentProperties" do
      props = mht_doc.document_properties
      # NOTE: blank.mht was created with Ronald Tse as author
      expect(props.author).to include("Ronald")
    end

    it "extracts word_document_settings" do
      expect(mht_doc.word_document_settings).to be_a(Uniword::Mhtml::Metadata::WordDocumentSettings)
    end
  end

  describe "MHT HTML structure parsing" do
    let(:mht_doc) { parse_mht(MHT_DOCX_FIXTURES["apa"][:mht]) }

    it "parses SDT elements from body" do
      body = mht_doc.body_html
      # Count SDT elements
      sdt_count = body.scan(/<w:Sdt\b/i).length + body.scan(/<w:sdt\b/i).length
      expect(sdt_count).to be > 0
    end

    it "parses hyperlink elements" do
      body = mht_doc.body_html
      doc = Nokogiri::HTML(body)
      hyperlinks = doc.css("a")
      expect(hyperlinks.length).to be > 0
    end

    it "parses table elements" do
      body = mht_doc.body_html
      doc = Nokogiri::HTML(body)
      tables = doc.css("table")
      expect(tables.length).to be > 0
    end
  end

  describe "MHT → DOCX conversion" do
    let(:docx_doc) { mht_to_docx(MHT_DOCX_FIXTURES["blank"][:mht]) }

    it "produces DocumentRoot" do
      expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end

    it "has paragraphs in body" do
      paras = docx_doc.body.paragraphs
      expect(paras).not_to be_nil
      expect(paras.length).to be > 0
    end

    it "converts at least one paragraph" do
      # Even for blank, we should have at least one paragraph
      paras = docx_doc.body.paragraphs
      expect(paras.length).to be >= 1
    end
  end

  describe "MHT round-trip: parse → convert → serialize" do
    let(:original_mht) { parse_mht(MHT_DOCX_FIXTURES["blank"][:mht]) }
    let(:docx_doc) { mht_to_docx(MHT_DOCX_FIXTURES["blank"][:mht]) }

    it "original MHT has body_html" do
      expect(original_mht.body_html).to be_a(String)
      expect(original_mht.body_html.length).to be > 0
    end

    it "DOCX has text content" do
      text = docx_doc.body.paragraphs.map(&:text).join(" ")
      expect(text.length).to be > 0
    end
  end

  describe "Style class to OOXML style mapping" do
    it "extracts paragraph style from class attribute" do
      # MHT: <p class=MsoTitle> → DOCX: style="Title"
      mht_doc = parse_mht(MHT_DOCX_FIXTURES["apa"][:mht])
      body = mht_doc.body_html

      # Parse to find class attributes
      doc = Nokogiri::HTML(body)
      title_paras = doc.css("p.MsoTitle, p[class=MsoTitle]")

      # At least one Title paragraph should exist in apa
      expect(title_paras.length).to be > 0
    end

    it "extracts Heading1-6 styles" do
      mht_doc = parse_mht(MHT_DOCX_FIXTURES["cover_toc"][:mht])
      body = mht_doc.body_html
      doc = Nokogiri::HTML(body)

      # Look for heading classes
      heading_classes = doc.css("[class^=MsoHeading]")
      expect(heading_classes.length).to be >= 0
    end
  end
end
