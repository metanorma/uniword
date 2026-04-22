# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Docx::Profile do
  describe ".load" do
    it "loads a preset by name" do
      profile = described_class.load(:word_2024_en)

      expect(profile.system).to be_a(Uniword::Docx::SystemProfile)
      expect(profile.locale).to be_a(Uniword::Docx::LocaleProfile)
      expect(profile.user).to be_a(Uniword::Docx::UserProfile)
    end

    it "raises for unknown preset" do
      expect { described_class.load(:nonexistent) }
        .to raise_error(ArgumentError, /not found/)
    end

    it "accepts custom user override" do
      user = Uniword::Docx::UserProfile.new(name: "Ada Lovelace")
      profile = described_class.load(:word_2024_en, user: user)

      expect(profile.user_name).to eq("Ada Lovelace")
    end

    it "stringifies symbol preset names" do
      profile = described_class.load("word_2024_en")
      expect(profile).to be_a(described_class)
    end
  end

  describe ".defaults" do
    it "returns Office 2024 + en-US profile" do
      profile = described_class.defaults

      expect(profile.system.name).to eq("office_2024")
      expect(profile.locale.locale).to eq("en")
    end
  end

  describe "delegation" do
    let(:profile) { described_class.load(:word_2024_en) }

    it "delegates body_font from system font scheme" do
      expect(profile.body_font).to eq("Aptos")
    end

    it "delegates heading_font from system font scheme" do
      expect(profile.heading_font).to eq("Aptos Display")
    end

    it "delegates lang from locale" do
      expect(profile.lang).to eq("en-US")
    end

    it "delegates decimal_symbol from locale" do
      expect(profile.decimal_symbol).to eq(".")
    end

    it "delegates list_separator from locale" do
      expect(profile.list_separator).to eq(",")
    end

    it "delegates application_name from system" do
      expect(profile.application_name).to eq("Microsoft Office Word")
    end

    it "delegates compat_mode from system" do
      expect(profile.compat_mode).to eq("15")
    end

    it "builds theme_font_lang hash" do
      tfl = profile.theme_font_lang
      expect(tfl[:val]).to eq("en-US")
      expect(tfl[:east_asia]).to eq("zh-CN")
    end
  end
end

RSpec.describe Uniword::Docx::SystemProfile do
  describe ".load" do
    it "loads office_2024 profile" do
      sp = described_class.load("office_2024")

      expect(sp.compat_mode).to eq("15")
      expect(sp.font_scheme_name).to eq("ms_office_2024")
      expect(sp.application_name).to eq("Microsoft Office Word")
    end

    it "loads office_2007 profile" do
      sp = described_class.load("office_2007")

      expect(sp.compat_mode).to eq("12")
      expect(sp.font_scheme_name).to eq("ms_office_2007")
    end

    it "raises for unknown profile" do
      expect { described_class.load("nonexistent") }
        .to raise_error(ArgumentError, /not found/)
    end
  end

  describe "#font_scheme" do
    it "lazily loads the font scheme" do
      sp = described_class.load("office_2024")
      fs = sp.font_scheme

      expect(fs).to be_a(Uniword::Themes::FontScheme)
      expect(fs.name).to eq("Office 2024+")
      expect(fs.major_font).to eq("Aptos Display")
      expect(fs.minor_font).to eq("Aptos")
    end

    it "caches the font scheme" do
      sp = described_class.load("office_2013")
      first = sp.font_scheme
      second = sp.font_scheme

      expect(first).to equal(second)
    end
  end
end

RSpec.describe Uniword::Docx::LocaleProfile do
  describe ".from_locale" do
    it "loads en locale" do
      lp = described_class.from_locale("en")

      expect(lp.lang).to eq("en-US")
      expect(lp.east_asia_lang).to eq("zh-CN")
      expect(lp.decimal_symbol).to eq(".")
      expect(lp.list_separator).to eq(",")
    end

    it "loads ja locale with East Asian fonts" do
      lp = described_class.from_locale("ja")

      expect(lp.lang).to eq("ja-JP")
      expect(lp.east_asia_lang).to eq("ja-JP")
      expect(lp.east_asian_font).to eq("Yu Gothic")
    end

    it "loads zh-CN locale" do
      lp = described_class.from_locale("zh-CN")

      expect(lp.lang).to eq("zh-CN")
      expect(lp.east_asian_font).to eq("DengXian")
    end

    it "raises for unknown locale" do
      expect { described_class.from_locale("xx") }
        .to raise_error(ArgumentError, /not found/)
    end
  end

  describe ".available_locales" do
    it "returns sorted list of locale codes" do
      locales = described_class.available_locales

      expect(locales).to include("en", "ja", "zh-CN", "ko", "de", "fr")
      expect(locales).to eq(locales.sort)
    end
  end
end

RSpec.describe Uniword::Docx::UserProfile do
  describe ".defaults" do
    it "returns empty user profile" do
      user = described_class.defaults

      expect(user.name).to eq("")
      expect(user.company).to eq("")
      expect(user.initials).to eq("")
    end
  end

  describe "#initialize" do
    it "accepts all user info fields" do
      user = described_class.new(
        name: "Ronald Tse",
        initials: "RT",
        company: "Ribose Inc",
        address: "123 Main St",
        city: "Hong Kong",
        state: "",
        zip: "",
        country_region: "HK",
        phone: "+852-1234-5678",
        email: "ronald@example.com"
      )

      expect(user.name).to eq("Ronald Tse")
      expect(user.initials).to eq("RT")
      expect(user.company).to eq("Ribose Inc")
      expect(user.city).to eq("Hong Kong")
      expect(user.country_region).to eq("HK")
      expect(user.phone).to eq("+852-1234-5678")
      expect(user.email).to eq("ronald@example.com")
    end
  end
end
