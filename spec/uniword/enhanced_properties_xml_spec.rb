# frozen_string_literal: true

require "spec_helper"
require "nokogiri"
require "uniword/builder"

RSpec.describe "Enhanced Properties XML Serialization" do
  # Namespace URI for WordProcessingML
  WORDML_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

  describe "Paragraph borders" do
    it "serializes borders to correct XML" do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).borders(
        top: "000000", bottom: "FF0000"
      )

      xml = para.to_xml
      doc = Nokogiri::XML(xml)

      # Verify w:pBdr element exists
      borders = doc.at_xpath("//w:pBdr", "w" => WORDML_NS)
      expect(borders).not_to be_nil

      # Verify top border
      top = borders.at_xpath("w:top", "w" => WORDML_NS)
      expect(top).not_to be_nil
      expect(top["w:color"]).to eq("000000")

      # Verify bottom border
      bottom = borders.at_xpath("w:bottom", "w" => WORDML_NS)
      expect(bottom).not_to be_nil
      expect(bottom["w:color"]).to eq("FF0000")
    end

    it "serializes all border positions" do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).borders(
        top: "000000",
        bottom: "111111",
        left: "222222",
        right: "333333",
        between: "444444",
        bar: "555555"
      )

      xml = para.to_xml
      doc = Nokogiri::XML(xml)

      borders = doc.at_xpath("//w:pBdr", "w" => WORDML_NS)
      expect(borders).not_to be_nil

      %w[top bottom left right between bar].each_with_index do |position, index|
        element = borders.at_xpath("w:#{position}", "w" => WORDML_NS)
        expect(element).not_to be_nil, "Expected #{position} border to exist"
        expected_color = (index.to_s * 6)
        expect(element["w:color"]).to eq(expected_color),
                                      "Expected #{position} border color #{expected_color}"
      end
    end
  end

  describe "Paragraph shading" do
    it "serializes shading to correct XML" do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).shading(
        fill: "FFFF00", pattern: "solid"
      )

      xml = para.to_xml
      doc = Nokogiri::XML(xml)

      shading = doc.at_xpath("//w:shd", "w" => WORDML_NS)
      expect(shading).not_to be_nil
      expect(shading["w:fill"]).to eq("FFFF00")
      expect(shading["w:val"]).to eq("solid")
    end

    it "serializes shading with foreground color" do
      para = Uniword::Wordprocessingml::Paragraph.new
      Uniword::Builder::ParagraphBuilder.new(para).shading(
        fill: "FFFF00", color: "000000", pattern: "diagCross"
      )

      xml = para.to_xml
      doc = Nokogiri::XML(xml)

      shading = doc.at_xpath("//w:shd", "w" => WORDML_NS)
      expect(shading["w:fill"]).to eq("FFFF00")
      expect(shading["w:color"]).to eq("000000")
      expect(shading["w:val"]).to eq("diagCross")
    end
  end

  describe "Tab stops" do
    it "serializes tab stops to correct XML" do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder << Uniword::Builder.tab_stop(
        position: 1440, alignment: "center", leader: "dot"
      )

      xml = para.to_xml
      doc = Nokogiri::XML(xml)

      tabs = doc.at_xpath("//w:tabs", "w" => WORDML_NS)
      expect(tabs).not_to be_nil

      tab = tabs.at_xpath("w:tab", "w" => WORDML_NS)
      expect(tab).not_to be_nil
      expect(tab["w:pos"]).to eq("1440")
      expect(tab["w:val"]).to eq("center")
      expect(tab["w:leader"]).to eq("dot")
    end

    it "serializes multiple tab stops" do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder << Uniword::Builder.tab_stop(position: 1440, alignment: "left")
      builder << Uniword::Builder.tab_stop(position: 2880, alignment: "center")
      builder << Uniword::Builder.tab_stop(
        position: 4320, alignment: "right", leader: "dot"
      )

      xml = para.to_xml
      doc = Nokogiri::XML(xml)

      tabs = doc.xpath("//w:tab", "w" => WORDML_NS)
      expect(tabs.size).to eq(3)

      expect(tabs[0]["w:pos"]).to eq("1440")
      expect(tabs[0]["w:val"]).to eq("left")

      expect(tabs[1]["w:pos"]).to eq("2880")
      expect(tabs[1]["w:val"]).to eq("center")

      expect(tabs[2]["w:pos"]).to eq("4320")
      expect(tabs[2]["w:val"]).to eq("right")
      expect(tabs[2]["w:leader"]).to eq("dot")
    end
  end

  describe "Run character spacing" do
    it "serializes character spacing to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).character_spacing(20)

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      spacing = doc.at_xpath("//w:spacing", "w" => WORDML_NS)
      expect(spacing).not_to be_nil
      expect(spacing["w:val"]).to eq("20")
    end

    it "serializes negative character spacing (condensing)" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).character_spacing(-10)

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      spacing = doc.at_xpath("//w:spacing", "w" => WORDML_NS)
      expect(spacing["w:val"]).to eq("-10")
    end
  end

  describe "Run kerning" do
    it "serializes kerning to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).kerning(24)

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      kern = doc.at_xpath("//w:kern", "w" => WORDML_NS)
      expect(kern).not_to be_nil
      expect(kern["w:val"]).to eq("24")
    end
  end

  describe "Run position (subscript/superscript)" do
    it "serializes position to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).position(5)

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      position = doc.at_xpath("//w:position", "w" => WORDML_NS)
      expect(position).not_to be_nil
      expect(position["w:val"]).to eq("5")
    end

    it "serializes negative position (subscript)" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).position(-5)

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      position = doc.at_xpath("//w:position", "w" => WORDML_NS)
      expect(position["w:val"]).to eq("-5")
    end
  end

  describe "Run text effects" do
    it "serializes outline to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).outline

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      outline = doc.at_xpath("//w:outline", "w" => WORDML_NS)
      expect(outline).not_to be_nil
    end

    it "serializes shadow to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).shadow

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      shadow = doc.at_xpath("//w:shadow", "w" => WORDML_NS)
      expect(shadow).not_to be_nil
    end

    it "serializes emboss to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).emboss

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      emboss = doc.at_xpath("//w:emboss", "w" => WORDML_NS)
      expect(emboss).not_to be_nil
    end

    it "serializes imprint to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).imprint

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      imprint = doc.at_xpath("//w:imprint", "w" => WORDML_NS)
      expect(imprint).not_to be_nil
    end
  end

  describe "Run shading" do
    it "serializes run shading to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).shading(
        fill: "FFFF00", pattern: "solid"
      )

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      shading = doc.at_xpath("//w:shd", "w" => WORDML_NS)
      expect(shading).not_to be_nil
      expect(shading["w:fill"]).to eq("FFFF00")
      expect(shading["w:val"]).to eq("solid")
    end

    it "serializes run shading with foreground" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).shading(
        fill: "FFFF00", color: "000000", pattern: "pct10"
      )

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      shading = doc.at_xpath("//w:shd", "w" => WORDML_NS)
      expect(shading["w:fill"]).to eq("FFFF00")
      expect(shading["w:color"]).to eq("000000")
      expect(shading["w:val"]).to eq("pct10")
    end
  end

  describe "Run emphasis mark" do
    it "serializes emphasis mark to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).emphasis_mark("dot")

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      em = doc.at_xpath("//w:em", "w" => WORDML_NS)
      expect(em).not_to be_nil
      expect(em["w:val"]).to eq("dot")
    end
  end

  describe "Run text expansion" do
    it "serializes text expansion to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).text_expansion(120)

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      w_elem = doc.at_xpath("//w:w", "w" => WORDML_NS)
      expect(w_elem).not_to be_nil
      expect(w_elem["w:val"]).to eq("120")
    end
  end

  describe "Run language" do
    it "serializes language to correct XML" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      Uniword::Builder::RunBuilder.new(run).language("en-US")

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      lang = doc.at_xpath("//w:lang", "w" => WORDML_NS)
      expect(lang).not_to be_nil
      expect(lang["w:val"]).to eq("en-US")
    end
  end

  describe "Complex combinations" do
    it "serializes paragraph with multiple properties" do
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder.borders(top: "000000", bottom: "FF0000")
      builder.shading(fill: "FFFF00")
      builder << Uniword::Builder.tab_stop(
        position: 1440, alignment: "center"
      )

      xml = para.to_xml
      doc = Nokogiri::XML(xml)

      # All three property groups should exist
      borders = doc.at_xpath("//w:pBdr", "w" => WORDML_NS)
      shading = doc.at_xpath("//w:shd", "w" => WORDML_NS)
      tabs = doc.at_xpath("//w:tabs", "w" => WORDML_NS)

      expect(borders).not_to be_nil
      expect(shading).not_to be_nil
      expect(tabs).not_to be_nil
    end

    it "serializes run with multiple effects" do
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      builder = Uniword::Builder::RunBuilder.new(run)
      builder.character_spacing(20)
      builder.kerning(24)
      builder.position(5)
      builder.outline
      builder.shadow
      builder.shading(fill: "FFFF00")

      xml = run.to_xml
      doc = Nokogiri::XML(xml)

      # All properties should exist
      spacing = doc.at_xpath("//w:spacing", "w" => WORDML_NS)
      kern = doc.at_xpath("//w:kern", "w" => WORDML_NS)
      position = doc.at_xpath("//w:position", "w" => WORDML_NS)
      outline = doc.at_xpath("//w:outline", "w" => WORDML_NS)
      shadow = doc.at_xpath("//w:shadow", "w" => WORDML_NS)
      shading = doc.at_xpath("//w:shd", "w" => WORDML_NS)

      expect(spacing).not_to be_nil
      expect(kern).not_to be_nil
      expect(position).not_to be_nil
      expect(outline).not_to be_nil
      expect(shadow).not_to be_nil
      expect(shading).not_to be_nil
    end
  end
end
