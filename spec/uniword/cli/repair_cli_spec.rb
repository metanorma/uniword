# frozen_string_literal: true

require "spec_helper"
require "zip"

# CLI coverage for `uniword repair` — load, reconcile, save, report.
RSpec.describe "uniword repair" do
  let(:cli) { Uniword::CLI.new }
  let(:output_dir) { "tmp/repair_cli_spec" }
  let(:input_path) { File.join(output_dir, "broken.docx") }
  let(:output_path) { File.join(output_dir, "fixed.docx") }

  let(:document_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:body><w:p><w:r><w:drawing><wp:inline><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:blipFill><a:blip r:embed="rId99"/></pic:blipFill></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p></w:body></w:document>
    XML
  end

  let(:broken_rels_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId99" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/missing.png"/></Relationships>
    XML
  end

  before do
    FileUtils.mkdir_p(output_dir)
    package = Uniword::Docx::Package.new
    package.document = Uniword::Wordprocessingml::DocumentRoot.from_xml(
      document_xml
    )
    package.document_rels =
      Uniword::Ooxml::Relationships::PackageRelationships.from_xml(
        broken_rels_xml
      )
    package.to_file(input_path, validate: false)
  end

  after do
    Dir.glob("#{output_dir}/*.docx").each { |f| safe_delete(f) }
  end

  it "repairs a dangling image reference and reports the fixes" do
    expect do
      cli.invoke(:repair, [input_path, output_path])
    end.to output(/Applied \d+ repair/).to_stdout

    fixed_xml = Zip::File.open(output_path) { |z| z.read("word/document.xml") }
    expect(fixed_xml).not_to include("rId99")
  end

  it "reports no repairs needed for a consistent document" do
    clean_path = File.join(output_dir, "clean.docx")
    doc = Uniword::Builder::DocumentBuilder.new
    doc.paragraph { |p| p << "plain text" }
    doc.save(clean_path)

    expect { cli.invoke(:repair, [clean_path, output_path]) }
      .to output(/No repairs needed/).to_stdout
  end

  it "lists every fix with --verbose" do
    expect { cli.invoke(:repair, [input_path, output_path], verbose: true) }
      .to output(/R\d+/).to_stdout
  end
end
