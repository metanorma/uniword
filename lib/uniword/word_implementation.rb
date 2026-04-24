# frozen_string_literal: true

module Uniword
  # Abstract base class for Word implementation queries
  #
  # This is a MODEL (not just a service). It has:
  # - State: platform, version, installation status
  # - Behavior: query paths, list resources
  #
  # Does NOT extend Lutaml::Model::Serializable because it doesn't need serialization.
  class WordImplementation
    # Factory - delegates to platform-specific implementation
    def self.detect
      WordImplementationFactory.create
    end

    # Abstract methods - raise if not overridden
    def installed?
      raise NotImplementedError
    end

    def version
      raise NotImplementedError
    end

    # Path accessors - return nil if not applicable
    def themes_path; end
    def stylesets_path; end
    def color_schemes_path; end
    def font_schemes_path; end
    def cache_path; end

    # Resource enumeration - return empty array by default
    def available_themes
      return [] unless themes_path && File.directory?(themes_path)

      Dir.glob(File.join(themes_path, "*.thmx")).map do |f|
        File.basename(f, ".thmx")
      end
    end

    def available_stylesets
      return [] unless stylesets_path && File.directory?(stylesets_path)

      Dir.glob(File.join(stylesets_path, "*.dotx")).map do |f|
        File.basename(f, ".dotx")
      end
    end

    def available_color_schemes
      return [] unless color_schemes_path && File.directory?(color_schemes_path)

      Dir.glob(File.join(color_schemes_path, "*.xml")).map do |f|
        File.basename(f, ".xml")
      end
    end

    def available_font_schemes
      return [] unless font_schemes_path && File.directory?(font_schemes_path)

      Dir.glob(File.join(font_schemes_path, "*.xml")).map do |f|
        File.basename(f, ".xml")
      end
    end
  end
end
