# frozen_string_literal: true

require "spec_helper"

# Referential integrity: allocator (builder) and legacy (template) paths
# repair dangling references identically — repair-by-stripping on both.
RSpec.describe "Reconciler referential integrity" do
  let(:reconciler_class) { Uniword::Docx::Reconciler }

  let(:document_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:body><w:p><w:hyperlink r:id="rId77"><w:r><w:t>dangling link</w:t></w:r></w:hyperlink><w:r><w:drawing><wp:inline><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:blipFill><a:blip r:embed="rId99"/></pic:blipFill></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p></w:body></w:document>
    XML
  end

  # Builds a package holding the same dangling-references document,
  # optionally with a populated allocator (builder path).
  def build_package(with_allocator:)
    package = Uniword::Docx::Package.new
    package.document = Uniword::Wordprocessingml::DocumentRoot.from_xml(
      document_xml,
    )
    package.document_rels = Uniword::Docx::Package.minimal_document_rels
    package.populate_allocator if with_allocator
    package
  end

  describe "allocator path vs legacy path" do
    it "strips the dangling hyperlink on both paths" do
      legacy = build_package(with_allocator: false)
      reconciler_class.new(legacy).reconcile

      builder = build_package(with_allocator: true)
      reconciler_class.new(builder).reconcile

      legacy_hls = legacy.document.body.paragraphs.flat_map(&:hyperlinks)
      builder_hls = builder.document.body.paragraphs.flat_map(&:hyperlinks)
      expect(legacy_hls).to be_empty
      expect(builder_hls).to be_empty
    end

    it "removes the dangling drawing on both paths" do
      legacy = build_package(with_allocator: false)
      reconciler_class.new(legacy).reconcile

      builder = build_package(with_allocator: true)
      reconciler_class.new(builder).reconcile

      legacy_drawings = legacy.document.body.paragraphs
        .flat_map(&:runs).flat_map(&:drawings)
      builder_drawings = builder.document.body.paragraphs
        .flat_map(&:runs).flat_map(&:drawings)
      expect(legacy_drawings).to be_empty
      expect(builder_drawings).to be_empty
    end

    it "records the same referential fixes on both paths" do
      legacy = build_package(with_allocator: false)
      legacy_reconciler = reconciler_class.new(legacy)
      legacy_reconciler.reconcile

      builder = build_package(with_allocator: true)
      builder_reconciler = reconciler_class.new(builder)
      builder_reconciler.reconcile

      referential = %w[R17 R18 R19 R20 R21 R22 R23 R32]
      legacy_codes = legacy_reconciler.applied_fixes.map(&:code) & referential
      builder_codes = builder_reconciler.applied_fixes.map(&:code) & referential
      expect(legacy_codes.sort).to eq(builder_codes.sort)
      expect(legacy_codes).to include("R21", "R23")
    end
  end

  describe "image reference repair" do
    it "keeps drawings whose r:embed resolves" do
      package = build_package(with_allocator: false)
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId99",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
          target: "media/image1.png",
        )

      reconciler_class.new(package).reconcile

      drawings = package.document.body.paragraphs
        .flat_map(&:runs).flat_map(&:drawings)
      expect(drawings.size).to eq(1)
    end

    it "keeps drawings without embed references" do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:body><w:p><w:r><w:drawing><wp:inline><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:blipFill><a:blip/></pic:blipFill></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p></w:body></w:document>
      XML
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      package.document_rels = Uniword::Docx::Package.minimal_document_rels

      reconciler_class.new(package).reconcile

      drawings = package.document.body.paragraphs
        .flat_map(&:runs).flat_map(&:drawings)
      expect(drawings.size).to eq(1)
    end
  end

  describe "relationship target repair" do
    let(:rel_class) { Uniword::Ooxml::Relationships::Relationship }

    def build_target_package(with_allocator: false)
      package = Uniword::Docx::Package.new
      package.document = target_document
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package.populate_allocator if with_allocator
      package
    end

    def target_document
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      doc.body = Uniword::Wordprocessingml::Body.new
      doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(content: "body"),
        )],
      )
      doc
    end

    it "strips document rels to parts the package does not carry" do
      [false, true].each do |with_allocator|
        package = build_target_package(with_allocator: with_allocator)
        package.document_rels.relationships << rel_class.new(
          id: "rId42",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml",
          target: "../docProps/meta.xml",
        )

        reconciler_class.new(package).reconcile

        targets = package.document_rels.relationships.map(&:target)
        expect(targets).not_to include("../docProps/meta.xml")
      end
    end

    it "records the repair with the .rels part path" do
      package = build_target_package
      package.document_rels.relationships << rel_class.new(
        id: "rId42",
        type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml",
        target: "../docProps/meta.xml",
      )

      reconciler = reconciler_class.new(package)
      reconciler.reconcile

      fix = reconciler.applied_fixes.find { |f| f.code == "R32" }
      expect(fix).not_to be_nil
      expect(fix.part).to eq("word/_rels/document.xml.rels")
      expect(fix.message).to include("../docProps/meta.xml")
    end

    it "keeps external relationships" do
      package = build_target_package
      package.document_rels.relationships << rel_class.new(
        id: "rId50",
        type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
        target: "https://example.com",
        target_mode: "External",
      )

      reconciler_class.new(package).reconcile

      targets = package.document_rels.relationships.map(&:target)
      expect(targets).to include("https://example.com")
    end

    it "keeps rels to carried parts (customXml items)" do
      package = build_target_package
      package.custom_xml_items = [{ index: 1, xml_content: "<root/>" }]
      package.document_rels.relationships << rel_class.new(
        id: "rId60",
        type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml",
        target: "../customXml/item1.xml",
      )

      reconciler_class.new(package).reconcile

      targets = package.document_rels.relationships.map(&:target)
      expect(targets).to include("../customXml/item1.xml")
    end

    it "strips package rels whose targets are not carried" do
      package = build_target_package
      package.package_rels = Uniword::Docx::Package.minimal_package_rels
      package.package_rels.relationships << rel_class.new(
        id: "rId9",
        type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties",
        target: "docProps/custom.xml",
      )

      reconciler = reconciler_class.new(package)
      reconciler.reconcile

      targets = package.package_rels.relationships.map(&:target)
      expect(targets).not_to include("docProps/custom.xml")
      fix = reconciler.applied_fixes.find { |f| f.code == "R32" }
      expect(fix.part).to eq("_rels/.rels")
    end
  end

  describe "valid documents" do
    it "produce zero referential repairs" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body = Uniword::Wordprocessingml::Body.new
      package.document.body.paragraphs <<
        Uniword::Wordprocessingml::Paragraph.new(
          runs: [Uniword::Wordprocessingml::Run.new(
            text: Uniword::Wordprocessingml::Text.new(content: "clean"),
          )],
        )

      reconciler = reconciler_class.new(package)
      reconciler.reconcile

      referential = %w[R17 R18 R19 R20 R21 R22 R23 R32]
      codes = reconciler.applied_fixes.map(&:code)
      expect(codes & referential).to be_empty
    end
  end
end
