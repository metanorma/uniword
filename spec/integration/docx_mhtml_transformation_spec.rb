# frozen_string_literal: true

require "spec_helper"

RSpec.describe "DOCX → MHT Transformation", type: :integration do
  INTEGRATION_FIXTURES = {
    "blank" => "spec/fixtures/blank/blank.docx",
    "apa" => "spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx",
    "mla" => "spec/fixtures/word-template-mla-style-paper/word-template-mla-style-paper.docx",
    "cover_toc" => "spec/fixtures/word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx",
  }.freeze

  def docx_to_mht(docx_path, doc_name = nil)
    docx_pkg = Uniword::Docx::Package.from_file(docx_path)
    Uniword::Transformation::Transformer.new.docx_package_to_mhtml(docx_pkg,
                                                                   doc_name)
  end

  def mht_to_string(mhtml_doc)
    Uniword::Infrastructure::MimePackager.new(mhtml_doc).build_mime_content
  end

  def parse_mht_string(mime_string)
    Uniword::Infrastructure::MimeParser.new.parse_content(mime_string)
  end

  describe "DOCX → MHT conversion for each fixture" do
    INTEGRATION_FIXTURES.each do |name, docx_path|
      describe name do
        let(:mhtml_doc) { docx_to_mht(docx_path, name) }
        let(:mime_string) { mht_to_string(mhtml_doc) }
        let(:reloaded_mht) { parse_mht_string(mime_string) }

        it "produces Mhtml::Document" do
          expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
        end

        it "has html_part" do
          expect(mhtml_doc.html_part).to be_a(Uniword::Mhtml::HtmlPart)
        end

        it "has valid body HTML with content" do
          expect(reloaded_mht.body_html).to be_a(String)
          expect(reloaded_mht.body_html.length).to be > 0
        end

        it "has at least one paragraph" do
          expect(reloaded_mht.body_html.scan("<p ").count).to be >= 1
        end

        it "produces valid MIME structure" do
          expect(mime_string).to start_with("MIME-Version: 1.0\r\n")
          expect(mime_string).to include("Content-Type: multipart/related")
          expect(mime_string).to include("Content-Type: text/html")
          expect(mime_string).to include("------=_NextPart_")
        end

        it "can be round-tripped (parse → serialize → parse)" do
          # The reloaded MHT should have the same body HTML content
          expect(reloaded_mht.body_html).to eq(mhtml_doc.body_html)
        end
      end
    end
  end

  describe "OoxmlToMhtmlConverter" do
    it "generates Mhtml::Document with html_part" do
      docx_pkg = Uniword::Docx::Package.from_file(INTEGRATION_FIXTURES["blank"])
      mhtml_doc = Uniword::Transformation::OoxmlToMhtmlConverter.document_to_mht(docx_pkg.document)

      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(mhtml_doc.html_part).to be_a(Uniword::Mhtml::HtmlPart)
      expect(mhtml_doc.html_part.raw_content).to include("<html")
      expect(mhtml_doc.html_part.raw_content).to include("</html>")
    end

    it "generates Word HTML4 with xmlns:w namespace" do
      docx_pkg = Uniword::Docx::Package.from_file(INTEGRATION_FIXTURES["blank"])
      mhtml_doc = Uniword::Transformation::OoxmlToMhtmlConverter.document_to_mht(docx_pkg.document)

      expect(mhtml_doc.html_part.raw_content).to include('xmlns:w="urn:schemas-microsoft-com:office:word"')
    end

    it "generates metadata comments" do
      docx_pkg = Uniword::Docx::Package.from_file(INTEGRATION_FIXTURES["blank"])
      mhtml_doc = Uniword::Transformation::OoxmlToMhtmlConverter.document_to_mht(docx_pkg.document)

      expect(mhtml_doc.html_part.raw_content).to include("<!--[if gte mso 9]>")
      expect(mhtml_doc.html_part.raw_content).to include("<o:DocumentProperties")
    end

    it "uses MsoNormal CSS class for default paragraphs" do
      docx_pkg = Uniword::Docx::Package.from_file(INTEGRATION_FIXTURES["blank"])
      mhtml_doc = Uniword::Transformation::OoxmlToMhtmlConverter.document_to_mht(docx_pkg.document)

      expect(mhtml_doc.html_part.raw_content).to include("class=MsoNormal")
    end

    it "preserves paragraph content from DOCX" do
      docx_pkg = Uniword::Docx::Package.from_file(INTEGRATION_FIXTURES["blank"])
      mhtml_doc = Uniword::Transformation::OoxmlToMhtmlConverter.document_to_mht(docx_pkg.document)

      # The body should contain the paragraph with non-breaking space
      expect(mhtml_doc.body_html).to include("<o:p>")
    end
  end

  describe "Transformation pipeline" do
    it "full pipeline: DOCX → MHT → parse back" do
      docx_pkg = Uniword::Docx::Package.from_file(INTEGRATION_FIXTURES["blank"])
      docx_pkg.document

      # Transform to MHT
      mhtml_doc = Uniword::Transformation::Transformer.new.docx_package_to_mhtml(
        docx_pkg, "blank"
      )

      # Serialize to MIME
      mime_string = Uniword::Infrastructure::MimePackager.new(mhtml_doc).build_mime_content

      # Parse back
      reloaded = Uniword::Infrastructure::MimeParser.new.parse_content(mime_string)

      # Verify key properties
      expect(reloaded).to be_a(Uniword::Mhtml::Document)
      expect(reloaded.html_part).to be_a(Uniword::Mhtml::HtmlPart)
      expect(reloaded.body_html).to include("MsoNormal")
    end
  end
end
