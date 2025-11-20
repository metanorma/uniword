# frozen_string_literal: true

module Uniword
  module Themes
    # Orchestrates theme loading from .thmx files
    #
    # Coordinates between ThemePackageReader and ThemeXmlParser
    # to load themes and their variants from .thmx packages.
    #
    # @example Load a theme
    #   loader = ThemeLoader.new
    #   theme = loader.load('Atlas.thmx')
    #   puts theme.name
    #   puts theme.variants.keys
    #
    # @example Load with specific variant
    #   theme = loader.load_with_variant('Atlas.thmx', 'variant2')
    #   puts theme.name
    class ThemeLoader
      # Load theme from .thmx file
      #
      # @param path [String] Path to .thmx file
      # @return [Theme] Loaded theme with variants and media
      # @raise [ArgumentError] if file is invalid
      def load(path)
        require_relative 'theme_package_reader'
        require_relative 'theme_xml_parser'

        # Extract package
        reader = ThemePackageReader.new
        extracted = reader.extract(path)

        # Parse base theme
        parser = ThemeXmlParser.new
        theme = parser.parse(extracted[:base])

        # Store source file reference
        theme.source_file = path

        # Store media files
        theme.media_files = extracted[:media] || {}

        # Load variants
        theme.variants = load_variants(extracted[:variants])

        theme
      end

      # Load theme with specific variant applied
      #
      # @param path [String] Path to .thmx file
      # @param variant_id [String, Integer] Variant identifier
      #   Can be 'variant1', 'variant2', etc. or numeric 1, 2, etc.
      # @return [Theme] Theme with variant applied
      # @raise [ArgumentError] if variant not found
      def load_with_variant(path, variant_id)
        # Normalize variant ID
        variant_key = normalize_variant_id(variant_id)

        # Load base theme
        base_theme = load(path)

        # Get variant
        variant = base_theme.variants[variant_key]
        unless variant
          raise ArgumentError,
                "Variant '#{variant_id}' not found. " \
                "Available variants: #{base_theme.variants.keys.join(', ')}"
        end

        # Apply variant to base theme
        variant.apply_to(base_theme)
      end

      private

      # Load all variants from extracted theme package
      #
      # @param variant_xmls [Hash] variant_id => theme XML content
      # @return [Hash] variant_id => ThemeVariant
      def load_variants(variant_xmls)
        require_relative 'theme_variant'

        variants = {}

        variant_xmls.each do |variant_id, theme_xml|
          variant = ThemeVariant.new(variant_id, theme_xml: theme_xml)
          variants[variant_id] = variant
        end

        variants
      end

      # Normalize variant ID to standard format
      #
      # Converts numeric IDs to variant{N} format
      #
      # @param variant_id [String, Integer] Variant identifier
      # @return [String] Normalized variant ID
      def normalize_variant_id(variant_id)
        case variant_id
        when Integer
          "variant#{variant_id}"
        when /^\d+$/
          "variant#{variant_id}"
        else
          variant_id.to_s
        end
      end
    end
  end
end