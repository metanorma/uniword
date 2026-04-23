# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Open-Source Resources Round-Trip" do
  let(:transformation) { Uniword::Themes::ThemeTransformation.new }

  describe "Color scheme round-trip" do
    Uniword::Resource::ColorSchemeLoader.available_schemes.each do |name|
      it "converts #{name} YAML to OOXML ColorScheme with valid XML" do
        scheme = Uniword::Resource::ColorSchemeLoader.load(name)
        word_colors = transformation.send(:build_color_scheme, scheme)

        xml = word_colors.to_xml
        expect(xml).to include("<clrScheme")
        expect(xml).to include("name=\"#{scheme.name}\"")
        expect(xml).to include("<srgbClr")
      end
    end
  end

  describe "Font scheme round-trip" do
    # MS font schemes (ms_office_*) intentionally contain MS fonts
    ofl_schemes = Uniword::Resource::FontSchemeLoader.available_schemes
      .reject { |n| n.start_with?("ms_office") }

    ofl_schemes.each do |name|
      it "converts #{name} YAML to OOXML FontScheme with script entries" do
        scheme = Uniword::Resource::FontSchemeLoader.load(name)
        word_fonts = transformation.send(:build_font_scheme, scheme)

        xml = word_fonts.to_xml
        expect(xml).to include("<fontScheme")
        expect(xml).to include("name=\"#{scheme.name}\"")

        # No MS fonts in OFL scheme output
        ms_fonts = %w[Calibri Cambria Arial Tahoma Consolas Verdana]
        ms_fonts.each do |font|
          expect(xml).not_to include(font),
                             "MS font '#{font}' found in #{name} output"
        end
      end
    end

    # MS font schemes round-trip without errors (no MS font check)
    %w[ms_office_2007 ms_office_2013 ms_office_2024].each do |name|
      it "round-trips #{name} YAML to OOXML FontScheme" do
        scheme = Uniword::Resource::FontSchemeLoader.load(name)
        word_fonts = transformation.send(:build_font_scheme, scheme)

        xml = word_fonts.to_xml
        expect(xml).to include("<fontScheme")
        expect(xml).to include("name=\"#{scheme.name}\"")
      end
    end
  end

  describe "Theme round-trip with OFL fonts" do
    Uniword::Themes::Theme.available_themes.each do |name|
      it "loads #{name}, converts to Word, generates valid XML with no MS fonts" do
        theme = Uniword::Themes::Theme.load(name)
        word_theme = theme.to_word_theme
        xml = word_theme.to_xml

        expect(xml).to include("<theme")
        expect(xml).to include("<fontScheme")

        # Verify no MS fonts
        ms_fonts = %w[Calibri Cambria Arial "Segoe UI" Consolas Verdana
                      Georgia Candara Corbel Constantia Aptos "Aptos Display"]
        ms_fonts.each do |font|
          expect(xml).not_to include(font),
                             "MS font '#{font}' in theme #{name}"
        end

        # Verify EA font populated
        expect(xml).to include("Noto Sans CJK")
      end
    end
  end

  describe "Multi-locale document element coverage" do
    %w[en ru zh-CN zh-TW ja fr es ar cs da de el en-GB es-MX
       fi fr-CA he hu id it ko nl no pl pt pt-PT sk sv th tr].each do |locale|
      it "has complete document elements for #{locale}" do
        categories = Uniword::Resource::DocumentElementLoader.available_categories(locale)
        expected = %w[cover_pages headers footers tables equations
                      bibliographies watermarks table_of_contents]
        expect(categories).to include(*expected)
      end
    end
  end

  describe "Document element to OOXML conversion" do
    it "converts an English cover page to a valid document" do
      template = Uniword::Resource::DocumentElementLoader.load("en",
                                                               "cover_pages")
      expect(template.elements).not_to be_empty

      converter = Uniword::Resource::DocumentElementConverter.new
      element = template.elements.first
      paragraphs = converter.to_paragraphs(element)

      expect(paragraphs).not_to be_empty
      expect(paragraphs.first).to be_a(Uniword::Wordprocessingml::Paragraph)
    end
  end
end
