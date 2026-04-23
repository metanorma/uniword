# frozen_string_literal: true

require "yaml"
require "securerandom"

module Uniword
  module Docx
    # Composition of three independent profile axes:
    #   SystemProfile — "What Word version to target"
    #   LocaleProfile  — "What locale/language to use"
    #   UserProfile    — "Who is creating this document"
    #
    # Used by Reconciler to populate DOCX parts with Word-expected content.
    #
    # @example Create from preset
    #   profile = Profile.load(:word_2024_en)
    #
    # @example Create with custom user
    #   profile = Profile.load(:word_2024_en,
    #     user: UserProfile.new(name: "Ada Lovelace"))
    #
    class Profile
      CONFIG_DIR = File.join(__dir__, "../../../config")

      attr_reader :system, :locale, :user

      def initialize(system:, locale:, user: UserProfile.defaults)
        @system = system
        @locale = locale
        @user = user
      end

      # Load a named preset from config/profiles.yml
      #
      # @param name [Symbol, String] Preset name (e.g., :word_2024_en)
      # @param user [UserProfile] Optional user override
      # @return [Profile]
      def self.load(name, user: nil)
        presets = load_presets
        key = name.to_s

        unless presets.key?(key)
          raise ArgumentError,
                "Profile preset '#{key}' not found. " \
                "Available: #{presets.keys.join(', ')}"
        end

        preset = presets[key]
        sys = SystemProfile.load(preset["system"])
        loc = LocaleProfile.from_locale(preset["locale"])
        new(system: sys, locale: loc, user: user || UserProfile.defaults)
      end

      # Default profile (Office 2024, en-US)
      def self.defaults
        new(
          system: SystemProfile.defaults,
          locale: LocaleProfile.from_locale("en"),
          user: UserProfile.defaults,
        )
      end

      # Delegate common values to sub-profiles
      def body_font
        system.font_scheme&.minor_font
      end

      def heading_font
        system.font_scheme&.major_font
      end

      def lang
        locale.lang
      end

      def east_asia_lang
        locale.east_asia_lang
      end

      def bidi_lang
        locale.bidi_lang
      end

      def decimal_symbol
        locale.decimal_symbol
      end

      def list_separator
        locale.list_separator
      end

      def user_name
        user.name
      end

      def user_company
        user.company
      end

      def application_name
        system.application_name
      end

      def app_version
        system.app_version
      end

      def compat_mode
        system.compat_mode
      end

      def theme_font_lang
        { val: locale.lang, east_asia: locale.east_asia_lang }
      end

      # --- Private helpers ---

      def self.load_presets
        path = File.join(CONFIG_DIR, "profiles.yml")
        YAML.load_file(path)["presets"]
      end
      private_class_method :load_presets
    end

    # System profile: Word version → fonts, theme, compat settings.
    #
    # Defines what Word version to target when generating DOCX output.
    # Loaded from config/system_profiles.yml.
    class SystemProfile
      CONFIG_DIR = File.join(__dir__, "../../../config")

      attr_reader :name, :compat_mode, :font_scheme_name,
                  :default_theme_name, :application_name, :app_version

      def initialize(name:, compat_mode:, font_scheme_name:,
                     application_name:, app_version:, default_theme_name: nil, **_opts)
        @name = name
        @compat_mode = compat_mode
        @font_scheme_name = font_scheme_name
        @default_theme_name = default_theme_name
        @application_name = application_name
        @app_version = app_version
      end

      # Load from config/system_profiles.yml
      def self.load(name)
        path = File.join(CONFIG_DIR, "system_profiles.yml")
        all = YAML.load_file(path)["profiles"]

        unless all.key?(name)
          raise ArgumentError,
                "System profile '#{name}' not found. " \
                "Available: #{all.keys.join(', ')}"
        end

        data = all[name]
        # Rename YAML keys to match constructor parameter names
        if data.key?("font_scheme")
          data["font_scheme_name"] =
            data.delete("font_scheme")
        end
        if data.key?("default_theme")
          data["default_theme_name"] =
            data.delete("default_theme")
        end
        new(name: name, **data.transform_keys(&:to_sym))
      end

      # Default: Office 2024
      def self.defaults
        load("office_2024")
      end

      # Lazily loaded font scheme
      def font_scheme
        @font_scheme ||= Resource::FontSchemeLoader.load(font_scheme_name)
      end
    end

    # Locale profile: language → lang tags, separators, East Asian fonts.
    #
    # Defines language-specific settings for DOCX generation.
    # Loaded from config/locale_profiles.yml.
    class LocaleProfile
      CONFIG_DIR = File.join(__dir__, "../../../config")

      attr_reader :locale, :lang, :east_asia_lang, :bidi_lang,
                  :decimal_symbol, :list_separator,
                  :east_asian_font, :east_asian_light_font

      def initialize(locale:, lang:, east_asia_lang:, bidi_lang:,
                     decimal_symbol:, list_separator:,
                     east_asian_font: nil, east_asian_light_font: nil)
        @locale = locale
        @lang = lang
        @east_asia_lang = east_asia_lang
        @bidi_lang = bidi_lang
        @decimal_symbol = decimal_symbol
        @list_separator = list_separator
        @east_asian_font = east_asian_font
        @east_asian_light_font = east_asian_light_font
      end

      # Load from config/locale_profiles.yml
      def self.from_locale(locale_code)
        path = File.join(CONFIG_DIR, "locale_profiles.yml")
        all = YAML.load_file(path)["locales"]

        unless all.key?(locale_code)
          raise ArgumentError,
                "Locale '#{locale_code}' not found. " \
                "Available: #{all.keys.join(', ')}"
        end

        data = all[locale_code]
        new(locale: locale_code, **data.transform_keys(&:to_sym))
      end

      # List all available locales
      def self.available_locales
        path = File.join(CONFIG_DIR, "locale_profiles.yml")
        YAML.load_file(path)["locales"].keys.sort
      end
    end

    # User profile: identity → author metadata.
    #
    # Maps to Word's UserInfo registry/plist entries.
    # Always user-supplied — no presets.
    class UserProfile
      attr_reader :name, :initials, :company, :address,
                  :city, :state, :zip, :country_region,
                  :phone, :email

      def initialize(name: "", initials: "", company: "",
                     address: "", city: "", state: "", zip: "",
                     country_region: "", phone: "", email: "")
        @name = name
        @initials = initials
        @company = company
        @address = address
        @city = city
        @state = state
        @zip = zip
        @country_region = country_region
        @phone = phone
        @email = email
      end

      # Empty default user
      def self.defaults
        new
      end
    end
  end
end
