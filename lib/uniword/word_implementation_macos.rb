# frozen_string_literal: true

module Uniword
  class MacOSWordImplementation < WordImplementation
    WORD_APP_PATH = "/Applications/Microsoft Word.app"
    RESOURCES_PATH = "/Applications/Microsoft Word.app/Contents/Resources"

    def installed?
      File.directory?(WORD_APP_PATH)
    end

    def version
      return nil unless installed?

      plist = File.join(WORD_APP_PATH, "Contents", "Info.plist")
      return nil unless File.exist?(plist)

      `defaults read "#{WORD_APP_PATH}/Contents" CFBundleShortVersionString 2>/dev/null`.strip.presence
    end

    def themes_path
      File.join(RESOURCES_PATH, "Office Themes") if installed?
    end

    def stylesets_path
      File.join(RESOURCES_PATH, "QuickStyles") if installed?
    end

    def color_schemes_path
      File.join(RESOURCES_PATH, "Office Themes", "Theme Colors") if installed?
    end

    def font_schemes_path
      File.join(RESOURCES_PATH, "Office Themes", "Theme Fonts") if installed?
    end

    def cache_path
      File.expand_path("~/.uniword")
    end
  end
end
