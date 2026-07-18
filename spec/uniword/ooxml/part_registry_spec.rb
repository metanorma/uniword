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
      expect(described_class.find_by_path("word/comments.xml")).to be_nil
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
        key: :comments,
        kind: :override,
        path: "word/comments.xml",
        target: "comments.xml",
        content_type: "#{wml_ct}.comments+xml",
        rel_type: "#{office_rel}/comments",
        rels_scope: :document,
      )
    end

    after do
      described_class.unregister(:comments)
    end

    it "makes a new part kind findable by key, path, and content type" do
      described_class.register(custom)

      expect(described_class.find_by_key(:comments)).to eq(custom)
      expect(described_class.find_by_path("word/comments.xml")).to eq(custom)
      expect(described_class.find_by_content_type("#{wml_ct}.comments+xml"))
        .to eq(custom)
      expect(described_class.override_for("/word/comments.xml")).to eq(custom)
    end

    it "appends new keys after the built-ins" do
      described_class.register(custom)

      expect(described_class.all.map(&:key).last).to eq(:comments)
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
end
