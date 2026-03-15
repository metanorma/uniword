# frozen_string_literal: true

# Add hyperlink and convenience methods to Run class

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Text run - inline text with formatting
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:r>
    class Run < Lutaml::Model::Serializable
      attribute :properties, RunProperties
      attribute :text, :string
      attribute :tab, Tab
      attribute :break, Break
      attribute :drawings, Drawing, collection: true, default: -> { [] }
      attribute :alternate_content, AlternateContent, default: nil

      xml do
        element 'r'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'rPr', to: :properties, render_nil: false
        map_element 't', to: :text, render_nil: false
        map_element 'tab', to: :tab, render_nil: false
        map_element 'br', to: :break, render_nil: false
        map_element 'drawing', to: :drawings, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
      end

      # Get bold property object
      #
      # @return [Properties::Bold, nil] The bold property object
      def bold
        properties&.bold
      end

      # Check if run is bold
      def bold?
        props = properties
        return false if props.nil?

        bold_prop = props.bold
        return false if bold_prop.nil?

        # Handle both wrapper object and primitive
        bold_val = bold_prop.respond_to?(:value) ? bold_prop.value : bold_prop
        bold_val == true
      end

      # Get italic property object
      #
      # @return [Properties::Italic, nil] The italic property object
      def italic
        properties&.italic
      end

      # Check if run is italic
      def italic?
        props = properties
        return false if props.nil?

        italic_prop = props.italic
        return false if italic_prop.nil?

        # Handle both wrapper object and primitive
        italic_val = italic_prop.respond_to?(:value) ? italic_prop.value : italic_prop
        italic_val == true
      end

      # Get underline property object
      #
      # @return [Properties::Underline, nil] The underline property object
      def underline
        properties&.underline
      end

      # Check if run is underlined
      def underline?
        properties&.underline && properties.underline != 'none'
      end

      # Set bold formatting
      def bold=(value)
        self.properties ||= RunProperties.new
        properties.bold = value.is_a?(Properties::Bold) ? value : Properties::Bold.new(value: value)
        self
      end

      # Set italic formatting
      def italic=(value)
        self.properties ||= RunProperties.new
        properties.italic = value.is_a?(Properties::Italic) ? value : Properties::Italic.new(value: value)
        self
      end

      # Set underline formatting
      def underline=(value)
        self.properties ||= RunProperties.new
        properties.underline = if value.is_a?(Properties::Underline)
                                 value
                               elsif value == true
                                 Properties::Underline.new(value: 'single')
                               else
                                 Properties::Underline.new(value: value.to_s)
                               end
        self
      end

      # Set text color
      def color=(value)
        self.properties ||= RunProperties.new
        properties.color = value.is_a?(Properties::ColorValue) ? value : Properties::ColorValue.new(value: value)
        self
      end

      # Set font
      def font=(value)
        self.properties ||= RunProperties.new
        properties.font = value
        self
      end

      # Set font size in points
      def size=(value)
        self.properties ||= RunProperties.new
        properties.size = Properties::FontSize.new(value: value * 2)
        self
      end

      # Set strike-through formatting
      def strike=(value)
        self.properties ||= RunProperties.new
        properties.strike = value.is_a?(Properties::Strike) ? value : Properties::Strike.new(value: value)
        self
      end

      # Set double-strike-through formatting
      def double_strike=(value)
        self.properties ||= RunProperties.new
        properties.double_strike = value.is_a?(Properties::DoubleStrike) ? value : Properties::DoubleStrike.new(value: value)
        self
      end

      # Set small caps formatting
      def small_caps=(value)
        self.properties ||= RunProperties.new
        properties.small_caps = value.is_a?(Properties::SmallCaps) ? value : Properties::SmallCaps.new(value: value)
        self
      end

      # Set all caps formatting
      def caps=(value)
        self.properties ||= RunProperties.new
        properties.caps = value.is_a?(Properties::Caps) ? value : Properties::Caps.new(value: value)
        self
      end

      # Set highlight color
      def highlight=(value)
        self.properties ||= RunProperties.new
        properties.highlight = value.is_a?(Properties::Highlight) ? value : Properties::Highlight.new(value: value)
        self
      end

      # Set kerning (font kerning threshold)
      #
      # @param value [Integer] Kerning threshold in half-points
      # @return [self] For method chaining
      def kerning=(value)
        self.properties ||= RunProperties.new
        properties.kerning = if value.is_a?(Properties::Kerning)
                               value
                             else
                               Properties::Kerning.new(value: value)
                             end
        self
      end

      # Set character spacing
      #
      # @param value [Integer, Properties::CharacterSpacing] Character spacing value
      # @return [self] For method chaining
      def character_spacing=(value)
        self.properties ||= RunProperties.new
        properties.character_spacing = if value.is_a?(Properties::CharacterSpacing)
                                         value
                                       else
                                         Properties::CharacterSpacing.new(value: value)
                                       end
        self
      end

      # Hyperlink storage (for v2.0 API compatibility)
      # In v2.0, we store hyperlink URL on the run for convenience
      # This allows docx.js API compatibility where runs can have hyperlinks directly
      # Note: This is stored as an instance variable, not as an XML attribute
      #
      # @return [String, nil] The hyperlink URL
      attr_reader :hyperlink

      # Set hyperlink URL (convenience method for v2.0 API compatibility)
      #
      # @param value [String] The hyperlink URL
      # @return [self] For method chaining
      def hyperlink=(value)
        @hyperlink = value
        self
      end

      # Set vertical alignment (superscript/subscript)
      def vert_align=(value)
        self.properties ||= RunProperties.new
        properties.vert_align = value
        self
      end

      # Set position (for superscript/subscript offset)
      #
      # @param value [Integer] Position offset in half-points
      # @return [self] For method chaining
      def position=(value)
        self.properties ||= RunProperties.new
        properties.position = if value.is_a?(Properties::Position)
                                value
                              else
                                Properties::Position.new(value: value)
                              end
        self
      end

      # Add text to run
      #
      # @param value [String] Text to add
      # @return [self] For method chaining
      def add_text(value)
        self.text = (text || '') + value.to_s
        self
      end

      # Get drawings from this run
      #
      # @return [Array<Drawing>] Array of drawing elements
      def drawings
        @drawings ||= []
      end

      # Accept a visitor (Visitor pattern)
      #
      # @param visitor [BaseVisitor] The visitor to accept
      # @return [void]
      def accept(visitor)
        visitor.visit_run(self)
      end

      # Set language (convenience method)
      #
      # @param value [String] Language code (e.g., "en-US")
      # @return [self] For method chaining
      def language=(value)
        self.properties ||= RunProperties.new
        properties.language = if value.is_a?(Properties::Language)
                               value
                             else
                               Properties::Language.new(val: value)
                             end
        self
      end

      # Set emphasis mark (convenience method)
      #
      # @param value [String] Emphasis mark type
      # @return [self] For method chaining
      def emphasis_mark=(value)
        self.properties ||= RunProperties.new
        properties.emphasis_mark = value.is_a?(Properties::EmphasisMark) ? value : Properties::EmphasisMark.new(value: value)
        self
      end

      # Set page break (convenience method)
      #
      # @param value [Boolean] True for page break
      # @return [self] For method chaining
      def page_break=(value)
        self.properties ||= RunProperties.new
        properties.page_break = value
        self
      end

      # Set outline (convenience method)
      #
      # @param value [Boolean, Integer] Outline level
      # @return [self] For method chaining
      def outline=(value)
        self.properties ||= RunProperties.new
        properties.outline_level = if value.is_a?(Properties::OutlineLevel)
                                     value
                                   else
                                     Properties::OutlineLevel.new(value: value)
                                   end
        self
      end

      # Set shading (convenience method)
      #
      # @param options [Hash] Shading options
      # @return [self] For method chaining
      def set_shading(options = {})
        self.properties ||= RunProperties.new
        properties.shading = Properties::Shading.new(
          fill: options[:fill],
          color: options[:color],
          pattern: options[:pattern] || 'clear'
        )
        self
      end

      # Substitute text in run
      #
      # @param pattern [Regexp, String] Pattern to match
      # @param replacement [String] Replacement text
      # @return [self] For method chaining
      def substitute(pattern, replacement)
        return self unless text

        self.text = text.gsub(pattern, replacement)
        self
      end

      # Substitute with block
      #
      # @param pattern [Regexp, String] Pattern to match
      # @yield [Match] Block receives match object
      # @return [self] For method chaining
      def substitute_with_block(pattern, &block)
        return self unless text

        self.text = text.gsub(pattern, &block)
        self
      end

      # Set text expansion (convenience method)
      #
      # @param value [String, Integer] Text expansion value
      # @return [self] For method chaining
      def text_expansion=(value)
        self.properties ||= RunProperties.new
        properties.width_scale = if value.is_a?(Properties::WidthScale)
                                   value
                                 else
                                   Properties::WidthScale.new(value: value)
                                 end
        self
      end

      # Get text expansion
      #
      # @return [Integer, nil] Text expansion value
      def text_expansion
        properties&.width_scale&.value
      end

      # Check if run has strikethrough
      #
      # @return [Boolean] true if run has strikethrough
      def strike?
        properties&.strike? || false
      end

      # Set shadow formatting
      #
      # @param value [Boolean, String] Shadow value
      # @return [self] For method chaining
      def shadow=(value)
        self.properties ||= RunProperties.new
        properties.shadow = if value.is_a?(Properties::Shadow)
                              value
                            else
                              Properties::Shadow.new(value: value)
                            end
        self
      end

      # Convert run to HTML
      #
      # @return [String] HTML representation of the run
      def to_html
        return '' unless text

        content = CGI.escapeHTML(text)

        # Apply formatting tags
        content = "<strong>#{content}</strong>" if bold?
        content = "<em>#{content}</em>" if italic?
        content = "<u>#{content}</u>" if underline?
        content = "<s>#{content}</s>" if strike?
        if properties&.color
          content = "<span style=\"color:##{properties.color}\">#{content}</span>"
        end

        # Handle font
        if properties&.font
          font_style = "font-family:#{properties.font};"
          content = "<span style=\"#{font_style}\">#{content}</span>"
        end

        content
      end

      # Get font size
      #
      # @return [Integer, nil] Font size in points
      def font_size
        size_val = properties&.size
        return nil unless size_val

        # Handle both wrapper objects and primitive values
        size_val = size_val.value if size_val.respond_to?(:value)
        size_val.to_i / 2
      end

      # Set font size
      #
      # @param value [Integer] Font size in points
      # @return [self] For method chaining
      def font_size=(value)
        self.properties ||= RunProperties.new
        properties.size = Properties::FontSize.new(value: value * 2)
        self
      end

      # Get font name
      #
      # @return [String, nil] Font name
      def font
        properties&.font
      end

      # Get font color
      #
      # @return [String, nil] Font color as hex
      def color
        properties&.color&.value
      end

      # Set font color
      #
      # @param value [String] Font color as hex
      # @return [self] For method chaining
      def color=(value)
        self.properties ||= RunProperties.new
        properties.color = Properties::ColorValue.new(value: value)
        self
      end

      # Set emboss
      #
      # @param value [Boolean] Emboss value
      # @return [self] For method chaining
      def emboss=(value)
        self.properties ||= RunProperties.new
        properties.emboss = if value.is_a?(Properties::Emboss)
                              value
                            else
                              Properties::Emboss.new(value: value)
                            end
        self
      end

      # Set imprint
      #
      # @param value [Boolean] Imprint value
      # @return [self] For method chaining
      def imprint=(value)
        self.properties ||= RunProperties.new
        properties.imprint = if value.is_a?(Properties::Imprint)
                               value
                             else
                               Properties::Imprint.new(value: value)
                             end
        self
      end

      # Get highlight color
      #
      # @return [String, nil] Highlight color value
      def highlight
        properties&.highlight&.value
      end

      # Set highlight color
      #
      # @param value [String] Highlight color
      # @return [self] For method chaining
      def highlight=(value)
        self.properties ||= RunProperties.new
        properties.highlight = value.is_a?(Properties::Highlight) ? value : Properties::Highlight.new(value: value)
        self
      end

      # Check if page break
      #
      # @return [Boolean] True if run contains page break
      def page_break?
        brk = self.break
        brk&.type == 'page'
      end

      # Get page break
      #
      # @return [Break, nil] The break element
      def page_break
        self.break
      end

      # Set page break
      #
      # @param value [Boolean, Break] Page break value
      # @return [self] For method chaining
      def page_break=(value)
        if value
          self.break ||= Break.new(type: 'page')
        else
          self.break = nil
        end
        self
      end

      # Check if run has strikethrough
      #
      # @return [Boolean] True if run has strikethrough
      def striked?
        strike?
      end

      # Custom inspect for readable output
      #
      # @return [String] Human-readable representation
      def inspect
        text_preview = text.to_s
        if text_preview.length > 40
          text_preview = "#{text_preview[0, 37]}..."
        end

        flags = []
        flags << 'bold' if bold?
        flags << 'italic' if italic?
        flags << 'underline' if underline?

        flags_str = flags.empty? ? '' : " #{flags.join(' ')}"
        "#<Uniword::Run#{flags_str} text=\"#{text_preview}\">"
      end
    end
  end
end
