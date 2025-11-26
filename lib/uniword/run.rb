# frozen_string_literal: true

require_relative 'element'
require_relative 'properties/run_properties'
require_relative 'ooxml/namespaces'

module Uniword
  # Represents a text run (inline text element with formatting).
  #
  # In document models, a Run is the smallest unit of text that can have
  # independent formatting. All text within a run shares the same properties.
  #
  # @example Create a simple run
  #   run = Uniword::Run.new(text: "Hello World")
  #
  # @example Create a bold run
  #   run = Uniword::Run.new(text: "Bold text")
  #   run.properties = Uniword::Properties::RunProperties.new(bold: true)
  #
  # @example Check formatting
  #   run.bold?      # => true/false
  #   run.italic?    # => true/false
  #   run.underline? # => true/false
  #
  # @attr [Properties::RunProperties] properties Text formatting properties
  # @attr [TextElement] text_element The text content wrapper
  #
  # @see Paragraph Container for runs
  # @see Properties::RunProperties For text formatting options
  class Run < Element
    # OOXML namespace configuration
    xml do
      element 'r'
      namespace Ooxml::Namespaces::WordProcessingML
      mixed_content

      map_element 'rPr', to: :properties, render_nil: false
      map_element 't', to: :text_element
    end

    # Text run properties (character formatting)
    attribute :properties, Properties::RunProperties

    # The text element containing the actual text content
    attribute :text_element, TextElement

    # Page break marker
    attr_accessor :page_break

    # Parent paragraph (set by paragraph when run is added)
    attr_accessor :parent_paragraph

    # Create a new Run instance
    #
    # @param attributes [Hash] Initial attributes
    # @option attributes [String] :Text Plain text (will be wrapped in TextElement)
    # @option attributes [String, TextElement] :Text_element Text element or string
    # @return [Run] The new Run instance
    def initialize(attributes = {})
      # Handle text parameter - it takes priority over text_element
      if attributes[:text]
        text_content = attributes.delete(:text)
        attributes.delete(:text_element) # Remove text_element if both provided
        attributes[:text_element] = TextElement.new(content: text_content)
      elsif attributes[:text_element].is_a?(String)
        # For compatibility - convert string to TextElement
        text_content = attributes.delete(:text_element)
        attributes[:text_element] = TextElement.new(content: text_content)
      end
      super
    end

    # Get the text content
    # Extracts the content from text_element for convenience
    #
    # @return [String, nil] The text content
    def text
      return nil unless @text_element
      # text_element should always be a TextElement now
      @text_element.content
    end

    # Set the text content
    # Wraps the text in a TextElement
    #
    # @param value [String] The text to set
    def text=(value)
      @text_element = if value.nil?
                        nil
                      else
                        TextElement.new(content: value)
                      end
    end

    # Add text content (alias for text= for API consistency)
    # Provides consistent API with Paragraph#add_text
    #
    # @param content [String] The text to set
    # @return [self] Returns self for method chaining
    def add_text(content)
      self.text = content
      self
    end

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_run(self)
    end

    # Substitute text in run, preserving formatting
    # Compatible with docx gem API
    #
    # @param pattern [String, Regexp] Pattern to match
    # @param replacement [String] Replacement text
    # @return [self] Returns self for method chaining
    #
    # @example Simple substitution
    #   run.substitute('_placeholder_', 'actual value')
    #
    # @example Regex substitution
    #   run.substitute(/\b[A-Z]+\b/, 'REPLACED')
    def substitute(pattern, replacement)
      return self unless text

      if pattern.is_a?(Regexp)
        # For regex patterns, apply word boundary logic to avoid
        # replacing single capital letters in mixed-case words
        # This ensures "Hello WORLD" -> "Hello World" not "Worldello World"
        self.text = text.gsub(pattern) do |match|
          # Check if this is a standalone match (word boundary context)
          match_start = Regexp.last_match.begin(0)
          match_end = Regexp.last_match.end(0)

          # Check if match is surrounded by word boundaries
          before_char = match_start > 0 ? text[match_start - 1] : ' '
          after_char = match_end < text.length ? text[match_end] : ' '

          # If it's a single letter at the start of a mixed-case word, skip it
          if match.length == 1 && after_char =~ /[a-z]/
            match
          else
            replacement
          end
        end
      else
        # For string patterns, do simple replacement
        self.text = text.gsub(pattern, replacement)
      end
      self
    end

    # Substitute text with block for captures
    # Compatible with docx gem API
    #
    # The block receives a MatchData object, allowing access to captures
    # This is different from String#gsub to handle $1/$2 properly
    #
    # @param pattern [Regexp] Pattern to match
    # @yield [MatchData] Gives match data to block
    # @return [self] Returns self for method chaining
    #
    # @example Using captures
    #   run.substitute_with_block(/total: (\d+)/) do |match|
    #     "total: #{match[1].to_i * 10}"
    #   end
    def substitute_with_block(pattern, &block)
      return self unless text

      self.text = text.gsub(pattern) do |_match|
        block.call(Regexp.last_match)
      end
      self
    end

    # Check if run has bold formatting
    # Checks own properties first, then inherits from paragraph style
    #
    # @return [Boolean] true if bold
    def bold?
      # Check if properties were explicitly set
      if @properties && @properties.bold != nil
        return @properties.bold
      end

      # Inherit from paragraph style if available
      style_run_props = paragraph_style_run_properties
      return style_run_props.bold if style_run_props&.bold != nil

      # Default to false
      false
    end

    # Check if run has italic formatting
    # Checks own properties first, then inherits from paragraph style
    #
    # @return [Boolean] true if italic
    def italic?
      # Check if properties were explicitly set
      if @properties && @properties.italic != nil
        return @properties.italic
      end

      # Inherit from paragraph style if available
      style_run_props = paragraph_style_run_properties
      return style_run_props.italic if style_run_props&.italic != nil

      # Default to false
      false
    end

    # Check if run has underline formatting
    #
    # @return [Boolean] true if underlined
    def underline?
      !properties&.underline.nil? && properties.underline != 'none'
    end

    # Check if run has strike-through formatting
    # Compatible with docx gem API
    #
    # @return [Boolean] true if strike-through
    def strike?
      properties&.strike || false
    end
    alias striked? strike?

    # Get the font size in points
    # Checks own properties first, then inherits from paragraph style
    #
    # @return [Integer, nil] Font size in points (half of size attribute)
    def font_size
      # Check if properties were explicitly set
      if @properties && @properties.size
        return @properties.size / 2
      end

      # Inherit from paragraph style if available
      style_run_props = paragraph_style_run_properties
      if style_run_props&.size
        return style_run_props.size / 2
      end

      # No font size defined
      nil
    end

    # Set bold formatting
    # Creates properties if needed
    #
    # @param value [Boolean] true for bold
    # @return [Boolean] the value set
    def bold=(value)
      ensure_properties
      @properties.bold = value
    end

    # Get bold formatting (non-predicate accessor)
    # For compatibility with docx-js style API
    #
    # @return [Boolean] true if bold
    def bold
      bold?
    end

    # Set italic formatting
    # Creates properties if needed
    #
    # @param value [Boolean] true for italic
    # @return [Boolean] the value set
    def italic=(value)
      ensure_properties
      @properties.italic = value
    end

    # Get italic formatting (non-predicate accessor)
    # For compatibility with docx-js style API
    #
    # @return [Boolean] true if italic
    def italic
      italic?
    end

    # Set underline formatting
    # Creates properties if needed
    #
    # @param value [String, Boolean, Hash] underline style or true for 'single'
    # @return [String, Boolean, Hash] the value set
    def underline=(value)
      ensure_properties
      # Track if it was set as a boolean for getter compatibility
      if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        @underline_bool = value
      else
        @underline_bool = nil
      end
      # Handle boolean for convenience (true = 'single', false = 'none')
      @properties.underline = case value
                              when true
                                'single'
                              when false
                                'none'
                              when Hash
                                value[:type] || 'single'
                              else
                                value
                              end
    end

    # Get underline formatting (non-predicate accessor)
    # For compatibility with docx-js style API
    # Returns true if underline was set as boolean, otherwise returns the style string
    #
    # @return [Boolean, String, nil] true if set as boolean, style string, or nil
    def underline
      # If @underline_bool is set, return that (for boolean setter compatibility)
      return @underline_bool if defined?(@underline_bool) && !@underline_bool.nil?
      # Otherwise return the actual underline style
      properties&.underline
    end

    # Set font size in points
    # Creates properties if needed
    #
    # @param value [Integer] font size in points (will be doubled for half-points)
    # @return [Integer] the value set
    def font_size=(value)
      ensure_properties
      # Font size is stored in half-points
      @properties.size = value * 2
    end

    # Set text color
    # Creates properties if needed
    #
    # @param value [String] hex color code (e.g., 'FF0000' for red)
    # @return [String] the value set
    def color=(value)
      ensure_properties
      @properties.color = value
    end

    # Get text color
    # Checks own properties first, then inherits from paragraph style
    # For compatibility with docx-js style API
    #
    # @return [String, nil] hex color code
    def color
      # Check if properties were explicitly set
      return @properties.color if @properties && @properties.color

      # Inherit from paragraph style if available
      style_run_props = paragraph_style_run_properties
      return style_run_props.color if style_run_props&.color

      # No color defined
      nil
    end

    # Set font family
    # Creates properties if needed
    #
    # @param value [String] font family name
    # @return [String] the value set
    def font=(value)
      ensure_properties
      @properties.font = value
    end

    # Get font family
    # Checks own properties first, then inherits from paragraph style
    # For compatibility with docx-js style API
    #
    # @return [String, nil] font family name
    def font
      # Check if properties were explicitly set
      return @properties.font if @properties && @properties.font

      # Inherit from paragraph style if available
      style_run_props = paragraph_style_run_properties
      return style_run_props.font if style_run_props&.font

      # No font defined
      nil
    end

    # Set highlight color
    # Creates properties if needed
    #
    # @param value [String] highlight color name
    # @return [String] the value set
    def highlight=(value)
      ensure_properties
      @properties.highlight = value
    end

    # Get highlight color
    #
    # @return [String, nil] highlight color
    def highlight
      properties&.highlight
    end

    # Set double strike-through formatting
    # Creates properties if needed
    #
    # @param value [Boolean] true for double strike
    # @return [Boolean] the value set
    def double_strike=(value)
      ensure_properties
      @properties.double_strike = value
    end

    # Get double strike-through formatting
    #
    # @return [Boolean] true if double strike
    def double_strike
      properties&.double_strike || false
    end

    # Set vertical alignment (superscript/subscript)
    # Creates properties if needed
    #
    # @param value [String] 'superscript', 'subscript', or 'baseline'
    # @return [String] the value set
    def vertical_align=(value)
      ensure_properties
      @properties.vertical_align = value
    end

    # Get vertical alignment
    #
    # @return [String, nil] vertical alignment
    def vertical_align
      properties&.vertical_align
    end

    # Set small caps formatting
    # Creates properties if needed
    #
    # @param value [Boolean] true for small caps
    # @return [Boolean] the value set
    def small_caps=(value)
      ensure_properties
      @properties.small_caps = value
    end

    # Get small caps formatting
    #
    # @return [Boolean] true if small caps
    def small_caps
      properties&.small_caps || false
    end

    # Set all caps formatting
    # Creates properties if needed
    #
    # @param value [Boolean] true for all caps
    # @return [Boolean] the value set
    def all_caps=(value)
      ensure_properties
      @properties.all_caps = value
    end

    # Get all caps formatting
    #
    # @return [Boolean] true if all caps
    def all_caps
      properties&.all_caps || false
    end

    # Set character spacing
    # Creates properties if needed
    #
    # @param value [Integer] Character spacing in twentieths of a point
    # @return [Integer] the value set
    def character_spacing=(value)
      ensure_properties
      @properties.character_spacing = Properties::CharacterSpacing.new(val: value)
    end

    # Get character spacing
    #
    # @return [Integer, nil] Character spacing in twentieths of a point
    def character_spacing
      properties&.character_spacing&.val
    end

    # Set kerning threshold
    # Creates properties if needed
    #
    # @param value [Integer] Kerning threshold in half-points
    # @return [Integer] the value set
    def kerning=(value)
      ensure_properties
      @properties.kerning = Properties::Kerning.new(val: value)
    end

    # Get kerning threshold
    #
    # @return [Integer, nil] Kerning threshold in half-points
    def kerning
      properties&.kerning&.val
    end

    # Set raised/lowered position
    # Creates properties if needed
    #
    # @param value [Integer] Position in half-points (positive = raised, negative = lowered)
    # @return [Integer] the value set
    def position=(value)
      ensure_properties
      @properties.position = Properties::Position.new(val: value)
    end

    # Get raised/lowered position
    #
    # @return [Integer, nil] Position in half-points
    def position
      properties&.position&.val
    end

    # Set text expansion/compression
    # Creates properties if needed
    #
    # @param value [Integer] Expansion percentage (100 = normal, >100 = expanded, <100 = compressed)
    # @return [Integer] the value set
    def text_expansion=(value)
      ensure_properties
      @properties.text_expansion = Properties::TextExpansion.new(val: value)
    end

    # Get text expansion/compression
    #
    # @return [Integer, nil] Expansion percentage
    def text_expansion
      properties&.text_expansion&.val
    end

    # Set outline effect
    # Creates properties if needed
    #
    # @param value [Boolean] true for outline effect
    # @return [Boolean] the value set
    def outline=(value)
      ensure_properties
      @properties.outline = value
    end

    # Get outline effect
    #
    # @return [Boolean] true if outline effect enabled
    def outline
      properties&.outline || false
    end

    # Set shadow effect
    # Creates properties if needed
    #
    # @param value [Boolean] true for shadow effect
    # @return [Boolean] the value set
    def shadow=(value)
      ensure_properties
      @properties.shadow = value
    end

    # Get shadow effect
    #
    # @return [Boolean] true if shadow effect enabled
    def shadow
      properties&.shadow || false
    end

    # Set emboss effect
    # Creates properties if needed
    #
    # @param value [Boolean] true for emboss effect
    # @return [Boolean] the value set
    def emboss=(value)
      ensure_properties
      @properties.emboss = value
    end

    # Get emboss effect
    #
    # @return [Boolean] true if emboss effect enabled
    def emboss
      properties&.emboss || false
    end

    # Set imprint effect
    # Creates properties if needed
    #
    # @param value [Boolean] true for imprint effect
    # @return [Boolean] the value set
    def imprint=(value)
      ensure_properties
      @properties.imprint = value
    end

    # Get imprint effect
    #
    # @return [Boolean] true if imprint effect enabled
    def imprint
      properties&.imprint || false
    end

    # Set hidden text
    # Creates properties if needed
    #
    # @param value [Boolean] true to hide text
    # @return [Boolean] the value set
    def hidden=(value)
      ensure_properties
      @properties.hidden = value
    end

    # Get hidden text setting
    #
    # @return [Boolean] true if text is hidden
    def hidden
      properties&.hidden || false
    end

    # Set emphasis mark
    # Creates properties if needed
    #
    # @param value [String] Emphasis mark type ('dot', 'comma', 'circle', 'underDot')
    # @return [String] the value set
    def emphasis_mark=(value)
      ensure_properties
      @properties.emphasis_mark = Properties::EmphasisMark.new(val: value)
    end

    # Get emphasis mark
    #
    # @return [String, nil] Emphasis mark type
    def emphasis_mark
      properties&.emphasis_mark&.val
    end

    # Set language
    # Creates properties if needed
    #
    # @param value [String] Language code (e.g., 'en-US', 'fr-FR')
    # @return [String] the value set
    def language=(value)
      ensure_properties
      @properties.language = Properties::Language.new(val: value)
    end

    # Get language
    #
    # @return [String, nil] Language code
    def language
      properties&.language&.val
    end

    # Set shading (background color and pattern)
    # Creates properties if needed
    #
    # @param fill [String, nil] Background fill color (hex)
    # @param color [String, nil] Foreground color (hex)
    # @param pattern [String, nil] Shading pattern ('clear', 'solid', etc.)
    # @return [self] Returns self for method chaining
    def set_shading(fill: nil, color: nil, pattern: nil)
      ensure_properties
      shading = Properties::RunShading.new(
        fill: fill,
        color: color,
        shading_type: pattern || 'clear'
      )
      @properties.shading = shading
      self
    end

    # Set strike-through formatting
    # Creates properties if needed
    #
    # @param value [Boolean] true for strike-through
    # @return [Boolean] the value set
    def strike=(value)
      ensure_properties
      @properties.strike = value
    end

    # Set hyperlink URL
    # Creates properties if needed
    #
    # @param value [String] hyperlink URL
    # @return [String] the value set
    def hyperlink=(value)
      # Store hyperlink reference
      @hyperlink_url = value
    end

    # Get hyperlink URL
    #
    # @return [String, nil] hyperlink URL
    def hyperlink
      @hyperlink_url
    end

    # Export run as HTML
    # Compatible with docx gem API
    #
    # @return [String] HTML representation of the run
    def to_html
      html = text.to_s

      # Apply formatting tags
      html = "<strong>#{html}</strong>" if bold?
      html = "<em>#{html}</em>" if italic?
      html = "<s>#{html}</s>" if strike?

      # Build inline styles
      styles = []
      styles << "text-decoration: underline" if underline?
      styles << "color: ##{properties.color}" if properties&.color
      styles << "font-size: #{font_size}pt" if properties&.size

      # Wrap in span if styles present
      html = "<span style=\"#{styles.join('; ')}\">#{html}</span>" if styles.any?

      html
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the run
    def inspect
      text_preview = text.to_s[0..30]
      text_preview += '...' if text.to_s.length > 30
      formatting = []
      formatting << 'bold' if bold?
      formatting << 'italic' if italic?
      formatting << 'underline' if underline?
      formatting << 'strike' if strike?
      fmt_str = formatting.any? ? " (#{formatting.join(', ')})" : ''
      "#<Uniword::Run text=#{text_preview.inspect}#{fmt_str}>"
    end

    protected

    # Validate that text is present
    #
    # @return [Boolean] true if text is not empty
    def required_attributes_valid?
      !text.nil?
    end

    private

    # Ensure properties object exists
    # Creates a new RunProperties if needed
    #
    # @return [Properties::RunProperties] the properties object
    def ensure_properties
      @properties ||= Properties::RunProperties.new
    end

    # Get run properties from parent paragraph's style
    # Returns nil if no parent paragraph or no style
    #
    # @return [Properties::RunProperties, nil] Style's run properties
    def paragraph_style_run_properties
      return nil unless parent_paragraph
      return nil unless parent_paragraph.parent_document
      return nil unless parent_paragraph.style_id

      # Get the paragraph style
      styles_config = parent_paragraph.parent_document.styles_configuration
      return nil unless styles_config

      style = styles_config.find_by_id(parent_paragraph.style_id)
      return nil unless style
      return nil unless style.respond_to?(:run_properties)

      style.run_properties
    end
  end
end
