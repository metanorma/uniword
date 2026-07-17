# frozen_string_literal: true

require "spec_helper"
require "zip"

RSpec.describe "Word compatibility" do
  let(:output_path) { File.join(Dir.mktmpdir, "word_compat.docx") }

  def read_part(path, part_name)
    Zip::File.open(path) do |z|
      entry = z.find_entry(part_name)
      return nil unless entry

      entry.get_input_stream.read.force_encoding("UTF-8")
    end
  end

  def all_xml_parts(path)
    parts = {}
    Zip::File.open(path) do |z|
      z.each do |entry|
        next if entry.directory?
        next unless entry.name.end_with?(".xml", ".rels")

        parts[entry.name] = entry.get_input_stream.read.force_encoding("UTF-8")
      end
    end
    parts
  end

  describe "from-scratch document" do
    before do
      builder = Uniword::Builder::DocumentBuilder.new
      builder.heading("Test Document", level: 1)
      builder.paragraph("Hello World")
      builder.table do |t|
        t.row { |r| r.cell(text: "A"); r.cell(text: "B") }
      end
      Uniword::DocumentWriter.new(builder.model).save(output_path)
    end

    it "all XML parts have standalone=\"yes\" in declaration" do
      all_xml_parts(output_path).each do |name, xml|
        declaration = xml.lines.first
        expect(declaration).to include('standalone="yes"'),
                                 "#{name} missing standalone=\"yes\": #{declaration}"
      end
    end

    it "paraId values are exactly 8 hex characters" do
      doc = read_part(output_path, "word/document.xml")
      doc.scan(/paraId="([A-Fa-f0-9]+)"/).each do |match|
        expect(match[0].length).to eq(8),
                                   "paraId #{match[0]} is #{match[0].length} chars, must be 8"
      end
    end

    it "rsidR values are exactly 8 hex characters" do
      doc = read_part(output_path, "word/document.xml")
      doc.scan(/rsidR="([A-Fa-f0-9]+)"/).each do |match|
        expect(match[0].length).to eq(8),
                                   "rsidR #{match[0]} is #{match[0].length} chars, must be 8"
      end
    end

    it "fontTable.xml has no empty <w:sig/> elements" do
      ft = read_part(output_path, "word/fontTable.xml")
      expect(ft).not_to include("<w:sig/>"),
                      "fontTable.xml has empty <w:sig/> which violates CT_FontSig schema"
    end

    it "theme1.xml has no empty <a:extLst/> element" do
      theme = read_part(output_path, "word/theme/theme1.xml")
      expect(theme).not_to include("<a:extLst/>"),
                         "theme1.xml has empty <a:extLst/>"
    end

    it "RunProperties elements follow ECMA-376 CT_RPr schema order" do
      styles = read_part(output_path, "word/styles.xml")
      # Find the docDefaults rPr block
      match = styles.match(%r{<w:rPrDefault><w:rPr>(.*?)</w:rPr>})
      expect(match).not_to be_nil, "docDefaults rPrDefault not found"

      rpr_content = match[1]
      elements = rpr_content.scan(/<w:(\w+)/).flatten

      # Verify kern comes before sz (the most common ordering violation)
      kern_idx = elements.index("kern")
      sz_idx = elements.index("sz")

      next unless kern_idx && sz_idx

      expect(kern_idx).to be < sz_idx,
                           "kern must come before sz in CT_RPr, got kern at #{kern_idx}, sz at #{sz_idx}"
    end

    it "Style elements follow ECMA-376 CT_Style schema order" do
      styles = read_part(output_path, "word/styles.xml")
      # Find Heading1 style block
      match = styles.match(%r{styleId="Heading1".*?</w:style>})
      expect(match).not_to be_nil, "Heading1 style not found"

      style_content = match[0]
      elements = style_content.scan(/<w:(\w+)/).flatten

      # semiHidden and unhideWhenUsed must come before qFormat
      semihidden_idx = elements.index("semiHidden")
      qformat_idx = elements.index("qFormat")

      # Only check if all three are present
      next unless semihidden_idx && qformat_idx

      expect(semihidden_idx).to be < qformat_idx,
                                   "semiHidden must come before qFormat in CT_Style"
    end

    it "TableProperties elements follow ECMA-376 CT_TblPrBase schema order" do
      doc = read_part(output_path, "word/document.xml")
      # Find the table properties block
      match = doc.match(%r{<w:tblPr>(.*?)</w:tblPr>})
      next unless match

      tblpr_content = match[1]
      elements = tblpr_content.scan(/<w:(\w+)/).flatten

      # tblStyle must come first if present
      tblstyle_idx = elements.index("tblStyle")
      tblw_idx = elements.index("tblW")

      next unless tblstyle_idx && tblw_idx

      expect(tblstyle_idx).to be < tblw_idx,
                                  "tblStyle must come before tblW in CT_TblPrBase"
    end

    it "all XML is well-formed" do
      require "nokogiri"
      all_xml_parts(output_path).each do |name, xml|
        expect { Nokogiri::XML(xml) }.not_to raise_error
        doc = Nokogiri::XML(xml)
        expect(doc.errors).to be_empty,
                              "#{name} has XML errors: #{doc.errors.map(&:message).join(', ')}"
      end
    end
  end

  describe "round-trip of external file" do
    let(:template_path) { "spec/examples/generated/simple_document.docx" }

    before do
      skip "template not found" unless File.exist?(template_path)
    end

    it "preserves standalone=\"yes\" on all parts after round-trip" do
      root = Uniword.load(template_path)
      Uniword::DocumentWriter.new(root).save(output_path)

      all_xml_parts(output_path).each do |name, xml|
        declaration = xml.lines.first
        expect(declaration).to include('standalone="yes"'),
                                 "#{name} missing standalone after round-trip"
      end
    end

    it "preserves element order through round-trip" do
      # Load original, save round-trip, compare element sequences
      root = Uniword.load(template_path)
      Uniword::DocumentWriter.new(root).save(output_path)

      orig_styles = read_part(template_path, "word/styles.xml")
      rt_styles = read_part(output_path, "word/styles.xml")

      # Extract element sequences from Heading1 style in both
      extract = lambda do |xml|
        match = xml.match(%r{styleId="Heading1".*?</w:style>})
        match ? match[0].scan(/<w:(\w+)/).flatten : []
      end

      orig_elements = extract.call(orig_styles)
      rt_elements = extract.call(rt_styles)

      expect(rt_elements).to eq(orig_elements),
                             "element order changed during round-trip"
    end
  end
end
