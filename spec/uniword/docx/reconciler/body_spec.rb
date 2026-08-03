# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler do
  describe "existing value preservation (||= pattern)" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }

    it "preserves pre-existing rsidR on paragraphs" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new(
        rsid_r: "AABBCCDD",
        rsid_r_default: "11223344",
        para_id: "DEADBEEF",
        text_id: "CAFEBABE",
      )
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Hello")
      para.runs << run
      package.document.body.paragraphs << para

      described_class.new(package, profile: profile).reconcile

      expect(para.rsid_r).to eq("AABBCCDD")
      expect(para.rsid_r_default).to eq("11223344")
      expect(para.para_id).to eq("DEADBEEF")
      expect(para.text_id).to eq("CAFEBABE")
    end

    it "preserves pre-existing section properties rsidR" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Hello")
      para.runs << run
      package.document.body.paragraphs << para
      package.document.body.section_properties =
        Uniword::Wordprocessingml::SectionProperties.new(
          rsid_r: "FFEEDDCC",
          page_size: Uniword::Wordprocessingml::PageSize.new(
            width: 12_240, height: 15_840
          ),
        )

      described_class.new(package, profile: profile).reconcile

      expect(package.document.body.section_properties.rsid_r).to eq("FFEEDDCC")
    end
  end

  describe "headers/footers reconciliation" do
    let(:header_class) { Uniword::Wordprocessingml::Header }
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:run_props_class) { Uniword::Wordprocessingml::RunProperties }
    let(:text_class) { Uniword::Wordprocessingml::Text }

    def build_package_with_headers
      package = Uniword::Docx::Package.new
      header = header_class.new
      para = Uniword::Wordprocessingml::Paragraph.new
      props = Uniword::Wordprocessingml::ParagraphProperties.new
      props.alignment = Uniword::Properties::Alignment.new(val: "right")
      para.properties = props

      run = run_class.new
      run.properties = run_props_class.new
      para.runs << run

      header.paragraphs << para
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.headers = { "default" => header }
      package
    end

    it "strips empty runs from header paragraphs" do
      package = build_package_with_headers
      described_class.new(package).reconcile

      header = package.document.headers["default"]
      expect(header.paragraphs.first.runs).to be_empty
    end

    it "preserves runs that have text content" do
      package = build_package_with_headers
      run = run_class.new
      run.text = text_class.new(content: "Header text")
      package.document.headers["default"].paragraphs.first.runs << run

      described_class.new(package).reconcile

      header = package.document.headers["default"]
      expect(header.paragraphs.first.runs.size).to eq(1)
    end
  end
end
