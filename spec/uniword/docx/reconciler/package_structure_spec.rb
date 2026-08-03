# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler do
  describe "Group 3: Package consistency" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }

    def build_full_package
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Hello")
      para.runs << run
      package.document.body.paragraphs << para
      package.content_types = Uniword::Docx::Package.minimal_content_types
      package.package_rels = Uniword::Docx::Package.minimal_package_rels
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package
    end

    describe "content types" do
      it "only includes rels and xml defaults" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        defaults = package.content_types.defaults.map(&:extension)
        expect(defaults).to eq(%w[rels xml])
      end

      it "includes overrides for all present parts" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        part_names = package.content_types.overrides.map(&:part_name)
        expect(part_names).to include("/word/document.xml")
        expect(part_names).to include("/word/styles.xml")
        expect(part_names).to include("/word/settings.xml")
        expect(part_names).to include("/word/fontTable.xml")
        expect(part_names).to include("/word/webSettings.xml")
        expect(part_names).to include("/word/theme/theme1.xml")
        expect(part_names).to include("/docProps/core.xml")
        expect(part_names).to include("/docProps/app.xml")
      end

      it "excludes overrides for absent parts" do
        package = build_full_package
        # No footnotes, endnotes, or numbering
        described_class.new(package, profile: profile).reconcile

        part_names = package.content_types.overrides.map(&:part_name)
        expect(part_names).not_to include("/word/footnotes.xml")
        expect(part_names).not_to include("/word/endnotes.xml")
        expect(part_names).not_to include("/word/numbering.xml")
      end

      it "includes overrides for footnotes when present" do
        package = build_full_package
        settings = Uniword::Wordprocessingml::Settings.new
        settings.footnote_pr = Uniword::Wordprocessingml::FootnotePr.new
        package.settings = settings
        described_class.new(package, profile: profile).reconcile

        part_names = package.content_types.overrides.map(&:part_name)
        expect(part_names).to include("/word/footnotes.xml")
      end
    end

    describe "package relationships" do
      it "uses rId1 for officeDocument" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rId1 = package.package_rels.relationships.find { |r| r.id == "rId1" }
        expect(rId1.target).to eq("word/document.xml")
        expect(rId1.type.to_s).to include("officeDocument")
      end

      it "uses rId2 for core-properties" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rId2 = package.package_rels.relationships.find { |r| r.id == "rId2" }
        expect(rId2.target).to eq("docProps/core.xml")
        expect(rId2.type.to_s).to include("core-properties")
      end

      it "uses rId3 for extended-properties" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rId3 = package.package_rels.relationships.find { |r| r.id == "rId3" }
        expect(rId3.target).to eq("docProps/app.xml")
        expect(rId3.type.to_s).to include("extended-properties")
      end

      it "preserves non-standard rels" do
        package = build_full_package
        # The custom-properties part must be carried by the package,
        # otherwise Group 4 strips the rel as dangling (R32).
        package.custom_properties = Uniword::Ooxml::CustomProperties.new
        package.package_rels.relationships <<
          Uniword::Ooxml::Relationships::Relationship.new(
            id: "rIdCustom",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties",
            target: "docProps/custom.xml",
          )

        described_class.new(package, profile: profile).reconcile

        custom = package.package_rels.relationships.find do |r|
          r.id == "rIdCustom"
        end
        expect(custom).not_to be_nil
        expect(custom.target).to eq("docProps/custom.xml")
      end
    end

    describe "document relationships" do
      it "uses correct rId ordering for standard parts" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rels = package.document_rels.relationships
        rId1 = rels.find { |r| r.id == "rId1" }
        rId2 = rels.find { |r| r.id == "rId2" }
        rId3 = rels.find { |r| r.id == "rId3" }
        rId4 = rels.find { |r| r.id == "rId4" }
        rId5 = rels.find { |r| r.id == "rId5" }

        expect(rId1.target).to eq("styles.xml")
        expect(rId2.target).to eq("settings.xml")
        expect(rId3.target).to eq("webSettings.xml")
        expect(rId4.target).to eq("fontTable.xml")
        expect(rId5.target).to eq("theme/theme1.xml")
      end

      it "does not include theme rId when theme is absent" do
        package = build_full_package
        # No profile → no theme
        described_class.new(package).reconcile

        rId5 = package.document_rels.relationships.find { |r| r.id == "rId5" }
        expect(rId5).to be_nil
      end

      it "preserves non-standard rels verbatim (no renumbering)" do
        package = build_full_package
        # The image part must be carried by the package, otherwise
        # Group 4 strips the rel as dangling (R32).
        package.document.image_parts = {
          "rIdExtra" => { data: "png-bytes", target: "media/image1.png",
                          content_type: "image/png" },
        }
        package.document_rels.relationships <<
          Uniword::Ooxml::Relationships::Relationship.new(
            id: "rIdExtra",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
            target: "media/image1.png",
          )

        described_class.new(package, profile: profile).reconcile

        extra = package.document_rels.relationships.find do |r|
          r.target == "media/image1.png"
        end
        expect(extra).not_to be_nil
        expect(extra.id).to eq("rIdExtra")
        expect(extra.type).to include("image")

        # Loaded standard rels keep their original ids
        styles = package.document_rels.relationships.find do |r|
          r.target == "styles.xml"
        end
        expect(styles.id).to eq("rId1")
      end

      it "preserves non-sequential template rIds verbatim" do
        package = build_full_package

        rels = package.document_rels
        rels.relationships.clear
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId1", type: ".../styles", target: "styles.xml",
        )
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId13", type: ".../fontTable", target: "fontTable.xml",
        )
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId99", type: ".../header", target: "header1.xml",
        )

        described_class.new(package, profile: profile).reconcile

        ids = rels.relationships.map(&:id)
        expect(ids).to include("rId1", "rId13")
        # The stale header rel (no backing part) is dropped, not renumbered
        expect(ids).not_to include("rId99")

        styles = rels.relationships.find { |r| r.target == "styles.xml" }
        expect(styles.id).to eq("rId1")
        font_table = rels.relationships.find { |r| r.target == "fontTable.xml" }
        expect(font_table.id).to eq("rId13")
      end

      it "updates sectPr references after renumbering" do
        package = build_full_package

        header = Uniword::Wordprocessingml::Header.new
        hdr_para = Uniword::Wordprocessingml::Paragraph.new
        hdr_para.runs << Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "Header"),
        )
        header.paragraphs << hdr_para
        package.document.headers ||= {}
        package.document.headers["default"] = header

        # Ensure section properties exist with a header reference using rId99
        sect_pr = package.document.body.section_properties
        unless sect_pr
          sect_pr = Uniword::Wordprocessingml::SectionProperties.new
          package.document.body.section_properties = sect_pr
        end
        sect_pr.header_references ||= []
        sect_pr.header_references <<
          Uniword::Wordprocessingml::HeaderReference.new(type: "default", r_id: "rId99")

        rels = package.document_rels
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId99",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
          target: "header1.xml",
        )

        described_class.new(package, profile: profile).reconcile

        ref = sect_pr.header_references.find { |r| r.type == "default" }
        expect(ref).not_to be_nil
        expect(ref.r_id).to match(/\ArId\d+\z/)
        expect(rels.relationships.map(&:id)).to include(ref.r_id)
      end
    end
  end
end
