# frozen_string_literal: true

require "spec_helper"

RSpec.describe "MHT → DOCX Content Matching" do
  # These fixtures represent real Word documents saved as MHT
  MHT_FIXTURES = {
    "blank" => "spec/fixtures/blank/blank.mht",
    "apa" => "spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.mht",
    "mla" => "spec/fixtures/word-template-mla-style-paper/word-template-mla-style-paper.mht",
    "cover_toc" => "spec/fixtures/word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.mht"
  }.freeze

  # Expected counts from DOCX source analysis
  DOCX_SOURCE_COUNTS = {
    "blank" => { paragraphs: 1, tables: 0 },
    "apa" => { paragraphs: 21, tables: 1 },
    "mla" => { paragraphs: 11, tables: 1 },
    "cover_toc" => { paragraphs: 7, tables: 1 }
  }.freeze

  # Helper: Parse MHT body HTML
  def parse_mht_body(mht_path)
    content = File.read(mht_path)
    if content =~ %r{<body[^>]*>(.*?)</body>}im
      Regexp.last_match(1)
    else
      ""
    end
  end

  # Helper: Count paragraphs in HTML
  def count_paragraphs(html)
    return 0 unless html

    doc = Nokogiri::HTML(html)
    doc.css("p, h1, h2, h3, h4, h5, h6, li, div").length
  end

  # Helper: Count tables in HTML
  def count_tables(html)
    return 0 unless html

    doc = Nokogiri::HTML(html)
    doc.css("table").length
  end

  # Helper: Strip tags to get text
  def strip_tags(html)
    return "" unless html

    html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
  end

  # Convert MHT to DOCX
  def mht_to_docx(mht_path)
    mht_doc = Uniword::Mhtml::MhtmlPackage.from_file(mht_path)
    Uniword::Transformation::Transformer.new.mhtml_to_docx(mht_doc)
  end

  describe "blank fixture" do
    let(:mht_path) { MHT_FIXTURES["blank"] }
    let(:mht_body) { parse_mht_body(mht_path) }
    let(:docx_doc) { mht_to_docx(mht_path) }
    let(:expected) { DOCX_SOURCE_COUNTS["blank"] }

    it "creates DocumentRoot with body" do
      expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(docx_doc.body).not_to be_nil
    end

    it "has paragraphs" do
      para_count = docx_doc.body.paragraphs.count
      expect(para_count).to be >= expected[:paragraphs],
                            "Expected at least #{expected[:paragraphs]} paragraphs, got #{para_count}"
    end

    it "has expected table count" do
      table_count = docx_doc.body.tables.count
      expect(table_count).to eq(expected[:tables])
    end

    it "body has non-empty text" do
      text = docx_doc.body.paragraphs.map(&:text).join(" ")
      expect(text.length).to be > 0
    end
  end

  describe "apa fixture" do
    let(:mht_path) { MHT_FIXTURES["apa"] }
    let(:mht_body) { parse_mht_body(mht_path) }
    let(:docx_doc) { mht_to_docx(mht_path) }
    let(:expected) { DOCX_SOURCE_COUNTS["apa"] }

    it "creates DocumentRoot with body" do
      expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(docx_doc.body).not_to be_nil
    end

    it "has paragraphs" do
      para_count = docx_doc.body.paragraphs.count
      expect(para_count).to be >= expected[:paragraphs],
                            "Expected at least #{expected[:paragraphs]} paragraphs, got #{para_count}"
    end

    it "has tables" do
      table_count = docx_doc.body.tables.count
      expect(table_count).to eq(expected[:tables])
    end

    it "body has substantial text" do
      text = docx_doc.body.paragraphs.map(&:text).join(" ")
      expect(text.length).to be > 100
    end

    it "parses MHT body successfully" do
      expect(mht_body.length).to be > 0
    end
  end

  describe "mla fixture" do
    let(:mht_path) { MHT_FIXTURES["mla"] }
    let(:mht_body) { parse_mht_body(mht_path) }
    let(:docx_doc) { mht_to_docx(mht_path) }
    let(:expected) { DOCX_SOURCE_COUNTS["mla"] }

    it "creates DocumentRoot with body" do
      expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(docx_doc.body).not_to be_nil
    end

    it "has paragraphs" do
      para_count = docx_doc.body.paragraphs.count
      expect(para_count).to be >= expected[:paragraphs],
                            "Expected at least #{expected[:paragraphs]} paragraphs, got #{para_count}"
    end

    it "has tables" do
      table_count = docx_doc.body.tables.count
      expect(table_count).to eq(expected[:tables])
    end

    it "body has substantial text" do
      text = docx_doc.body.paragraphs.map(&:text).join(" ")
      expect(text.length).to be > 100
    end
  end

  describe "cover_toc fixture" do
    let(:mht_path) { MHT_FIXTURES["cover_toc"] }
    let(:mht_body) { parse_mht_body(mht_path) }
    let(:docx_doc) { mht_to_docx(mht_path) }
    let(:expected) { DOCX_SOURCE_COUNTS["cover_toc"] }

    it "creates DocumentRoot with body" do
      expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(docx_doc.body).not_to be_nil
    end

    it "has paragraphs" do
      para_count = docx_doc.body.paragraphs.count
      expect(para_count).to be >= expected[:paragraphs],
                            "Expected at least #{expected[:paragraphs]} paragraphs, got #{para_count}"
    end

    it "has tables" do
      table_count = docx_doc.body.tables.count
      expect(table_count).to eq(expected[:tables])
    end

    it "body has substantial text" do
      text = docx_doc.body.paragraphs.map(&:text).join(" ")
      expect(text.length).to be > 50
    end
  end

  describe "All fixtures content validation" do
    MHT_FIXTURES.each do |name, mht_path|
      describe name do
        let(:mht_body) { parse_mht_body(mht_path) }
        let(:docx_doc) { mht_to_docx(mht_path) }

        it "converts MHT to DOCX successfully" do
          expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
        end

        it "has paragraphs in body" do
          expect(docx_doc.body.paragraphs.count).to be > 0
        end

        it "paragraphs have text content" do
          texts = docx_doc.body.paragraphs.map(&:text).reject(&:empty?)
          expect(texts.length).to be > 0
        end
      end
    end
  end
end
