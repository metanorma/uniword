# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

# Pin the text-escaping contract: builder-carried strings become Run
# text data, and the XML mapping must escape XML specials inside <w:t>.
# metanorma-iso#898 found the isodoc layer dropping dl terms carrying
# bare "&" and "<"; this spec keeps uniword's own path from regressing
# the same way.
RSpec.describe Uniword::Builder::ParagraphBuilder do
  let(:builder) { described_class.new }
  let(:special) { "Fish & Chips <1> >0" }

  def paragraph_xml
    builder << special
    builder.model.to_xml
  end

  it "escapes XML specials inside w:t" do
    xml = paragraph_xml

    expect(xml).to include("&amp;")
    expect(xml).to include("&lt;1&gt;")
    expect(xml).to include("&gt;0")
  end

  it "never emits the raw specials inside w:t" do
    xml = paragraph_xml

    expect(xml).not_to include("Fish & Chips")
    expect(xml).not_to include("<1>")
  end

  it "round-trips the literal characters" do
    paragraph = Uniword::Wordprocessingml::Paragraph.from_xml(paragraph_xml)

    expect(paragraph.text).to eq(special)
  end
end
