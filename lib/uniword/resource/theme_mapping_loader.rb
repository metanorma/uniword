# frozen_string_literal: true

module Uniword
  module Resource
    # Loads and queries the Uniword <-> MS Office theme/styleset mapping
    #
    # The mapping is stored in config/theme_mapping.yml and provides:
    # - Bidirectional name lookup (Uniword <-> MS)
    # - Color fingerprint data for MS theme detection
    # - Customizable mapping entries
    #
    # @example Look up Uniword theme from MS name
    #   ThemeMappingLoader.ms_to_uniword_theme("Atlas")  #=> "meridian"
    #
    # @example Look up MS name from Uniword theme
    #   ThemeMappingLoader.uniword_to_ms_theme("meridian")  #=> "Atlas"
    #
    # @example Get color fingerprint for detection
    #   ThemeMappingLoader.theme_fingerprint("meridian")
    class ThemeMappingLoader
      MAPPING_PATH = File.join(__dir__, "../../..", "config", "theme_mapping.yml")

      # Load and cache the mapping YAML
      #
      # @return [Hash] Parsed mapping data
      def self.mapping
        @mapping ||= YAML.load_file(MAPPING_PATH)
      end

      # Clear cached mapping (useful after file changes)
      def self.reload!
        @mapping = nil
        mapping
      end

      # Look up MS theme name from Uniword theme slug
      #
      # @param uniword_name [String] Uniword theme slug (e.g., "meridian")
      # @return [String, nil] MS theme name or nil
      def self.uniword_to_ms_theme(uniword_name)
        mapping["themes"]&.dig(uniword_name, "ms_name")
      end

      # Look up Uniword theme slug from MS theme name
      #
      # @param ms_name [String] MS theme name (e.g., "Atlas")
      # @return [String, nil] Uniword theme slug or nil
      def self.ms_to_uniword_theme(ms_name)
        mapping["themes"]&.each do |uniword_slug, entry|
          return uniword_slug if entry["ms_name"] == ms_name
        end
        nil
      end

      # Look up MS styleset name from Uniword styleset slug
      #
      # @param uniword_name [String] Uniword styleset slug
      # @return [String, nil] MS styleset name or nil
      def self.uniword_to_ms_styleset(uniword_name)
        mapping["stylesets"]&.dig(uniword_name, "ms_name")
      end

      # Look up Uniword styleset slug from MS styleset name
      #
      # @param ms_name [String] MS styleset name
      # @return [String, nil] Uniword styleset slug or nil
      def self.ms_to_uniword_styleset(ms_name)
        mapping["stylesets"]&.each do |uniword_slug, entry|
          return uniword_slug if entry["ms_name"] == ms_name
        end
        nil
      end

      # Get color fingerprint for a Uniword theme
      #
      # @param uniword_name [String] Uniword theme slug
      # @return [Hash, nil] Color fingerprint hash with 10 keys
      def self.theme_fingerprint(uniword_name)
        mapping["themes"]&.dig(uniword_name, "color_fingerprint")
      end

      # Get all theme mappings
      #
      # @return [Hash] All theme entries keyed by Uniword slug
      def self.all_theme_mappings
        mapping["themes"] || {}
      end

      # Get all styleset mappings
      #
      # @return [Hash] All styleset entries keyed by Uniword slug
      def self.all_styleset_mappings
        mapping["stylesets"] || {}
      end

      # Find Uniword theme by matching a color hash against fingerprints
      #
      # @param colors [Hash] Color hash with keys like "accent1", "dk2", etc.
      # @return [String, nil] Uniword theme slug or nil
      def self.find_by_colors(colors)
        normalized = normalize_colors(colors)

        all_theme_mappings.each do |uniword_slug, entry|
          fp = entry["color_fingerprint"]
          next unless fp

          return uniword_slug if fingerprint_match?(normalized, fp)
        end

        nil
      end

      # Match a color hash against a fingerprint (primary keys: accent1, accent2, dk2)
      #
      # @param actual [Hash] Actual colors from document
      # @param fingerprint [Hash] Fingerprint colors from mapping
      # @return [Boolean]
      def self.fingerprint_match?(actual, fingerprint)
        %w[accent1 accent2 dk2].all? do |key|
          normalize_hex(actual[key]) == normalize_hex(fingerprint[key])
        end
      end

      def self.normalize_colors(colors)
        result = {}
        colors.each { |k, v| result[k.to_s] = v }
        result
      end

      def self.normalize_hex(hex)
        return nil unless hex

        hex.to_s.upcase.gsub(/^#/, "").rjust(6, "0")
      end
    end
  end
end
