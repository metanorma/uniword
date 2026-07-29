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
      package.document.image_parts = {
        "rId99" => { data: "png", target: "media/image1.png",
                     content_type: "image/png" },
      }
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

  describe "repair ordering" do
    it "strips a dangling rel and its drawing in a single pass" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.from_xml(
        document_xml
      )
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId99",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
          target: "media/missing.png",
        )

      reconciler = reconciler_class.new(package)
      reconciler.reconcile

      codes = reconciler.applied_fixes.map(&:code)
      expect(codes).to include("R32", "R23")
      drawings = package.document.body.paragraphs
        .flat_map(&:runs).flat_map(&:drawings)
      expect(drawings).to be_empty
    end
  end
end

# Separate top-level group on purpose: these merged-in examples need
# `described_class`, while the group above must keep its exact
# "Reconciler referential integrity" description so `rspec -e` filters and CI
# configs keep matching it. Merging the two back would silently break that
# filter — no test would fail to tell you.
RSpec.describe Uniword::Docx::Reconciler do
  describe "referential integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:fn_ref_class) { Uniword::Wordprocessingml::FootnoteReference }
    let(:header_ref_class) { Uniword::Wordprocessingml::HeaderReference }
    let(:footer_ref_class) { Uniword::Wordprocessingml::FooterReference }
    let(:sect_pr_class) { Uniword::Wordprocessingml::SectionProperties }
    let(:page_size_class) { Uniword::Wordprocessingml::PageSize }
    let(:settings_class) { Uniword::Wordprocessingml::Settings }
    let(:footnotes_class) { Uniword::Wordprocessingml::Footnotes }
    let(:footnote_class) { Uniword::Wordprocessingml::Footnote }
    let(:footnote_pr_class) { Uniword::Wordprocessingml::FootnotePr }

    def build_package_with_body_paragraphs(*paras)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      paras.each { |p| package.document.body.paragraphs << p }
      package
    end

    it "preserves valid footnote references" do
      run = run_class.new(
        text: text_class.new(value: "text"),
        footnote_reference: fn_ref_class.new(id: "1"),
      )
      para = para_class.new(runs: [run])
      package = build_package_with_body_paragraphs(para)

      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package.settings = settings
      package.footnotes = footnotes

      described_class.new(package).reconcile

      expect(para.runs.size).to eq(1)
      expect(para.runs.first.footnote_reference.id).to eq("1")
    end

    it "removes dangling header references from sectPr" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        header_references: [
          header_ref_class.new(type: "default", r_id: "rIdGhost"),
          header_ref_class.new(type: "first", r_id: "rIdValid"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = [
        { r_id: "rIdValid", content: Uniword::Wordprocessingml::Header.new },
      ]

      described_class.new(package).reconcile

      refs = sect_pr.header_references
      expect(refs.size).to eq(1)
      expect(refs.first.r_id).to eq("rIdValid")
    end

    it "removes dangling footer references from sectPr" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        footer_references: [
          footer_ref_class.new(type: "default", r_id: "rIdGhost"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = [
        { r_id: "rIdReal", content: Uniword::Wordprocessingml::Footer.new },
      ]

      described_class.new(package).reconcile

      expect(sect_pr.footer_references).to be_empty
    end

    it "preserves valid header and footer references" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        header_references: [
          header_ref_class.new(type: "default", r_id: "rId1"),
        ],
        footer_references: [
          footer_ref_class.new(type: "default", r_id: "rId2"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = [
        { r_id: "rId1", content: Uniword::Wordprocessingml::Header.new },
        { r_id: "rId2", content: Uniword::Wordprocessingml::Footer.new },
      ]

      described_class.new(package).reconcile

      expect(sect_pr.header_references.size).to eq(1)
      expect(sect_pr.footer_references.size).to eq(1)
    end

    it "collects valid rIds from document_rels" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        header_references: [
          header_ref_class.new(type: "default", r_id: "rId7"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = [
        {
          r_id: "rId7",
          target: "header1.xml",
          rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
          content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml",
          content: Uniword::Wordprocessingml::Header.new,
        },
      ]
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId7",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
          target: "header1.xml",
        )

      described_class.new(package).reconcile

      expect(sect_pr.header_references.size).to eq(1)
    end
  end

  describe "style reference integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:style_ref_class) { Uniword::Properties::StyleReference }

    def build_package_with_style(style_val)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      props = Uniword::Wordprocessingml::ParagraphProperties.new(
        style: style_ref_class.new(value: style_val),
      )
      para = para_class.new(
        properties: props,
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package.document.body.paragraphs << para
      package
    end

    it "preserves style reference when style exists in styles.xml" do
      package = build_package_with_style("Heading1")
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "Heading1",
        name: Uniword::Wordprocessingml::StyleName.new(val: "heading 1"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(package.document.body.paragraphs.first.style.value)
        .to eq("Heading1")
    end

    it "removes style reference when style does not exist" do
      package = build_package_with_style("GhostStyle")
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "Normal",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Normal"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(package.document.body.paragraphs.first.properties.style).to be_nil
    end

    it "handles empty styles gracefully" do
      package = build_package_with_style("AnyStyle")
      package.styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )

      described_class.new(package).reconcile

      expect(package.document.body.paragraphs.first.properties.style).to be_nil
    end
  end

  describe "style inheritance integrity" do
    it "removes dangling basedOn reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "text"),
        )],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "MyStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "My Style"),
        basedOn: Uniword::Wordprocessingml::BasedOn.new(val: "GhostParent"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(styles.styles.first.basedOn).to be_nil
    end

    it "removes dangling link reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "text"),
        )],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "MyStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "My Style"),
        link: Uniword::Wordprocessingml::Link.new(val: "GhostCharStyle"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(styles.styles.first.link).to be_nil
    end

    it "preserves valid basedOn and link references" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "text"),
        )],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "ParentStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Parent"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "character", styleId: "LinkedChar",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Linked Char"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "ChildStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Child"),
        basedOn: Uniword::Wordprocessingml::BasedOn.new(val: "ParentStyle"),
        link: Uniword::Wordprocessingml::Link.new(val: "LinkedChar"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      child = styles.styles.find { |s| s.id == "ChildStyle" }
      expect(child.basedOn.val).to eq("ParentStyle")
      expect(child.link.val).to eq("LinkedChar")
    end
  end

  describe "run and table style integrity" do
    it "removes dangling run style (rStyle) reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      run = Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "styled"),
        properties: Uniword::Wordprocessingml::RunProperties.new(
          style: Uniword::Properties::RunStyleReference.new(value: "GhostChar"),
        ),
      )
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [run],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "character", styleId: "Emphasis",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Emphasis"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(run.properties.style).to be_nil
    end

    it "removes dangling table style (tblStyle) reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      tbl = Uniword::Wordprocessingml::Table.new(
        properties: Uniword::Wordprocessingml::TableProperties.new(
          style: Uniword::Wordprocessingml::TableStyle.new(val: "GhostTable"),
        ),
        rows: [Uniword::Wordprocessingml::TableRow.new(
          cells: [Uniword::Wordprocessingml::TableCell.new(
            paragraphs: [Uniword::Wordprocessingml::Paragraph.new(
              runs: [Uniword::Wordprocessingml::Run.new(
                text: Uniword::Wordprocessingml::Text.new(value: "cell"),
              )],
            )],
          )],
        )],
      )
      package.document.body.tables << tbl
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "table", styleId: "TableNormal",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Normal Table"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(tbl.properties.style).to be_nil
    end

    it "preserves valid run and table style references" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      run = Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "styled"),
        properties: Uniword::Wordprocessingml::RunProperties.new(
          style: Uniword::Properties::RunStyleReference.new(value: "Emphasis"),
        ),
      )
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [run],
      )
      tbl = Uniword::Wordprocessingml::Table.new(
        properties: Uniword::Wordprocessingml::TableProperties.new(
          style: Uniword::Wordprocessingml::TableStyle.new(val: "TableNormal"),
        ),
        rows: [Uniword::Wordprocessingml::TableRow.new(
          cells: [Uniword::Wordprocessingml::TableCell.new(
            paragraphs: [Uniword::Wordprocessingml::Paragraph.new(
              runs: [Uniword::Wordprocessingml::Run.new(
                text: Uniword::Wordprocessingml::Text.new(value: "cell"),
              )],
            )],
          )],
        )],
      )
      package.document.body.tables << tbl
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "character", styleId: "Emphasis",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Emphasis"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "table", styleId: "TableNormal",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Normal Table"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(run.properties.style.value).to eq("Emphasis")
      expect(tbl.properties.style.val).to eq("TableNormal")
    end
  end

  describe "numbering body reference integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }

    def build_package_with_num_id(num_id)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      num_pr = Uniword::Properties::NumberingProperties.new(
        num_id: Uniword::Properties::NumberingId.new(value: num_id),
      )
      props = Uniword::Wordprocessingml::ParagraphProperties.new(
        numbering_properties: num_pr,
      )
      para = para_class.new(
        properties: props,
        runs: [run_class.new(text: text_class.new(value: "item"))],
      )
      package.document.body.paragraphs << para
      package
    end

    it "preserves numbering reference when numId exists" do
      package = build_package_with_num_id(1)
      num_config = Uniword::Wordprocessingml::NumberingConfiguration.new
      num_config.add_instance(abstract_num_id: 0, num_id: 1)
      package.numbering = num_config

      described_class.new(package).reconcile

      num_pr = package.document.body.paragraphs.first.properties.numbering_properties
      expect(num_pr).not_to be_nil
    end

    it "removes numbering reference when numId does not exist" do
      package = build_package_with_num_id(99)
      num_config = Uniword::Wordprocessingml::NumberingConfiguration.new
      num_config.add_instance(abstract_num_id: 0, num_id: 1)
      package.numbering = num_config

      described_class.new(package).reconcile

      num_pr = package.document.body.paragraphs.first.properties.numbering_properties
      expect(num_pr).to be_nil
    end

    it "preserves numId=0 (no numbering marker)" do
      package = build_package_with_num_id(0)

      described_class.new(package).reconcile

      num_pr = package.document.body.paragraphs.first.properties.numbering_properties
      expect(num_pr).not_to be_nil
    end
  end

  describe "hyperlink reference integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:hyperlink_class) { Uniword::Wordprocessingml::Hyperlink }

    it "removes hyperlink with dangling rId" do
      hl = hyperlink_class.new(id: "rId99")
      hl.runs << run_class.new(text: text_class.new(value: "click"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels

      described_class.new(package).reconcile

      expect(para.hyperlinks).to be_empty
    end

    it "preserves hyperlink with valid rId" do
      hl = hyperlink_class.new(id: "rId10")
      hl.runs << run_class.new(text: text_class.new(value: "click"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId10",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
          target: "http://example.com",
        )

      described_class.new(package).reconcile

      expect(para.hyperlinks.size).to eq(1)
    end

    it "preserves internal anchor hyperlinks without rId check" do
      hl = hyperlink_class.new(anchor: "bookmark1")
      hl.runs << run_class.new(text: text_class.new(value: "jump"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para

      described_class.new(package).reconcile

      expect(para.hyperlinks.size).to eq(1)
    end

    it "preserves non-rId hyperlinks (builder-generated URLs)" do
      hl = hyperlink_class.new(id: "https://example.com")
      hl.runs << run_class.new(text: text_class.new(value: "link"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels

      described_class.new(package).reconcile

      expect(para.hyperlinks.size).to eq(1)
    end
  end

  describe "paraId uniqueness" do
    it "deduplicates colliding paraIds" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new

      p1 = Uniword::Wordprocessingml::Paragraph.new(para_id: "DEADBEEF")
      p1.runs << Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "first"),
      )
      p2 = Uniword::Wordprocessingml::Paragraph.new(para_id: "DEADBEEF")
      p2.runs << Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "second"),
      )
      package.document.body.paragraphs << p1
      package.document.body.paragraphs << p2

      described_class.new(package).reconcile

      ids = package.document.body.paragraphs.map(&:para_id)
      expect(ids.uniq.size).to eq(ids.size)
    end
  end

  describe "rId uniqueness" do
    it "deduplicates colliding rIds in document_rels" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      para.runs << Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "x"),
      )
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels

      # Inject a duplicate rId1
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId1",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
          target: "media/image1.png",
        )

      described_class.new(package).reconcile

      ids = package.document_rels.relationships.map(&:id)
      expect(ids.uniq.size).to eq(ids.size)
    end
  end
end
