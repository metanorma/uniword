# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::PartRegistry do
  let(:wml_ct) do
    "application/vnd.openxmlformats-officedocument.wordprocessingml"
  end
  let(:office_rel) do
    "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  end

  describe "built-in registrations" do
    it "registers the standard document parts" do
      styles = described_class.find_by_key(:styles)

      expect(styles.path).to eq("word/styles.xml")
      expect(styles.part_name).to eq("/word/styles.xml")
      expect(styles.target).to eq("styles.xml")
      expect(styles.content_type).to eq("#{wml_ct}.styles+xml")
      expect(styles.rel_type).to eq("#{office_rel}/styles")
      expect(styles.rels_scope).to eq(:document)
      expect(styles).to be_override
      expect(styles).to be_required
    end

    it "registers package-scoped parts" do
      document = described_class.find_by_key(:document)

      expect(document.rel_type).to eq("#{office_rel}/officeDocument")
      expect(document).to be_package_rel
    end

    it "registers numbered parts as patterns" do
      header = described_class.find_by_key(:header)

      expect(header.path).to be_nil
      expect(header.path_for(counter: 1)).to eq("word/header1.xml")
      expect(header.part_name_for(counter: 2)).to eq("/word/header2.xml")
      expect(header.target_for(counter: 3)).to eq("header3.xml")
      expect(header.content_type).to eq("#{wml_ct}.header+xml")
      expect(header.rel_type).to eq("#{office_rel}/header")
    end

    it "registers parts without content types or relationships" do
      hyperlink = described_class.find_by_key(:hyperlink)

      expect(hyperlink.content_type).to be_nil
      expect(hyperlink.rel_type).to eq("#{office_rel}/hyperlink")
      expect(hyperlink).not_to be_override
      expect(hyperlink).not_to be_default
    end
  end

  describe ".find_by_key" do
    it "finds a definition by its key" do
      expect(described_class.find_by_key(:settings).part_name)
        .to eq("/word/settings.xml")
    end

    it "accepts string keys" do
      expect(described_class.find_by_key("settings").key).to eq(:settings)
    end

    it "returns nil for unknown keys" do
      expect(described_class.find_by_key(:no_such_part)).to be_nil
    end
  end

  describe ".find_by_path" do
    it "finds by package-relative path" do
      expect(described_class.find_by_path("word/styles.xml").key)
        .to eq(:styles)
    end

    it "finds by leading-slash part name" do
      expect(described_class.find_by_path("/word/styles.xml").key)
        .to eq(:styles)
    end

    it "matches numbered paths against patterns" do
      expect(described_class.find_by_path("word/footer7.xml").key)
        .to eq(:footer)
    end

    it "returns nil for unregistered paths" do
      expect(described_class.find_by_path("word/glossary.xml")).to be_nil
    end
  end

  describe ".find_by_content_type" do
    it "finds the definition with the given content type" do
      numbering_ct = "#{wml_ct}.numbering+xml"

      expect(described_class.find_by_content_type(numbering_ct).key)
        .to eq(:numbering)
    end

    it "returns nil for unknown content types" do
      expect(described_class.find_by_content_type("text/plain")).to be_nil
    end
  end

  describe ".override_for" do
    it "finds override definitions by part name" do
      expect(described_class.override_for("/word/fontTable.xml").key)
        .to eq(:font_table)
    end

    it "matches numbered override parts" do
      expect(described_class.override_for("/word/header9.xml").key)
        .to eq(:header)
    end

    it "does not match default-only definitions" do
      expect(described_class.override_for("/word/media/image1.png"))
        .to be_nil
    end
  end

  describe ".default_for" do
    it "finds default definitions by extension" do
      expect(described_class.default_for("png").key).to eq(:png)
    end

    it "returns nil for unknown extensions" do
      expect(described_class.default_for("bin")).to be_nil
    end
  end

  describe ".standard_defaults / .standard_overrides" do
    it "keeps the historic ContentTypes.generate default order" do
      expect(described_class.standard_defaults.map(&:key))
        .to eq(%i[jpeg png gif rels xml])
    end

    it "keeps the historic ContentTypes.generate override order" do
      expect(described_class.standard_overrides.map(&:key))
        .to eq(%i[document numbering styles settings web_settings
                  font_table theme core_properties app_properties])
    end
  end

  describe ".package_rel_types" do
    it "lists the package-level relationship types" do
      expect(described_class.package_rel_types).to contain_exactly(
        "#{office_rel}/officeDocument",
        "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties",
        "#{office_rel}/extended-properties",
        "#{office_rel}/custom-properties",
      )
    end
  end

  describe "loader metadata" do
    let(:rels_parts) do
      %i[content_types package_rels document_rels settings_rels
         theme_rels footnotes_rels endnotes_rels]
    end

    it "selects the xml_model loader for fixed XML parts" do
      expect(described_class.find_by_key(:styles).loader).to eq(:xml_model)
    end

    it "names the parsing model class" do
      expect(described_class.find_by_key(:styles).loader_model)
        .to eq(Uniword::Wordprocessingml::StylesConfiguration)
    end

    it "names the package and document attributes" do
      styles = described_class.find_by_key(:styles)

      expect([styles.package_attribute, styles.document_attribute])
        .to eq(%i[styles styles_configuration])
    end

    it "resolves the main document path from package relationships" do
      expect(described_class.find_by_key(:document).path_resolution)
        .to eq(:office_document)
    end

    it "resolves the document rels path as the document sidecar" do
      expect(described_class.find_by_key(:document_rels).path_resolution)
        .to eq(:office_document_rels)
    end

    it "registers every read-side rels part as loadable" do
      expect(rels_parts.map { |k| described_class.find_by_key(k) })
        .to all(be_loadable)
    end

    it "registers the header/footer strategy for both kinds" do
      expect([described_class.find_by_key(:header).loader,
              described_class.find_by_key(:footer).loader])
        .to eq(%i[header_footer header_footer])
    end

    it "registers the chart, image, and embedding strategies" do
      keys = %i[chart image ole_object]

      expect(keys.map { |k| described_class.find_by_key(k).loader })
        .to eq(%i[chart image embedding])
    end

    it "registers the custom_xml and theme_media strategies" do
      expect([described_class.find_by_key(:custom_xml_item).loader,
              described_class.find_by_key(:theme_media).loader])
        .to eq(%i[custom_xml theme_media])
    end

    it "keeps write-only parts without loaders" do
      keys = %i[bibliography hyperlink thmx_theme]

      expect(keys.map { |k| described_class.find_by_key(k).loadable? })
        .to all(be(false))
    end

    it "carries the numbering copy guard" do
      expect(described_class.find_by_key(:numbering).to_package_guard)
        .to eq(:numbering_configuration_loaded?)
    end

    it "carries the comments copy type" do
      expect(described_class.find_by_key(:comments).to_package_type)
        .to eq(Uniword::CommentsPart)
    end
  end

  describe ".loadable" do
    let(:load_order) { described_class.loadable.map(&:key) }

    it "orders content types and package rels before the document" do
      expect([load_order.index(:content_types),
              load_order.index(:package_rels)])
        .to all(be < load_order.index(:document))
    end

    it "orders the document and its rels before dependent parts" do
      expect([load_order.index(:header), load_order.index(:chart),
              load_order.index(:image)])
        .to all(be > load_order.index(:document_rels))
    end

    it "orders headers before footers and theme before theme media" do
      expect([load_order.index(:header) < load_order.index(:footer),
              load_order.index(:theme) < load_order.index(:theme_media)])
        .to eq([true, true])
    end

    it "excludes parts without loaders" do
      expect(load_order)
        .not_to include(:hyperlink, :bibliography, :thmx_theme,
                        :custom_xml_item_props, :jpeg, :rels)
    end
  end

  describe ".copied_to_document / .copied_to_package" do
    let(:rels_parts) do
      %i[content_types package_rels document_rels settings_rels
         theme_rels footnotes_rels endnotes_rels]
    end

    let(:copy_methods) do
      described_class.copied_to_package.flat_map do |d|
        [d.package_attribute, :"#{d.package_attribute}=",
         d.document_attribute, :"#{d.document_attribute}="]
      end
    end

    it "mirrors core attribute-backed parts onto the document" do
      expect(described_class.copied_to_document.map(&:key))
        .to include(:styles, :numbering, :settings, :font_table,
                    :web_settings, :theme)
    end

    it "mirrors properties and note parts onto the document" do
      expect(described_class.copied_to_document.map(&:key))
        .to include(:core_properties, :app_properties, :footnotes,
                    :endnotes, :comments, :custom_xml_item)
    end

    it "mirrors rels parts onto the document" do
      keys = described_class.copied_to_document.map(&:key)

      expect(rels_parts - keys).to be_empty
    end

    it "excludes parts the loader places directly" do
      expect(described_class.copied_to_document.map(&:key))
        .not_to include(:chart, :ole_object, :bibliography, :document)
    end

    it "mirrors package-owned parts back to the package" do
      keys = described_class.copied_to_package.map(&:key)

      expect(keys).to include(:ole_object)
    end

    it "no longer copies chart or bibliography parts to the package" do
      keys = described_class.copied_to_package.map(&:key)

      expect(keys).not_to include(:chart, :bibliography)
    end

    it "differs between directions only by the copy_to_document flag" do
      both = described_class.copied_to_package.map(&:key)
      document = described_class.copied_to_document.map(&:key)

      expect(both - document).to eq(%i[ole_object])
    end

    it "names attributes that exist on the package and the document" do
      models = [Uniword::Docx::Package.new,
                Uniword::Wordprocessingml::DocumentRoot.new]

      expect(copy_methods - models.flat_map(&:methods)).to be_empty
    end
  end

  describe ".all" do
    it "returns every definition in registration order" do
      keys = described_class.all.map(&:key)

      expect(keys.first).to eq(:jpeg)
      expect(keys).to include(:document, :styles, :image, :ole_object)
    end

    it "returns a copy that does not mutate the registry" do
      described_class.all.clear

      expect(described_class.all).not_to be_empty
    end
  end

  describe "custom registration" do
    let(:custom) do
      Uniword::Ooxml::PartDefinition.new(
        key: :glossary,
        kind: :override,
        path: "word/glossary.xml",
        target: "glossary.xml",
        content_type: "#{wml_ct}.glossary+xml",
        rel_type: "#{office_rel}/glossary",
        rels_scope: :document,
      )
    end

    after do
      described_class.unregister(:glossary)
    end

    it "makes a new part kind findable by key, path, and content type" do
      described_class.register(custom)

      expect(described_class.find_by_key(:glossary)).to eq(custom)
      expect(described_class.find_by_path("word/glossary.xml")).to eq(custom)
      expect(described_class.find_by_content_type("#{wml_ct}.glossary+xml"))
        .to eq(custom)
      expect(described_class.override_for("/word/glossary.xml")).to eq(custom)
    end

    it "appends new keys after the built-ins" do
      described_class.register(custom)

      expect(described_class.all.map(&:key).last).to eq(:glossary)
    end

    it "replaces an existing key in place, preserving position" do
      original = described_class.find_by_key(:styles)
      before = described_class.all.map(&:key)
      replacement = Uniword::Ooxml::PartDefinition.new(
        key: :styles, kind: :override, path: "word/styles.xml",
        target: "styles.xml", content_type: "#{wml_ct}.styles+xml",
        rel_type: "#{office_rel}/styles", rels_scope: :document
      )

      begin
        described_class.register(replacement)

        expect(described_class.all.map(&:key)).to eq(before)
        expect(described_class.find_by_key(:styles)).to eq(replacement)
      ensure
        described_class.register(original)
      end
    end

    it "rejects non-PartDefinition registrations" do
      expect { described_class.register({ key: :bad }) }
        .to raise_error(ArgumentError, /PartDefinition/)
    end
  end

  describe ".emitted_paths" do
    let(:package) do
      Uniword::Docx::Package.new.tap do |pkg|
        pkg.document = Uniword::Wordprocessingml::DocumentRoot.new
        pkg.document.body = Uniword::Wordprocessingml::Body.new
        # Mirror the to_zip_content model state the sweep runs against.
        pkg.settings = Uniword::Wordprocessingml::Settings.new
        pkg.font_table = Uniword::Wordprocessingml::FontTable.new
        pkg.web_settings = Uniword::Wordprocessingml::WebSettings.new
      end
    end

    it "includes single-instance parts whose models are present" do
      paths = described_class.emitted_paths(package)

      expect(paths).to include("word/document.xml", "word/styles.xml",
                               "word/settings.xml")
    end

    it "omits single-instance parts whose models are absent" do
      paths = described_class.emitted_paths(package)

      expect(paths).not_to include("word/footnotes.xml",
                                   "word/endnotes.xml")
    end

    it "enumerates collection families from their stored parts" do
      package.document.image_parts["rId1"] = {
        data: "png", target: "media/image1.png",
        content_type: "image/png",
      }

      expect(described_class.emitted_paths(package))
        .to include("word/media/image1.png")
    end

    it "enumerates customXml items with their properties parts" do
      package.custom_xml_items = [
        { index: 1, xml_content: "<a/>", props_xml: "<p/>" },
      ]

      paths = described_class.emitted_paths(package)
      expect(paths).to include("customXml/item1.xml",
                               "customXml/itemProps1.xml")
    end

    it "enumerates header/footer parts from the unified store" do
      package.document.header_footer_parts <<
        Uniword::Docx::HeaderFooterPart.new(
          r_id: "rId7", target: "header1.xml",
          rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
          content: Uniword::Wordprocessingml::Header.new,
          type: "default",
        )

      expect(described_class.emitted_paths(package))
        .to include("word/header1.xml")
    end
  end
end
