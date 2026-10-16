# frozen_string_literal: true

require "spec_helper"

# This converter read the rPr toggles by object presence — `if props.bold` is
# true whenever the <w:b> element exists, whatever its w:val says — so an
# explicitly-not-bold run came out <strong>. Its sibling MhtmlElementRenderer
# reads the same run correctly, and the two disagreed about the same document.
RSpec.describe Uniword::Transformation::OoxmlToHtmlConverter do
  let(:ns) { 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"' }

  def run_with(rpr)
    Uniword::Wordprocessingml::Run.from_xml(
      %(<w:r #{ns}><w:rPr>#{rpr}</w:rPr><w:t>hi</w:t></w:r>),
    )
  end

  spellings = { "1" => true, "true" => true, "on" => true,
                "0" => false, "false" => false, "off" => false }.freeze

  describe ".run_to_html" do
    spellings.each do |spelling, bold|
      it "#{bold ? 'wraps' : 'does not wrap'} <strong> for w:b w:val=#{spelling.inspect}" do
        html = described_class.run_to_html(run_with(%(<w:b w:val="#{spelling}"/>)))

        expect(html).to eq(bold ? "<strong>hi</strong>" : "hi")
      end

      it "#{bold ? 'wraps' : 'does not wrap'} <em> for w:i w:val=#{spelling.inspect}" do
        html = described_class.run_to_html(run_with(%(<w:i w:val="#{spelling}"/>)))

        expect(html).to eq(bold ? "<em>hi</em>" : "hi")
      end
    end

    it "wraps a bare <w:b/>, which ST_OnOff reads as on" do
      expect(described_class.run_to_html(run_with("<w:b/>"))).to eq("<strong>hi</strong>")
    end

    it "wraps a bare <w:i/>, which ST_OnOff reads as on" do
      expect(described_class.run_to_html(run_with("<w:i/>"))).to eq("<em>hi</em>")
    end

    it "leaves a run with no toggles alone" do
      expect(described_class.run_to_html(run_with(""))).to eq("hi")
    end
  end

  # The two renderers in this namespace have to agree about the same run.
  # They use different tag vocabularies (HTML5 <strong> vs HTML4 <b>), so
  # compare whether each emphasised the run at all, not the markup.
  describe "agreement with MhtmlElementRenderer" do
    spellings.each_key do |spelling|
      it "agrees on whether w:val=#{spelling.inspect} is bold" do
        run = run_with(%(<w:b w:val="#{spelling}"/>))

        expect(described_class.run_to_html(run).include?("<strong>"))
          .to be(Uniword::Transformation::MhtmlElementRenderer.new
                   .run_to_html(run).include?("<b>"))
      end
    end
  end

  # The bug is reachable from the gem's public API, not just this internal.
  describe "through DocumentRoot#to_html_document" do
    def document_html(spelling)
      Uniword::Wordprocessingml::DocumentRoot.from_xml(<<~XML).to_html_document
        <w:document #{ns}><w:body><w:p><w:r>
          <w:rPr><w:b w:val="#{spelling}"/></w:rPr>
          <w:t>explicitly not bold</w:t>
        </w:r></w:p></w:body></w:document>
      XML
    end

    %w[0 false off].each do |spelling|
      it "does not emit <strong> for w:b w:val=#{spelling.inspect}" do
        expect(document_html(spelling)).not_to include("<strong>")
      end
    end

    %w[1 true on].each do |spelling|
      it "emits <strong> for w:b w:val=#{spelling.inspect}" do
        expect(document_html(spelling)).to include("<strong>")
      end
    end
  end
end
