# frozen_string_literal: true

require_relative 'properties/paragraph_properties'
require_relative 'properties/run_properties'
require_relative 'properties/table_properties'

module Uniword
  # Represents a document style definition
  # Responsibility: Hold style properties and inheritance
  #
  # Styles are reusable formatting definitions that can be applied to
  # paragraphs, runs, tables, or numbering. They support inheritance
  # via the basedOn property, creating a style hierarchy.
  class Style < Lutaml::Model::Serializable
    # OOXML namespace configuration
    xml do
      root 'style'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      # Style attributes
      map_attribute 'type', to: :type
      map_attribute 'styleId', to: :id
      map_attribute 'default', to: :default
      map_attribute 'customStyle', to: :custom

      # Style metadata elements
      map_element 'name', to: :name, render_nil: false
      map_element 'basedOn', to: :based_on, render_nil: false
      map_element 'next', to: :next_style, render_nil: false
      map_element 'link', to: :linked_style, render_nil: false
      map_element 'uiPriority', to: :ui_priority, render_nil: false
      map_element 'qFormat', to: :quick_format, render_nil: false

      # Property containers
      map_element 'pPr', to: :paragraph_properties, render_nil: false
      map_element 'rPr', to: :run_properties, render_nil: false
      map_element 'tblPr', to: :table_properties, render_nil: false
    end

    # YAML serialization (for bundled stylesets)
    yaml do
      # Style metadata
      map 'id', to: :id
      map 'type', to: :type
      map 'name', to: :name
      map 'default', to: :default
      map 'custom', to: :custom
      map 'based_on', to: :based_on
      map 'next_style', to: :next_style
      map 'linked_style', to: :linked_style
      map 'ui_priority', to: :ui_priority
      map 'quick_format', to: :quick_format

      # ========================================================================
      # Paragraph Formatting Properties (for paragraph and table styles)
      # ========================================================================
      map 'contextual_spacing', to: :contextual_spacing

      # ========================================================================
      # Character/Run Formatting Properties (for all style types)
      # ========================================================================
      map 'underline', to: :underline
      map 'strike', to: :strike
      map 'double_strike', to: :double_strike
      map 'small_caps', to: :small_caps
      map 'all_caps', to: :all_caps
      map 'character_spacing', to: :character_spacing
      map 'vertical_align', to: :vertical_align
      map 'font_weight', to: :font_weight
      map 'font_family_cs', to: :font_family_cs
      map 'font_family_ea', to: :font_family_ea

      # ========================================================================
      # Property Container Objects (for StyleSet support)
      # ========================================================================
      # Used when styles are loaded from .dsf, .dst files are referenced.
      map 'paragraph_properties', to: :paragraph_properties
      map 'run_properties', to: :run_properties
      map 'table_properties', to: :table_properties
    end

    # Style identifier (unique ID)
    attribute :id, :string

    # Style type: paragraph, character, table, or numbering
    attribute :type, :string

    # Human-readable style name
    attribute :name, :string

    # Whether this is a default style
    attribute :default, :boolean, default: -> { false }

    # Whether this is a custom (user-defined) style
    attribute :custom, :boolean, default: -> { false }

    # ID of the style this is based on (inheritance)
    attribute :based_on, :string

    # ID of the style to use for the next paragraph
    attribute :next_style, :string

    # ID of a linked style (e.g., character style linked to paragraph style)
    attribute :linked_style, :string

    # UI priority for style ordering
    attribute :ui_priority, :integer

    # Whether this style appears in quick format gallery
    attribute :quick_format, :boolean, default: -> { false }

    # ========================================================================
    # Paragraph Formatting Properties (for paragraph and table styles)
    # ========================================================================

    # Paragraph alignment: left, center, right, both (justify), distribute
    attribute :alignment, :string

    # Spacing before paragraph in twips (1/20 point, 1440 twips = 1 inch)
    attribute :spacing_before, :integer

    # Spacing after paragraph in twips
    attribute :spacing_after, :integer

    # Line spacing value in twips or percentage
    attribute :line_spacing, :integer

    # Line spacing rule: auto, exact, atLeast
    attribute :line_spacing_rule, :string

    # Left indent in twips
    attribute :indent_left, :integer

    # Right indent in twips
    attribute :indent_right, :integer

    # First line indent in twips (can be negative for hanging indent)
    attribute :indent_first_line, :integer

    # Keep with next paragraph (boolean)
    attribute :keep_next, :boolean, default: -> { false }

    # Keep lines together (prevent page break within paragraph)
    attribute :keep_lines, :boolean, default: -> { false }

    # Page break before this paragraph
    attribute :page_break_before, :boolean, default: -> { false }

    # Widow/orphan control
    attribute :widow_control, :boolean, default: -> { true }

    # Contextual spacing (suppress spacing between paragraphs of same style)
    attribute :contextual_spacing, :boolean, default: -> { false }

    # Outline level (1-9 for headings, 10 for body text)
    attribute :outline_level, :integer

    # ========================================================================
    # Character/Run Formatting Properties (for all style types)
    # ========================================================================

    # Font family name
    attribute :font_family, :string

    # Font size in half-points (22 = 11pt, 24 = 12pt)
    attribute :font_size, :integer

    # Font color as RGB hex (e.g., "FF0000" for red)
    attribute :font_color, :string

    # Theme color reference (e.g., "accent1", "dark1", "light1")
    attribute :font_color_theme, :string

    # Theme color tint/shade value (-255 to 255)
    attribute :font_color_theme_tint, :integer

    # Bold formatting
    attribute :bold, :boolean, default: -> { false }

    # Italic formatting
    attribute :italic, :boolean, default: -> { false }

    # Underline style: none, single, double, thick, dotted, dottedHeavy,
    # dash, dashedHeavy, dashLong, dashLongHeavy, dotDash, dashDotHeavy,
    # dotDotDash, dashDotDotHeavy, wave, wavyHeavy, wavyDouble, words
    attribute :underline, :string

    # Strikethrough formatting
    attribute :strike, :boolean, default: -> { false }

    # Double strikethrough formatting
    attribute :double_strike, :boolean, default: -> { false }

    # Small caps formatting
    attribute :small_caps, :boolean, default: -> { false }

    # All caps formatting
    attribute :all_caps, :boolean, default: -> { false }

    # Character spacing in twips
    attribute :character_spacing, :integer

    # Vertical alignment: baseline, superscript, subscript
    attribute :vertical_align, :string

    # Font weight (100-900, where 400=normal, 700=bold)
    attribute :font_weight, :integer

    # Complex script font family
    attribute :font_family_cs, :string

    # East Asian font family
    attribute :font_family_ea, :string

    # ========================================================================
    # Property Container Objects (NEW - for StyleSet support)
    # ========================================================================

    # Paragraph properties object (contains all paragraph formatting)
    # Used when loading from .dotx StyleSets
    attribute :paragraph_properties, Properties::ParagraphProperties

    # Run properties object (contains all character formatting)
    # Used when loading from .dotx StyleSets
    attribute :run_properties, Properties::RunProperties

    # Table properties object (contains all table formatting)
    # Used when loading from .dotx StyleSets
    attribute :table_properties, Properties::TableProperties

    # Aliases for docx-js compatibility
    alias_method :style_id, :id
    alias_method :style_id=, :id=
    alias_method :style_name, :name
    alias_method :style_name=, :name=

    # Override initialize to handle alias parameters
    def initialize(attributes = {})
      # Convert aliases to actual attribute names
      if attributes.key?(:style_id)
        attributes[:id] = attributes.delete(:style_id)
      end
      if attributes.key?(:style_name)
        attributes[:name] = attributes.delete(:style_name)
      end
      super
    end

    # Get the effective properties by resolving inheritance chain
    # Subclasses should implement this to merge properties from base styles
    #
    # @param styles_config [StylesConfiguration] The styles configuration
    # @return [Hash] Merged properties
    def effective_properties(styles_config = nil)
      properties = own_properties

      if based_on && styles_config
        begin
          base_style = styles_config.style_by_id(based_on)
          base_props = base_style.effective_properties(styles_config)
          properties = base_props.merge(properties)
        rescue StandardError
          # Base style not found, use own properties only
        end
      end

      properties
    end

    # Get this style's own properties
    #
    # This method returns all formatting properties defined on this style,
    # excluding metadata properties. Used for style inheritance resolution.
    #
    # @return [Hash] Style's own formatting properties
    def own_properties
      props = {}

      # Paragraph properties (only for paragraph/table styles)
      if paragraph_style? || table_style?
        props[:alignment] = alignment if alignment
        props[:spacing_before] = spacing_before if spacing_before
        props[:spacing_after] = spacing_after if spacing_after
        props[:line_spacing] = line_spacing if line_spacing
        props[:line_spacing_rule] = line_spacing_rule if line_spacing_rule
        props[:indent_left] = indent_left if indent_left
        props[:indent_right] = indent_right if indent_right
        props[:indent_first_line] = indent_first_line if indent_first_line
        props[:keep_next] = keep_next unless keep_next.nil?
        props[:keep_lines] = keep_lines unless keep_lines.nil?
        props[:page_break_before] = page_break_before unless page_break_before.nil?
        props[:widow_control] = widow_control unless widow_control.nil?
        props[:contextual_spacing] = contextual_spacing unless contextual_spacing.nil?
        props[:outline_level] = outline_level if outline_level
      end

      # Character/run properties (for all style types)
      props[:font_family] = font_family if font_family
      props[:font_size] = font_size if font_size
      props[:font_color] = font_color if font_color
      props[:font_color_theme] = font_color_theme if font_color_theme
      props[:font_color_theme_tint] = font_color_theme_tint if font_color_theme_tint
      props[:bold] = bold unless bold.nil?
      props[:italic] = italic unless italic.nil?
      props[:underline] = underline if underline
      props[:strike] = strike unless strike.nil?
      props[:double_strike] = double_strike unless double_strike.nil?
      props[:small_caps] = small_caps unless small_caps.nil?
      props[:all_caps] = all_caps unless all_caps.nil?
      props[:character_spacing] = character_spacing if character_spacing
      props[:vertical_align] = vertical_align if vertical_align
      props[:font_weight] = font_weight if font_weight
      props[:font_family_cs] = font_family_cs if font_family_cs
      props[:font_family_ea] = font_family_ea if font_family_ea

      props
    end

    # Check if this is a paragraph style
    #
    # @return [Boolean] true if paragraph style
    def paragraph_style?
      type == 'paragraph'
    end

    # Check if this is a character style
    #
    # @return [Boolean] true if character style
    def character_style?
      type == 'character'
    end

    # Check if this is a table style
    #
    # @return [Boolean] true if table style
    def table_style?
      type == 'table'
    end

    # Check if this is a numbering style
    #
    # @return [Boolean] true if numbering style
    def numbering_style?
      type == 'numbering'
    end

    # Validate the style
    #
    # @return [Boolean] true if valid
    def valid?
      !id.to_s.strip.empty? &&
        !type.nil? && %w[paragraph character table numbering].include?(type)
    end

    # ========================================================================
    # Property Helper Methods for XML Serialization
    # ========================================================================

    # Check if this style has any paragraph properties defined
    #
    # @return [Boolean] true if any paragraph property is set
    def has_paragraph_properties?
      return false unless paragraph_style? || table_style?

      alignment || spacing_before || spacing_after || line_spacing ||
        line_spacing_rule || indent_left || indent_right || indent_first_line ||
        keep_next || keep_lines || page_break_before || widow_control ||
        contextual_spacing || outline_level
    end

    # Check if this style has any run/character properties defined
    #
    # @return [Boolean] true if any run property is set
    def has_run_properties?
      font_family || font_size || font_color || font_color_theme ||
        font_color_theme_tint || bold || italic || underline || strike ||
        double_strike || small_caps || all_caps || character_spacing ||
        vertical_align || font_weight || font_family_cs || font_family_ea
    end

    # Build paragraph properties XML fragment
    # This will be used when serializing styles to word/styles.xml
    #
    # @return [String, nil] XML fragment for <w:pPr> element
    def paragraph_properties_xml
      return nil unless has_paragraph_properties?

      parts = []

      # Alignment
      parts << %(<w:jc w:val="#{alignment}"/>) if alignment

      # Spacing
      if spacing_before || spacing_after || line_spacing
        attrs = []
        attrs << %(w:before="#{spacing_before}") if spacing_before
        attrs << %(w:after="#{spacing_after}") if spacing_after
        attrs << %(w:line="#{line_spacing}") if line_spacing
        attrs << %(w:lineRule="#{line_spacing_rule}") if line_spacing_rule
        parts << "<w:spacing #{attrs.join(' ')}/>"
      end

      # Indentation
      if indent_left || indent_right || indent_first_line
        attrs = []
        attrs << %(w:left="#{indent_left}") if indent_left
        attrs << %(w:right="#{indent_right}") if indent_right
        attrs << %(w:firstLine="#{indent_first_line}") if indent_first_line && indent_first_line >= 0
        attrs << %(w:hanging="#{-indent_first_line}") if indent_first_line && indent_first_line < 0
        parts << "<w:ind #{attrs.join(' ')}/>"
      end

      # Paragraph behavior
      parts << '<w:keepNext/>' if keep_next
      parts << '<w:keepLines/>' if keep_lines
      parts << '<w:pageBreakBefore/>' if page_break_before
      parts << '<w:widowControl/>' if widow_control
      parts << '<w:contextualSpacing/>' if contextual_spacing

      # Outline level
      parts << %(<w:outlineLvl w:val="#{outline_level}"/>) if outline_level

      "<w:pPr>#{parts.join}</w:pPr>"
    end

    # Build run/character properties XML fragment
    # This will be used when serializing styles to word/styles.xml
    #
    # @return [String, nil] XML fragment for <w:rPr> element
    def run_properties_xml
      return nil unless has_run_properties?

      parts = []

      # Font families
      if font_family || font_family_cs || font_family_ea
        attrs = []
        attrs << %(w:ascii="#{font_family}") if font_family
        attrs << %(w:hAnsi="#{font_family}") if font_family
        attrs << %(w:cs="#{font_family_cs || font_family}") if font_family || font_family_cs
        attrs << %(w:eastAsia="#{font_family_ea || font_family}") if font_family || font_family_ea
        parts << "<w:rFonts #{attrs.join(' ')}/>"
      end

      # Font size (stored in half-points, serialized in half-points)
      parts << %(<w:sz w:val="#{font_size}"/>) if font_size
      parts << %(<w:szCs w:val="#{font_size}"/>) if font_size

      # Font color
      if font_color || font_color_theme
        attrs = []
        attrs << %(w:val="#{font_color}") if font_color
        attrs << %(w:themeColor="#{font_color_theme}") if font_color_theme
        attrs << %(w:themeTint="#{font_color_theme_tint}") if font_color_theme_tint
        parts << "<w:color #{attrs.join(' ')}/>"
      end

      # Text formatting
      parts << '<w:b/>' if bold
      parts << '<w:bCs/>' if bold
      parts << '<w:i/>' if italic
      parts << '<w:iCs/>' if italic
      parts << %(<w:u w:val="#{underline}"/>) if underline
      parts << '<w:strike/>' if strike
      parts << '<w:dstrike/>' if double_strike
      parts << '<w:smallCaps/>' if small_caps
      parts << '<w:caps/>' if all_caps

      # Character spacing
      parts << %(<w:spacing w:val="#{character_spacing}"/>) if character_spacing

      # Vertical alignment
      parts << %(<w:vertAlign w:val="#{vertical_align}"/>) if vertical_align

      "<w:rPr>#{parts.join}</w:rPr>"
    end
  end
end