# frozen_string_literal: true

require "spec_helper"
require "canon/comparison"

# Add canon to load path
$LOAD_PATH.unshift("/Users/mulgogi/src/lutaml/canon/lib")

RSpec.describe "Style Round-Trip Fidelity" do
  describe "XML → Model → XML round-trip" do
    let(:sample_style_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:style xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                 w:type="paragraph"
                 w:styleId="Heading1"
                 w:customStyle="1">
          <w:name w:val="Heading 1"/>
          <w:basedOn w:val="Normal"/>
          <w:next w:val="Normal"/>
          <w:link w:val="Heading1Char"/>
          <w:uiPriority w:val="9"/>
          <w:qFormat/>
          <w:pPr>
            <w:spacing w:before="240" w:after="60"/>
            <w:jc w:val="left"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:outlineLvl w:val="0"/>
          </w:pPr>
          <w:rPr>
            <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
            <w:b/>
            <w:bCs/>
            <w:sz w:val="32"/>
            <w:szCs w:val="32"/>
            <w:color w:val="2E74B5" w:themeColor="accent1" w:themeShade="BF"/>
          </w:rPr>
        </w:style>
      XML
    end

    it "preserves all XML when round-tripping Style" do
      # Parse XML to Model
      style = Uniword::Wordprocessingml::Style.from_xml(sample_style_xml)

      # Serialize back to XML
      output_xml = style.to_xml

      # Compare using Canon
      result = Canon::Comparison.equivalent?(
        sample_style_xml,
        output_xml,
        verbose: true,
      )

      expect(result.equivalent?).to be(true),
                                    "Style XML round-trip failed:\n\nOriginal:\n#{sample_style_xml}\n\nOutput:\n#{output_xml}"
    end

    it "captures style attributes" do
      style = Uniword::Wordprocessingml::Style.from_xml(sample_style_xml)

      expect(style.type).to eq("paragraph")
      expect(style.id).to eq("Heading1")
      expect(style.default).to be(false)
      expect(style.custom?).to be(true)
    end

    it "captures style metadata elements" do
      style = Uniword::Wordprocessingml::Style.from_xml(sample_style_xml)

      expect(style.style_name).to eq("Heading 1")
      expect(style.based_on).to eq("Normal")
      expect(style.next_style).to eq("Normal")
      expect(style.linked_style).to eq("Heading1Char")
      expect(style.ui_priority).to eq(9)
      expect(style.quick_format).to be(true)
    end

    it "captures paragraph properties" do
      style = Uniword::Wordprocessingml::Style.from_xml(sample_style_xml)

      expect(style.spacing_before).to eq(240)
      expect(style.spacing_after).to eq(60)
      expect(style.alignment.value).to eq("left")
      expect(style.keep_next).to be(true)
      expect(style.keep_lines).to be(true)
      expect(style.outline_level).to eq(0)
    end

    it "captures run/character properties" do
      style = Uniword::Wordprocessingml::Style.from_xml(sample_style_xml)

      expect(style.font_family).to eq("Calibri")
      expect(style.bold).to be(true)
      expect(style.font_size).to eq(32)
      expect(style.font_color).to eq("2E74B5")
      expect(style.font_color_theme).to eq("accent1")
      expect(style.font_color_theme_tint).to eq("BF")
    end
  end

  # Word splits one paragraph's spacing across several w:spacing elements
  # (seen in Modern.dotx). Covered with inline XML so it runs without the
  # private fixture submodule.
  describe "repeated w:spacing in one w:pPr" do
    let(:repeated_spacing_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:style xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                 w:type="paragraph" w:styleId="NoSpacing">
          <w:name w:val="No Spacing"/>
          <w:pPr>
            <w:spacing w:before="0" w:after="0"/>
            <w:spacing w:line="240" w:lineRule="auto"/>
          </w:pPr>
        </w:style>
      XML
    end
    let(:style) do
      Uniword::Wordprocessingml::Style.from_xml(repeated_spacing_xml)
    end

    it "keeps every entry when parsing" do
      expect(style.paragraph_properties.spacing.map do |s|
        [s.before, s.after, s.line, s.line_rule]
      end).to eq([[0, 0, nil, nil], [nil, nil, 240, "auto"]])
    end

    it "keeps every entry through a round-trip" do
      reparsed = Uniword::Wordprocessingml::Style.from_xml(
        style.to_xml(prefix: true),
      )

      expect(reparsed.paragraph_properties.spacing.map do |s|
        [s.before, s.after, s.line, s.line_rule]
      end).to eq([[0, 0, nil, nil], [nil, nil, 240, "auto"]])
    end

    it "reads spacing_before and spacing_after across entries" do
      expect([style.spacing_before, style.spacing_after]).to eq([0, 0])
    end

    it "finds a value that lives on a later entry" do
      style = Uniword::Wordprocessingml::Style.from_xml(
        repeated_spacing_xml.sub('w:before="0" w:after="0"', 'w:line="240"')
                            .sub('w:line="240" w:lineRule="auto"',
                                 'w:before="120" w:after="60"'),
      )

      expect([style.spacing_before, style.spacing_after]).to eq([120, 60])
    end

    it "resolves conflicting values last-wins, matching Word readers" do
      style = Uniword::Wordprocessingml::Style.from_xml(
        repeated_spacing_xml.sub('w:line="240" w:lineRule="auto"',
                                 'w:before="777"'),
      )

      expect(style.spacing_before).to eq(777)
    end
  end
end
