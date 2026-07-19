# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Ooxml::ElementOrder do
  let(:footnotes_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:footnotes xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:footnote w:id="1"><w:p><w:r><w:t>x</w:t></w:r></w:p></w:footnote></w:footnotes>
    XML
  end

  let(:parsed) do
    Uniword::Wordprocessingml::Footnotes.from_xml(footnotes_xml)
  end

  describe ".mutable_order" do
    it "returns a mutable copy for a parsed (frozen) order" do
      expect(parsed.element_order).to be_frozen

      order = described_class.mutable_order(parsed)

      expect(order).not_to be_frozen
      expect(order.map(&:name)).to eq(%w[footnote])
    end

    it "assigns the thawed array back so mutations register" do
      order = described_class.mutable_order(parsed)
      order << Lutaml::Xml::Element.new("Element", "footnote")

      expect(parsed.element_order.map(&:name))
        .to eq(%w[footnote footnote])
    end
  end

  describe ".insert_once" do
    it "inserts after the named anchor" do
      described_class.insert_once(parsed, "bookmarkStart",
                                  after: "footnote")

      expect(parsed.element_order.map(&:name))
        .to eq(%w[footnote bookmarkStart])
    end

    it "inserts before the named anchor" do
      described_class.insert_once(parsed, "bookmarkStart",
                                  before: "footnote")

      expect(parsed.element_order.map(&:name))
        .to eq(%w[bookmarkStart footnote])
    end

    it "appends when the after-anchor is missing" do
      described_class.insert_once(parsed, "bookmarkStart",
                                  after: "no_such_element")

      expect(parsed.element_order.map(&:name).last).to eq("bookmarkStart")
    end

    it "is idempotent for existing entries" do
      described_class.insert_once(parsed, "footnote", after: "footnote")

      expect(parsed.element_order.map(&:name)).to eq(%w[footnote])
    end
  end

  describe ".insert_at" do
    it "inserts at the given position" do
      described_class.insert_at(parsed, 1,
                                Lutaml::Xml::Element.new("Element", "sdt"))

      expect(parsed.element_order.map(&:name))
        .to eq(%w[footnote sdt])
    end
  end

  describe ".append" do
    it "appends repeatable entries" do
      2.times do
        described_class.append(parsed,
                               Lutaml::Xml::Element.new("Element", "footnote"))
      end

      expect(parsed.element_order.map(&:name).count("footnote")).to eq(3)
    end
  end

  # Regression lock for the bug class: parse (frozen order) → mutate
  # (reconcile-time injection) → serialize must not raise FrozenError.
  describe "parse → mutate → serialize regressions" do
    it "footnotes: separator injection on parsed notes serializes" do
      notes = parsed
      notes.footnote_entries.unshift(
        Uniword::Wordprocessingml::Footnote.new(
          id: -1, type: "separator",
          paragraphs: [Uniword::Wordprocessingml::Paragraph.new],
        ),
      )

      expect { notes.to_xml }.not_to raise_error
      expect(notes.to_xml).to include("separator")
    end

    it "endnotes: separator injection on parsed notes serializes" do
      endnotes_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:endnotes xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:endnote w:id="1"><w:p><w:r><w:t>x</w:t></w:r></w:p></w:endnote></w:endnotes>
      XML
      endnotes = Uniword::Wordprocessingml::Endnotes.from_xml(endnotes_xml)
      endnotes.endnote_entries.unshift(
        Uniword::Wordprocessingml::Endnote.new(
          id: -1, type: "separator",
          paragraphs: [Uniword::Wordprocessingml::Paragraph.new],
        ),
      )

      expect { endnotes.to_xml }.not_to raise_error
      expect(endnotes.to_xml).to include("separator")
    end

    it "body: TOC insert on a parsed document serializes" do
      doc_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>Heading</w:t></w:r></w:p></w:body></w:document>
      XML
      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(doc_xml)
      generator = Uniword::Toc::TocGenerator.new(doc)
      generator.insert(
        [Uniword::Toc::TocEntry.new(level: 1, text: "Heading")],
        position: 0,
      )

      expect { doc.to_xml }.not_to raise_error
      expect(doc.to_xml).to include("TOC")
    end

    it "settings: updateFields on parsed settings serializes in order" do
      settings_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:characterSpacingControl w:val="doNotCompress"/></w:settings>
      XML
      settings = Uniword::Wordprocessingml::Settings.from_xml(settings_xml)
      settings.update_fields = Uniword::Wordprocessingml::UpdateFields.new
      described_class.insert_once(settings, "updateFields",
                                  after: "characterSpacingControl")

      xml = settings.to_xml
      expect(xml).to include("updateFields")
      expect(xml.index("characterSpacingControl"))
        .to be < xml.index("updateFields")
    end
  end
end
