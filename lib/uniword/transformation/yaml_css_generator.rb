# frozen_string_literal: true

module Uniword
  module Transformation
    # Generates Word HTML4 CSS from YAML style configuration hashes.
    #
    # Converts OOXML style definitions (paragraph/character properties) to CSS
    # rules suitable for MHTML output. Produces @font-face declarations,
    # paragraph/heading/character style rules, @page definitions, and @list
    # definitions.
    #
    # @example Generate CSS from YAML configs
    #   generator = YamlCssGenerator.new(
    #     styles: YAML.load_file("styles.yml"),
    #     doc_defaults: YAML.load_file("doc_defaults.yml"),
    #     numbering: YAML.load_file("numbering.yml")
    #   )
    #   css = generator.generate
    #
    # @api private
    class YamlCssGenerator
      # Static @font-face declarations for common ISO fonts.
      FONT_FACE_LIBRARY = {
        "Arial" => <<~CSS,
          @font-face {
            font-family: Arial;
            panose-1: 2 11 6 4 2 2 2 2 2 4;
            mso-font-charset: 0;
            mso-generic-font-family: swiss;
            mso-font-pitch: variable;
            mso-font-signature: -536859905 -1073711037 9 0 511 0;
          }
        CSS
        "Courier New" => <<~CSS,
          @font-face {
            font-family: "Courier New";
            panose-1: 2 7 3 9 2 2 5 2 4 4;
            mso-font-charset: 0;
            mso-generic-font-family: roman;
            mso-font-pitch: fixed;
            mso-font-signature: -536859905 -1073711037 9 0 511 0;
          }
        CSS
        "Cambria Math" => <<~CSS,
          @font-face {
            font-family: "Cambria Math";
            panose-1: 2 4 5 3 5 4 6 3 2 4;
            mso-font-charset: 0;
            mso-generic-font-family: roman;
            mso-font-pitch: variable;
            mso-font-signature: -536870145 1107305727 0 0 415 0;
          }
        CSS
        "Calibri" => <<~CSS,
          @font-face {
            font-family: Calibri;
            panose-1: 2 15 5 2 2 2 4 3 2 4;
            mso-font-charset: 0;
            mso-generic-font-family: swiss;
            mso-font-pitch: variable;
            mso-font-signature: -536870145 1073786111 1 0 415 0;
          }
        CSS
        "Cambria" => <<~CSS,
          @font-face {
            font-family: Cambria;
            panose-1: 2 4 5 3 5 4 6 3 2 4;
            mso-font-charset: 0;
            mso-generic-font-family: roman;
            mso-font-pitch: variable;
            mso-font-signature: -536870145 1073743103 0 0 415 0;
          }
        CSS
        "Segoe UI" => <<~CSS,
          @font-face {
            font-family: "Segoe UI";
            panose-1: 2 11 5 2 4 2 4 2 2 3;
            mso-font-charset: 0;
            mso-generic-font-family: swiss;
            mso-font-pitch: variable;
            mso-font-signature: -469750017 -1073683329 9 0 511 0;
          }
        CSS
        "Times New Roman" => <<~CSS,
          @font-face {
            font-family: "Times New Roman";
            panose-1: 2 2 6 3 5 4 5 2 3 4;
            mso-font-charset: 0;
            mso-generic-font-family: roman;
            mso-font-pitch: variable;
            mso-font-signature: -536870145 1073743103 0 0 415 0;
          }
        CSS
        "SimSun" => <<~CSS,
          @font-face {
            font-family: "SimSun";
            panose-1: 2 1 6 0 3 1 1 1 1 1;
            mso-font-charset: 134;
            mso-generic-font-family: auto;
            mso-font-pitch: variable;
            mso-font-signature: 515 135135232 16 0 262144 0;
          }
        CSS
        "SimHei" => <<~CSS,
          @font-face {
            font-family: "SimHei";
            panose-1: 2 1 6 9 6 1 1 1 1 1;
            mso-font-charset: 134;
            mso-generic-font-family: modern;
            mso-font-pitch: fixed;
            mso-font-signature: 515 135135232 16 0 262144 0;
          }
        CSS
        "MS Mincho" => <<~CSS,
          @font-face {
            font-family: "MS Mincho";
            panose-1: 2 2 6 9 4 2 5 8 3 4;
            mso-font-charset: 128;
            mso-generic-font-family: roman;
            mso-font-pitch: fixed;
            mso-font-signature: -536870145 1791491579 134217746 0 131231 0;
          }
        CSS
        "Malgun Gothic" => <<~CSS,
          @font-face {
            font-family: "Malgun Gothic";
            panose-1: 2 11 5 3 2 0 0 2 0 4;
            mso-font-charset: 129;
            mso-generic-font-family: swiss;
            mso-font-pitch: variable;
            mso-font-signature: -1879048145 701988091 18 0 524289 0;
          }
        CSS
        "Cambria serif" => <<~CSS,
          @font-face {
            font-family: "Cambria", serif;
            panose-1: 2 2 6 9 4 2 5 8 3 4;
            mso-font-charset: 128;
            mso-generic-font-family: roman;
            mso-font-pitch: fixed;
            mso-font-signature: -536870145 1791491579 134217746 0 131231 0;
          }
        CSS
      }.freeze

      # Default font-family declaration based on primary font
      DEFAULT_FONT_FAMILY = '"Cambria", serif'
      DEFAULT_FAREAST_FONT = '"SimSun", serif'

      # @param styles [Hash] Parsed styles.yml content
      # @param doc_defaults [Hash] Parsed doc_defaults.yml content
      # @param numbering [Hash, nil] Parsed numbering.yml content
      def initialize(styles:, doc_defaults:, numbering: nil)
        style_lib = styles["style_library"] || styles
        @para_styles = style_lib["paragraph_styles"] || {}
        @char_styles = style_lib["character_styles"] || {}
        @doc_defaults = doc_defaults["run_properties"] || {}
        @numbering = numbering
        @defaults = resolve_defaults
        @normal_spacing_after = (@para_styles.dig("Normal", "paragraph_properties", "spacing", "after") || "6.0")
      end

      # Generate complete CSS string for MHTML output.
      def generate
        parts = []
        parts << "@charset \"UTF-8\";"
        parts << generate_font_faces
        parts << "/* Style Definitions */"
        parts << generate_all_styles
        parts << generate_page_section
        parts << generate_list_section
        parts << generate_mso_normal_table
        parts << generate_list_containers
        parts << generate_ol_ul
        parts.compact.join("\n")
      end

      private

      # Resolve default run properties from doc_defaults merged with Normal style.
      def resolve_defaults
        normal_run = @para_styles.dig("Normal", "run_properties") || {}
        merged = @doc_defaults.merge(normal_run)
        {
          ascii_font: merged.dig("fonts", "ascii") || "Cambria",
          hansi_font: merged.dig("fonts", "hAnsi") || "Cambria",
          fareast_font: merged.dig("fonts", "eastAsia") || "Calibri",
          bidi_font: merged.dig("fonts", "cs") || "Times New Roman",
          font_size: merged["font_size"] || "11.0",
          lang: merged["lang_val"] || "en-GB",
          fareast_lang: merged["lang_eastasia"] || "en-US",
        }
      end

      # Collect all referenced fonts and generate @font-face declarations.
      def generate_font_faces
        fonts = Set.new
        collect_fonts_from_styles(@para_styles, fonts)
        collect_fonts_from_styles(@char_styles, fonts)
        fonts << @defaults[:ascii_font] if @defaults[:ascii_font]

        faces = []
        fonts.each do |font|
          next if font.nil? || font.empty?

          face = FONT_FACE_LIBRARY[font]
          if face
            faces << face.strip
          else
            faces << generic_font_face(font)
          end
        end
        "/* Font Definitions */\n#{faces.join("\n")}" unless faces.empty?
      end

      def collect_fonts_from_styles(styles, fonts)
        styles.each_value do |style|
          run_props = style["run_properties"] || {}
          font_hash = run_props["fonts"] || {}
          font_hash.each_value { |f| fonts << f if f }
        end
      end

      def generic_font_face(font)
        <<~CSS.strip
          @font-face {
            font-family: "#{font}";
            mso-font-charset: 0;
            mso-font-pitch: variable;
          }
        CSS
      end

      # Generate all style rules (paragraph, heading, character).
      def generate_all_styles
        parts = []

        # Normal style
        if @para_styles["Normal"]
          parts << generate_mso_normal(@para_styles["Normal"])
        end

        # Headings h1-h6
        (1..6).each do |n|
          key = "Heading#{n}"
          style = @para_styles[key]
          parts << generate_heading(n, style, key) if style
        end

        # TOC styles
        (1..9).each do |n|
          key = "TOC#{n}"
          style = @para_styles[key]
          parts << generate_toc_style(n, style, key) if style
        end

        # ISO-specific paragraph styles
        iso_para_styles = %w[
          ForewordTitle IntroTitle BiblioTitle ANNEX
          a2 a3 a4 a5 a6
          Note Example Code Formula Definition Terms TermNum
          FigureTitle AnnexFigureTitle Tabletitle AnnexTableTitle
          Tablebody BodyText ForewordText Source List ListParagraph
          zzSTDTitle zzContents zzCopyright Header Footer
          NormalWeb BalloonText Caption
        ]
        iso_para_styles.each do |name|
          style = @para_styles[name]
          parts << generate_paragraph_style(name, style) if style
        end

        # Any remaining paragraph styles not yet generated
        generated = Set.new(%w[Normal Heading1 Heading2 Heading3 Heading4 Heading5 Heading6
                               TOC1 TOC2 TOC3 TOC4 TOC5 TOC6 TOC7 TOC8 TOC9] + iso_para_styles)
        @para_styles.each do |name, style|
          next if generated.include?(name)

          parts << generate_paragraph_style(name, style)
        end

        # Generic p style
        parts << generate_generic_p

        # Hyperlink styles
        parts << generate_hyperlink_styles

        # Character styles
        @char_styles.each do |name, style|
          parts << generate_character_style(name, style)
        end

        # MsoChpDefault
        parts << generate_mso_chp_default

        parts.compact.join("\n\n")
      end

      def generate_mso_normal(style)
        props = build_css_properties(style)
        <<~CSS
          p.MsoNormal, li.MsoNormal, div.MsoNormal {
          #{props}
          }
        CSS
      end

      def generate_heading(level, style, _key)
        css_props = build_css_properties(style)
        # Heading styles use h1-h6 tag selectors
        <<~CSS
          h#{level} {
          #{css_props}
          }
        CSS
      end

      def generate_toc_style(level, style, _key)
        css_props = build_css_properties(style)
        <<~CSS
          p.MsoToc#{level}, li.MsoToc#{level}, div.MsoToc#{level} {
          #{css_props}
          }
        CSS
      end

      def generate_paragraph_style(name, style)
        css_props = build_css_properties(style)
        <<~CSS
          p.#{name}, li.#{name}, div.#{name} {
          #{css_props}
          }
        CSS
      end

      def generate_character_style(name, style)
        css_props = build_char_css_properties(style)
        return nil if css_props.strip.empty?

        <<~CSS
          span.#{name} {
          #{css_props}
          }
        CSS
      end

      # Build CSS properties string for a paragraph style.
      def build_css_properties(style)
        lines = []
        para_props = style["paragraph_properties"] || {}
        run_props = style["run_properties"] || {}

        # mso-style metadata
        lines << "  mso-style-unhide: no;"
        if style["quick_format"]
          lines << "  mso-style-qformat: yes;"
        end
        if style["name"]
          lines << "  mso-style-name: \"#{style['name']}\";"
        end
        if style["based_on"]
          lines << "  mso-style-parent: \"#{style['based_on']}\";"
        end
        if style["linked_style"]
          lines << "  mso-style-link: \"#{style['linked_style']}\";"
        end
        if style["next_style"]
          lines << "  mso-style-next: #{style['next_style']};"
        end
        if style["ui_priority"]
          lines << "  mso-style-priority: #{style['ui_priority']};"
        end
        if style["semi_hidden"]
          lines << "  mso-style-noshow: yes;"
        end

        # Margins from spacing
        spacing = para_props["spacing"] || {}
        before = spacing["before"]
        after = spacing["after"]
        if before
          lines << "  margin-top: #{pt_value(before)};"
        else
          lines << "  margin-top: 0cm;"
        end
        lines << "  margin-right: 0cm;"
        if after
          lines << "  margin-bottom: #{pt_value(after)};"
        else
          lines << "  margin-bottom: #{pt_value(@normal_spacing_after)};"
        end
        lines << "  margin-left: 0cm;"

        # Indent
        indent = para_props["indent"] || {}
        if indent["left"] && indent["left"] != "0.0"
          lines << "  margin-left: #{cm_value(indent['left'])};"
        end
        if indent["right"] && indent["right"] != "0.0"
          lines << "  margin-right: #{cm_value(indent['right'])};"
        end

        # Text indent (firstLine or hanging)
        if indent["hanging"] && indent["hanging"] != "0.0"
          lines << "  text-indent: -#{cm_value(indent['hanging'])};"
        elsif indent["firstLine"] && indent["firstLine"] != "0.0"
          lines << "  text-indent: #{cm_value(indent['firstLine'])};"
        else
          lines << "  text-indent: 0cm;" unless indent["hanging"]
        end

        # Alignment
        alignment = para_props["alignment"]
        align_map = { "both" => "justify", "left" => "left", "center" => "center",
                      "right" => "right", "distribute" => "justify" }
        if alignment
          lines << "  text-align: #{align_map[alignment] || alignment};"
        end

        # Line height
        line = spacing["line"]
        if line
          lines << "  line-height: #{pt_value(line)};"
          rule = spacing["line_rule"]
          if rule == "exact"
            lines << "  mso-line-height-rule: exactly;"
          end
        end

        # Pagination
        lines << "  mso-pagination: widow-orphan;"
        if para_props["keep_next"]
          lines << "  page-break-after: avoid;"
        end
        if para_props["page_break_before"]
          lines << "  page-break-before: always;"
        end

        # Outline level
        outline = para_props["outline_level"]
        if outline
          lines << "  mso-outline-level: #{outline.to_i + 1};"
        end

        # Tab stops
        tabs = para_props["tabs"]
        if tabs && !tabs.empty?
          tab_parts = tabs.map do |tab|
            pos = cm_value(tab["position"])
            case tab["type"]
            when "left" then pos
            when "right" then "right #{pos}"
            when "center" then "center #{pos}"
            when "clear" then "clear #{pos}"
            when "num" then pos
            else pos
            end
          end
          lines << "  tab-stops: #{tab_parts.join(' ')};"
        end

        # Borders
        borders = para_props["borders"]
        if borders && !borders.empty?
          borders.each do |border|
            side = border["type"]
            val = border["val"]
            sz = border["sz"]
            space = border["space"]
            color = border["color"]
            border_str = "#{val}"
            border_str += " ##{color}" if color
            border_str += " #{pt_value(sz)}" if sz
            lines << "  border-#{side}: #{border_str};"
            lines << "  mso-border-#{side}-alt: solid ##{color} #{pt_value(sz)};" if color && sz
            if space
              padding_side = side == "top" || side == "bottom" ? "top" : "left"
              lines << "  padding: #{pt_value(space)};"
            end
          end
        end

        # Font size
        font_size = run_props["font_size"]
        if font_size
          lines << "  font-size: #{pt_value(font_size)};"
        else
          lines << "  font-size: #{pt_value(@defaults[:font_size])};"
        end

        # Font family
        fonts = run_props["fonts"] || {}
        ascii = fonts["ascii"] || @defaults[:ascii_font]
        if ascii
          lines << "  font-family: \"#{ascii}\", serif;"
        end

        # Bold/Italic
        if run_props["bold"]
          lines << "  font-weight: bold;"
        end
        if run_props["italic"]
          lines << "  font-style: italic;"
        end

        # Underline
        if run_props["underline"]
          lines << "  text-decoration: underline;"
        end

        # Color
        color = run_props["color"]
        if color
          lines << "  color: ##{color};"
        end

        # Font-specific mso properties
        fareast = fonts["eastAsia"]
        if fareast
          lines << "  mso-fareast-font-family: \"#{fareast}\", serif;"
        elsif ascii == "Cambria"
          lines << "  mso-fareast-font-family: \"SimSun\", serif;"
        end

        bidi = fonts["cs"]
        if bidi
          lines << "  mso-bidi-font-family: \"#{bidi}\", serif;"
        elsif ascii
          lines << "  mso-bidi-font-family: \"#{ascii}\", serif;"
        end

        # Language
        lang = run_props["lang_val"]
        lines << "  mso-ansi-language: #{lang || @defaults[:lang]};"

        fareast_lang = run_props["lang_eastasia"]
        if fareast_lang
          lines << "  mso-fareast-language: #{lang_code(fareast_lang)};"
        end

        lines.join("\n")
      end

      # Build CSS properties for character styles.
      def build_char_css_properties(style)
        lines = []
        run_props = style["run_properties"] || {}

        # mso-style metadata
        lines << "  mso-style-name: \"#{style['name']}\";" if style["name"]
        if style["ui_priority"]
          lines << "  mso-style-priority: #{style['ui_priority']};"
        end
        if style["semi_hidden"]
          lines << "  mso-style-noshow: yes;"
        end
        if style["linked_style"]
          lines << "  mso-style-link: \"#{style['linked_style']}\";"
        end

        # Font size
        font_size = run_props["font_size"]
        if font_size
          lines << "  mso-ansi-font-size: #{pt_value(font_size)};"
          lines << "  mso-bidi-font-size: #{pt_value(font_size)};" if run_props["font_size_cs"]
        end

        # Font family
        fonts = run_props["fonts"] || {}
        ascii = fonts["ascii"]
        if ascii
          lines << "  font-family: \"#{ascii}\", serif;"
          lines << "  mso-ascii-font-family: #{ascii};"
        end

        fareast = fonts["eastAsia"]
        lines << "  mso-fareast-font-family: \"#{fareast}\", serif;" if fareast

        hansi = fonts["hAnsi"]
        lines << "  mso-hansi-font-family: \"#{hansi}\", serif;" if hansi

        bidi = fonts["cs"]
        lines << "  mso-bidi-font-family: \"#{bidi}\";" if bidi

        # Bold/Italic
        lines << "  font-weight: bold;" if run_props["bold"]
        lines << "  mso-bidi-font-weight: normal;" if run_props["bold"]
        lines << "  font-style: italic;" if run_props["italic"]

        # Color
        color = run_props["color"]
        lines << "  color: ##{color};" if color

        # Underline
        lines << "  text-decoration: underline;" if run_props["underline"]

        # Language
        lang = run_props["lang_val"]
        lines << "  mso-ansi-language: #{lang || @defaults[:lang]};" if lang || @defaults[:lang]

        lines.join("\n")
      end

      def generate_generic_p
        <<~CSS
          p {
            mso-style-noshow: yes;
            mso-style-priority: 99;
            mso-margin-top-alt: auto;
            margin-right: 0cm;
            mso-margin-bottom-alt: auto;
            mso-pagination: widow-orphan;
            font-size: #{pt_value(@defaults[:font_size])};
            font-family: "#{@defaults[:ascii_font]}", serif;
            mso-ansi-language: #{@defaults[:lang]};
          }
        CSS
      end

      def generate_hyperlink_styles
        <<~CSS
          a:link, span.MsoHyperlink {
            mso-style-priority: 99;
            mso-style-unhide: no;
            mso-style-parent: "";
            color: blue;
            text-decoration: underline;
            text-underline: single;
          }

          a:visited, span.MsoHyperlinkFollowed {
            mso-style-noshow: yes;
            mso-style-priority: 99;
            color: #954F72;
            text-decoration: underline;
            text-underline: single;
          }
        CSS
      end

      def generate_mso_chp_default
        <<~CSS
          .MsoChpDefault {
            mso-style-type: export-only;
            mso-default-props: yes;
            font-family: "#{@defaults[:ascii_font]}", serif;
            font-size: 10pt;
            mso-ascii-font-family: "#{@defaults[:ascii_font]}", serif;
            mso-fareast-font-family: "SimSun", serif;
            mso-hansi-font-family: "#{@defaults[:ascii_font]}", serif;
          }
        CSS
      end

      def generate_mso_normal_table
        <<~CSS
          table.MsoNormalTable {
            mso-style-name: "Table Normal";
            mso-tstyle-rowband-size: 0;
            mso-tstyle-colband-size: 0;
            mso-style-noshow: yes;
            mso-style-priority: 99;
            mso-style-parent: "";
            mso-padding-alt: 0cm 5.4pt 0cm 5.4pt;
            mso-para-margin: 0cm;
            mso-para-margin-bottom: 0.0001pt;
            mso-pagination: widow-orphan;
            font-size: 10pt;
            font-family: "#{@defaults[:ascii_font]}", serif;
          }
        CSS
      end

      # Generate @page section definitions.
      def generate_page_section
        <<~CSS
          /* Page Definitions */
          @page {
            mso-mirror-margins: yes;
            mso-footnote-separator: url(cid:header.html) fs;
            mso-footnote-continuation-separator: url(cid:header.html) fcs;
            mso-endnote-separator: url(cid:header.html) es;
            mso-endnote-continuation-separator: url(cid:header.html) ecs;
            mso-facing-pages: yes;
          }
          @page WordSection1 {
            size: 595.3pt 841.9pt;
            margin: 39.7pt 36.85pt 14.2pt 42.55pt;
            mso-header-margin: 35.45pt;
            mso-footer-margin: 0cm;
            mso-gutter-margin: 1cm;
            mso-even-header: url(cid:header.html) eha;
            mso-even-footer: url(cid:header.html) efa;
            mso-footer: url(cid:header.html) fa;
            mso-paper-source: 0;
          }
          div.WordSection1 {
            page: WordSection1;
          }
        CSS
      end

      # Generate @list definitions from numbering.yml.
      def generate_list_section
        return "" unless @numbering

        definitions = @numbering["definitions"] || []
        instances = @numbering["instances"] || []

        return "" if definitions.empty?

        parts = []
        definitions.each_with_index do |defn, idx|
          parts << generate_list_definition(idx, defn)
        end

        parts.join("\n")
      end

      def generate_list_definition(idx, defn)
        abstract_id = defn["abstract_num_id"]
        levels = defn["levels"] || []
        parts = ["@list l#{idx} {"]

        # Build level CSS
        levels.each do |level|
          level_num = level["ilvl"].to_i
          parts << "  @list l#{idx}:level#{level_num + 1} {"

          fmt = level["format"]
          if fmt
            fmt_map = {
              "decimal" => nil, "bullet" => "mso-level-number-format: bullet;",
              "upperLetter" => "mso-level-number-format: alpha-upper;",
              "lowerLetter" => "mso-level-number-format: alpha-lower;",
              "upperRoman" => "mso-level-number-format: roman-upper;",
              "lowerRoman" => "mso-level-number-format: roman-lower;",
            }
            parts << "    #{fmt_map[fmt]}" if fmt_map[fmt]
          end

          text = level["text"]
          parts << "    mso-level-text: \"#{text}\";" if text

          para_props = level["paragraph_properties"] || {}
          indent = para_props["indent"] || {}
          left = indent["left"]
          hanging = indent["hanging"]
          if left
            parts << "    margin-left: #{cm_value(left)};"
          end
          if hanging
            parts << "    text-indent: -#{cm_value(hanging)};"
          end

          parts << "  }"
        end

        parts << "}"
        parts.join("\n")
      end

      def generate_list_containers
        lines = (1..9).map do |n|
          <<~CSS
            div.ListContLevel#{n} {
              mso-style-priority: 34;
              margin-left: #{n * 18}pt;
              margin-right: 0cm;
            }
          CSS
        end
        lines.join("\n")
      end

      def generate_ol_ul
        <<~CSS
          ol {
            margin-bottom: 0cm;
            margin-left: 18pt;
          }

          ul {
            margin-bottom: 0cm;
            margin-left: 18pt;
          }
        CSS
      end

      # Format a value as points (e.g., "11.0" → "11pt")
      def pt_value(val)
        return "0pt" unless val
        v = val.to_f
        v == v.to_i ? "#{v.to_i}pt" : "#{v}pt"
      end

      # Format a value as centimeters (e.g., "0.71" → "0.71cm")
      def cm_value(val)
        return "0cm" unless val
        v = val.to_f
        v == v.to_i ? "#{v.to_i}cm" : "#{v}cm"
      end

      # Convert language code: "ja-JP" → "JA", "en-GB" stays "EN-GB"
      def lang_code(lang)
        return lang unless lang

        case lang
        when "ja-JP" then "JA"
        when "zh-CN" then "ZH-CN"
        else lang.upcase
        end
      end
    end
  end
end
