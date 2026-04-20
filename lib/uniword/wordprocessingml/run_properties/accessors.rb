# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class RunProperties < Lutaml::Model::Serializable
      # Convenience getter/setter methods for RunProperties.
      #
      # Delegates to wrapper objects (RunFonts, Language, Shading)
      # for ergonomic access to nested properties.
      module Accessors
        # --- Font accessors ---

        def font
          fonts&.ascii
        end

        def font=(value)
          self.fonts ||= Properties::RunFonts.new
          fonts.ascii = value
        end

        def font_ascii
          fonts&.ascii
        end

        def font_east_asia
          fonts&.east_asia
        end

        def font_h_ansi
          fonts&.h_ansi
        end

        def font_cs
          fonts&.cs
        end

        # --- Language accessors ---

        def language_val
          language&.val
        end

        def language_east_asia
          language&.east_asia
        end

        def language_bidi
          language&.bidi
        end

        # --- Shading accessors ---

        def shading_fill
          shading&.fill
        end

        def shading_type
          shading&.pattern
        end

        def shading_color
          shading&.fill
        end

        def shading_color=(value)
          self.shading ||= Properties::Shading.new
          shading.fill = value
          self
        end

        # --- Misc accessors ---

        def page_break=(_value)
          self
        end

        def text_expansion
          width_scale
        end

        def text_expansion=(value)
          self.width_scale = if value.is_a?(Properties::WidthScale)
                               value
                             else
                               Properties::WidthScale.new(value: value)
                             end
          self
        end
      end
    end
  end
end
