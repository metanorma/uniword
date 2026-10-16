# frozen_string_literal: true

require "spec_helper"

# The ST_OnOff toggles that used to sit outside the converged set.
RSpec.describe "ST_OnOff readers outside run properties" do
  ns = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'

  describe Uniword::Wordprocessingml::StructuredDocumentTag::ShowingPlaceholderHeader do
    # This element mapped no w:val at all, so an explicitly-off flag came
    # back on and the four spellings were indistinguishable.
    { "1" => true, "0" => false, "true" => true, "false" => false,
      "on" => true, "off" => false }.each do |spelling, expected|
      it "reads w:val=#{spelling.inspect} as #{expected}" do
        props = Uniword::Wordprocessingml::StructuredDocumentTagProperties
          .from_xml(%(<w:sdtPr #{ns}><w:showingPlcHdr w:val="#{spelling}"/></w:sdtPr>))

        expect(props.showing_placeholder_header.on?).to be(expected)
      end

      it "round-trips w:val=#{spelling.inspect} without flipping" do
        props = Uniword::Wordprocessingml::StructuredDocumentTagProperties
          .from_xml(%(<w:sdtPr #{ns}><w:showingPlcHdr w:val="#{spelling}"/></w:sdtPr>))
        reparsed = Uniword::Wordprocessingml::StructuredDocumentTagProperties
          .from_xml(props.to_xml)

        expect(reparsed.showing_placeholder_header.on?).to be(expected)
      end
    end

    it "reads a bare element as on" do
      props = Uniword::Wordprocessingml::StructuredDocumentTagProperties
        .from_xml(%(<w:sdtPr #{ns}><w:showingPlcHdr/></w:sdtPr>))

      expect(props.showing_placeholder_header.on?).to be(true)
    end
  end

  describe Uniword::Wordprocessingml::StructuredDocumentTag::Temporary do
    # Same defect as its showingPlcHdr sibling above: no w:val was mapped, so
    # an explicitly-off flag read as on AND the attribute was destroyed on
    # write.
    { "1" => true, "0" => false, "true" => true, "false" => false,
      "on" => true, "off" => false }.each do |spelling, expected|
      it "reads w:val=#{spelling.inspect} as #{expected}" do
        props = Uniword::Wordprocessingml::StructuredDocumentTagProperties
          .from_xml(%(<w:sdtPr #{ns}><w:temporary w:val="#{spelling}"/></w:sdtPr>))

        expect(props.temporary.on?).to be(expected)
      end

      it "round-trips w:val=#{spelling.inspect} without flipping" do
        props = Uniword::Wordprocessingml::StructuredDocumentTagProperties
          .from_xml(%(<w:sdtPr #{ns}><w:temporary w:val="#{spelling}"/></w:sdtPr>))
        reparsed = Uniword::Wordprocessingml::StructuredDocumentTagProperties
          .from_xml(props.to_xml)

        expect(reparsed.temporary.on?).to be(expected)
      end
    end

    # The write half: an off flag has to survive as an attribute on disk, not
    # come back out as a bare <w:temporary/> that every reader calls on.
    # Assert the value that was written, not merely that some w:val exists —
    # w:val="1" would satisfy a bare presence check while inverting the flag.
    %w[0 false off].each do |spelling|
      it "writes w:val=#{spelling.inspect} back out unchanged" do
        props = Uniword::Wordprocessingml::StructuredDocumentTagProperties
          .from_xml(%(<w:sdtPr #{ns}><w:temporary w:val="#{spelling}"/></w:sdtPr>))

        expect(props.to_xml).to match(/<w:temporary[^>]*w:val="#{spelling}"/)
      end
    end

    it "reads a bare element as on" do
      props = Uniword::Wordprocessingml::StructuredDocumentTagProperties
        .from_xml(%(<w:sdtPr #{ns}><w:temporary/></w:sdtPr>))

      expect(props.temporary.on?).to be(true)
    end

    # Built in code rather than parsed. This is the half BooleanValSetter
    # owns: it normalises an assigned boolean so an on toggle writes the bare
    # element Word expects and an off one writes w:val="false".
    it "writes a bare element when built on" do
      expect(described_class.new(value: true).to_xml).not_to match(/val=/)
    end

    # "false" specifically: BooleanValSetter normalises an assigned Ruby
    # boolean to the one ST_OnOff spelling, so the output is not merely "some
    # off token".
    it "writes val=\"false\" when built off" do
      expect(described_class.new(value: false).to_xml).to match(/val="false"/)
    end

    it "reads back what it built, both ways" do
      expect([true, false].map { |v| described_class.new(value: v).on? })
        .to eq([true, false])
    end
  end

  describe Uniword::Wordprocessingml::UpdateFields do
    { "1" => true, "0" => false, "true" => true, "false" => false,
      "on" => true, "off" => false }.each do |spelling, expected|
      it "reads w:val=#{spelling.inspect} as #{expected}" do
        expect(described_class.from_xml(%(<w:updateFields #{ns} w:val="#{spelling}"/>)).on?)
          .to be(expected)
      end
    end

    it "reads a bare element as on, the way Word does" do
      expect(described_class.from_xml(%(<w:updateFields #{ns}/>)).on?).to be(true)
    end

    # The old OoxmlBoolean-typed attribute raised on anything outside the
    # ST_OnOff vocabulary. A reader must not blow up on a malformed document.
    it "reads an unknown token as on instead of raising" do
      expect(described_class.from_xml(%(<w:updateFields #{ns} w:val="banana"/>)).on?)
        .to be(true)
    end

    it "still exposes value as a boolean" do
      expect(described_class.new.value).to be(true)
    end
  end
end
