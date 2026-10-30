# frozen_string_literal: true

require "spec_helper"
require "uniword/mhtml/word_css"

RSpec.describe Uniword::Mhtml::WordCss do
  describe ".default_css" do
    it "returns CSS string" do
      css = described_class.default_css
      expect(css).to be_a(String)
      expect(css).not_to be_empty
    end

    it "includes MsoNormal style" do
      css = described_class.default_css
      expect(css).to include("MsoNormal")
    end

    it "includes heading styles" do
      css = described_class.default_css
      expect(css).to include("h1")
      expect(css).to include("h2")
      expect(css).to include("h3")
    end

    it "includes font definitions" do
      css = described_class.default_css
      expect(css).to include("@font-face")
      expect(css).to include("font-family")
    end

    it "includes page definitions" do
      css = described_class.default_css
      expect(css).to include("@page")
    end

    it "includes list definitions" do
      css = described_class.default_css
      expect(css).to include("@list")
    end

    it "includes table styles" do
      css = described_class.default_css
      expect(css).to include("MsoNormalTable")
    end
  end

  describe ".basic_css" do
    it "returns fallback CSS" do
      css = described_class.basic_css
      expect(css).to be_a(String)
      expect(css).not_to be_empty
    end

    it "includes essential styles" do
      css = described_class.basic_css
      expect(css).to include("MsoNormal")
      expect(css).to include("h1")
      expect(css).to include("h2")
      expect(css).to include("h3")
      expect(css).to include("MsoNormalTable")
      expect(css).to include("MsoHyperlink")
    end
  end

  # WordCss consumes a WordprocessingML styles configuration: generate_style_css
  # calls styles_config.styles.map and then reads style-object methods, while
  # Mhtml::StylesConfiguration#styles is a plain hash of CSS properties.
  def styles_config_from(*style_xml)
    Uniword::Wordprocessingml::StylesConfiguration.from_xml(<<~XML)
      <w:styles
        xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        #{style_xml.join}
      </w:styles>
    XML
  end

  # Note w:sz is in half-points, so w:val="24" is a 12pt font.
  def style_xml(id, **opts)
    [
      %(<w:style w:type="paragraph" w:styleId="#{id}">),
      paragraph_props_xml(opts[:align]),
      run_props_xml(opts),
      "</w:style>",
    ].join
  end

  def paragraph_props_xml(align)
    return "" unless align

    %(<w:pPr><w:jc w:val="#{align}"/></w:pPr>)
  end

  def run_props_xml(opts)
    parts = [
      (%(<w:rFonts w:ascii="#{opts[:font]}"/>) if opts[:font]),
      ("<w:b/>" if opts[:bold]),
      ("<w:i/>" if opts[:italic]),
      (%(<w:sz w:val="#{opts[:half_points]}"/>) if opts[:half_points]),
    ].compact
    return "" if parts.empty?

    "<w:rPr>#{parts.join}</w:rPr>"
  end

  def single_style(xml)
    styles_config_from(xml).styles.first
  end

  # A style whose w:b and w:i carry explicit ST_OnOff values.
  def toggle_style(bold_val, italic_val)
    single_style(<<~XML)
      <w:style w:type="paragraph" w:styleId="Toggles"><w:rPr>
        <w:b w:val="#{bold_val}"/><w:i w:val="#{italic_val}"/>
        <w:rFonts w:ascii="Arial"/>
      </w:rPr></w:style>
    XML
  end

  # generate_list_css calls numbering_config.instances, which only
  # Wordprocessingml::NumberingConfiguration declares.
  def numbering_config_from(*num_ids)
    nums = num_ids.map { |id| %(<w:num w:numId="#{id}"/>) }.join
    Uniword::Wordprocessingml::NumberingConfiguration.from_xml(<<~XML)
      <w:numbering
        xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        #{nums}
      </w:numbering>
    XML
  end

  describe ".generate_style_css" do
    it "returns empty string for nil config" do
      css = described_class.generate_style_css(nil)
      expect(css).to eq("")
    end

    it "generates CSS from a parsed WordprocessingML styles configuration" do
      config = styles_config_from(
        style_xml("RichStyle", font: "Arial", bold: true, italic: true,
                               align: "right"),
      )

      expected = <<~CSS.chomp
        .RichStyle {
          font-family: 'Arial';
          font-weight: bold;
          font-style: italic;
          text-align: right;
        }
      CSS

      expect(described_class.generate_style_css(config)).to eq(expected)
    end

    it "handles styles without optional properties" do
      config = styles_config_from(style_xml("Simple"))

      css = described_class.generate_style_css(config)

      expect(css).to eq("")
    end

    it "generates one rule per style" do
      config = styles_config_from(
        style_xml("First", font: "Arial"),
        style_xml("Second", font: "Georgia"),
      )

      css = described_class.generate_style_css(config)

      expect(css).to include(".First")
      expect(css).to include(".Second")
    end
  end

  describe ".generate_list_css" do
    it "returns empty string for nil config" do
      css = described_class.generate_list_css(nil)
      expect(css).to eq("")
    end

    it "generates CSS for numbering" do
      config = numbering_config_from(1)

      css = described_class.generate_list_css(config)

      expect(css).to include("@list l1")
      expect(css).to include("mso-list-id: 1")
    end

    it "handles multiple numbering instances" do
      config = numbering_config_from(1, 2, 3)

      css = described_class.generate_list_css(config)

      expect(css).to include("@list l1")
      expect(css).to include("@list l2")
      expect(css).to include("@list l3")
    end
  end

  describe ".build_style_rule" do
    it "returns nil for nil style" do
      rule = described_class.build_style_rule(nil)
      expect(rule).to be_nil
    end

    it "builds CSS rule for style with font" do
      style = single_style(style_xml("TestStyle", font: "Times New Roman"))

      rule = described_class.build_style_rule(style)

      expect(rule).to include(".TestStyle")
      expect(rule).to include("Times New Roman")
    end

    it "builds CSS rule for style with multiple properties" do
      style = single_style(
        style_xml("RichStyle", font: "Arial", half_points: 28, bold: true,
                               italic: true, align: "right"),
      )

      rule = described_class.build_style_rule(style)

      expect(rule).to include(".RichStyle")
      expect(rule).to include("Arial")
      expect(rule).to include("14pt")
      expect(rule).to include("bold")
      expect(rule).to include("italic")
      expect(rule).to include("right")
    end

    it "converts the half-point w:sz value to points" do
      style = single_style(style_xml("Sized", half_points: 24))

      expect(described_class.build_style_rule(style))
        .to include("font-size: 12pt")
    end

    it "returns nil for style with no properties" do
      style = single_style(style_xml("EmptyStyle"))

      rule = described_class.build_style_rule(style)

      expect(rule).to be_nil
    end

    # An ST_OnOff false token must not turn the toggle on. rFonts keeps the
    # rule non-nil so the absence assertions have a string to run against.
    it "omits toggles whose w:val is an ST_OnOff false token" do
      rule = described_class.build_style_rule(toggle_style("0", "0"))

      expect(rule).not_to include("font-weight: bold")
      expect(rule).not_to include("font-style: italic")
    end

    it "returns nil for a style with no styleId" do
      style = single_style(
        %(<w:style><w:rPr><w:rFonts w:ascii="Arial"/></w:rPr></w:style>),
      )

      expect(described_class.build_style_rule(style)).to be_nil
    end
  end

  describe ".build_list_rule" do
    it "returns nil for nil instance" do
      rule = described_class.build_list_rule(nil)
      expect(rule).to be_nil
    end

    it "builds @list rule" do
      instance = numbering_config_from(5).instances.first

      rule = described_class.build_list_rule(instance)
      expect(rule).to include("@list l5")
      expect(rule).to include("mso-list-id: 5")
    end
  end

  describe "CSS file existence" do
    it "wordstyle.css file exists" do
      css_path = File.join(__dir__, "../../../lib/uniword/mhtml/wordstyle.css")
      expect(File.exist?(css_path)).to be true
    end

    it "wordstyle.css is readable" do
      css_path = File.join(__dir__, "../../../lib/uniword/mhtml/wordstyle.css")
      expect(File.readable?(css_path)).to be true
    end

    it "wordstyle.css is not empty" do
      css_path = File.join(__dir__, "../../../lib/uniword/mhtml/wordstyle.css")
      content = File.read(css_path)
      expect(content.length).to be > 100
    end
  end
end
