# frozen_string_literal: true

require "spec_helper"

# The MHTML converter rendered only document.body.elements, so a document's
# footnotes — which the DOCX output keeps in word/footnotes.xml — never
# reached the MHTML body. Word's own MHTML export carries them as a
# footnote-list section at the end of the body; this suite pins that
# behavior.
RSpec.describe Uniword::Transformation::OoxmlToMhtmlConverter do
  let(:ns) { 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"' }

  def footnote_xml(id, type: nil, text: "Body of footnote #{id}")
    type_attr = type ? %( w:type="#{type}") : ""
    <<~XML
      <w:footnote#{type_attr} w:id="#{id}"><w:p><w:r><w:t xml:space="preserve">#{text}</w:t></w:r></w:p></w:footnote>
    XML
  end

  def document_with_footnotes(footnote_xmls)
    Uniword::Wordprocessingml::DocumentRoot.from_xml(
      <<~XML
        <w:document #{ns}>
          <w:body><w:p><w:r><w:t>Hello</w:t></w:r></w:p></w:body>
        </w:document>
      XML
    ).tap do |document|
      document.footnotes = Uniword::Wordprocessingml::Footnotes.from_xml(
        %(<w:footnotes #{ns}>#{footnote_xmls.join}</w:footnotes>),
      )
    end
  end

  def converter_for(document)
    described_class.new(document)
  end

  describe "footnote list" do
    it "appends real footnote entries as a footnote-list section" do
      document = document_with_footnotes([footnote_xml(2), footnote_xml(3)])
      html = converter_for(document).build_html_body

      expect(html).to include("mso-element:footnote-list")
      expect(html).to include("mso-element:footnote")
      expect(html).to include("Body of footnote 2")
      expect(html).to include("Body of footnote 3")
    end

    it "anchors each entry with its footnote id" do
      document = document_with_footnotes([footnote_xml(7)])
      html = converter_for(document).build_html_body

      expect(html).to include(%(id="ftn7"))
    end

    it "omits separator and continuationSeparator plumbing entries" do
      document = document_with_footnotes([
        footnote_xml(-1, type: "separator", text: "separator"),
        footnote_xml(0, type: "continuationSeparator", text: "continuation"),
        footnote_xml(1),
      ])
      html = converter_for(document).build_html_body

      expect(html).not_to include("separator")
      expect(html).not_to include("continuation")
      expect(html).to include("Body of footnote 1")
    end

    it "emits no footnote list for a document without footnotes" do
      document = document_with_footnotes([])
      html = converter_for(document).build_html_body

      expect(html).not_to include("mso-element:footnote-list")
    end

    it "renders the entry paragraphs with their run content" do
      document = document_with_footnotes([
        footnote_xml(1, text: "Withdrawn."),
      ])
      html = converter_for(document).build_html_body

      expect(html).to include("Withdrawn.")
    end
  end
end
