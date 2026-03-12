# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Paragraph - block-level text element
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:p>
    class Paragraph < Lutaml::Model::Serializable
      attribute :properties, ParagraphProperties
      attribute :runs, Run, collection: true, default: -> { [] }
      attribute :hyperlinks, Hyperlink, collection: true, default: -> { [] }
      attribute :bookmark_starts, BookmarkStart, collection: true, default: -> { [] }
      attribute :bookmark_ends, BookmarkEnd, collection: true, default: -> { [] }
      attribute :field_chars, FieldChar, collection: true, default: -> { [] }
      attribute :instr_text, InstrText, collection: true, default: -> { [] }
      attribute :comment_range_starts, CommentRangeStart, collection: true, default: -> { [] }
      attribute :comment_range_ends, CommentRangeEnd, collection: true, default: -> { [] }
      attribute :comment_references, CommentReference, collection: true, default: -> { [] }
      attribute :alternate_content, AlternateContent, default: nil
      attribute :sdts, StructuredDocumentTag, collection: true, default: -> { [] }
      attribute :o_math_paras, Uniword::Math::OMathPara, collection: true, default: -> { [] }

      # Pattern 0: Revision tracking attributes (rsid)
      attribute :rsid_r, :string          # Revision ID for paragraph creation
      attribute :rsid_r_default, :string  # Default revision ID
      attribute :rsid_p, :string          # Revision ID for properties

      xml do
        element 'p'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Revision tracking attributes
        map_attribute 'rsidR', to: :rsid_r, render_nil: false
        map_attribute 'rsidRDefault', to: :rsid_r_default, render_nil: false
        map_attribute 'rsidP', to: :rsid_p, render_nil: false

        map_element 'pPr', to: :properties, render_nil: false
        map_element 'r', to: :runs, render_nil: false
        map_element 'hyperlink', to: :hyperlinks, render_nil: false
        map_element 'bookmarkStart', to: :bookmark_starts, render_nil: false
        map_element 'bookmarkEnd', to: :bookmark_ends, render_nil: false
        map_element 'fldChar', to: :field_chars, render_nil: false
        map_element 'instrText', to: :instr_text, render_nil: false
        map_element 'commentRangeStart', to: :comment_range_starts, render_nil: false
        map_element 'commentRangeEnd', to: :comment_range_ends, render_nil: false
        map_element 'commentReference', to: :comment_references, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
        map_element 'sdt', to: :sdts, render_nil: false
        # oMathPara from MathML namespace - the target class declares its namespace
        map_element 'oMathPara', to: :o_math_paras,
                                 render_nil: false
      end

      # Add text run to paragraph
      #
      # @param text [String] Text content
      # @param options [Hash] Formatting options
      # @return [Run] The created run
      def add_text(text, **options)
        run = Run.new
        run.text = text

        if options.any?
          run.properties ||= RunProperties.new
          run.properties.bold = Properties::Bold.new(value: true) if options[:bold]
          run.properties.italic = Properties::Italic.new(value: true) if options[:italic]
          if options[:underline]
            run.properties.underline = Properties::Underline.new(value: options[:underline])
          end
          if options[:color]
            run.properties.color = Properties::ColorValue.new(value: options[:color])
          end
          if options[:size]
            run.properties.size = Properties::FontSize.new(value: options[:size] * 2)
          end
          run.properties.font = options[:font] if options[:font]
        end

        self.runs ||= []
        runs << run
        run
      end

      # Add run to paragraph
      #
      # @param text [String, nil] Optional text content
      # @param options [Hash] Formatting options
      # @return [Run] The created/added run
      def add_run(run_or_text = nil, **options)
        case run_or_text
        when Run
          runs << run_or_text
          run_or_text
        else
          add_text(run_or_text, **options) if run_or_text
        end
      end

      # Get paragraph text
      #
      # @return [String] Combined text from all runs
      def text
        return '' unless runs

        runs.map { |r| r.text.to_s }.join
      end

      # Check if paragraph is empty
      #
      # @return [Boolean] true if no runs or all runs empty
      def empty?
        !runs || runs.empty? || runs.all? { |r| r.text.to_s.empty? }
      end

      # Set paragraph alignment (fluent interface)
      #
      # @param alignment [String, Symbol] Alignment value (left, center, right, justify)
      # @return [self] For method chaining
      def align(alignment)
        self.properties ||= ParagraphProperties.new
        properties.alignment = alignment.to_s
        self
      end

      # Set paragraph style
      #
      # @param style_name [String] Style name or ID
      # @return [self] For method chaining
      def set_style(style_name)
        self.properties ||= ParagraphProperties.new
        properties.style = style_name
        self
      end

      # Set paragraph numbering
      #
      # @param num_id [Integer] Numbering ID
      # @param level [Integer] Numbering level (0-based)
      # @return [self] For method chaining
      def set_numbering(num_id, level = 0)
        self.properties ||= ParagraphProperties.new
        properties.num_id = num_id
        properties.ilvl = level
        self
      end

      # Numbering ID
      #
      # @return [Integer, nil] Numbering ID
      def num_id
        properties&.num_id
      end

      # Numbering level
      #
      # @return [Integer, nil] Numbering level (0-based)
      def ilvl
        properties&.ilvl
      end

      # Set spacing before paragraph
      #
      # @param value [Integer] Spacing in twips (1/1440 inch)
      # @return [self] For method chaining
      def spacing_before(value)
        self.properties ||= ParagraphProperties.new
        properties.spacing_before = value
        self
      end

      # Set spacing after paragraph
      #
      # @param value [Integer] Spacing in twips (1/1440 inch)
      # @return [self] For method chaining
      def spacing_after(value)
        self.properties ||= ParagraphProperties.new
        properties.spacing_after = value
        self
      end

      # Get or set line spacing
      #
      # @param value [Float, nil] Line spacing multiplier (nil to get current value)
      # @param rule [String] Line rule (auto, exact, atLeast)
      # @return [Float, Hash, self] Returns current value when called without args,
      #   or self for method chaining when setting
      def line_spacing(value = nil, rule = 'auto')
        if value.nil? && !block_given?
          # Getter behavior - return current line spacing
          return get_line_spacing
        end

        # Setter behavior
        self.properties ||= ParagraphProperties.new
        properties.line_spacing = value
        properties.line_rule = rule
        self
      end

      # Set line spacing (setter method for simple API)
      #
      # @param value [Float, Hash] Line spacing value or hash with :value and :rule keys
      # @return [self] For method chaining
      def line_spacing=(value)
        case value
        when Hash
          spacing_value = value[:value] || value['value']
          spacing_rule = value[:rule] || value['rule']
          # Normalize 'multiple' to 'auto' and 'at_least' to 'atLeast'
          spacing_rule = 'auto' if spacing_rule == 'multiple'
          spacing_rule = 'atLeast' if spacing_rule == 'at_least'
          line_spacing(spacing_value, spacing_rule || 'auto')
        when Numeric
          line_spacing(value, 'auto')
        else
          line_spacing(value.to_f, 'auto')
        end
      end

      # Get line spacing
      #
      # @return [Float, Hash] Numeric value for auto spacing, or hash with rule and value for other rules
      def get_line_spacing
        return nil unless properties&.line_spacing

        if properties.line_rule == 'auto'
          properties.line_spacing
        else
          { rule: properties.line_rule, value: properties.line_spacing }
        end
      end
      alias line_spacing_value get_line_spacing

      # Set left indent
      #
      # @param value [Integer] Indent in twips (1/1440 inch)
      # @return [self] For method chaining
      def indent_left(value)
        self.properties ||= ParagraphProperties.new
        properties.indent_left = value
        self
      end

      # Set right indent
      #
      # @param value [Integer] Indent in twips (1/1440 inch)
      # @return [self] For method chaining
      def indent_right(value)
        self.properties ||= ParagraphProperties.new
        properties.indent_right = value
        self
      end

      # Set first line indent
      #
      # @param value [Integer] Indent in twips (1/1440 inch)
      # @return [self] For method chaining
      def indent_first_line(value)
        self.properties ||= ParagraphProperties.new
        properties.indent_first_line = value
        self
      end

      # Set paragraph style (setter method)
      #
      # @param value [String] Style name or ID
      # @return [String] The style that was set
      def style=(value)
        self.properties ||= ParagraphProperties.new
        properties.style = value
      end

      # Get paragraph style
      #
      # @return [String, nil] Style name or nil if not set
      def style
        properties&.style
      end

      # Alias for style (for compatibility)
      alias style_id style

      # Set borders on paragraph
      #
      # @param options [Hash] Border options (:top, :bottom, :left, :right, :style, :color, :size)
      # @return [self] For method chaining
      def set_borders(options = {})
        self.properties ||= ParagraphProperties.new
        # ParagraphProperties handles borders through pBdr element
        properties.borders ||= ParagraphBorder.new
        options.each do |key, value|
          case key
          when :top
            properties.borders.top = Border.new(val: value)
          when :bottom
            properties.borders.bottom = Border.new(val: value)
          when :left
            properties.borders.left = Border.new(val: value)
          when :right
            properties.borders.right = Border.new(val: value)
          end
        end
        self
      end

      # Set shading on paragraph
      #
      # @param options [Hash] Shading options (:fill, :color, :pattern)
      # @return [self] For method chaining
      def set_shading(options = {})
        self.properties ||= ParagraphProperties.new
        properties.shading = Shading.new(
          fill: options[:fill],
          color: options[:color],
          pattern: options[:pattern] || 'clear'
        )
        self
      end

      # Add tab stop to paragraph
      #
      # @param position [Integer] Tab position in twips
      # @param alignment [Symbol, String] Tab alignment (:left, :center, :right, :decimal)
      # @return [self] For method chaining
      def add_tab_stop(position, alignment = :left)
        self.properties ||= ParagraphProperties.new
        properties.tab_stops ||= []
        properties.tab_stops << TabStop.new(position: position, alignment: alignment.to_s)
        self
      end

      # Get numbering properties
      #
      # @return [Hash, nil] Hash with :num_id and :level, or nil
      def numbering
        return nil unless properties&.num_id

        { num_id: properties.num_id, level: properties.ilvl }
      end

      # Check if paragraph has numbering
      #
      # @return [Boolean] true if paragraph has numbering
      def numbered?
        properties&.num_id ? true : false
      end

      # Add hyperlink to paragraph
      #
      # @param target [String] URL or bookmark target
      # @param text [String] Link text
      # @param options [Hash] Additional options
      # @return [Hyperlink] The created hyperlink
      def add_hyperlink(target, text = nil, **options)
        hyperlink = Hyperlink.new
        hyperlink.target = target

        if text
          run = Run.new
          run.text = text
          if options.any?
            run.properties ||= RunProperties.new
            run.properties.color = '0000FF' if options[:color].nil? || options[:color] == true
            if options[:underline].nil? || options[:underline] == true
              run.properties.underline = 'single'
            end
          end
          hyperlink.runs << run
        end

        self.hyperlinks ||= []
        hyperlinks << hyperlink
        hyperlink
      end

      # Get first hyperlink (nil-safe accessor)
      #
      # @return [Hyperlink, nil] First hyperlink or nil if none
      def hyperlink
        hyperlinks&.first
      end

      # Get images in paragraph (from runs)
      #
      # @return [Array<Drawing>] Array of drawing elements
      def images
        runs.flat_map(&:drawings).compact
      end

      # Accept a visitor (Visitor pattern)
      #
      # @param visitor [BaseVisitor] The visitor to accept
      # @return [void]
      def accept(visitor)
        visitor.visit_paragraph(self)
      end

      # Get num_id directly
      #
      # @return [String, nil] Numbering ID
      def num_id
        properties&.num_id
      end

      # Set alignment
      #
      # @param value [String, Symbol] Alignment value
      # @return [self] For method chaining
      def alignment=(value)
        self.properties ||= ParagraphProperties.new
        properties.alignment = value
        self
      end

      # Get contextual spacing
      #
      # @return [Boolean, nil] Contextual spacing value
      def contextual_spacing
        properties&.contextual_spacing
      end

      # Set contextual spacing
      #
      # @param value [Boolean] Contextual spacing value
      # @return [self] For method chaining
      def contextual_spacing=(value)
        self.properties ||= ParagraphProperties.new
        properties.contextual_spacing = value
        self
      end

      # Set paragraph text (replaces all existing content)
      #
      # @param value [String] The text content to set
      # @return [String] The text that was set
      def text=(value)
        self.runs = []
        if value
          run = Run.new
          run.text = value.to_s
          runs << run
        end
        value
      end

      # Get all breaks from paragraph runs
      #
      # @return [Array<Break>] Array of break elements from all runs
      def breaks
        runs.flat_map do |run|
          run.break ? [run.break] : []
        end.compact
      end

      # Convert paragraph to HTML
      #
      # @return [String] HTML representation of the paragraph
      def to_html
        content = runs.map(&:to_html).join

        # Apply paragraph-level styling
        style_attrs = []
        if properties&.alignment
          text_align = case properties.alignment.to_s
                       when 'center' then 'center'
                       when 'right' then 'right'
                       when 'justify', 'both' then 'justify'
                       else 'left'
                       end
          style_attrs << "text-align:#{text_align}" unless text_align == 'left'
        end

        if style_attrs.any?
          "<p style=\"#{style_attrs.join(';')}\">#{content}</p>"
        else
          "<p>#{content}</p>"
        end
      end

      # Extract current properties (for testing/compatibility)
      #
      # @return [Hash] Current properties as a hash
      def extract_current_properties
        {
          alignment: extract_value(properties&.alignment),
          style: extract_value(properties&.style),
          spacing_before: properties&.spacing&.before,
          spacing_after: properties&.spacing&.after,
          line_spacing: properties&.spacing&.line,
          indent_left: properties&.indentation&.left,
          indent_right: properties&.indentation&.right,
          indent_first_line: properties&.indentation&.first_line
        }.compact
      end

      # Helper method to extract value from wrapper or return primitive directly
      #
      # @param value [Object] The value to extract from
      # @return [Object, nil] The extracted value or nil
      def extract_value(value)
        return nil unless value

        value.respond_to?(:value) ? value.value : value
      end
      private :extract_value

      # Iterate over text runs
      #
      # @yield [Run] Each run in the paragraph
      def each_text_run(&block)
        return enum_for(:runs) unless block_given?

        runs.each(&block)
      end

      # Get alignment (alias)
      #
      # @return [String, nil] Alignment value
      def alignment
        align_val = properties&.alignment
        return nil unless align_val

        # Handle both wrapper objects and primitive values
        align_val.respond_to?(:value) ? align_val.value : align_val
      end

      # Get spacing before
      #
      # @return [Integer, nil] Spacing before value
      def spacing_before
        properties&.spacing&.before
      end

      # Set spacing before
      #
      # @param value [Integer] Spacing before value
      # @return [self] For method chaining
      def spacing_before=(value)
        self.properties ||= ParagraphProperties.new
        properties.spacing_before = value
        self
      end

      # Remove all runs
      #
      # @return [Array<Run>] Removed runs
      def remove!
        runs.clear
      end

      # Set spacing before (fluent API)
      #
      # @param value [Integer] Spacing before in twips
      # @return [self] For method chaining
      def spacing_before=(value)
        self.properties ||= ParagraphProperties.new
        properties.spacing_before = value
        self
      end

      # Add image to paragraph
      #
      # @param image_path [String] Path to image file
      # @param options [Hash] Image options
      # @return [Drawing] The created drawing
      def add_image(image_path, options = {})
        run = Run.new
        run.add_image(image_path, options)
        runs << run
        run
      end
    end
  end
end
