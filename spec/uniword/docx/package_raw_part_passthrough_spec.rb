# frozen_string_literal: true

require "spec_helper"

# Unknown-part passthrough (TODO.refactor/05): parts no registry
# definition models are carried byte-for-byte with their content
# types and relationships intact, and the write-time gate treats
# them as first-class.
RSpec.describe Uniword::Docx::Package do
  let(:output_dir) { File.expand_path("../../tmp/raw_passthrough", __dir__) }

  before { FileUtils.mkdir_p(output_dir) }

  after do
    Dir.glob(File.join(output_dir, "*.docx")).each { |f| safe_delete(f) }
  end

  describe "raw passthrough of no_styles.docx (docProps/meta.xml)" do
    let(:fixture) { "spec/fixtures/docx_gem/no_styles.docx" }
    let(:output_path) { File.join(output_dir, "no_styles_roundtrip.docx") }
    let(:package) { described_class.from_file(fixture) }
    let(:meta_part) { package.raw_parts["docProps/meta.xml"] }

    before { package.to_file(output_path) }

    it "carries the unmodelled part as a RawPart" do
      expect(meta_part).to be_a(Uniword::Docx::RawPart)
    end

    it "carries the part's source content type" do
      expect(meta_part.content_type).to eq("application/xml")
    end

    it "records the referencing relationship id" do
      expect(meta_part.r_id).to eq("rId1")
    end

    it "round-trips the part byte-identically" do
      expect(ZipHelper.extract_file(output_path, "docProps/meta.xml"))
        .to eq(ZipHelper.extract_file(fixture, "docProps/meta.xml"))
    end

    it "keeps the relationship targeting the raw part" do
      expect(package.document_rels.relationships.map(&:target))
        .to include("../docProps/meta.xml")
    end

    it "records no R32 strip for the raw part's rel" do
      expect(package.applied_fixes.select { |f| f.code == "R32" }.join)
        .not_to include("meta.xml")
    end

    it "passes the write-time integrity gate with the raw part" do
      issues = Uniword::Docx::PackageIntegrityChecker.new.check(
        package.to_zip_content(validate: true),
      )

      expect(issues).to be_empty
    end

    it "survives the document-level load/save path byte-identically" do
      Uniword::DocumentFactory.from_file(fixture).save(output_path)

      expect(ZipHelper.extract_file(output_path, "docProps/meta.xml"))
        .to eq(ZipHelper.extract_file(fixture, "docProps/meta.xml"))
    end
  end

  describe "raw passthrough of an unmodelled binary part" do
    let(:input_path) { File.join(output_dir, "with_binary.docx") }
    let(:output_path) { File.join(output_dir, "with_binary_out.docx") }
    let(:vba_bytes) { (0..255).map(&:chr).join.b }
    let(:package) { described_class.from_file(input_path) }

    before do
      add_binary_part("spec/fixtures/docx_gem/no_styles.docx", input_path)
      package.to_file(output_path)
    end

    it "round-trips the binary part byte-identically" do
      expect(ZipHelper.extract_file(output_path, "word/vbaProject.bin"))
        .to eq(vba_bytes)
    end

    it "keeps the binary part's relationship" do
      rels = ZipHelper.extract_file(output_path,
                                    "word/_rels/document.xml.rels")

      expect(rels).to include("vbaProject.bin")
    end

    it "declares the binary part's content type as an Override" do
      expect(package.to_zip_content["[Content_Types].xml"])
        .to include('PartName="/word/vbaProject.bin"', vba_content_type)
    end

    it "passes the write-time integrity gate" do
      issues = Uniword::Docx::PackageIntegrityChecker.new.check(
        package.to_zip_content(validate: true),
      )

      expect(issues).to be_empty
    end

    def vba_content_type
      "application/vnd.ms-office.vbaProject"
    end

    # Copy the source package, adding word/vbaProject.bin (binary
    # bytes invalid as UTF-8), its document relationship, and a
    # content-type Override.
    def add_binary_part(source_path, target_path)
      entries = read_zip_entries(source_path)
      entries["word/vbaProject.bin"] = vba_bytes
      entries["word/_rels/document.xml.rels"] =
        entries["word/_rels/document.xml.rels"].sub(
          "</Relationships>",
          "#{vba_relationship}</Relationships>",
        )
      entries["[Content_Types].xml"] =
        entries["[Content_Types].xml"].sub(
          "</Types>",
          "#{vba_override}</Types>",
        )
      write_zip_entries(target_path, entries)
    end

    def vba_relationship
      type = "http://schemas.microsoft.com/office/2007" \
             "/relationships/vbaProject"
      "<Relationship Id=\"rIdVba\" Type=\"#{type}\" " \
        "Target=\"vbaProject.bin\"/>"
    end

    def vba_override
      "<Override PartName=\"/word/vbaProject.bin\" " \
        "ContentType=\"#{vba_content_type}\"/>"
    end

    def read_zip_entries(path)
      Zip::File.open(path) do |zip|
        zip.each_with_object({}) do |entry, hash|
          hash[entry.name] = entry.get_input_stream.read unless entry.directory?
        end
      end
    end

    def write_zip_entries(path, entries)
      Zip::OutputStream.open(path) do |zos|
        entries.each do |name, bytes|
          zos.put_next_entry(name)
          zos.write(bytes)
        end
      end
    end
  end

  describe "a package without unknown parts" do
    let(:fixture) { "spec/fixtures/docx_gem/formatting.docx" }
    let(:package) { described_class.from_file(fixture) }

    it "carries no raw parts" do
      expect(package.raw_parts).to be_empty
    end

    it "emits only registry-known entries (raw path adds nothing)" do
      expect(unknown_entries(package.to_zip_content)).to be_empty
    end

    def unknown_entries(content)
      content.keys.reject do |name|
        name.end_with?(".rels") || name == "[Content_Types].xml" ||
          Uniword::Ooxml::PartRegistry.find_by_path(name)
      end
    end
  end

  describe "claim order (registry first, raw remainder)" do
    it "does not raw-carry parts the registry models" do
      package = described_class.from_file("spec/fixtures/docx_gem/basic.docx")

      expect(package.raw_parts.keys)
        .to contain_exactly("word/stylesWithEffects.xml")
    end

    it "does not raw-carry a main document at a non-standard path" do
      package = described_class.from_file(
        "spec/fixtures/docx_gem/office365.docx",
      )

      expect(package.raw_parts).to be_empty
    end

    it "does not raw-carry customXml item rels sidecars" do
      package = described_class.from_file(
        "spec/fixtures/docx_gem/saving_wps.docx",
      )

      expect(package.raw_parts.keys.grep(%r{\AcustomXml/_rels/}))
        .to be_empty
    end
  end

  describe "a raw part with no declared content type" do
    let(:input_path) { File.join(output_dir, "with_trash.docx") }
    let(:output_path) { File.join(output_dir, "with_trash_out.docx") }
    let(:trash_bytes) { "word junk bytes".b }

    before do
      add_undeclared_part("spec/fixtures/docx_gem/no_styles.docx", input_path)
      described_class.from_file(input_path).to_file(output_path)
    end

    it "saves without an OPC-005 failure" do
      issues = Uniword::Docx::PackageIntegrityChecker.new.check(
        described_class.from_file(input_path).to_zip_content(validate: true),
      )

      expect(issues).to be_empty
    end

    it "declares application/octet-stream for the undeclared part" do
      content_types = described_class.from_file(input_path)
        .to_zip_content["[Content_Types].xml"]

      expect(content_types).to include('PartName="/[trash]/0000.dat"')
      expect(content_types).to include("application/octet-stream")
    end

    it "round-trips the part byte-identically" do
      expect(ZipHelper.extract_file(output_path, "[trash]/0000.dat"))
        .to eq(trash_bytes)
    end

    # Copy the source package, adding [trash]/0000.dat with NO content
    # type declaration (Word's own junk folders look exactly like this).
    def add_undeclared_part(source_path, target_path)
      entries = Zip::File.open(source_path).each_with_object({}) do |e, h|
        h[e.name] = e.get_input_stream.read unless e.directory?
      end
      entries["[trash]/0000.dat"] = trash_bytes
      Zip::OutputStream.open(target_path) do |zos|
        entries.each do |name, bytes|
          zos.put_next_entry(name)
          zos.write(bytes)
        end
      end
    end
  end
end
