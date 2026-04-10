# frozen_string_literal: true

module Uniword
  class LinuxWordImplementation < WordImplementation
    # NOTE: There is no Microsoft Word for Linux
    # Linux users must manually copy theme files from another system

    def installed?
      false # No native Word on Linux
    end

    def version
      nil
    end

    def themes_path
      # User-configured path for manually copied themes
      ENV['UNIWORD_THEMES_PATH'] || File.expand_path('~/.local/share/uniword/themes/source')
    end

    def stylesets_path
      ENV['UNIWORD_STYLESETS_PATH'] || File.expand_path('~/.local/share/uniword/stylesets/source')
    end

    def color_schemes_path
      ENV['UNIWORD_COLOR_SCHEMES_PATH'] || File.expand_path('~/.local/share/uniword/color_schemes/source')
    end

    def font_schemes_path
      ENV['UNIWORD_FONT_SCHEMES_PATH'] || File.expand_path('~/.local/share/uniword/font_schemes/source')
    end

    def cache_path
      # XDG cache directory
      if ENV['XDG_CACHE_HOME']
        File.join(ENV['XDG_CACHE_HOME'], 'uniword')
      else
        File.expand_path('~/.cache/uniword')
      end
    end
  end
end
