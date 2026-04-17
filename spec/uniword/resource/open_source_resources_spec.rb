# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Open-Source Resource Integrity" do
  MS_FONTS = %w[
    Calibri Cambria Arial
    "Times New Roman" "Segoe UI" Consolas
    Tahoma Verdana "Trebuchet MS" "Courier New"
    Georgia Candara Corbel Constantia
    Aptos "Aptos Display" Impact
    "Gill Sans MT" "Tw Cen MT" "Century Gothic"
    "Century Schoolbook" Rockwell "Franklin Gothic Book"
    "Palatino Linotype" "Bookman Old Style"
    "Arial Black" "Rockwell Condensed" "Tw Cen MT Condensed"
  ].freeze

  describe "Font Registry" do
    let(:registry) { YAML.load_file("data/resources/font_registry.yml") }

    it "loads valid YAML" do
      expect(registry).to be_a(Hash)
    end

    it "contains required sections" do
      expect(registry).to include("latin", "east_asian", "complex_script",
                                  "per_script", "substitutions")
    end

    it "has substitution entries for known MS fonts" do
      subs = registry["substitutions"]
      expect(subs).to include("Calibri", "Arial", "Times New Roman",
                              "Segoe UI", "Tahoma", "Cambria")
    end

    it "has per_script entries for all script codes" do
      per_script = registry["per_script"]
      %w[Jpan Hans Hant Hang Arab Hebr Deva Beng Thai Viet].each do |script|
        expect(per_script).to include(script), "Missing script: #{script}"
      end
    end

    it "does not use MS fonts as target values in substitutions" do
      ms_font_names = %w[Calibri Cambria Arial Tahoma Consolas Verdana Georgia]
      registry["substitutions"].each do |_ms, ofl|
        ms_font_names.each do |ms|
          expect(ofl).not_to eq(ms),
            "Substitution target '#{ofl}' matches MS font '#{ms}'"
        end
      end
    end
  end

  describe "Color Schemes" do
    let(:schemes_dir) { "data/color_schemes" }

    it "has exactly 23 color scheme files" do
      files = Dir.glob(File.join(schemes_dir, "*.yml"))
      expect(files.count).to eq(23)
    end

    it "each scheme has 12 colors" do
      Dir.glob(File.join(schemes_dir, "*.yml")).each do |path|
        data = YAML.load_file(path)
        colors = data["colors"]
        expect(colors).to be_a(Hash)
        expected_keys = %w[dk1 lt1 dk2 lt2 accent1 accent2 accent3 accent4 accent5 accent6 hlink folHlink]
        expected_keys.each do |key|
          expect(colors).to include(key),
            "#{File.basename(path)} missing color key: #{key}"
        end
      end
    end

    it "all color values are valid hex codes" do
      Dir.glob(File.join(schemes_dir, "*.yml")).each do |path|
        data = YAML.load_file(path)
        data["colors"].each do |key, value|
          next if value.nil?
          expect(value.to_s).to match(/\A[0-9A-Fa-f]{6}\z/),
            "#{File.basename(path)} color #{key}=#{value} is not valid hex"
        end
      end
    end
  end

  describe "Font Schemes" do
    let(:schemes_dir) { "data/font_schemes" }

    it "has exactly 25 font scheme files" do
      files = Dir.glob(File.join(schemes_dir, "*.yml"))
      expect(files.count).to eq(25)
    end

    it "each scheme has major and minor sections" do
      Dir.glob(File.join(schemes_dir, "*.yml")).each do |path|
        data = YAML.load_file(path)
        expect(data).to include("major", "minor"),
          "#{File.basename(path)} missing major/minor sections"
        expect(data["major"]).to include("latin"),
          "#{File.basename(path)} major missing latin"
        expect(data["minor"]).to include("latin"),
          "#{File.basename(path)} minor missing latin"
      end
    end

    it "each scheme has per_script entries" do
      Dir.glob(File.join(schemes_dir, "*.yml")).each do |path|
        data = YAML.load_file(path)
        expect(data).to include("per_script"),
          "#{File.basename(path)} missing per_script"
        expect(data["per_script"]).to be_a(Hash)
      end
    end
  end

  describe "No MS fonts in bundled YAML data" do
    it "theme font values contain no Microsoft font names" do
      Dir.glob("data/themes/*.yml").each do |path|
        content = File.read(path)
        MS_FONTS.each do |font|
          # Check only in value position (after colon)
          if content.match?(/(?:major_font|minor_font): *#{Regexp.escape(font)}$/)
            expect(false).to be true,
              "MS font '#{font}' found in #{path}"
          end
        end
      end
    end

    it "font scheme files contain no Microsoft font names as typeface values" do
      Dir.glob("data/font_schemes/*.yml").each do |path|
        data = YAML.load_file(path)
        %w[major minor].each do |section|
          %w[latin east_asian complex_script].each do |key|
            val = data.dig(section, key).to_s
            MS_FONTS.each do |font|
              expect(val).not_to eq(font),
                "MS font '#{font}' found in #{path} #{section}.#{key}"
            end
          end
        end
        data["per_script"]&.each do |script, typeface|
          MS_FONTS.each do |font|
            expect(typeface.to_s).not_to eq(font),
              "MS font '#{font}' found in #{path} per_script.#{script}"
          end
        end
      end
    end

    it "styleset files contain no Microsoft font names in run properties" do
      ms_simple = %w[Calibri Cambria Arial Tahoma Consolas Verdana
                     Georgia Candara Corbel Constantia Aptos]
      Dir.glob("data/stylesets/*.yml").each do |path|
        content = File.read(path)
        ms_simple.each do |font|
          expect(content).not_to match(/font: *#{Regexp.escape(font)}$/),
            "MS font '#{font}' found in #{path}"
          expect(content).not_to match(/font_ascii: *#{Regexp.escape(font)}$/),
            "MS font '#{font}' (ascii) found in #{path}"
        end
      end
    end
  end
end

RSpec.describe Uniword::Resource::ColorSchemeLoader do
  it "loads a color scheme by name" do
    scheme = described_class.load("azure")
    expect(scheme).to be_a(Uniword::Themes::ColorScheme)
    expect(scheme.name).to eq("Azure")
  end

  it "returns available schemes" do
    schemes = described_class.available_schemes
    expect(schemes).to include("azure", "emerald", "crimson", "indigo")
    expect(schemes.count).to eq(23)
  end

  it "raises ArgumentError for non-existent scheme" do
    expect { described_class.load("nonexistent") }.to raise_error(ArgumentError, /not found/)
  end
end

RSpec.describe Uniword::Resource::FontSchemeLoader do
  it "loads a font scheme by name" do
    scheme = described_class.load("carlito_sans")
    expect(scheme).to be_a(Uniword::Themes::FontScheme)
    expect(scheme.name).to eq("Carlito Sans")
    expect(scheme.major_font).to eq("Carlito")
    expect(scheme.minor_font).to eq("Carlito")
  end

  it "returns available schemes" do
    schemes = described_class.available_schemes
    expect(schemes).to include("carlito_sans", "modern_office", "eb_garamond")
    expect(schemes.count).to eq(25)
  end

  it "raises ArgumentError for non-existent scheme" do
    expect { described_class.load("nonexistent") }.to raise_error(ArgumentError, /not found/)
  end

  it "populates per_script from YAML" do
    scheme = described_class.load("carlito_sans")
    expect(scheme.per_script).to be_a(Hash)
    expect(scheme.per_script).to include("Jpan" => "Noto Sans CJK JP",
                                         "Hans" => "Noto Sans CJK SC")
  end
end

RSpec.describe Uniword::Resource::DocumentElementLoader do
  it "loads elements by locale and category" do
    template = described_class.load("en", "cover_pages")
    expect(template).to be_a(Uniword::Resource::DocumentElementTemplate)
    expect(template.locale).to eq("en")
    expect(template.category).to eq("cover_pages")
    expect(template.elements).not_to be_empty
  end

  it "lists available categories for a locale" do
    categories = described_class.available_categories("en")
    expect(categories).to include("cover_pages", "headers", "footers",
                                  "tables", "watermarks")
  end

  it "lists all 30 available locales" do
    locales = described_class.available_locales
    expected = %w[en ru zh-CN zh-TW ja fr es ar cs da de el en-GB es-MX
                  fi fr-CA he hu id it ko nl no pl pt pt-PT sk sv th tr]
    expected.each do |loc|
      expect(locales).to include(loc), "Missing locale: #{loc}"
    end
    expect(locales.count).to eq(30)
  end

  it "raises ArgumentError for non-existent locale/category" do
    expect { described_class.load("xx", "nonexistent") }.to raise_error(ArgumentError)
  end

  it "all 30 locales have 8 categories" do
    expected = %w[en ru zh-CN zh-TW ja fr es ar cs da de el en-GB es-MX
                  fi fr-CA he hu id it ko nl no pl pt pt-PT sk sv th tr]
    expected.each do |locale|
      categories = described_class.available_categories(locale)
      expect(categories.count).to eq(8),
        "#{locale} has #{categories.count} categories, expected 8"
    end
  end
end

RSpec.describe Uniword::Resource::FontSubstitutor do
  it "substitutes Latin fonts" do
    expect(described_class.substitute("Calibri")).to eq("Carlito")
    expect(described_class.substitute("Arial")).to eq("Liberation Sans")
    expect(described_class.substitute("Times New Roman")).to eq("Liberation Serif")
  end

  it "substitutes per-script fonts" do
    expect(described_class.substitute_script("Jpan", "メイリオ")).to eq("Noto Sans CJK JP")
    expect(described_class.substitute_script("Hans", "宋体")).to eq("Noto Sans CJK SC")
  end

  it "returns original font when no substitution exists" do
    expect(described_class.substitute("Helvetica")).to eq("Helvetica")
  end

  it "transforms friendly font scheme with EA/CS population" do
    fs = Uniword::Themes::FontScheme.new(
      name: "Test",
      major_font: "Calibri",
      minor_font: "Arial"
    )
    result = described_class.transform_friendly_font_scheme(fs)
    expect(result.major_font).to eq("Carlito")
    expect(result.minor_font).to eq("Liberation Sans")
    expect(result.major_east_asian).not_to be_empty
    expect(result.major_complex_script).not_to be_empty
  end
end
