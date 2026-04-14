# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Text run - inline text with formatting
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:r>
    class Run < Lutaml::Model::Serializable
      attribute :properties, RunProperties
      attribute :text, Text
      attribute :tab, Tab
      attribute :break, Break
      attribute :drawings, Drawing, collection: true, initialize_empty: true
      attribute :pictures, Picture, collection: true, initialize_empty: true
      attribute :alternate_content, AlternateContent, default: nil
      attribute :footnote_reference, FootnoteReference
      attribute :endnote_reference, EndnoteReference
      attribute :field_char, FieldChar
      attribute :instr_text, InstrText
      attribute :position_tab, PositionTab
      attribute :del_text, DeletedText
      attribute :no_break_hyphen, NoBreakHyphen
      attribute :sym, Symbol
      attribute :last_rendered_page_break, LastRenderedPageBreak

      # Revision tracking attributes
      attribute :rsid_r, :string          # Revision ID for run
      attribute :rsid_r_pr, :string       # Revision ID for run properties

      # Non-serialized runtime reference to parent paragraph for style inheritance
      attr_accessor :parent_paragraph

      xml do
        element 'r'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'rsidR', to: :rsid_r, render_nil: false
        map_attribute 'rsidRPr', to: :rsid_r_pr, render_nil: false

        map_element 'rPr', to: :properties, render_nil: false
        map_element 't', to: :text, render_nil: false
        map_element 'tab', to: :tab, render_nil: false
        map_element 'br', to: :break, render_nil: false
        map_element 'drawing', to: :drawings, render_nil: false
        map_element 'pict', to: :pictures, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
        map_element 'footnoteReference', to: :footnote_reference, render_nil: false
        map_element 'endnoteReference', to: :endnote_reference, render_nil: false
        map_element 'fldChar', to: :field_char, render_nil: false
        map_element 'instrText', to: :instr_text, render_nil: false
        map_element 'ptab', to: :position_tab, render_nil: false
        map_element 'delText', to: :del_text, render_nil: false
        map_element 'noBreakHyphen', to: :no_break_hyphen, render_nil: false
        map_element 'sym', to: :sym, render_nil: false
        map_element 'lastRenderedPageBreak', to: :last_rendered_page_break, render_nil: false
      end

      # Initialize with text normalization
      # With Text.cast defined, lutaml-model handles String->Text conversion
      # during attribute assignment via attr.cast_value()
      def initialize(attrs = {})
        super
      end

      # Accept a visitor (Visitor pattern)
      #
      # @param visitor [BaseVisitor] The visitor to accept
      # @return [void]
      def accept(visitor)
        visitor.visit_run(self)
      end

      # Substitute text in run
      #
      # @param pattern [Regexp, String] Pattern to match
      # @param replacement [String] Replacement text
      # @return [self] For method chaining
      def substitute(pattern, replacement)
        return self unless text

        self.text = text.to_s.gsub(pattern, replacement)
        self
      end

      # Substitute with block
      #
      # @param pattern [Regexp, String] Pattern to match
      # @yield [MatchData] Block receives match data object
      # @return [self] For method chaining
      def substitute_with_block(pattern, &block)
        return self unless text

        self.text = text.to_s.gsub(pattern) do |_match_str|
          block.call(Regexp.last_match)
        end
        self
      end

      # Custom inspect for readable output
      #
      # @return [String] Human-readable representation
      def inspect
        text_preview = text.to_s
        text_preview = "#{text_preview[0, 37]}..." if text_preview.length > 40

        flags = []
        flags << 'bold' if properties&.bold&.value == true
        flags << 'italic' if properties&.italic&.value == true
        if flags.any?
          "#<#{self.class} text=\"#{text_preview}\", #{flags.join(', ')}>"
        else
          "#<#{self.class} text=\"#{text_preview}\">"
        end
      end

      # Get effective run properties including inherited from paragraph style
      #
      # This implements OOXML style inheritance where run properties
      # are resolved per-property with explicit values taking precedence
      # over inherited style values.
      #
      # Priority order (per property):
      # 1. Explicit run property (highest)
      # 2. Paragraph style's run property (from rPr in style definition)
      # 3. Style's basedOn chain (cascade up to Normal/Default)
      #
      # @return [RunProperties, nil] The effective run properties or nil
      def effective_run_properties
        inherited = inherited_from_style

        # If no explicit properties, return inherited directly
        return inherited unless properties

        # If no inherited properties, return explicit directly
        return properties unless inherited

        # Merge: explicit overrides inherited per-property
        merge_properties(inherited, properties)
      end

      # Convenience accessor for font size in points (half-points in OOXML)
      # Returns effective size from inherited style if not explicitly set
      #
      # @return [Integer, nil] Font size in points, or nil
      def font_size
        effective = effective_run_properties
        return nil unless effective

        size_val = effective.size
        return nil unless size_val

        # size is stored in half-points, convert to points
        raw = size_val.value
        return nil unless raw

        half_pts = raw.to_i
        half_pts.positive? ? half_pts / 2 : nil
      end

      private

      # Merge two RunProperties objects with override taking precedence
      #
      # Creates a new RunProperties where each attribute is taken from
      # `override` if set, otherwise from `base`.
      #
      # @param base [RunProperties] Base (inherited) properties
      # @param override [RunProperties] Override (explicit) properties
      # @return [RunProperties] Merged properties
      def merge_properties(base, override)
        merged = RunProperties.new

        # Get all attribute names from RunProperties class
        RunProperties.attributes.each_key do |attr_name|
          override_val = override.send(attr_name)
          base_val = base.send(attr_name)

          # Use override if it's non-nil AND not using default value
          # For boolean properties like Bold, check if it was explicitly set
          use_override = if override_val.is_a?(Lutaml::Model::Serializable)
                           # Check if the property has any non-default/non-nil values
                           override_val.class.attributes.any? do |k, _|
                             iv = override_val.instance_variable_get(:"@#{k}")
                             iv && !override_val.using_default?(k)
                           end
                         else
                           !override_val.nil?
                         end

          begin
            if use_override
              merged.send(:"#{attr_name}=", override_val)
            elsif base_val
              merged.send(:"#{attr_name}=", base_val)
            end
          rescue StandardError
            # Skip attributes that can't be set
          end
        end

        merged
      end

      # Get inherited run properties from paragraph style chain
      #
      # Follows the OOXML style inheritance chain via basedOn attribute
      # until a style with run properties is found.
      #
      # @return [RunProperties, nil] Inherited run properties or nil
      def inherited_from_style
        return nil unless parent_paragraph

        paragraph = parent_paragraph
        style_id = paragraph.style

        return nil unless style_id
        return nil unless paragraph.parent_document

        styles_config = paragraph.parent_document.styles_configuration
        return nil unless styles_config

        # Find the style and follow its basedOn chain
        visited = Set.new
        current_style_id = style_id

        while current_style_id && !visited.include?(current_style_id)
          visited << current_style_id

          style = styles_config.style_by_id(current_style_id)
          break unless style

          # Return run properties if this style defines them
          return style.rPr if style.rPr

          # Move up the basedOn chain
          current_style_id = style.basedOn&.val
        end

        nil
      end

      # Create Text object with xml:space="preserve" when needed
      def create_text_object(string)
        text_obj = Text.new(content: string)
        if string.start_with?(' ') || string.end_with?(' ') || string.include?("\t")
          text_obj.xml_space = 'preserve'
        end
        text_obj
      end
    end
  end
end
