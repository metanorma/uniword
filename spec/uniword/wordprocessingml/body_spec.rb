# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::Body do
  describe "#elements" do
    it "returns paragraphs and tables in document order from element_order" do
      xml = <<~XML
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:r><w:t>para one</w:t></w:r></w:p>
            <w:tbl><w:tr><w:tc><w:p><w:r><w:t>in table</w:t></w:r></w:p></w:tc></w:tr></w:tbl>
            <w:p><w:r><w:t>para two</w:t></w:r></w:p>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      kinds = doc.body.elements.map { |e| e.class.name.split("::").last }

      expect(kinds).to eq(["Paragraph", "Table", "Paragraph"])
    end

    it "preserves interleave of multiple tables among paragraphs" do
      xml = <<~XML
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:tbl><w:tr><w:tc><w:p><w:r><w:t>t1</w:t></w:r></w:p></w:tc></w:tr></w:tbl>
            <w:p><w:r><w:t>p1</w:t></w:r></w:p>
            <w:tbl><w:tr><w:tc><w:p><w:r><w:t>t2</w:t></w:r></w:p></w:tc></w:tr></w:tbl>
            <w:p><w:r><w:t>p2</w:t></w:r></w:p>
            <w:tbl><w:tr><w:tc><w:p><w:r><w:t>t3</w:t></w:r></w:p></w:tc></w:tr></w:tbl>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      kinds = doc.body.elements.map { |e| e.class.name.split("::").last }

      expect(kinds).to eq(
        ["Table", "Paragraph", "Table", "Paragraph", "Table"],
      )
    end

    it "places bookmark starts and ends at their actual positions among blocks" do
      xml = <<~XML
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:r><w:t>p1</w:t></w:r></w:p>
            <w:bookmarkStart w:id="0" w:name="bm0"/>
            <w:p><w:r><w:t>p2</w:t></w:r></w:p>
            <w:bookmarkEnd w:id="0"/>
            <w:tbl><w:tr><w:tc><w:p><w:r><w:t>t1</w:t></w:r></w:p></w:tc></w:tr></w:tbl>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      kinds = doc.body.elements.map { |e| e.class.name.split("::").last }

      expect(kinds).to eq(
        ["Paragraph", "BookmarkStart", "Paragraph", "BookmarkEnd", "Table"],
      )
    end

    it "includes section_properties after the other blocks when present in element_order" do
      xml = <<~XML
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:r><w:t>p1</w:t></w:r></w:p>
            <w:tbl><w:tr><w:tc><w:p><w:r><w:t>t1</w:t></w:r></w:p></w:tc></w:tr></w:tbl>
            <w:sectPr/>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)
      kinds = doc.body.elements.map { |e| e.class.name.split("::").last }

      expect(kinds.last).to eq("SectionProperties")
      expect(kinds[0..-2]).to eq(["Paragraph", "Table"])
    end
  end
end
