# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Style definition
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:style>
    class Style < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :type, :string
      attribute :styleId, :string
      attribute :default, :boolean
      attribute :customStyle, :boolean
      attribute :name, StyleName
      attribute :basedOn, BasedOn
      attribute :nextStyle, Next  # Renamed from 'next' to avoid Ruby keyword conflict
      attribute :link, Link
      attribute :uiPriority, UiPriority
      attribute :qFormat, Properties::QuickFormat
      attribute :pPr, ParagraphProperties
      attribute :rPr, RunProperties
      attribute :tblPr, TableProperties
      attribute :tcPr, TableCellProperties

      xml do
        element 'style'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'type', to: :type
        map_attribute 'styleId', to: :styleId
        map_attribute 'default', to: :default
        map_attribute 'customStyle', to: :customStyle
        map_element 'name', to: :name, render_nil: false
        map_element 'basedOn', to: :basedOn, render_nil: false
        map_element 'next', to: :nextStyle, render_nil: false  # Maps XML 'next' to nextStyle attribute
        map_element 'link', to: :link, render_nil: false
        map_element 'uiPriority', to: :uiPriority, render_nil: false
        map_element 'qFormat', to: :qFormat, render_nil: false
        map_element 'pPr', to: :pPr, render_nil: false
        map_element 'rPr', to: :rPr, render_nil: false
        map_element 'tblPr', to: :tblPr, render_nil: false
        map_element 'tcPr', to: :tcPr, render_nil: false
      end

      # Convenience accessor methods for style metadata

      # Get style ID
      #
      # @return [String, nil] Style ID
      def id
        styleId
      end

      # Set style ID
      #
      # @param value [String] Style ID
      def id=(value)
        self.styleId = value
      end

      # Get style name value
      #
      # @return [String, nil] Style name
      def style_name
        name&.val
      end

      # Set style name
      #
      # @param value [String] Style name
      def style_name=(value)
        self.name = StyleName.new(val: value)
      end

      # Get based-on style reference
      #
      # @return [String, nil] Parent style ID
      def based_on
        basedOn&.val
      end

      # Set based-on style reference
      #
      # @param value [String] Parent style ID
      def based_on=(value)
        self.basedOn = BasedOn.new(val: value)
      end

      # Get next style reference
      #
      # @return [String, nil] Next style ID
      def next_style
        nextStyle&.val
      end

      # Set next style reference
      #
      # @param value [String] Next style ID
      def next_style=(value)
        self.nextStyle = Next.new(val: value)
      end

      # Get linked style reference
      #
      # @return [String, nil] Linked style ID
      def linked_style
        link&.val
      end

      # Set linked style reference
      #
      # @param value [String] Linked style ID
      def linked_style=(value)
        self.link = Link.new(val: value)
      end

      # Get UI priority
      #
      # @return [Integer, nil] UI priority value
      def ui_priority
        uiPriority&.val&.to_i
      end

      # Set UI priority
      #
      # @param value [Integer] UI priority value
      def ui_priority=(value)
        self.uiPriority = UiPriority.new(val: value.to_s)
      end

      # Check if quick format
      #
      # @return [Boolean] True if quick format style
      def quick_format
        val = qFormat
        # Handle boolean primitive
        return true if val == true
        # Handle Bold wrapper object
        val = val.value if val.respond_to?(:value)
        val == true
      end
      alias quick_format? quick_format

      # Convenience accessors for paragraph properties

      # Get spacing before
      #
      # @return [Integer, nil] Spacing before in twips
      def spacing_before
        pPr&.spacing&.before || pPr&.spacing_before
      end

      # Get spacing after
      #
      # @return [Integer, nil] Spacing after in twips
      def spacing_after
        pPr&.spacing&.after || pPr&.spacing_after
      end

      # Get alignment
      #
      # @return [String, nil] Alignment value
      def alignment
        pPr&.alignment
      end

      # Check keep next
      #
      # @return [Boolean] True if keep with next
      def keep_next
        return false unless pPr

        val = pPr.keep_next
        return true if val == true
        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Check keep lines
      #
      # @return [Boolean] True if keep lines together
      def keep_lines
        return false unless pPr

        val = pPr.keep_lines
        return true if val == true
        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Get outline level
      #
      # @return [Integer, nil] Outline level
      def outline_level
        pPr&.outline_level&.value&.to_i
      end

      # Convenience accessors for run properties

      # Get font family
      #
      # @return [String, nil] Font family name
      def font_family
        rPr&.fonts&.ascii || rPr&.font
      end

      # Check bold
      #
      # @return [Boolean, nil] True if bold
      def bold
        return nil unless rPr

        val = rPr.bold
        return nil if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Get font size
      #
      # @return [Integer, nil] Font size in half-points
      def font_size
        rPr&.size&.value&.to_i
      end

      # Get font color
      #
      # @return [String, nil] Font color as hex
      def font_color
        rPr&.color&.value
      end

      # Get font color theme
      #
      # @return [String, nil] Theme color name
      def font_color_theme
        rPr&.color&.theme_color
      end

      # Get font color theme tint/shade
      #
      # @return [String, nil] Theme shade/tint value
      def font_color_theme_tint
        rPr&.color&.theme_shade || rPr&.color&.theme_tint
      end

      # Check if custom style
      #
      # @return [Boolean] True if custom style
      def custom?
        customStyle == true
      end
      alias custom custom?

      # Alias for pPr (paragraph properties)
      #
      # @return [ParagraphProperties, nil] Paragraph properties
      def paragraph_properties
        pPr
      end

      # Alias for rPr (run properties)
      #
      # @return [RunProperties, nil] Run properties
      def run_properties
        rPr
      end
    end
  end
end
