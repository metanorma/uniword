# frozen_string_literal: true

require_relative 'element'
require_relative 'run'
require_relative 'properties/paragraph_properties'
require_relative 'comment'
require_relative 'comment_range'
require_relative 'hyperlink'
require_relative 'bookmark'
require_relative 'unknown_element'
require_relative 'ooxml/namespaces'

module Uniword
  # Represents a paragraph (block-level text element).
  #
  # A paragraph contains one or more runs (text segments with formatting).
  # It is a block-level element that represents a single paragraph of text.
  #
  # @example Create a simple paragraph
  #   para = Uniword::Paragraph.new
  #   para.add_text("Hello World")
  #
  # @example Create a formatted paragraph
  #   para = Uniword::Paragraph.new
  #   para.add_text("Bold text", bold: true)
  #   para.add_text(" and italic text", italic: true)
  #
  # @example Set paragraph style
  #   para = Uniword::Paragraph.new
  #   para.set_style('Heading1')
  #   para.add_text("Chapter 1")
  #
  # @example Create a numbered paragraph
  #   para = Uniword::Paragraph.new
  #   para.set_numbering(1, 0)  # numbering_id=1, level=0
  #   para.add_text("First item")
  #
  # @attr [Properties::ParagraphProperties] properties Paragraph formatting
  # @attr [Array<Run>] runs Text runs in this paragraph
  #
  # @see Run For text formatting
  # @see Properties::ParagraphProperties For paragraph formatting options
  class Paragraph < Element
    # OOXML namespace configuration
    xml do
      element 'p'
      namespace Ooxml::Namespaces::WordProcessingML
      mixed_content

      map_element 'pPr', to: :properties, render_nil: false
      map_element 'r', to: :runs
    end

    # Paragraph formatting properties
    attribute :properties, Properties::ParagraphProperties

    # Array of runs (text segments) in this paragraph
    attribute :runs, Run, collection: true, default: -> { [] }

    # Comments attached to this paragraph
    attr_accessor :attached_comments

    # Comment ranges in this paragraph
    attr_accessor :comment_ranges

    # Initialize paragraph
    def initialize(attributes = {})
      super
      @attached_comments = []
      @comment_ranges = []
      @breaks = []
      # Initialize properties to allow setting attributes
      @properties ||= Properties::ParagraphProperties.new unless attributes[:properties]
    end

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_paragraph(self)
    end

    # Get the plain text content of this paragraph
    # Concatenates text from all runs
    # Images are skipped as they don't contain text
    #
    # @return [String] The combined text from all runs
    def text
      runs.select { |run| run.respond_to?(:text) && !run.is_a?(Image) }
          .map(&:text)
          .join
    end

    # Add a run to this paragraph
    # Supports both old API (Run instance) and new API (text with options and block)
    #
    # @param run_or_text [Run, Image, Hyperlink, String] The run to add or text content
    # @param options [Hash] Formatting options (bold, italic, etc.) when text is provided
    # @yield [Run] Optional block to configure the run
    # @return [Array, Run] Returns runs array for backward compatibility when given Run, otherwise returns the added run
    def add_run(run_or_text = nil, **options, &block)
      return_array = false
      run = case run_or_text
            when Run, Image, Hyperlink, Bookmark, UnknownElement
              # Old API: add_run(run_instance)
              # Also accept Image, Hyperlink, Bookmark, and UnknownElement which are Run-like elements
              # Return array for backward compatibility
              return_array = true unless block_given? || options.any?
              run_or_text
            when String
              # New API: add_run("text", bold: true)
              r = Run.new(text: run_or_text)
              # Apply formatting options
              if options.any?
                r.properties = Properties::RunProperties.new(
                  bold: options[:bold],
                  italic: options[:italic],
                  underline: options[:underline],
                  font: options[:font],
                  size: options[:size],
                  color: options[:color]
                )
              end
              r
            when nil
              # New API: add_run { |r| r.text = "text" }
              Run.new
            else
              raise ArgumentError, 'run must be a Run, Image, Hyperlink, Bookmark, or UnknownElement instance'
            end

      # Yield to block if provided (for docx-js style API)
      yield(run) if block_given?

      # Set parent paragraph for property inheritance
      run.parent_paragraph = self if run.respond_to?(:parent_paragraph=)

      runs << run
      return_array ? runs : run
    end

    # Create and add a text run with the given content and optional formatting
    #
    # @param text [String] The text content
    # @param properties [Properties::RunProperties, nil] Optional run properties object
    # @param bold [Boolean, nil] Make text bold
    # @param italic [Boolean, nil] Make text italic
    # @param underline [String, nil] Underline style
    # @param font [String, nil] Font name
    # @param size [Integer, nil] Font size in half-points
    # @param color [String, nil] Text color
    # @return [Run] Returns the created run
    def add_text(text, properties: nil, **options)
      run = Run.new(text: text)

      # Use provided properties or create from options
      if properties
        run.properties = properties
      elsif options.any?
        run.properties = Properties::RunProperties.new(
          bold: options[:bold],
          italic: options[:italic],
          underline: options[:underline],
          font: options[:font],
          size: options[:size],
          color: options[:color]
        )
      end

      add_run(run)
      run  # Return the created run
    end

    # Add a hyperlink to this paragraph
    # Supports both positional and keyword arguments for compatibility
    #
    # @param text_or_url [String] The link text
    # @param url [String, nil] External URL (keyword arg)
    # @param anchor [String, nil] Internal bookmark reference
    # @param tooltip [String, nil] Tooltip text
    # @param properties [Properties::RunProperties, nil] Optional run properties
    # @param options [Hash] Additional formatting options (bold, italic, etc.)
    #
    def add_hyperlink(text_or_url, text_or_options = nil, url: nil, anchor: nil, tooltip: nil, properties: nil, **options)
      # Handle both APIs:
      # Old: add_hyperlink(url, text)
      # New: add_hyperlink(text, url: url)
      link_text, link_url = if text_or_options.is_a?(String)
                              # Old API: add_hyperlink(url, text)
                              [text_or_options, text_or_url]
                            elsif text_or_options.is_a?(Hash)
                              # New API with hash: add_hyperlink(text, {url: url})
                              [text_or_url, text_or_options[:url] || url]
                            else
                              # New API with keywords: add_hyperlink(text, url: url)
                              [text_or_url, url]
                            end

      hyperlink = Hyperlink.new(
        url: link_url,
        anchor: anchor,
        text: link_text,
        tooltip: tooltip
      )

      # Apply custom formatting to the run if specified
      if properties || options.any?
        run = hyperlink.runs.first
        if properties
          run.properties = properties
        elsif options.any?
          run.properties = Properties::RunProperties.new(
            bold: options[:bold],
            italic: options[:italic],
            underline: options[:underline] || 'single',
            font: options[:font],
            size: options[:size],
            color: options[:color] || '0563C1'
          )
        end
      end

      add_run(hyperlink)
      self
    end

    # Check if paragraph is empty (has no runs or all runs are empty)
    #
    # @return [Boolean] true if empty
    def empty?
      runs.empty? || runs.all? { |r| r.text.nil? || r.text.empty? }
    end

    # Get the number of runs in this paragraph
    #
    # @return [Integer] The number of runs
    def run_count
      runs.size
    end

    # Iterate over each text run within a paragraph
    # Compatible with docx gem API
    #
    # @yield [Run] Gives each run to the block
    # @return [void]
    def each_text_run(&block)
      runs.each(&block)
    end

    # Get alignment from properties or inherit from style
    # Returns string value for API compatibility ("left", "center", "right", "both")
    #
    # @return [String, nil] The alignment value as string, or nil if not set
    def alignment
      # First check direct properties
      align = properties&.alignment

      # If not set, try to inherit from paragraph style
      if align.nil? && @parent_document && properties&.style
        style_config = @parent_document.styles_configuration
        if style_config
          style = style_config.find_by_id(properties.style)
          align = style&.paragraph_properties&.alignment if style
        end
      end

      # Return string value for API compatibility
      # Return nil if no alignment is explicitly set
      align&.to_s
    end

    # Get style name from properties
    # Returns the style name (e.g., "Heading 1") for user-facing API
    # Falls back to style ID if name cannot be resolved
    #
    # @return [String, nil] The style name or ID
    def style
      style_id_val = properties&.style
      return nil unless style_id_val

      # Try to resolve to style name if document has styles configuration
      if @parent_document&.styles_configuration
        style_obj = @parent_document.styles_configuration.find_by_id(style_id_val)
        return style_obj.name if style_obj&.name
      end

      # Fall back to ID if cannot resolve
      style_id_val
    end

    # Get style ID from properties
    # Returns the raw style ID (e.g., "Heading1")
    #
    # @return [String, nil] The style ID
    def style_id
      properties&.style
    end

    # Set numbering for this paragraph
    #
    # @param num_id [Integer] The numbering instance ID
    # @param level [Integer] The numbering level (0-8)
    # @return [void]
    def set_numbering(num_id, level = 0)
      # Build attributes from existing properties
      props_attrs = {}
      if properties
        props_attrs[:style] = properties.style if properties.style
        props_attrs[:alignment] = properties.alignment if properties.alignment
        props_attrs[:spacing_before] = properties.spacing_before if properties.spacing_before
        props_attrs[:spacing_after] = properties.spacing_after if properties.spacing_after
        props_attrs[:line_spacing] = properties.line_spacing if properties.line_spacing
        props_attrs[:line_rule] = properties.line_rule if properties.line_rule
        props_attrs[:indent_left] = properties.indent_left if properties.indent_left
        props_attrs[:indent_right] = properties.indent_right if properties.indent_right
        props_attrs[:indent_first_line] = properties.indent_first_line if properties.indent_first_line
        props_attrs[:keep_next] = properties.keep_next if properties.keep_next
        props_attrs[:keep_lines] = properties.keep_lines if properties.keep_lines
        props_attrs[:page_break_before] = properties.page_break_before if properties.page_break_before
        props_attrs[:outline_level] = properties.outline_level if properties.outline_level
      end
      props_attrs[:num_id] = num_id
      props_attrs[:ilvl] = level
      @properties = Properties::ParagraphProperties.new(**props_attrs)
    end

    # Get numbering instance ID
    #
    # @return [Integer, nil] The numbering instance ID
    def num_id
      value = properties&.num_id
      value.nil? ? nil : value.to_i
    end

    # Get numbering level
    #
    # @return [Integer, nil] The numbering level
    def ilvl
      properties&.ilvl
    end

    # Check if paragraph has numbering
    #
    # @return [Boolean] true if numbered
    def numbered?
      !num_id.nil?
    end

    # Get numbering information for this paragraph
    # Compatible with docx gem API
    #
    # @return [Hash, nil] Hash with :num_id and :ilvl (level), or nil if not numbered
    def numbering
      return nil unless numbered?
      { num_id: num_id, ilvl: ilvl, level: ilvl }
    end

    # Set numbering from hash (docx-js compatibility)
    # Accepts hash with :reference, :level, :format, and optional :instance
    #
    # @param value [Hash] Numbering configuration
    # @option value [String, Integer] :reference Numbering reference/ID
    # @option value [Integer] :level Numbering level (0-8)
    # @option value [Integer] :instance Optional instance ID
    # @option value [String] :format Numbering format ('decimal', 'bullet', etc.)
    # @return [Hash] the value set
    def numbering=(value)
      return unless value.is_a?(Hash)

      # Extract numbering ID from reference or instance
      num_id = value[:instance] || value[:reference]
      level = value[:level] || 0
      format = value[:format]

      # If format is provided but no num_id, use helper methods
      if num_id.nil? && format
        case format.to_s
        when 'decimal'
          set_list_number(level)
        when 'bullet'
          set_list_bullet(level)
        else
          # Fallback to decimal for unknown formats
          set_list_number(level)
        end
      else
        # Use existing set_numbering method when num_id is provided
        set_numbering(num_id, level)
      end
      value
    end

    # Set this paragraph as a numbered list item
    # Creates or uses default decimal numbering configuration
    #
    # @param level [Integer] The list level (0-8)
    # @param num_id [Integer, nil] Optional numbering ID (creates default if not provided)
    # @return [self] Returns self for method chaining
    def set_list_number(level = 0, num_id: nil)
      # Get or create numbering ID
      numbering_id = if num_id
                       num_id
                     elsif @parent_document&.numbering_configuration
                       @parent_document.numbering_configuration.default_decimal_num_id
                     else
                       1 # Default fallback
                     end

      set_numbering(numbering_id, level)
      self
    end

    # Set this paragraph as a bulleted list item
    # Creates or uses default bullet numbering configuration
    #
    # @param level [Integer] The list level (0-8)
    # @param num_id [Integer, nil] Optional numbering ID (creates default if not provided)
    # @return [self] Returns self for method chaining
    def set_list_bullet(level = 0, num_id: nil)
      # Get or create numbering ID
      numbering_id = if num_id
                       num_id
                     elsif @parent_document&.numbering_configuration
                       @parent_document.numbering_configuration.default_bullet_num_id
                     else
                       2 # Default fallback (different from decimal)
                     end

      set_numbering(numbering_id, level)
      self
    end

    # Get all hyperlinks in this paragraph
    # Compatible with docx gem API
    #
    # @return [Array<Hyperlink>] Array of hyperlinks in this paragraph
    def hyperlinks
      runs.select { |run| run.is_a?(Hyperlink) }
    end

    # Get all images in this paragraph
    # Compatible with docx gem API
    #
    # @return [Array<Image>] Array of images in this paragraph
    def images
      runs.select { |run| run.is_a?(Image) }
    end

    # Add an image to this paragraph
    # Compatible with docx gem API
    #
    # @param path_or_image [String, Image] Image file path or Image instance
    # @param width [Integer, nil] Image width in EMUs
    # @param height [Integer, nil] Image height in EMUs
    # @param options [Hash] Additional options
    # @return [Image] The added image
    def add_image(path_or_image, width: nil, height: nil, **options)
      require_relative 'image'

      image = if path_or_image.is_a?(Image)
                path_or_image
              else
                # Create image from path
                # For now, create a placeholder - full implementation would handle file
                Image.new(
                  relationship_id: options[:relationship_id] || "rId#{rand(1000..9999)}",
                  width: width,
                  height: height,
                  filename: path_or_image,
                  alt_text: options[:alt_text],
                  title: options[:title]
                )
              end

      # Add image as a run
      add_run(image)
      image
    end

    # Add a math equation to this paragraph
    # Compatible with docx gem API and new fluent API
    #
    # @param formula [Plurimath::Math::Formula, String, nil] Formula object or LaTeX/MathML string
    # @param format [Symbol] Input format (:latex, :mathml, :asciimath, :omml) when string is provided
    # @param display_type [Symbol] Display mode (:inline or :block)
    # @param options [Hash] Additional options
    # @return [MathEquation] The added equation
    def add_math_equation(formula = nil, format: :latex, display_type: :inline, **options, &block)
      require_relative 'math_equation'

      equation = if formula.is_a?(MathEquation)
                   formula
                 elsif formula.respond_to?(:to_latex)
                   # Plurimath::Math::Formula object
                   MathEquation.new(
                     formula: formula,
                     display_type: display_type.to_s,
                     **options
                   )
                 elsif formula.is_a?(String)
                   # Parse string based on format
                   require 'plurimath'
                   parsed_formula = Plurimath::Math.parse(formula, format)
                   MathEquation.new(
                     formula: parsed_formula,
                     display_type: display_type.to_s,
                     **options
                   )
                 else
                   # Create empty equation (can be configured via block)
                   MathEquation.new(
                     display_type: display_type.to_s,
                     **options
                   )
                 end

      # Yield to block if provided
      yield(equation) if block_given?

      # Set parent paragraph for context
      equation.parent_paragraph = self if equation.respond_to?(:parent_paragraph=)

      # Add equation as a run
      add_run(equation)
      equation
    end

    # Get all math equations in this paragraph
    # Compatible with docx gem API
    #
    # @return [Array<MathEquation>] Array of equations in this paragraph
    def math_equations
      runs.select { |run| run.is_a?(MathEquation) }
    end

    # Set the style for this paragraph (fluent interface)
    #
    # @param style_name [String] The style name
    # @return [self] Returns self for method chaining
    def set_style(style_name)
      if properties.nil?
        self.properties = Properties::ParagraphProperties.new(style: style_name)
      else
        # Create new properties with updated style
        self.properties = Properties::ParagraphProperties.new(
          style: style_name,
          alignment: properties.alignment,
          spacing_before: properties.spacing_before,
          spacing_after: properties.spacing_after,
          line_spacing: properties.line_spacing,
          line_rule: properties.line_rule,
          indent_left: properties.indent_left,
          indent_right: properties.indent_right,
          indent_first_line: properties.indent_first_line,
          keep_next: properties.keep_next,
          keep_lines: properties.keep_lines,
          page_break_before: properties.page_break_before,
          outline_level: properties.outline_level,
          num_id: properties.num_id,
          ilvl: properties.ilvl
        )
      end
      self
    end

    # Set the alignment for this paragraph (fluent interface)
    #
    # @param alignment_value [String, Symbol] The alignment value (left, right, center, justify)
    # @return [self] Returns self for method chaining
    def align(alignment_value)
      update_properties(alignment: alignment_value)
      self
    end

    # Helper method to update properties immutably
    # Creates a new properties object with updated values
    private def update_properties(**updates)
      current_attrs = properties ? extract_current_properties : {}
      self.properties = Properties::ParagraphProperties.new(**current_attrs.merge(updates))
    end

    # Extract current property values for recreation
    private def extract_current_properties
      return {} unless properties

      {
        # Basic properties
        style: properties.style,
        alignment: properties.alignment,
        spacing_before: properties.spacing_before,
        spacing_after: properties.spacing_after,
        line_spacing: properties.line_spacing,
        line_rule: properties.line_rule,
        indent_left: properties.indent_left,
        indent_right: properties.indent_right,
        indent_first_line: properties.indent_first_line,
        keep_next: properties.keep_next,
        keep_lines: properties.keep_lines,
        page_break_before: properties.page_break_before,
        outline_level: properties.outline_level,
        num_id: properties.num_id,
        ilvl: properties.ilvl,

        # Enhanced properties (42+ total)
        borders: properties.borders,
        shading: properties.shading,
        tab_stops: properties.tab_stops,
        numbering_properties: properties.numbering_properties,
        frame_properties: properties.frame_properties,
        section_properties: properties.section_properties,
        suppress_line_numbers: properties.suppress_line_numbers,
        contextual_spacing: properties.contextual_spacing,
        bidirectional: properties.bidirectional,
        mirror_indents: properties.mirror_indents,
        snap_to_grid: properties.snap_to_grid,
        widow_control: properties.widow_control,
        text_direction: properties.text_direction,
        conditional_formatting: properties.conditional_formatting,
        run_properties: properties.run_properties,
        properties_change: properties.properties_change
      }.compact
    end

    # Set alignment for this paragraph (property setter)
    # Creates properties if needed
    #
    # @param value [String, Symbol] The alignment value (left, right, center, justify)
    # @return [String] the value set
    def alignment=(value)
      ensure_properties
      properties.alignment = value.to_s
    end

    # Set style for this paragraph (property setter)
    # Creates properties if needed
    #
    # @param value [String] The style name or ID
    # @return [String] the value set
    def style=(value)
      ensure_properties
      properties.style = value
    end

    # Set spacing before paragraph
    # Creates properties if needed
    #
    # @param value [Integer] spacing in points or twips
    # @return [Integer] the value set
    def spacing_before=(value)
      ensure_properties
      properties.spacing_before = value
    end

    # Set spacing after paragraph
    # Creates properties if needed
    #
    # @param value [Integer] spacing in points or twips
    # @return [Integer] the value set
    def spacing_after=(value)
      ensure_properties
      properties.spacing_after = value
    end

    # Set line spacing
    # Creates properties if needed
    #
    # Supports three formats:
    # - Numeric (Float/Integer): Sets "auto" (multiple) spacing, e.g. 1.5
    # - Hash with :rule and :value: Fine-grained control
    #   - { rule: "exact", value: 240 }: Exactly 12pt (240 twips)
    #   - { rule: "atLeast", value: 280 }: At least 14pt (280 twips)
    #   - { rule: "multiple", value: 1.5 }: 1.5x line spacing
    #
    # @param value [Numeric, Hash] line spacing value or hash with :rule and :value
    # @return [Numeric, Hash] the value set
    def line_spacing=(value)
      ensure_properties

      if value.is_a?(Hash)
        # Fine-grained control with rule and value
        rule = value[:rule] || value['rule']
        spacing_value = value[:value] || value['value']

        # Normalize rule names to OOXML format
        normalized_rule = case rule.to_s.downcase
                         when 'exact' then 'exact'
                         when 'atleast', 'at_least' then 'atLeast'
                         when 'multiple', 'auto' then 'auto'
                         else 'auto'
                         end

        properties.line_rule = normalized_rule
        properties.line_spacing = spacing_value.to_f
      else
        # Simple numeric value - treat as "auto" (multiple) spacing
        properties.line_rule = 'auto'
        properties.line_spacing = value.to_f
      end

      value
    end

    # Set left indentation
    # Creates properties if needed
    #
    # @param value [Integer] indentation in twips
    # @return [Integer] the value set
    def indent_left=(value)
      ensure_properties
      properties.indent_left = value
    end

    # Set right indentation
    # Creates properties if needed
    #
    # @param value [Integer] indentation in twips
    # @return [Integer] the value set
    def indent_right=(value)
      ensure_properties
      properties.indent_right = value
    end

    # Set first line indentation
    # Creates properties if needed
    #
    # @param value [Integer] indentation in twips
    # @return [Integer] the value set
    def indent_first_line=(value)
      ensure_properties
      properties.indent_first_line = value
    end

    # Set paragraph borders
    # Creates properties if needed
    #
    # @param top [String, Hash, nil] Top border color or border hash
    # @param bottom [String, Hash, nil] Bottom border color or border hash
    # @param left [String, Hash, nil] Left border color or border hash
    # @param right [String, Hash, nil] Right border color or border hash
    # @param between [String, Hash, nil] Between border for consecutive paragraphs
    # @param bar [String, Hash, nil] Bar border (vertical line on left)
    # @return [self] Returns self for method chaining
    def set_borders(top: nil, bottom: nil, left: nil, right: nil, between: nil, bar: nil)
      ensure_properties

      borders = Properties::ParagraphBorders.new(
        top: border_from_param(top),
        bottom: border_from_param(bottom),
        left: border_from_param(left),
        right: border_from_param(right),
        between: border_from_param(between),
        bar: border_from_param(bar)
      )

      update_properties(borders: borders)
      self
    end

    # Set paragraph shading (background color)
    # Creates properties if needed
    #
    # @param fill [String, nil] Background fill color (hex)
    # @param color [String, nil] Foreground color (hex)
    # @param pattern [String, nil] Shading pattern ('clear', 'solid', etc.)
    # @return [self] Returns self for method chaining
    def set_shading(fill: nil, color: nil, pattern: nil)
      ensure_properties

      shading = Properties::ParagraphShading.new(
        fill: fill,
        color: color,
        shading_type: pattern || 'clear'
      )

      update_properties(shading: shading)
      self
    end

    # Add a tab stop to this paragraph
    # Creates properties if needed
    #
    # @param position [Integer] Tab stop position in twips
    # @param alignment [String] Tab alignment ('left', 'center', 'right', 'decimal', 'bar')
    # @param leader [String, nil] Tab leader character ('none', 'dot', 'hyphen', 'underscore', 'middleDot')
    # @return [self] Returns self for method chaining
    def add_tab_stop(position:, alignment: 'left', leader: nil)
      ensure_properties

      current_tabs = properties.tab_stops || Properties::TabStopCollection.new
      # Use the TabStopCollection's add_tab method
      current_tabs.add_tab(position, alignment, leader || 'none')

      update_properties(tab_stops: current_tabs)
      self
    end

    # Get contextual spacing setting
    #
    # @return [Boolean, nil] contextual spacing setting
    def contextual_spacing
      properties&.contextual_spacing
    end

    # Set contextual spacing
    # Creates properties if needed
    #
    # @param value [Boolean] contextual spacing value
    # @return [Boolean] the value set
    def contextual_spacing=(value)
      ensure_properties
      properties.contextual_spacing = value
    end

    # Add a line break to this paragraph
    # Creates a run with a break element
    #
    # @param type [String, Symbol] break type (:line, :page, :column)
    # @return [Run] the created run with break
    def add_break(type = :line)
      run = Run.new(text: '')
      # Mark the run as having a break
      case type.to_sym
      when :page
        run.page_break = true
      when :line, :column
        # Line break is the default, column breaks are similar
        # These would need proper implementation in serialization
      end
      add_run(run)
      # Track the break
      @breaks << { type: type.to_sym, run: run }
      run
    end

    # Get all breaks in this paragraph
    #
    # @return [Array] array of break info hashes
    def breaks
      @breaks ||= []
    end

    # Remove this paragraph from its parent document
    # Compatible with docx gem API
    #
    # @return [self] Returns self for method chaining
    def remove!
      if @parent_document
        @parent_document.body.paragraphs.delete(self)
        @parent_document.clear_element_cache
      end
      self
    end

    # Parent document accessor (set by document when added)
    attr_accessor :parent_document

    # Set text content (replaces all runs with single run)
    # Compatible with docx gem API
    #
    # @param content [String] The new text content
    # @return [String] The text that was set
    def text=(content)
      # Clear existing runs
      self.runs = []
      # Add new run with content
      add_text(content)
      content
    end

    # Export paragraph as HTML
    # Compatible with docx gem API
    #
    # @return [String] HTML representation of the paragraph
    def to_html
      html_content = runs.map(&:to_html).join

      # Build style attributes
      styles = []
      # Only add text-align if explicitly set and not the default "left"
      if alignment && alignment != 'left'
        styles << "text-align: #{alignment}"
      end
      styles << "margin-top: #{properties.spacing_before}pt" if properties&.spacing_before
      styles << "margin-bottom: #{properties.spacing_after}pt" if properties&.spacing_after

      style_attr = styles.any? ? " style=\"#{styles.join('; ')}\"" : ""

      "<p#{style_attr}>#{html_content}</p>"
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the paragraph
    def inspect
      text_preview = text[0..50]
      text_preview += '...' if text.length > 50
      "#<Uniword::Paragraph runs=#{runs.count} comments=#{attached_comments.count} style=#{style.inspect} text=#{text_preview.inspect}>"
    end

    # Add a comment to this paragraph
    #
    # @param comment [Comment] The comment to add
    # @param range [Hash, nil] Optional range specification { start: index, end: index }
    # @return [self] Returns self for method chaining
    def add_comment(comment, range: nil)
      raise ArgumentError, 'comment must be a Comment instance' unless comment.is_a?(Comment)

      # Store comment
      @attached_comments << comment

      # Create range markers
      start_marker = CommentRange.new(
        comment_id: comment.comment_id,
        marker_type: :start
      )
      end_marker = CommentRange.new(
        comment_id: comment.comment_id,
        marker_type: :end
      )
      reference_marker = CommentRange.new(
        comment_id: comment.comment_id,
        marker_type: :reference
      )

      # Store range markers
      @comment_ranges << start_marker
      @comment_ranges << end_marker
      @comment_ranges << reference_marker

      self
    end

    # Get all comments attached to this paragraph
    #
    # @return [Array<Comment>] The attached comments
    def comments
      @attached_comments
    end

    # Check if paragraph has comments
    #
    # @return [Boolean] true if has comments
    def has_comments?
      !@attached_comments.empty?
    end

    # Remove a comment by ID
    #
    # @param comment_id [String] The comment ID to remove
    # @return [Comment, nil] The removed comment if found
    def remove_comment(comment_id)
      comment = @attached_comments.find { |c| c.comment_id == comment_id.to_s }
      if comment
        @attached_comments.delete(comment)
        @comment_ranges.reject! { |r| r.comment_id == comment_id.to_s }
      end
      comment
    end

    protected

    # Validate that paragraph has at least one run
    # Override if different validation is needed
    #
    # @return [Boolean] true if valid
    def required_attributes_valid?
      true # Paragraphs can be empty
    end

    private

    # Ensure properties object exists
    # Creates a new ParagraphProperties if needed
    #
    # @return [Properties::ParagraphProperties] the properties object
    def ensure_properties
      @properties ||= Properties::ParagraphProperties.new
    end

    # Convert a border parameter to a Border object
    # Accepts string (color), hash (full border spec), or nil
    #
    # @param param [String, Hash, nil] Border specification
    # @return [Properties::Border, nil] Border object or nil
    private def border_from_param(param)
      return nil if param.nil?

      case param
      when String
        # Simple color string - create default border with that color
        Properties::Border.new(style: 'single', size: 4, color: param)
      when Hash
        # Full border specification
        Properties::Border.new(
          style: param[:style] || 'single',
          size: param[:size] || 4,
          color: param[:color],
          space: param[:space],
          shadow: param[:shadow],
          frame: param[:frame]
        )
      else
        nil
      end
    end
  end
end
