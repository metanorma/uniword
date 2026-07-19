# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Builder::CommentAnchorer do
  let(:w_ns) { "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }

  describe ".anchor" do
    it "is a no-op for a nil paragraph" do
      expect { described_class.anchor(nil, "1") }.not_to raise_error
    end

    context "with a fresh paragraph" do
      let(:paragraph) do
        Uniword::Wordprocessingml::Paragraph.new.tap do |p|
          p.runs << Uniword::Wordprocessingml::Run.new(text: "reviewed text")
        end
      end

      it "appends range markers and a reference run" do
        described_class.anchor(paragraph, "1")

        expect(paragraph.comment_range_starts.map(&:id)).to eq(["1"])
        expect(paragraph.comment_range_ends.map(&:id)).to eq(["1"])
        reference = paragraph.runs.last
        expect(reference.comment_reference.id).to eq("1")
        expect(reference.properties.style.value).to eq("CommentReference")
      end

      it "serializes anchors in Word's canonical order" do
        described_class.anchor(paragraph, "1")

        xml = paragraph.to_xml
        start_pos = xml.index("commentRangeStart")
        run_pos = xml.index("<t>reviewed text</t>")
        end_pos = xml.index("commentRangeEnd")
        ref_pos = xml.index("commentReference")
        expect(start_pos).to be < run_pos
        expect(run_pos).to be < end_pos
        expect(end_pos).to be < ref_pos
      end
    end

    context "with a parsed paragraph" do
      let(:paragraph) do
        Uniword::Wordprocessingml::Paragraph.from_xml(
          %(<w:p xmlns:w="#{w_ns}">) \
          '<w:pPr><w:pStyle w:val="BodyText"/></w:pPr>' \
          '<w:bookmarkStart w:id="3" w:name="mark"/>' \
          "<w:r><w:t>parsed text</w:t></w:r>" \
          '<w:bookmarkEnd w:id="3"/></w:p>',
        )
      end

      it "inserts anchors without disturbing parsed order" do
        described_class.anchor(paragraph, "7")

        xml = paragraph.to_xml
        start_pos = xml.index("commentRangeStart")
        expect(xml.index("pStyle")).to be < start_pos
        expect(start_pos).to be < xml.index("bookmarkStart")
        expect(xml.index("parsed text")).to be < xml.index("bookmarkEnd")
        end_pos = xml.index("commentRangeEnd")
        expect(xml.index("bookmarkEnd")).to be < end_pos
        expect(end_pos).to be < xml.index("commentReference")
      end
    end

    context "with two anchors on the same paragraph" do
      let(:paragraph) do
        Uniword::Wordprocessingml::Paragraph.new.tap do |p|
          p.runs << Uniword::Wordprocessingml::Run.new(text: "shared text")
        end
      end

      it "nests markers the way Word emits them" do
        described_class.anchor(paragraph, "1")
        described_class.anchor(paragraph, "2")

        xml = paragraph.to_xml
        expect(xml.scan("commentRangeStart").size).to eq(2)
        expect(xml.scan("commentRangeEnd").size).to eq(2)
        expect(xml.scan("commentReference").size).to eq(2)

        first_start = xml.index('commentRangeStart w:id="1"')
        second_start = xml.index('commentRangeStart w:id="2"')
        first_end = xml.index('commentRangeEnd w:id="1"')
        first_ref = xml.index('commentReference w:id="1"')
        second_ref = xml.index('commentReference w:id="2"')
        expect(first_start).to be < second_start
        expect(second_start).to be < first_end
        expect(first_end).to be < first_ref
        expect(first_ref).to be < second_ref
      end

      it "keeps element_order consistent with the collections" do
        described_class.anchor(paragraph, "1")
        described_class.anchor(paragraph, "2")

        order = paragraph.element_order
        expect(order.count { |e| e.name == "r" }).to eq(paragraph.runs.size)
        expect(order.count { |e| e.name == "commentRangeStart" })
          .to eq(2)
        expect(order.count { |e| e.name == "commentRangeEnd" })
          .to eq(2)
      end
    end
  end
end
