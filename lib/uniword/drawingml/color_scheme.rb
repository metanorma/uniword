# frozen_string_literal: true

module Uniword
  module Drawingml
      # Represents an sRGB color in DrawingML
      class SrgbColor < Lutaml::Model::Serializable
        attribute :val, :string

        xml do
          element 'srgbClr'
          namespace Ooxml::Namespaces::DrawingML
          map_attribute 'val', to: :val
        end
      end

      # Represents a system color in DrawingML
      class SysColor < Lutaml::Model::Serializable
        attribute :val, :string
        attribute :last_clr, :string

        xml do
          element 'sysClr'
          namespace Ooxml::Namespaces::DrawingML
          map_attribute 'val', to: :val
          map_attribute 'lastClr', to: :last_clr
        end
      end

      # Base class for theme color elements
      class ThemeColorBase < Lutaml::Model::Serializable
        attribute :srgb_clr, SrgbColor
        attribute :sys_clr, SysColor

        # Get the effective color value
        def value
          @srgb_clr&.val || @sys_clr&.last_clr || '000000'
        end

        # Set RGB value
        def rgb=(val)
          @srgb_clr = SrgbColor.new(val: val)
          @sys_clr = nil
        end

        # Set system color
        def system_color=(type:, last_clr:)
          @sys_clr = SysColor.new(val: type, last_clr: last_clr)
          @srgb_clr = nil
        end
      end

      # Individual color element classes for each of the 12 theme colors
      class Dk1Color < ThemeColorBase
        xml do
          element 'dk1'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Lt1Color < ThemeColorBase
        xml do
          element 'lt1'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Dk2Color < ThemeColorBase
        xml do
          element 'dk2'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Lt2Color < ThemeColorBase
        xml do
          element 'lt2'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Accent1Color < ThemeColorBase
        xml do
          element 'accent1'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Accent2Color < ThemeColorBase
        xml do
          element 'accent2'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Accent3Color < ThemeColorBase
        xml do
          element 'accent3'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Accent4Color < ThemeColorBase
        xml do
          element 'accent4'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Accent5Color < ThemeColorBase
        xml do
          element 'accent5'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class Accent6Color < ThemeColorBase
        xml do
          element 'accent6'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class HlinkColor < ThemeColorBase
        xml do
          element 'hlink'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      class FolHlinkColor < ThemeColorBase
        xml do
          element 'folHlink'
          namespace Ooxml::Namespaces::DrawingML
          map_element 'srgbClr', to: :srgb_clr
          map_element 'sysClr', to: :sys_clr
        end
      end

      # Represents a color scheme from a Word document theme.
      #
      # Color schemes define the theme colors used throughout the document.
      # There are 12 standard theme colors in Office Open XML.
      #
      # @example Create a custom color scheme
      #   scheme = Uniword::ColorScheme.new
      #   scheme.colors[:accent1] = '0066CC'  # Corporate blue
      #   scheme.colors[:accent2] = 'FF6600'  # Corporate orange
      class ColorScheme < Lutaml::Model::Serializable
        # The 12 standard theme colors defined in OOXML
        THEME_COLORS = %w[
          dk1 lt1 dk2 lt2
          accent1 accent2 accent3 accent4 accent5 accent6
          hlink folHlink
        ].freeze

        # Color scheme name
        attribute :name, :string, default: -> { 'Office' }

        # Individual color attributes for lutaml-model serialization
        attribute :dk1, Dk1Color
        attribute :lt1, Lt1Color
        attribute :dk2, Dk2Color
        attribute :lt2, Lt2Color
        attribute :accent1, Accent1Color
        attribute :accent2, Accent2Color
        attribute :accent3, Accent3Color
        attribute :accent4, Accent4Color
        attribute :accent5, Accent5Color
        attribute :accent6, Accent6Color
        attribute :hlink, HlinkColor
        attribute :fol_hlink, FolHlinkColor

        # OOXML namespace configuration
        xml do
          element 'clrScheme'
          namespace Ooxml::Namespaces::DrawingML

          map_attribute 'name', to: :name

          map_element 'dk1', to: :dk1
          map_element 'lt1', to: :lt1
          map_element 'dk2', to: :dk2
          map_element 'lt2', to: :lt2
          map_element 'accent1', to: :accent1
          map_element 'accent2', to: :accent2
          map_element 'accent3', to: :accent3
          map_element 'accent4', to: :accent4
          map_element 'accent5', to: :accent5
          map_element 'accent6', to: :accent6
          map_element 'hlink', to: :hlink
          map_element 'folHlink', to: :fol_hlink
        end

        # Hash mapping color names to RGB hex values (compatibility layer)
        attr_accessor :colors

        # Initialize color scheme
        #
        # @param attributes [Hash] Color scheme attributes
        def initialize(attributes = {})
          super
          @colors = {}
          # Initialize color objects with default values
          @dk1 ||= Dk1Color.new
          @dk1.rgb = '000000' if @dk1.srgb_clr.nil? && @dk1.sys_clr.nil?

          @lt1 ||= Lt1Color.new
          @lt1.rgb = 'FFFFFF' if @lt1.srgb_clr.nil? && @lt1.sys_clr.nil?

          @dk2 ||= Dk2Color.new
          @dk2.rgb = '44546A' if @dk2.srgb_clr.nil? && @dk2.sys_clr.nil?

          @lt2 ||= Lt2Color.new
          @lt2.rgb = 'E7E6E6' if @lt2.srgb_clr.nil? && @lt2.sys_clr.nil?

          @accent1 ||= Accent1Color.new
          @accent1.rgb = '4472C4' if @accent1.srgb_clr.nil? && @accent1.sys_clr.nil?

          @accent2 ||= Accent2Color.new
          @accent2.rgb = 'ED7D31' if @accent2.srgb_clr.nil? && @accent2.sys_clr.nil?

          @accent3 ||= Accent3Color.new
          @accent3.rgb = 'A5A5A5' if @accent3.srgb_clr.nil? && @accent3.sys_clr.nil?

          @accent4 ||= Accent4Color.new
          @accent4.rgb = 'FFC000' if @accent4.srgb_clr.nil? && @accent4.sys_clr.nil?

          @accent5 ||= Accent5Color.new
          @accent5.rgb = '5B9BD5' if @accent5.srgb_clr.nil? && @accent5.sys_clr.nil?

          @accent6 ||= Accent6Color.new
          @accent6.rgb = '70AD47' if @accent6.srgb_clr.nil? && @accent6.sys_clr.nil?

          @hlink ||= HlinkColor.new
          @hlink.rgb = '0563C1' if @hlink.srgb_clr.nil? && @hlink.sys_clr.nil?

          @fol_hlink ||= FolHlinkColor.new
          @fol_hlink.rgb = '954F72' if @fol_hlink.srgb_clr.nil? && @fol_hlink.sys_clr.nil?

          # Build hash interface
          sync_colors_hash
        end

        # Sync the hash interface with attribute values
        def sync_colors_hash
          @colors = {
            dk1: @dk1&.value,
            lt1: @lt1&.value,
            dk2: @dk2&.value,
            lt2: @lt2&.value,
            accent1: @accent1&.value,
            accent2: @accent2&.value,
            accent3: @accent3&.value,
            accent4: @accent4&.value,
            accent5: @accent5&.value,
            accent6: @accent6&.value,
            hlink: @hlink&.value,
            folHlink: @fol_hlink&.value
          }.compact
        end

        # Get a color by name
        #
        # @param color_name [String, Symbol] The color name (e.g., :accent1)
        # @return [String, nil] The RGB hex color value
        def [](color_name)
          color_name = color_name.to_sym
          # Map folHlink to fol_hlink for attribute access
          attr_name = color_name == :folHlink ? :fol_hlink : color_name
          color_obj = instance_variable_get("@#{attr_name}")
          color_obj&.value
        end

        # Set a color by name
        #
        # @param color_name [String, Symbol] The color name
        # @param value [String] The RGB hex color value
        def []=(color_name, value)
          color_name = color_name.to_sym
          # Map folHlink to fol_hlink for attribute access
          attr_name = color_name == :folHlink ? :fol_hlink : color_name

          # Create appropriate color class instance
          color_class = case attr_name
                        when :dk1 then Dk1Color
                        when :lt1 then Lt1Color
                        when :dk2 then Dk2Color
                        when :lt2 then Lt2Color
                        when :accent1 then Accent1Color
                        when :accent2 then Accent2Color
                        when :accent3 then Accent3Color
                        when :accent4 then Accent4Color
                        when :accent5 then Accent5Color
                        when :accent6 then Accent6Color
                        when :hlink then HlinkColor
                        when :fol_hlink then FolHlinkColor
                        else Dk1Color
                        end

          color_obj = color_class.new
          color_obj.rgb = value
          instance_variable_set("@#{attr_name}", color_obj)
          @colors[color_name] = value
        end

        # Get all defined colors
        #
        # @return [Hash] All colors
        def all_colors
          sync_colors_hash
          @colors
        end

        # Check if color scheme has a specific color defined
        #
        # @param color_name [String, Symbol] The color name
        # @return [Boolean] true if color is defined
        def has_color?(color_name)
          self[color_name] != nil
        end

        # Duplicate the color scheme
        #
        # @return [ColorScheme] A deep copy of this color scheme
        def dup
          new_scheme = ColorScheme.new(name: name)
          THEME_COLORS.each do |color_name|
            value = self[color_name]
            new_scheme[color_name] = value if value
          end
          new_scheme
        end
      end
  end
end
