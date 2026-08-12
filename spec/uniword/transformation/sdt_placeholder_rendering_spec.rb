# frozen_string_literal: true

require "spec_helper"

# The renderer used to emit the SDT flags for the mere presence of their
# elements, so <w:showingPlcHdr w:val="0"/> came out of the round trip as a
# placeholder Word would show, and <w:temporary w:val="0"/> as an SDT Word
# would delete on first edit. Both now read the toggle like every other one.
RSpec.describe Uniword::Transformation::MhtmlElementRenderer do
  subject(:renderer) { described_class.new }

  let(:ns) { 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"' }

  def render(flag)
    xml = <<~XML
      <w:p #{ns}>
        <w:sdt>
          <w:sdtPr>#{flag}</w:sdtPr>
          <w:sdtContent><w:r><w:t>Click here</w:t></w:r></w:sdtContent>
        </w:sdt>
      </w:p>
    XML
    renderer.paragraph_to_html(Uniword::Wordprocessingml::Paragraph.from_xml(xml))
  end

  { "1" => true, "true" => true, "on" => true,
    "0" => false, "false" => false, "off" => false }.each do |spelling, shown|
    it "#{shown ? 'emits' : 'omits'} showingPlcHdr for w:val=#{spelling.inspect}" do
      html = render(%(<w:showingPlcHdr w:val="#{spelling}"/>))

      if shown
        expect(html).to include('w:showingPlcHdr="t"')
      else
        expect(html).not_to include("showingPlcHdr")
      end
    end
  end

  it "emits showingPlcHdr for a bare element" do
    expect(render("<w:showingPlcHdr/>")).to include('w:showingPlcHdr="t"')
  end

  it "omits showingPlcHdr when the sdt has no placeholder flag" do
    expect(render("")).not_to include("showingPlcHdr")
  end

  { "1" => true, "true" => true, "on" => true,
    "0" => false, "false" => false, "off" => false }.each do |spelling, shown|
    it "#{shown ? 'emits' : 'omits'} temporary for w:val=#{spelling.inspect}" do
      html = render(%(<w:temporary w:val="#{spelling}"/>))

      if shown
        expect(html).to include('w:temporary="t"')
      else
        expect(html).not_to include("temporary")
      end
    end
  end

  it "emits temporary for a bare element" do
    expect(render("<w:temporary/>")).to include('w:temporary="t"')
  end

  it "omits temporary when the sdt has no temporary flag" do
    expect(render("")).not_to include("temporary")
  end
end
