# frozen_string_literal: true

require "spec_helper"

# lutaml-model hands a custom `to:` method the accumulating hash and drops its
# return value, so every Style writer that returned a value wrote nothing.
# Style#to_yaml silently lost name, quick_format, based_on, next_style,
# linked_style and ui_priority — six keys, one of them an ST_OnOff toggle.
RSpec.describe Uniword::Wordprocessingml::Style do
  let(:ns) { 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"' }

  def parse(inner, attrs = "")
    described_class.from_xml(
      %(<w:style #{ns} w:type="paragraph" w:styleId="Heading1" #{attrs}>) +
      "#{inner}</w:style>",
    )
  end

  describe "#to_yaml" do
    it "writes every key a populated style sets" do
      style = parse(<<~XML)
        <w:name w:val="heading 1"/>
        <w:basedOn w:val="Normal"/>
        <w:next w:val="Normal"/>
        <w:link w:val="Heading1Char"/>
        <w:uiPriority w:val="9"/>
        <w:qFormat/>
      XML

      expect(YAML.safe_load(style.to_yaml)).to eq(
        "id" => "Heading1",
        "type" => "paragraph",
        "name" => "heading 1",
        "quick_format" => true,
        "based_on" => "Normal",
        "next_style" => "Normal",
        "linked_style" => "Heading1Char",
        "ui_priority" => 9,
      )
    end

    it "leaves out the keys the style does not set" do
      expect(YAML.safe_load(parse("").to_yaml).keys).to eq(%w[id type])
    end

    # Only the six keys these writers own. w:default and w:customStyle are
    # plain `map` entries that read back as false rather than absent; that
    # asymmetry predates this change and is not what these writers control.
    # Both sides are compared against an explicit hash, not against each other:
    # if the six writers regressed, both serializations would lose the same six
    # keys and a self-comparison would still pass.
    it "survives the YAML round trip" do
      keys = %w[name quick_format based_on next_style linked_style ui_priority]
      expected = {
        "name" => "heading 1",
        "quick_format" => false,
        "based_on" => "Normal",
        "next_style" => "Normal",
        "linked_style" => "Heading1Char",
        "ui_priority" => 9,
      }
      style = parse(<<~XML)
        <w:name w:val="heading 1"/>
        <w:basedOn w:val="Normal"/>
        <w:next w:val="Normal"/>
        <w:link w:val="Heading1Char"/>
        <w:uiPriority w:val="9"/>
        <w:qFormat w:val="0"/>
      XML

      reparsed = described_class.from_yaml(style.to_yaml)

      expect(YAML.safe_load(style.to_yaml).slice(*keys)).to eq(expected)
      expect(YAML.safe_load(reparsed.to_yaml).slice(*keys)).to eq(expected)
    end
  end

  # w:qFormat is ST_OnOff. Every spelling has to reach YAML as the boolean
  # Word would show, not as the mere presence of the element.
  describe "#to_yaml quick_format across the ST_OnOff spellings" do
    { "1" => true, "true" => true, "on" => true,
      "0" => false, "false" => false, "off" => false }.each do |spelling, expected|
      it "writes quick_format #{expected} for w:val=#{spelling.inspect}" do
        style = parse(%(<w:qFormat w:val="#{spelling}"/>))

        expect(YAML.safe_load(style.to_yaml)["quick_format"]).to be(expected)
      end
    end

    it "writes quick_format true for a bare element" do
      expect(YAML.safe_load(parse("<w:qFormat/>").to_yaml)["quick_format"]).to be(true)
    end

    it "leaves quick_format out when the style has no w:qFormat" do
      expect(YAML.safe_load(parse("").to_yaml)).not_to have_key("quick_format")
    end
  end
end
