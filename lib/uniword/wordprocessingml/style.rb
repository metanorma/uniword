# frozen_string_literal: true

require "lutaml/model"

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
      attribute :default, Uniword::Ooxml::Types::OoxmlBoolean
      attribute :customStyle, Uniword::Ooxml::Types::OoxmlBoolean
      attribute :name, StyleName
      attribute :basedOn, BasedOn
      attribute :nextStyle, Next # Renamed from 'next' to avoid Ruby keyword conflict
      attribute :link, Link
      attribute :uiPriority, UiPriority
      attribute :qFormat, Properties::QuickFormat
      attribute :semiHidden, SemiHidden
      attribute :unhideWhenUsed, UnhideWhenUsed
      attribute :rsid, Rsid, collection: true
      attribute :pPr, ParagraphProperties
      attribute :rPr, RunProperties
      attribute :tblPr, TableProperties
      attribute :tcPr, TableCellProperties

      # YAML mapping for flat YAML structure
      yaml do
        map "id", to: :styleId
        map "type", to: :type
        map "name", with: { from: :yaml_name_from, to: :yaml_name_to }
        map "default", to: :default
        map "custom", to: :customStyle
        map "quick_format",
            with: { from: :yaml_quick_format_from, to: :yaml_quick_format_to }
        map "based_on",
            with: { from: :yaml_based_on_from, to: :yaml_based_on_to }
        map "next_style",
            with: { from: :yaml_next_style_from, to: :yaml_next_style_to }
        map "linked_style",
            with: { from: :yaml_linked_style_from, to: :yaml_linked_style_to }
        map "ui_priority",
            with: { from: :yaml_ui_priority_from, to: :yaml_ui_priority_to }
        map "paragraph_properties", to: :pPr
        map "run_properties", to: :rPr
      end

      # YAML transform methods (instance methods - called via send on an instance)
      def yaml_name_from(instance, value)
        instance.name = StyleName.new(val: value) if value
      end

      def yaml_name_to(instance, _doc)
        instance.name&.val
      end

      def yaml_quick_format_from(instance, value)
        instance.qFormat = Properties::QuickFormat.new(value: value) unless value.nil?
      end

      def yaml_quick_format_to(instance, _doc)
        instance.qFormat&.value
      end

      def yaml_based_on_from(instance, value)
        instance.basedOn = BasedOn.new(val: value) if value
      end

      def yaml_based_on_to(instance, _doc)
        instance.basedOn&.val
      end

      def yaml_next_style_from(instance, value)
        instance.nextStyle = Next.new(val: value) if value
      end

      def yaml_next_style_to(instance, _doc)
        instance.nextStyle&.val
      end

      def yaml_linked_style_from(instance, value)
        instance.link = Link.new(val: value) if value
      end

      def yaml_linked_style_to(instance, _doc)
        instance.link&.val
      end

      def yaml_ui_priority_from(instance, value)
        instance.uiPriority = UiPriority.new(val: value.to_s) if value
      end

      def yaml_ui_priority_to(instance, _doc)
        instance.uiPriority&.val&.to_i
      end

      xml do
        element "style"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "type", to: :type
        map_attribute "styleId", to: :styleId
        map_attribute "default", to: :default, render_default: false,
                                 value_map: { to: { true => true, false => :omitted } }
        map_attribute "customStyle", to: :customStyle, render_default: false,
                                     value_map: { to: { true => true, false => :omitted } }
        map_element "name", to: :name, render_nil: false
        map_element "basedOn", to: :basedOn, render_nil: false
        map_element "next", to: :nextStyle, render_nil: false # Maps XML 'next' to nextStyle attribute
        map_element "link", to: :link, render_nil: false
        map_element "uiPriority", to: :uiPriority, render_nil: false
        map_element "qFormat", to: :qFormat, render_nil: false
        map_element "semiHidden", to: :semiHidden, render_nil: false
        map_element "unhideWhenUsed", to: :unhideWhenUsed, render_nil: false
        map_element "rsid", to: :rsid, render_nil: false
        map_element "pPr", to: :pPr, render_nil: false
        map_element "rPr", to: :rPr, render_nil: false
        map_element "tblPr", to: :tblPr, render_nil: false
        map_element "tcPr", to: :tcPr, render_nil: false
      end

      # Convenience read-only accessors (aliases for lutaml-model attributes)

      def id
        styleId
      end

      def style_name
        @name&.val
      end

      def based_on
        basedOn&.val
      end

      def next_style
        nextStyle&.val
      end

      def linked_style
        link&.val
      end

      def ui_priority
        uiPriority&.val&.to_i
      end

      def quick_format
        val = qFormat
        return true if val == true

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      def spacing_before
        pPr&.spacing&.before || pPr&.spacing_before
      end

      def spacing_after
        pPr&.spacing&.after || pPr&.spacing_after
      end

      def alignment
        pPr&.alignment
      end

      def keep_next
        return false unless pPr

        val = pPr.keep_next_wrapper
        return false if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      def keep_lines
        return false unless pPr

        val = pPr.keep_lines_wrapper
        return false if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      def outline_level
        pPr&.outline_level&.value&.to_i
      end

      def font_family
        rPr&.fonts&.ascii || rPr&.font
      end

      def bold
        return nil unless rPr

        val = rPr.bold
        return nil if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      def font_size
        rPr&.size&.value&.to_i
      end

      def font_color
        rPr&.color&.value
      end

      def font_color_theme
        rPr&.color&.theme_color
      end

      def font_color_theme_tint
        rPr&.color&.theme_shade || rPr&.color&.theme_tint
      end

      def custom?
        customStyle == true
      end

      def paragraph_style?
        type == "paragraph"
      end

      def character_style?
        type == "character"
      end

      def table_style?
        type == "table"
      end

      def numbering_style?
        type == "numbering"
      end

      def paragraph_properties
        pPr
      end

      def run_properties
        rPr
      end

      def to_xml(options = {})
        super(options.merge(fix_boolean_elements: true))
      end
    end
  end
end
