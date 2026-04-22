# frozen_string_literal: true

module Uniword
  module Resource
    # Detects Microsoft Word built-in themes and transitions them to
    # Uniword equivalents using the color fingerprint mapping.
    #
    # @example Auto-detect and transition
    #   doc = Uniword::Document.open("ms_report.docx")
    #   result = ThemeTransition.auto_transition!(doc)
    #   # => { uniword_slug: "meridian", ms_name: "Atlas" }
    #
    # @example Detect by theme object
    #   slug = ThemeTransition.detect_ms_theme(doc.theme)
    #   # => "meridian"
    #
    # @example Detect by name string
    #   slug = ThemeTransition.from_ms_name("Atlas")
    #   # => "meridian"
    class ThemeTransition
      # Color keys used for fingerprint matching.
      # These 3 colors are sufficient to uniquely identify each MS theme.
      FINGERPRINT_KEYS = %w[accent1 accent2 dk2].freeze

      # Result object returned from transition operations
      TransitionResult = Struct.new(:uniword_slug, :ms_name, keyword_init: true)

      # Detect which Uniword theme corresponds to the MS theme in a Drawingml::Theme
      #
      # @param drawingml_theme [Drawingml::Theme] OOXML theme from a document
      # @return [String, nil] Uniword theme slug or nil if no match
      def self.detect_ms_theme(drawingml_theme)
        return nil unless drawingml_theme

        colors = extract_colors(drawingml_theme)
        return nil unless colors

        ThemeMappingLoader.find_by_colors(colors)
      end

      # Look up Uniword theme by MS theme name string
      #
      # @param ms_name [String] MS theme display name (e.g., "Atlas")
      # @return [String, nil] Uniword theme slug or nil
      def self.from_ms_name(ms_name)
        ThemeMappingLoader.ms_to_uniword_theme(ms_name)
      end

      # Look up Uniword styleset by MS styleset name string
      #
      # @param ms_name [String] MS styleset display name (e.g., "Distinctive")
      # @return [String, nil] Uniword styleset slug or nil
      def self.styleset_from_ms_name(ms_name)
        ThemeMappingLoader.ms_to_uniword_styleset(ms_name)
      end

      # Auto-transition: detect MS theme in document, apply Uniword equivalent
      #
      # @param document [Wordprocessingml::DocumentRoot] Target document
      # @return [TransitionResult, nil] Result with slug and name, or nil if no match
      def self.auto_transition!(document)
        word_theme = document.theme
        return nil unless word_theme

        # Try detection by color fingerprint
        uniword_slug = detect_ms_theme(word_theme)

        # Fall back to detection by theme name
        uniword_slug = from_ms_name(word_theme.name) if uniword_slug.nil? && word_theme.respond_to?(:name) && word_theme.name

        return nil unless uniword_slug

        ms_name = ThemeMappingLoader.uniword_to_ms_theme(uniword_slug)

        # Apply the Uniword theme
        apply_uniword_theme(document, uniword_slug)

        TransitionResult.new(uniword_slug: uniword_slug, ms_name: ms_name)
      end

      # Apply a specific Uniword theme to a document
      #
      # @param document [Wordprocessingml::DocumentRoot] Target document
      # @param uniword_slug [String] Uniword theme slug
      # @return [void]
      def self.apply_uniword_theme(document, uniword_slug)
        friendly = Themes::Theme.load(uniword_slug)
        word_theme = Themes::ThemeTransformation.new.to_word(friendly)
        Themes::ThemeApplicator.new.apply(word_theme, document)
      end

      # Extract color values from a Drawingml::Theme's color scheme
      #
      # @param drawingml_theme [Drawingml::Theme]
      # @return [Hash, nil] Hash with string keys and hex values
      def self.extract_colors(drawingml_theme)
        cs = drawingml_theme.theme_elements&.clr_scheme
        return nil unless cs

        {
          "dk1" => extract_hex(cs, :dk1),
          "lt1" => extract_hex(cs, :lt1),
          "dk2" => extract_hex(cs, :dk2),
          "lt2" => extract_hex(cs, :lt2),
          "accent1" => extract_hex(cs, :accent1),
          "accent2" => extract_hex(cs, :accent2),
          "accent3" => extract_hex(cs, :accent3),
          "accent4" => extract_hex(cs, :accent4),
          "accent5" => extract_hex(cs, :accent5),
          "accent6" => extract_hex(cs, :accent6)
        }
      end

      # Extract hex value from a color scheme color slot
      #
      # @param color_scheme [Drawingml::ColorScheme] Color scheme object
      # @param key [Symbol] Color key (e.g., :accent1)
      # @return [String, nil] Hex color value
      def self.extract_hex(color_scheme, key)
        color_scheme[key]
      end
    end
  end
end
