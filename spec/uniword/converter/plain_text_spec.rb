# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

# Plain-text editing round trip (issue #80): DocumentRoot <-> Markdown
# and AsciiDoc through the Coradoc CoreModel bridge.
RSpec.describe Uniword::Converter::PlainText do
  let(:converter) { described_class.new }
  let(:output_dir) { "tmp/converter_plain_text_spec" }

  before { FileUtils.mkdir_p(output_dir) }

  after do
    Dir.glob("#{output_dir}/*").each { |f| safe_delete(f) }
  end

  # -- shared document fixture -----------------------------------------

  def build_feature_document
    doc = Uniword::Builder::DocumentBuilder.new
    doc.heading("Main Title", level: 1)
    doc.heading("Section", level: 2)
    doc.paragraph do |p|
      bold = Uniword::Builder::RunBuilder.new
      bold.text("bold word")
      bold.bold
      p << bold
      plain = Uniword::Builder::RunBuilder.new
      plain.text(" and ")
      p << plain
      italic = Uniword::Builder::RunBuilder.new
      italic.text("italic word")
      italic.italic
      p << italic
    end
    doc.bullet_list do |l|
      l.item("first")
      l.item("second")
    end
    doc.table do |t|
      t.row do |row|
        row.header_row
        row.cell(text: "Name")
        row.cell(text: "Value")
      end
      t.row do |row|
        row.cell(text: "alpha")
        row.cell(text: "1")
      end
    end
    link = Uniword::Hyperlink.new(url: "https://example.com",
                                  text: "Example Site")
    doc.paragraph do |p|
      p << "See " << link.to_model(allocator: doc.allocator)
    end
    doc
  end

  def reloaded(document, name)
    path = File.join(output_dir, name)
    document.save(path)
    Uniword::DocumentFactory.from_file(path)
  end

  def heading_style(paragraph)
    Array(paragraph.properties&.style).first&.value
  end

  def run_flags(paragraph)
    paragraph.runs.filter_map do |run|
      props = run.properties
      next if props.nil?

      flags = []
      flags << "bold" unless props.bold.nil?
      flags << "italic" unless props.italic.nil?
      flags
    end.flatten
  end

  describe "lazy loading" do
    it "does not load the coradoc gems when uniword is required" do
      code = 'require "uniword"; print defined?(Coradoc).inspect'
      out = IO.popen([RbConfig.ruby, "-e", code], &:read)
      expect(out).to eq("nil")
    end
  end

  describe "#to_markdown" do
    it "emits a marker for every supported feature" do
      md = converter.to_markdown(build_feature_document.build)

      expect(md).to include("# Main Title")
      expect(md).to include("## Section")
      expect(md).to include("**bold word**")
      expect(md).to include("*italic word*")
      expect(md).to include("- first")
      expect(md).to include("- second")
      expect(md).to include("| Name | Value |")
      expect(md).to include("| --- | --- |")
      expect(md).to include("[Example Site](https://example.com)")
    end

    it "warns about dropped features on the logger" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("Anchored")
      doc.comment(author: "Reviewer", text: "Fix this")

      buffer = StringIO.new
      original_logger = Uniword.logger
      Uniword.logger = Logger.new(buffer)
      converter.to_markdown(doc.build)
    ensure
      Uniword.logger = original_logger
      expect(buffer.string).to include("dropped: comments")
    end

    it "restores rewritten hyperlink ids on the source document" do
      document = build_feature_document.build

      converter.to_markdown(document)

      hyperlinks = document.body.paragraphs.flat_map(&:hyperlinks)
      expect(hyperlinks.first.id).to match(/\ArId\d+\z/)
    end
  end

  describe "#to_markdown_result" do
    it "records converted block counts" do
      result = converter.to_markdown_result(build_feature_document.build)

      expect(result.format).to eq(:markdown)
      expect(result.direction).to eq(:docx_to_markdown)
      expect(result.block_counts[:headings]).to eq(1)
      expect(result.block_counts[:lists]).to eq(1)
      expect(result.block_counts[:tables]).to eq(1)
      expect(result.block_counts[:links]).to eq(1)
      expect(result).to be_clean
      expect(result.dropped_features).to be_empty
    end

    it "records dropped features for lossy content" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("Anchored")
      doc.comment(author: "Reviewer", text: "Fix this")

      result = converter.to_markdown_result(doc.build)

      expect(result).not_to be_clean
      expect(result).to be_dropped("comments")
    end

    it "raises FidelityError in strict mode" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("Anchored")
      doc.comment(author: "Reviewer", text: "Fix this")

      expect { converter.to_markdown_result(doc.build, strict: true) }
        .to raise_error(Uniword::FidelityError, /comments/)
    end
  end

  describe "#from_markdown" do
    it "round-trips structure through save and reload" do
      md = converter.to_markdown(build_feature_document.build)
      document = converter.from_markdown(md)
      loaded = reloaded(document, "from_md.docx")

      paragraphs = loaded.body.paragraphs
      expect(heading_style(paragraphs[0])).to eq("Heading1")
      expect(paragraphs[0].text).to eq("Main Title")
      expect(heading_style(paragraphs[1])).to eq("Heading2")
      expect(paragraphs[1].text).to eq("Section")

      # bold and italic runs survive with their formatting
      expect(run_flags(paragraphs[2])).to eq(%w[bold italic])

      # list items keep their numbering reference
      list_items = paragraphs.select do |p|
        numbering = p.properties&.numbering_properties
        numbering && !numbering.num_id.nil?
      end
      expect(list_items.map(&:text)).to eq(%w[first second])

      # table survives with its header row
      table = loaded.body.tables.first
      expect(table.rows.size).to eq(2)
      expect(table.rows.first.cells.map(&:text)).to eq(%w[Name Value])
      expect(table.rows.first.properties.tbl_header).not_to be_nil
      expect(table.rows.last.properties&.tbl_header).to be_nil
    end

    it "keeps inline links as literal text (upstream flattening)" do
      document = converter.from_markdown(
        "See [Example Site](https://example.com) for more.",
      )

      paragraph = document.body.paragraphs.first
      expect(paragraph.hyperlinks).to be_empty
      expect(paragraph.text)
        .to include("[Example Site](https://example.com)")
    end
  end

  describe "#to_asciidoc" do
    it "emits an AsciiDoc marker for every supported feature" do
      adoc = converter.to_asciidoc(build_feature_document.build)

      expect(adoc).to include("= Main Title")
      expect(adoc).to include("=== Section")
      expect(adoc).to include("*bold word*")
      expect(adoc).to include("_italic word_")
      expect(adoc).to include("* first")
      expect(adoc).to include("* second")
      expect(adoc).to include("|===")
      expect(adoc).to include("| Name | Value")
      expect(adoc).to include("https://example.com[Example Site]")
    end
  end

  describe "#from_asciidoc" do
    it "round-trips structure through save and reload" do
      adoc = converter.to_asciidoc(build_feature_document.build)
      document = converter.from_asciidoc(adoc)
      loaded = reloaded(document, "from_adoc.docx")

      paragraphs = loaded.body.paragraphs
      expect(paragraphs.map(&:text)).to include("Main Title")
      expect(heading_style(paragraphs[1])).to eq("Heading2")
      expect(paragraphs[1].text).to eq("Section")
      expect(run_flags(paragraphs[2])).to eq(%w[bold italic])

      table = loaded.body.tables.first
      expect(table.rows.size).to eq(2)
      expect(table.rows.first.properties.tbl_header).not_to be_nil

      # links become real External relationships
      hyperlink = paragraphs.flat_map(&:hyperlinks).first
      display_text = hyperlink.runs.flat_map(&:text).map(&:content).join
      expect(display_text).to eq("Example Site")
      rels = loaded.document_rels.relationships
      target = rels.find do |rel|
        rel.type.include?("hyperlink") && rel.target == "https://example.com"
      end
      expect(target).not_to be_nil
      expect(hyperlink.id).to eq(target.id)
    end
  end

  describe "fidelity boundary detection" do
    it "detects headers and footers" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("Body text")
      doc.footer { |f| f << "Footer text" }

      result = converter.to_markdown_result(doc.build)

      expect(result).to be_dropped("headers/footers")
    end

    it "detects section properties" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("Body text")
      doc.section

      result = converter.to_markdown_result(doc.build)

      expect(result).to be_dropped("section properties")
    end

    it "detects tracked changes without crashing the conversion" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("kept text")
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      insertion = Uniword::Wordprocessingml::Insertion.new
      insertion.runs << Uniword::Wordprocessingml::Run.new(text: "inserted")
      paragraph.insertions << insertion
      doc << paragraph

      result = converter.to_markdown_result(doc.build)

      expect(result).to be_dropped("tracked changes")
    end

    it "detects math content" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("Euler wrote")
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      paragraph.o_maths << Omml::Models::OMath.new
      doc << paragraph

      result = converter.to_markdown_result(doc.build)

      expect(result).to be_dropped("math (OMML)")
    end

    it "detects content controls (unwrapped)" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("before")
      doc.content_control(tag: "name", alias_name: "Name",
                          placeholder_text: "Enter name")
      doc.paragraph("after")

      result = converter.to_markdown_result(doc.build)

      expect(result).to be_dropped("structured document tags (unwrapped)")
    end

    it "detects images" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph("with picture")
      run = Uniword::Wordprocessingml::Run.new
      run.drawings << Uniword::Wordprocessingml::Drawing.new
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      paragraph.runs << run
      doc << paragraph

      result = converter.to_markdown_result(doc.build)

      expect(result).to be_dropped("images")
    end

    it "converts footnotes to GFM references and definitions" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph do |p|
        p << "Has a note"
        p << doc.footnote("The note text")
      end

      result = converter.to_markdown_result(doc.build)

      expect(result).not_to be_dropped("footnotes")
      expect(result.text).to include("Has a note")
      expect(result.text).to include("[^")
      expect(result.text).to include("The note text")
    end
  end
end
