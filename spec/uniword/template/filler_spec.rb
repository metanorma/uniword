# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Template::Filler do
  let(:doc) { build_doc }

  def build_doc
    document = Uniword::Wordprocessingml::DocumentRoot.new
    document.body = Uniword::Wordprocessingml::Body.new
    document
  end

  def text_element(content)
    text = Uniword::Wordprocessingml::Text.new(content: content)
    if Uniword::Wordprocessingml::Text.preserve_whitespace?(content)
      text.xml_space = "preserve"
    end
    text
  end

  def run_with_text(content, bold: false)
    run = Uniword::Wordprocessingml::Run.new
    run.text = [text_element(content)]
    if bold
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.bold = Uniword::Properties::Bold.new
    end
    run
  end

  def add_paragraph(*runs)
    para = Uniword::Wordprocessingml::Paragraph.new
    runs.each { |run| para.runs << run }
    doc.body.paragraphs << para
    para
  end

  def set_sdt_name(sdt, name, kind)
    props = Uniword::Wordprocessingml::StructuredDocumentTagProperties.new
    if kind == :alias
      props.alias_name =
        Uniword::Wordprocessingml::StructuredDocumentTag::Alias.new(value: name)
    else
      props.tag =
        Uniword::Wordprocessingml::StructuredDocumentTag::Tag.new(value: name)
    end
    sdt.properties = props
  end

  def add_sdt(name, kind: :alias, runs: nil)
    sdt = Uniword::Wordprocessingml::StructuredDocumentTag.new
    set_sdt_name(sdt, name, kind)
    content = Uniword::Wordprocessingml::StructuredDocumentTag::Content.new
    para = Uniword::Wordprocessingml::Paragraph.new
    add_sdt_runs(para, runs)
    content.paragraphs << para
    sdt.content = content
    doc.body.structured_document_tags << sdt
    sdt
  end

  def add_sdt_runs(para, runs)
    (runs || [run_with_text("placeholder")]).each { |run| para.runs << run }
  end

  def add_field(instr, run_text: "0")
    field = Uniword::Wordprocessingml::SimpleField.new(instr: instr)
    field.runs << run_with_text(run_text)
    para = Uniword::Wordprocessingml::Paragraph.new
    para.simple_fields << field
    doc.body.paragraphs << para
    field
  end

  def sdt_runs(sdt)
    sdt.content.paragraphs.first.runs
  end

  describe "{{var}} text placeholders" do
    it "replaces a placeholder inside run text" do
      para = add_paragraph(run_with_text("Hello {{name}}!"))

      result = described_class.new(doc).fill({ "name" => "World" })

      expect(para.runs.first.text_string).to eq("Hello World!")
      expect(result.filled[:text]).to eq(1)
    end

    it "resolves nested data keys as dotted paths" do
      para = add_paragraph(run_with_text("{{client.name}}"))

      described_class.new(doc).fill({ "client" => { "name" => "Acme" } })

      expect(para.runs.first.text_string).to eq("Acme")
    end

    it "accepts symbol keys" do
      para = add_paragraph(run_with_text("Dear {{client.name}},"))

      described_class.new(doc).fill({ client: { name: "Zoe" } })

      expect(para.runs.first.text_string).to eq("Dear Zoe,")
    end

    it "preserves xml:space for values with surrounding spaces" do
      para = add_paragraph(run_with_text("{{v}}"))

      described_class.new(doc).fill({ "v" => "  padded  " })

      text = para.runs.first.text.first
      expect(text.content).to eq("  padded  ")
      expect(text.xml_space).to eq("preserve")
    end

    it "leaves xml:space unset when the value needs no preservation" do
      para = add_paragraph(run_with_text("{{v}}"))

      described_class.new(doc).fill({ "v" => "x" })

      text = para.runs.first.text.first
      expect(text.content).to eq("x")
      expect(text.xml_space).to be_nil
    end
  end

  describe "content controls" do
    it "fills an sdt matched by alias" do
      sdt = add_sdt("editor")

      result = described_class.new(doc).fill({ "editor" => "Jane" })

      expect(sdt_runs(sdt).first.text_string).to eq("Jane")
      expect(result.filled[:sdt]).to eq(1)
    end

    it "fills an sdt matched by tag when no alias is set" do
      sdt = add_sdt("doc_ref", kind: :tag)

      result = described_class.new(doc).fill({ "doc_ref" => "N123" })

      expect(sdt_runs(sdt).first.text_string).to eq("N123")
      expect(result.filled[:sdt]).to eq(1)
    end

    it "keeps the first run's properties and drops extra runs" do
      runs = [run_with_text("{{sum}}", bold: true), run_with_text(" more")]
      sdt = add_sdt("sum", runs: runs)

      described_class.new(doc).fill({ "sum" => "42 EUR" })

      expect(sdt_runs(sdt).size).to eq(1)
      expect(sdt_runs(sdt).first.text_string).to eq("42 EUR")
      expect(sdt_runs(sdt).first.properties.bold).to be_truthy
    end

    it "keeps a single empty-text run when the value is empty" do
      sdt = add_sdt("note")

      described_class.new(doc).fill({ "note" => "" })

      expect(sdt_runs(sdt).size).to eq(1)
      expect(sdt_runs(sdt).first.text_string).to eq("")
    end

    it "scans an unmatched sdt's content for text placeholders" do
      runs = [run_with_text("{{inside}}")]
      sdt = add_sdt("unknown_control", runs: runs)

      result = described_class.new(doc).fill({ "inside" => "found" })

      expect(sdt_runs(sdt).first.text_string).to eq("found")
      expect(result.filled[:text]).to eq(1)
      expect(result.filled[:sdt]).to eq(0)
    end
  end

  describe "mail merge fields" do
    it "fills a MERGEFIELD simple field" do
      field = add_field(" MERGEFIELD client_name \\* MERGEFORMAT ")

      result = described_class.new(doc).fill({ "client_name" => "Acme" })

      expect(field.runs.first.text_string).to eq("Acme")
      expect(result.filled[:mergefield]).to eq(1)
    end

    it "parses quoted MERGEFIELD names" do
      field = add_field(%( MERGEFIELD "total due" \\* MERGESAVE ))

      described_class.new(doc).fill({ "total due" => " 42 " })

      text = field.runs.first.text.first
      expect(text.content).to eq(" 42 ")
      expect(text.xml_space).to eq("preserve")
    end

    it "ignores non-MERGEFIELD simple fields" do
      field = add_field(" PAGE \\* ARABIC ")

      result = described_class.new(doc).fill({ "PAGE" => "nope" })

      expect(field.runs.first.text_string).to eq("0")
      expect(result.total_filled).to eq(0)
    end
  end

  describe "missing variables" do
    it "leaves unknown placeholders untouched and reports the names" do
      para = add_paragraph(run_with_text("Hello {{ghost}}"))
      para2 = add_paragraph(run_with_text("{{also_missing}}"))

      result = described_class.new(doc).fill({ "name" => "World" })

      expect(para.runs.first.text_string).to eq("Hello {{ghost}}")
      expect(para2.runs.first.text_string).to eq("{{also_missing}}")
      expect(result.missing).to eq(%w[also_missing ghost])
    end

    it "does not fill sdt placeholders whose name has no data" do
      sdt = add_sdt("editor")

      result = described_class.new(doc).fill({})

      expect(sdt_runs(sdt).first.text_string).to eq("placeholder")
      expect(result.missing).to eq(["editor"])
    end

    it "raises MissingVariablesError listing names in strict mode" do
      add_paragraph(run_with_text("{{ghost}}"))
      add_paragraph(run_with_text("{{phantom}}"))

      expect do
        described_class.new(doc).fill({ "ghost" => "x" }, strict: true)
      end.to raise_error(Uniword::MissingVariablesError, /phantom/)
    end

    it "does not raise in strict mode when all variables are present" do
      add_paragraph(run_with_text("{{ghost}}"))

      result = described_class.new(doc).fill({ "ghost" => "x" }, strict: true)

      expect(result.complete?).to be(true)
    end
  end

  describe "container traversal" do
    def add_table_cell_paragraph(para)
      cell = Uniword::Wordprocessingml::TableCell.new
      cell.paragraphs << para
      row = Uniword::Wordprocessingml::TableRow.new
      row.cells << cell
      table = Uniword::Wordprocessingml::Table.new
      table.rows << row
      doc.body.tables << table
    end

    it "fills placeholders inside table cells" do
      cell_para = Uniword::Wordprocessingml::Paragraph.new
      cell_para.runs << run_with_text("{{cell_var}}")
      add_table_cell_paragraph(cell_para)

      result = described_class.new(doc).fill({ "cell_var" => "filled" })

      expect(cell_para.runs.first.text_string).to eq("filled")
      expect(result.filled[:text]).to eq(1)
    end

    def add_all_placeholder_kinds
      add_paragraph(run_with_text("{{who}}"))
      add_sdt("editor")
      add_field(" MERGEFIELD total ")
      add_field(" MERGEFIELD discount ")
    end

    it "counts each source kind separately" do
      data = { "who" => "Ada", "editor" => "Jane",
               "total" => "9", "discount" => "1" }
      add_all_placeholder_kinds
      result = described_class.new(doc).fill(data)
      expect(result.filled).to eq(sdt: 1, mergefield: 2, text: 1)
      expect(result.total_filled).to eq(4)
    end

    it "reports counts and summary through to_h" do
      add_paragraph(run_with_text("{{who}}"))

      result = described_class.new(doc).fill({ "who" => "Ada" })

      expect(result.to_h[:filled][:text]).to eq(1)
      expect(result.to_h[:total_filled]).to eq(1)
      expect(result.to_h[:summary]).to include("1 text placeholder(s)")
    end

    it "serializes the report through to_json" do
      add_paragraph(run_with_text("{{who}}"))

      result = described_class.new(doc).fill({ "who" => "Ada" })

      expect(JSON.parse(result.to_json)["total_filled"]).to eq(1)
    end
  end
end
