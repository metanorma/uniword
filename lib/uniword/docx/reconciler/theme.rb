# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Theme creation and repair.
      #
      # Creates default theme when missing (profile-dependent) and
      # repairs broken fmtScheme on loaded documents.
      module Theme
        def reconcile_theme
          return unless profile
          return if package.theme

          theme_name = profile.system.default_theme_name
          return unless theme_name

          begin
            friendly = Themes::Theme.load(theme_name)
            word_theme = friendly.to_word_theme
            word_theme.name = "Office Theme"
            package.theme = word_theme
            record_fix(FixCodes::THEME_CREATED,
                       "Created default theme with complete fmtScheme",
                       part: "word/theme/theme1.xml")
          rescue ArgumentError
            nil
          end
        end

        def repair_theme
          theme = package.theme
          return unless theme

          fmt = theme.theme_elements&.fmt_scheme
          return unless fmt

          repaired = false

          if count_fill_styles(fmt.fill_style_lst) < 2
            ensure_minimal_fill_list(fmt)
            repaired = true
          end

          if count_line_styles(fmt.ln_style_lst) < 3
            ensure_minimal_line_list(fmt)
            repaired = true
          end

          if count_effect_styles(fmt.effect_style_lst) < 3
            ensure_minimal_effect_list(fmt)
            repaired = true
          end

          if count_fill_styles(fmt.bg_fill_style_lst) < 2
            ensure_minimal_bg_fill_list(fmt)
            repaired = true
          end

          return unless repaired

          record_fix(FixCodes::THEME_CREATED,
                     "Repaired theme fmtScheme with minimum required content",
                     part: "word/theme/theme1.xml")
        end

        private

        def count_fill_styles(lst)
          return 0 unless lst

          (lst.solid_fills || []).size + (lst.gradient_fills || []).size +
            (lst.blip_fills || []).size
        end

        def count_line_styles(lst)
          return 0 unless lst
          (lst.lines || []).size
        end

        def count_effect_styles(lst)
          return 0 unless lst
          (lst.effect_styles || []).size
        end

        def ensure_minimal_fill_list(fmt)
          fmt.fill_style_lst =
            ensure_minimal_solid_fills(
              Drawingml::FillStyleList, fmt.fill_style_lst
            )
        end

        def ensure_minimal_bg_fill_list(fmt)
          fmt.bg_fill_style_lst =
            ensure_minimal_solid_fills(
              Drawingml::BackgroundFillStyleList, fmt.bg_fill_style_lst
            )
        end

        # Shared fill list repair logic.
        def ensure_minimal_solid_fills(lst_class, current_lst)
          lst = current_lst || lst_class.new
          fills = Array(lst.solid_fills).dup
          while fills.size < 2
            fills << Drawingml::SolidFill.new(
              scheme_clr: Drawingml::SchemeColor.new(
                val: "accent#{fills.size + 1}"
              ),
            )
          end
          lst.solid_fills = fills
          lst
        end

        def ensure_minimal_line_list(fmt)
          lst = fmt.ln_style_lst || Drawingml::LineStyleList.new
          lines = Array(lst.lines).dup
          widths = [9525, 25400, 38100]
          while lines.size < 3
            idx = lines.size
            lines << Drawingml::LineProperties.new(
              width: widths[idx] || 9525,
              solid_fill: Drawingml::SolidFill.new(
                scheme_clr: Drawingml::SchemeColor.new(val: "accent#{idx + 1}"),
              ),
            )
          end
          lst.lines = lines
          fmt.ln_style_lst = lst
        end

        def ensure_minimal_effect_list(fmt)
          lst = fmt.effect_style_lst || Drawingml::EffectStyleList.new
          styles = Array(lst.effect_styles).dup
          while styles.size < 3
            styles << Drawingml::EffectStyle.new
          end
          lst.effect_styles = styles
          fmt.effect_style_lst = lst
        end
      end
    end
  end
end
