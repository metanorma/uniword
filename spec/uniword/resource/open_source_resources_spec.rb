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
      registry["substitutions"].each_value do |ofl|
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
    let(:ofl_schemes) do
      Dir.glob(File.join(schemes_dir, "*.yml"))
         .reject { |p| File.basename(p).start_with?("ms_office") }
    end

    it "has exactly 25 OFL font scheme files" do
      expect(ofl_schemes.count).to eq(25)
    end

    it "each scheme has major and minor sections" do
      ofl_schemes.each do |path|
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
      ofl_schemes.each do |path|
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
      Dir.glob("data/font_schemes/*.yml")
         .reject { |p| File.basename(p).start_with?("ms_office") }
         .each do |path|
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
    expect(schemes).to include("carlito_sans", "modern_office", "eb_garamond",
                               "ms_office_2024", "ms_office_2013", "ms_office_2007")
    expect(schemes.count).to eq(28)
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

RSpec.describe "MS Theme/StyleSet Slug Scan" do
  it "no theme file uses an MS theme name as slug" do
    ms_slugs = %w[atlas badge berlin celestial crop depth droplet facet
                  feathered gallery headlines integral ion ion_boardroom
                  madison main_event mesh office_theme
                  office_2013_2022_theme organic parallax parcel
                  retrospect savon slice vapor_trail view wisp wood_type]
    actual = Dir.glob("data/themes/*.yml").map { |f| File.basename(f, ".yml") }
    ms_slugs.each do |slug|
      expect(actual).not_to include(slug),
                            "MS theme slug '#{slug}' still exists in data/themes/"
    end
  end

  it "no styleset file uses an MS styleset name as slug" do
    ms_slugs = %w[distinctive elegant fancy formal manuscript modern
                  newsprint perspective simple thatch traditional word_2010]
    actual = Dir.glob("data/stylesets/*.yml").map { |f| File.basename(f, ".yml") }
    ms_slugs.each do |slug|
      expect(actual).not_to include(slug),
                            "MS styleset slug '#{slug}' still exists in data/stylesets/"
    end
  end

  it "all 7 target locales have document elements" do
    %w[en ru zh-CN zh-TW ja fr es].each do |locale|
      categories = Uniword::Resource::DocumentElementLoader.available_categories(locale)
      expected = %w[cover_pages headers footers tables equations
                    bibliographies watermarks table_of_contents]
      expect(categories).to include(*expected),
                            "Locale #{locale} missing expected categories"
    end
  end
end

RSpec.describe Uniword::Resource::ThemeMappingLoader do
  it "maps Uniword theme to MS equivalent" do
    expect(described_class.uniword_to_ms_theme("meridian")).to eq("Atlas")
    expect(described_class.uniword_to_ms_theme("emblem")).to eq("Badge")
    expect(described_class.uniword_to_ms_theme("corporate")).to eq("Office 2013-2022")
  end

  it "maps MS theme to Uniword equivalent" do
    expect(described_class.ms_to_uniword_theme("Atlas")).to eq("meridian")
    expect(described_class.ms_to_uniword_theme("Badge")).to eq("emblem")
    expect(described_class.ms_to_uniword_theme("Office 2013-2022")).to eq("corporate")
  end

  it "maps Uniword styleset to MS equivalent" do
    expect(described_class.uniword_to_ms_styleset("signature")).to eq("Distinctive")
    expect(described_class.uniword_to_ms_styleset("contemporary")).to eq("Modern")
  end

  it "maps MS styleset to Uniword equivalent" do
    expect(described_class.ms_to_uniword_styleset("Distinctive")).to eq("signature")
    expect(described_class.ms_to_uniword_styleset("Modern")).to eq("contemporary")
  end

  it "returns nil for unknown names" do
    expect(described_class.ms_to_uniword_theme("NonExistent")).to be_nil
    expect(described_class.uniword_to_ms_theme("nonexistent")).to be_nil
    expect(described_class.ms_to_uniword_styleset("NonExistent")).to be_nil
  end

  it "has color fingerprints for all 29 themes" do
    mappings = described_class.all_theme_mappings
    expect(mappings.count).to eq(29)
    mappings.each do |slug, entry|
      expect(entry).to include("ms_name", "color_fingerprint"),
                       "Theme #{slug} missing ms_name or color_fingerprint"
      expect(entry["color_fingerprint"]).to include("accent1", "accent2", "dk2"),
                                            "Theme #{slug} fingerprint missing accent1/accent2/dk2"
    end
  end

  it "has mapping entries for all 12 stylesets" do
    mappings = described_class.all_styleset_mappings
    expect(mappings.count).to eq(12)
    mappings.each do |slug, entry|
      expect(entry).to include("ms_name"),
                       "StyleSet #{slug} missing ms_name"
    end
  end

  it "color fingerprints are unique by accent1+accent2+dk2" do
    fingerprints = described_class.all_theme_mappings.map do |_slug, entry|
      fp = entry["color_fingerprint"]
      [fp["accent1"], fp["accent2"], fp["dk2"]].join(":")
    end
    expect(fingerprints.uniq.count).to eq(fingerprints.count),
                                       "Duplicate color fingerprints found"
  end

  it "finds theme by colors" do
    result = described_class.find_by_colors(
      "accent1" => "F81B02", "accent2" => "FC7715", "dk2" => "454545"
    )
    expect(result).to eq("meridian")
  end

  it "returns nil for unmatched colors" do
    result = described_class.find_by_colors(
      "accent1" => "000000", "accent2" => "000000", "dk2" => "000000"
    )
    expect(result).to be_nil
  end
end

RSpec.describe Uniword::Resource::ThemeTransition do
  let(:transformation) { Uniword::Themes::ThemeTransformation.new }

  it "detects MS theme by name" do
    expect(described_class.from_ms_name("Atlas")).to eq("meridian")
    expect(described_class.from_ms_name("Badge")).to eq("emblem")
    expect(described_class.from_ms_name("Office 2013-2022")).to eq("corporate")
  end

  it "detects MS styleset by name" do
    expect(described_class.styleset_from_ms_name("Distinctive")).to eq("signature")
    expect(described_class.styleset_from_ms_name("Modern")).to eq("contemporary")
  end

  it "returns nil for unknown MS name" do
    expect(described_class.from_ms_name("Unknown Theme")).to be_nil
  end

  it "detects MS theme by color fingerprint in a loaded theme" do
    # Load a Uniword theme (which has the same colors as its MS equivalent)
    friendly = Uniword::Themes::Theme.load("meridian")
    word_theme = transformation.to_word(friendly)

    detected = described_class.detect_ms_theme(word_theme)
    expect(detected).to eq("meridian")
  end

  it "auto-transitions a document with a known theme" do
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    doc.apply_theme("meridian")

    result = described_class.auto_transition!(doc)
    expect(result).not_to be_nil
    expect(result.uniword_slug).to eq("meridian")
    expect(result.ms_name).to eq("Atlas")
  end
end
