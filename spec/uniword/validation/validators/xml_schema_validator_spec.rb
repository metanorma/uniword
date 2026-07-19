# frozen_string_literal: true

require "spec_helper"
require "zip"

# MCE-aware preprocessing (TODO.refactor/06): extension attributes
# declared ignorable are stripped before XSD validation; genuine
# errors still surface.
RSpec.describe Uniword::Validation::Validators::XmlSchemaValidator do
  let(:output_dir) { "tmp/xsd_validator_spec" }
  let(:validator) do
    described_class.new("xml_schema" => { "xsd_validation" => true })
  end

  let(:w_ns) do
    "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  end
  let(:w14_ns) { "http://schemas.microsoft.com/office/word/2010/wordml" }
  let(:mc_ns) do
    "http://schemas.openxmlformats.org/markup-compatibility/2006"
  end

  before { FileUtils.mkdir_p(output_dir) }

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  def write_zip(path, document_xml)
    Zip::File.open(path, create: true) do |zip|
      zip.get_output_stream("[Content_Types].xml") do |f|
        f.write(%(<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>))
      end
      zip.get_output_stream("word/document.xml") do |f|
        f.write(document_xml)
      end
    end
  end

  def error_messages(result)
    result.errors + result.warnings
  end

  describe "MCE preprocessing" do
    it "strips ignorable extension attributes (w14:paraId)" do
      document_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="#{w_ns}" xmlns:w14="#{w14_ns}" xmlns:mc="#{mc_ns}" mc:Ignorable="w14"><w:body><w:p w14:paraId="12345678" w14:textId="77777777"><w:r><w:t>text</w:t></w:r></w:p></w:body></w:document>
      XML
      path = File.join(output_dir, "mce.docx")
      write_zip(path, document_xml)

      result = validator.validate(path)

      expect(error_messages(result).join).not_to include("paraId")
      expect(error_messages(result).join).not_to include("textId")
    end

    it "strips the mc:Ignorable attribute itself" do
      settings_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:settings xmlns:w="#{w_ns}" xmlns:w14="#{w14_ns}" xmlns:mc="#{mc_ns}" mc:Ignorable="w14"><w:characterSpacingControl w:val="doNotCompress"/></w:settings>
      XML
      path = File.join(output_dir, "settings_mce.docx")
      write_zip(path, settings_xml.gsub("document.xml", "settings.xml"))
      # Rewrite the entry name to word/settings.xml
      settings_path = File.join(output_dir, "settings2.docx")
      Zip::File.open(settings_path, create: true) do |zip|
        zip.get_output_stream("[Content_Types].xml") do |f|
          f.write(%(<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/></Types>))
        end
        zip.get_output_stream("word/settings.xml") { |f| f.write(settings_xml) }
      end

      result = validator.validate(settings_path)

      expect(error_messages(result).join).not_to include("Ignorable")
    end

    it "leaves content alone when no mc:Ignorable is declared" do
      document_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="#{w_ns}"><w:body><w:p><w:r><w:t>text</w:t></w:r></w:p></w:body></w:document>
      XML
      path = File.join(output_dir, "plain.docx")
      write_zip(path, document_xml)

      expect { validator.validate(path) }.not_to raise_error
    end
  end

  describe "genuine errors still surface" do
    it "reports a schema-invalid document (pgMar missing required attrs)" do
      document_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="#{w_ns}"><w:body><w:p><w:r><w:t>text</w:t></w:r></w:p><w:sectPr><w:pgMar w:top="1440"/></w:sectPr></w:body></w:document>
      XML
      path = File.join(output_dir, "invalid.docx")
      write_zip(path, document_xml)

      result = validator.validate(path)

      expect(error_messages(result).join).to include("pgMar")
    end
  end
end
