# frozen_string_literal: true

module Uniword
  # Null Object Pattern - returns safe defaults for unknown platforms
  class NullWordImplementation < WordImplementation
    def installed?
      false
    end

    def version
      nil
    end

    def themes_path
      nil
    end

    def stylesets_path
      nil
    end

    def color_schemes_path
      nil
    end

    def font_schemes_path
      nil
    end

    def cache_path
      File.expand_path("~/.uniword")
    end
  end
end
