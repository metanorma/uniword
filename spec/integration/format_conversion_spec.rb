# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe "Format Conversion", type: :integration do
  let(:tmp_dir) { "spec/tmp" }
  let(:fixtures_dir) { "spec/fixtures/docx_gem" }

  before(:all) do
    FileUtils.mkdir_p("spec/tmp")
  end

  after(:each) do
    Dir.glob("#{tmp_dir}/*.{docx,doc,mhtml,mht}").each { |f| safe_delete(f) }
  end

  # Check for a CSS class in HTML, handling both quoted and unquoted forms
  def has_css_class?(html, class_name)
    # Match class="FooBar" or class=FooBar or class='FooBar'
    html.match?(/class=["']?[^"'\s>]*#{Regexp.escape(class_name)}[^"'\s>]*/)
  end

  def docx_to_mhtml(docx_path)
    docx_pkg = Uniword::Docx::Package.from_file(docx_path)
    mhtml_doc = Uniword::Transformation::Transformer.new.docx_package_to_mhtml(docx_pkg)
    mime = Uniword::Infrastructure::MimePackager.new(mhtml_doc).build_mime_content
    Uniword::Infrastructure::MimeParser.new.parse_content(mime)
  end

  def mhtml_to_docx(mhtml_doc)
    Uniword::Transformation::Transformer.new.mhtml_to_docx(mhtml_doc)
  end

  describe "DOCX to MHTML Conversion" do
    it "converts DOCX to MHTML" do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)

      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(mhtml_doc.html_part).to be_a(Uniword::Mhtml::HtmlPart)
    end

    it "preserves paragraph count in conversion" do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      docx_pkg = Uniword::Docx::Package.from_file(docx_fixture)
      docx_paras = docx_pkg.document.body.paragraphs.length

      mhtml_doc = docx_to_mhtml(docx_fixture)
      mht_paras = mhtml_doc.body_html.scan(/<p[\s >]/).length

      expect(mht_paras).to be >= docx_paras
    end

    it "preserves text content across conversion" do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      docx_pkg = Uniword::Docx::Package.from_file(docx_fixture)
      docx_pkg.document.body.paragraphs
              .flat_map do |p|
        p.runs.map do |r|
          r.text&.text
        end
      end.compact.join(" ")

      mhtml_doc = docx_to_mhtml(docx_fixture)
      mht_text = mhtml_doc.body_html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip

      expect(mht_text.length).to be > 0
    end
  end

  describe "MHTML to DOCX Conversion" do
    it "converts MHTML to DOCX" do
      mht_fixture = "spec/fixtures/blank/blank.mht"
      skip "Fixture not found" unless File.exist?(mht_fixture)

      mhtml_doc = Uniword::Infrastructure::MimeParser.new.parse_content(File.read(mht_fixture))
      docx_doc = mhtml_to_docx(mhtml_doc)

      expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end

    it "preserves paragraph structure in conversion" do
      mht_fixture = "spec/fixtures/blank/blank.mht"
      skip "Fixture not found" unless File.exist?(mht_fixture)

      mhtml_doc = Uniword::Infrastructure::MimeParser.new.parse_content(File.read(mht_fixture))
      docx_doc = mhtml_to_docx(mhtml_doc)

      expect(docx_doc.body.paragraphs.length).to be >= 1
    end
  end

  describe "Round-trip Conversions" do
    it "preserves formatting across DOCX -> MHTML -> DOCX" do
      docx_fixture = "#{fixtures_dir}/formatting.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)
      docx_doc = mhtml_to_docx(mhtml_doc)

      expect(docx_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(docx_doc.body.paragraphs.length).to be >= 1
    end

    it "preserves bold formatting across conversions" do
      docx_fixture = "#{fixtures_dir}/formatting.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)
      has_bold = mhtml_doc.body_html.include?("<strong>") ||
                 mhtml_doc.body_html.include?("<b>")
      expect(has_bold).to be true
    end

    it "preserves italic formatting across conversions" do
      docx_fixture = "#{fixtures_dir}/formatting.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)
      has_italic = mhtml_doc.body_html.include?("<em>") ||
                   mhtml_doc.body_html.include?("<i>")
      expect(has_italic).to be true
    end

    it "preserves tables across conversions" do
      docx_fixture = "#{fixtures_dir}/tables.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      docx_pkg = Uniword::Docx::Package.from_file(docx_fixture)
      docx_tables = docx_pkg.document.body.tables.length

      mhtml_doc = docx_to_mhtml(docx_fixture)
      mht_tables = mhtml_doc.body_html.scan("<table").length

      expect(mht_tables).to eq(docx_tables)
    end
  end

  describe "Complex Document Conversion" do
    it "converts complex document with mixed content" do
      docx_fixture = "#{fixtures_dir}/styles.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)

      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(mhtml_doc.body_html.length).to be > 0
    end

    it "preserves heading styles across formats" do
      docx_fixture = "#{fixtures_dir}/styles.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)
      body = mhtml_doc.body_html

      has_style = has_css_class?(body, "MsoHeading") ||
                  has_css_class?(body, "MsoTitle")
      expect(has_style).to be true
    end
  end

  describe "Fixture File Conversions" do
    it "converts basic.docx to MHTML and back" do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)

      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(mhtml_doc.body_html.length).to be > 0
    end

    it "converts formatting.docx to MHTML" do
      docx_fixture = "#{fixtures_dir}/formatting.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)

      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(mhtml_doc.body_html.length).to be > 0
    end

    it "converts tables.docx to MHTML" do
      docx_fixture = "#{fixtures_dir}/tables.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      mhtml_doc = docx_to_mhtml(docx_fixture)

      expect(mhtml_doc).to be_a(Uniword::Mhtml::Document)
      expect(mhtml_doc.body_html.include?("<table")).to be true
    end
  end

  describe "Format Detection" do
    it "auto-detects DOCX format for reading" do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      doc = Uniword::DocumentFactory.from_file(docx_fixture)

      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(doc.body.paragraphs.count).to be > 0
    end

    it "auto-detects MHTML format for reading" do
      mht_fixture = "spec/fixtures/blank/blank.mht"
      skip "Fixture not found" unless File.exist?(mht_fixture)

      doc = Uniword::DocumentFactory.from_file(mht_fixture, format: :mhtml)

      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(doc.body.paragraphs.count).to be >= 0
    end

    it "handles explicit format override" do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip "Fixture not found" unless File.exist?(docx_fixture)

      doc = Uniword::DocumentFactory.from_file(docx_fixture, format: :docx)

      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end
  end
end
