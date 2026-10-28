# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Theme and style application for DocumentRoot — Word's
    # Design/Layout/Styles surfaces as document-level API.
    #
    # Extracted from DocumentRoot to keep the document model focused:
    # bundled and file-based theme application, stylesets, font and
    # color schemes, font replacement, page setup, and style
    # management (rename/remove).
    module DocumentStyling
      # Applies a Uniword theme by name, updating doc defaults and
      # built-in heading/hyperlink styles to reference the theme.
      #
      # @param name [String, Symbol] Theme slug (e.g., 'meridian',
      #   'corporate')
      # @param options [Hash] optional overrides
      # @option options [Hash] :colors override specific color keys
      # @option options [String] :major_font override major font
      # @option options [String] :minor_font override minor font
      # @return [self] For method chaining
      def apply_theme(name, **options)
        friendly = Themes::Theme.load(name.to_s)

        options[:colors]&.each do |key, value|
          friendly.color_scheme[key.to_s] = value
        end
        if options[:major_font]
          friendly.font_scheme.major_font = options[:major_font]
        end
        if options[:minor_font]
          friendly.font_scheme.minor_font = options[:minor_font]
        end

        word_theme = Themes::ThemeTransformation.new.to_word(friendly)
        Themes::ThemeApplicator.new.apply(word_theme, self)
        self
      end

      # Apply theme from .thmx file
      #
      # @param path [String] Path to .thmx file
      # @param variant [String, Integer, nil] Optional variant
      # @return [self] For method chaining
      def apply_theme_file(path, variant: nil)
        loader = Themes::ThemeLoader.new
        self.theme = if variant
                       loader.load_with_variant(path, variant)
                     else
                       loader.load(path)
                     end
        self
      end

      # Apply StyleSet to document
      #
      # @param name [String, Symbol] StyleSet slug (e.g., 'signature',
      #   'heritage')
      # @param strategy [Symbol] Application strategy (:keep_existing,
      #   :replace, :rename)
      # @return [self] For method chaining
      def apply_styleset(name, strategy: :keep_existing)
        styleset = Uniword::Stylesets::YamlStyleSetLoader
          .load_bundled(name.to_s)
        styleset.apply_to(self, strategy: strategy)
        self
      end

      # Apply a bundled font scheme to the document's theme
      #
      # Mirrors Word's Design → Fonts gallery: replaces only the theme's
      # fontScheme — colors and formats are untouched. Creates the theme
      # part from the bundled Office theme when the document has none.
      #
      # @param name [String, Symbol] Font scheme slug (data/font_schemes/)
      # @return [self] For method chaining
      # @raise [ArgumentError] if the scheme is unknown
      def apply_font_scheme(name)
        fonts = Resource::FontSchemeLoader.load(name.to_s)
        transformation = Themes::ThemeTransformation.new
        ensure_theme!(transformation)
        theme.theme_elements.font_scheme =
          transformation.build_font_scheme(fonts)
        self
      end

      # Apply a bundled color scheme to the document's theme
      #
      # Mirrors Word's Design → Colors gallery: replaces only the theme's
      # clrScheme — fonts and formats are untouched. Creates the theme
      # part from the bundled Office theme when the document has none.
      #
      # @param name [String, Symbol] Color scheme slug (data/color_schemes/)
      # @return [self] For method chaining
      # @raise [ArgumentError] if the scheme is unknown
      def apply_color_scheme(name)
        colors = Resource::ColorSchemeLoader.load(name.to_s)
        transformation = Themes::ThemeTransformation.new
        ensure_theme!(transformation)
        theme.theme_elements.clr_scheme =
          transformation.build_color_scheme(colors)
        self
      end

      # Replace one font family with another across the document
      #
      # Mirrors Word's Home → Replace → Replace Fonts: rewrites rFonts
      # references in styles and defaults, body content, headers,
      # footers, notes, comments, and numbering. Theme font references
      # (asciiTheme etc.) are untouched — use #apply_font_scheme for
      # those.
      #
      # @param from [String] Font family to replace (exact match)
      # @param to [String] Replacement font family
      # @return [Integer] Number of rFonts attribute values rewritten
      def replace_font(from:, to:)
        replacer = FontReplacer.new(from: from, to: to)
        replacer.replace(self)
      end

      # Find and replace text across document parts.
      #
      # Mirrors Word's Home → Replace dialog (without the GUI).
      # Replaces every non-overlapping match of `pattern` with
      # `replacement` across the configured scopes. Returns a
      # `FindReplace::Result` with per-scope counts.
      #
      # v1 limitation: matches inside a single run only. Matches
      # that span run boundaries are silently skipped (Word does the
      # same in default mode).
      #
      # @param pattern [String, Regexp] literal String or Regexp
      # @param replacement [String] replacement text; for regex
      #   patterns, may reference captures via `\1`, `\2`, ...
      # @param scope [Symbol, Array<Symbol>, :all] one or more of
      #   `:body`, `:headers`, `:footers`, `:footnotes`, `:endnotes`,
      #   `:comments`, `:styles`, or `:all` (default)
      # @param ignore_case [Boolean] case-insensitive match
      # @return [FindReplace::Result]
      def find_replace(pattern, replacement, scope: :all, ignore_case: false)
        matcher = build_find_replace_matcher(pattern, replacement, ignore_case)
        FindReplace::Engine.new(document: self, matcher: matcher,
                                scopes: scope).run
      end

      # Turn change tracking on. Every subsequent edit is recorded as
      # a tracked change. Mirrors Word's Review → Track Changes → On.
      #
      # @return [self]
      def track_changes_on!
        ensure_settings.track_changes = Wordprocessingml::TrackChanges.new
        self
      end

      # Turn change tracking off. Existing tracked changes remain in
      # the document; new edits are applied silently. Mirrors Word's
      # Review → Track Changes → Off.
      #
      # @return [self]
      def track_changes_off!
        ensure_settings.track_changes = nil
        self
      end

      # True when change tracking is enabled.
      #
      # @return [Boolean]
      def track_changes_enabled?
        settings&.track_changes ? true : false
      end

      # Redact PII patterns and/or custom regex across the document.
      #
      # Built on FindReplace. Default pattern library matches US
      # phone numbers, email, SSN, credit card numbers, IPv4
      # addresses. Pass `patterns: :pii` for defaults, or an array
      # of names (`[:ssn, :email]`) to select a subset.
      #
      # @param patterns [Symbol, Array<Symbol>, Array<Redact::Pattern>]
      #   `:pii` (default), or names/Pattern objects to apply
      # @param scope [Symbol, Array<Symbol>, :all] find-replace scope
      # @return [Redact::Result]
      def redact(patterns: :pii, scope: :all)
        Redact::Engine.new(document: self, patterns: patterns,
                           scope: scope).run
      end

      # Run a lint ruleset against the document.
      #
      # @param ruleset [Lint::Ruleset, Array<Lint::Rule>] rules to
      #   apply
      # @return [Lint::Result]
      def lint(ruleset:)
        Lint::Engine.new(document: self, ruleset: ruleset).run
      end

      # Counter for auto-numbered captions. Persisted across the
      # document's lifetime; reset on document load.
      #
      # @return [Caption::Counter]
      def caption_counter
        @caption_counter ||= Caption::Counter.new
      end

      # Add an auto-numbered caption paragraph to the body and
      # return the bookmark name (for use in cross-references).
      #
      # The caption is appended as a new paragraph with style
      # "Caption" and a SEQ field. The bookmark wraps the entire
      # paragraph so cross-references resolve to the caption text.
      #
      # @param label [String] "Figure", "Table", "Equation", or any
      #   other category — each gets its own counter
      # @param text [String] caption body
      # @param separator [String] between the label/number and the
      #   body (default ": ")
      # @return [String] bookmark name (e.g. "_Figure1")
      def add_caption(label:, text:, separator: ": ")
        builder = Caption::CaptionBuilder.new(caption_counter)
        paragraph, bookmark_name = builder.build(label: label,
                                                 text: text,
                                                 separator: separator)
        body.paragraphs << paragraph
        bookmark_name
      end

      # Build a cross-reference run targeting a bookmark. Returns a
      # Run containing a SimpleField with a REF instruction. The
      # caller decides where to place it.
      #
      # @param bookmark_name [String] target bookmark
      # @return [Wordprocessingml::SimpleField]
      def cross_reference_to(bookmark_name)
        Caption::CrossReference.new(bookmark_name).build
      end

      # Apply uniform page setup to every section of the document
      #
      # Mirrors Word's Layout dialog: named paper sizes, orientation
      # (with Word-style dimension swap), and margins.
      #
      # @param size [String, nil] Paper size: letter, legal, a4, a5,
      #   executive
      # @param orientation [String, nil] "portrait" or "landscape"
      # @param margins [Integer, String, nil] Uniform margin for all
      #   sides (twips, or "1in" / "2.5cm" / "25mm")
      # @param top, right, bottom, left [Integer, String, nil] Per-side
      #   margin overrides
      # @return [Integer] Number of sections updated
      def apply_page_setup(size: nil, orientation: nil, margins: nil,
                           top: nil, right: nil, bottom: nil, left: nil)
        setup = PageSetup.new(size: size, orientation: orientation,
                              margins: margins, top: top, right: right,
                              bottom: bottom, left: left)
        setup.apply(self)
      end

      # Remove one style from the document's style definitions
      #
      # Default styles (w:default="1") are never removed.
      #
      # @param style_id [String] Style id (w:styleId)
      # @return [Style, nil] The removed style, or nil when not
      #   removed (absent or protected)
      def remove_style(style_id)
        style = styles_configuration.style(style_id)
        return unless StyleCleanup.new(self).remove?(style_id)

        style
      end

      # Rename a style's display name (w:name) — Word's style rename.
      # References (pStyle/rStyle/tblStyle) target the styleId, so they
      # keep working unchanged.
      #
      # @param identifier [String] Style id (w:styleId) or current
      #   display name (w:name)
      # @param new_name [String] New display name
      # @return [Style, nil] The renamed style, or nil when not found
      def rename_style(identifier, new_name)
        style = styles_configuration.style(identifier)
        return unless style

        style.name = StyleName.new(val: new_name)
        style
      end

      # Remove every style that no content references — Word's
      # Styles-pane decluttering as one call. Default styles are kept.
      #
      # @return [Array<String>] Ids of removed styles
      def remove_unused_styles
        StyleCleanup.new(self).remove_unused
      end

      # Auto-transition from MS theme to Uniword equivalent
      #
      # Detects the MS theme in the document's embedded theme and replaces
      # it with the corresponding Uniword theme (font-substituted, renamed).
      #
      # @return [Hash, nil] { uniword_slug:, ms_name: } or nil if no match
      #
      # @example
      #   result = doc.auto_transition_theme
      #   puts "Transitioned from " \
      #        "#{result[:ms_name]} to #{result[:uniword_slug]}"
      def auto_transition_theme
        Resource::ThemeTransition.auto_transition!(self)
      end

      # Apply theme from another document
      #
      # @param source_path [String] Path to source .docx file
      # @return [self] For method chaining
      def apply_theme_from(source_path)
        source_doc = Uniword.load(source_path)
        self.theme = source_doc.theme.dup if source_doc.theme
        self
      end

      # Apply styles from another document
      #
      # @param source_path [String] Path to source .docx file
      # @param strategy [Symbol] Conflict resolution strategy
      # @return [self] For method chaining
      def apply_styles_from(source_path, strategy: :keep_existing)
        source_doc = Uniword.load(source_path)
        styles_configuration.merge(source_doc.styles_configuration,
                                   conflict_resolution: strategy)
        self
      end

      # Apply both theme and styles from a template document
      #
      # @param template_path [String] Path to template .docx file
      # @param strategy [Symbol] Conflict resolution strategy for styles
      # @return [self] For method chaining
      def apply_template(template_path, strategy: :keep_existing)
        template_doc = Uniword.load(template_path)
        self.theme = template_doc.theme.dup if template_doc.theme
        styles_configuration.merge(template_doc.styles_configuration,
                                   conflict_resolution: strategy)
        self
      end

      private

      def build_find_replace_matcher(pattern, replacement, ignore_case)
        if pattern.is_a?(Regexp)
          FindReplace::RegexMatcher.new(pattern: pattern,
                                        replacement: replacement)
        else
          FindReplace::StringMatcher.new(pattern: pattern,
                                         replacement: replacement,
                                         ignore_case: ignore_case)
        end
      end

      def ensure_settings
        self.settings ||= Wordprocessingml::Settings.new
      end

      # Ensure the document carries a theme part, creating it from a
      # fresh parse of the bundled Office theme when absent (every
      # document gets its own copy — no shared state).
      #
      # @param transformation [Themes::ThemeTransformation] Converter
      # @return [void]
      def ensure_theme!(transformation)
        return if theme&.theme_elements

        self.theme = transformation.default_office_theme
      end
    end
  end
end
