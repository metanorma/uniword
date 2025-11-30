# frozen_string_literal: true

require 'nokogiri'

module Uniword
  module StyleSets
    # Parses styles.xml files into Style objects
    #
    # Handles parsing of word/styles.xml from .dotx packages,
    # extracting all style definitions using lutaml-model deserialization.
    #
    # @example Parse a styles XML file
    #   parser = StyleSetXmlParser.new
    #   styles = parser.parse(styles_xml_content)
    #   puts "Loaded #{styles.count} styles"
    class StyleSetXmlParser
      # WordprocessingML namespace used in styles XML
      WORDML_NS = {
        'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
      }.freeze

      # Parse word/styles.xml into array of Style objects
      #
      # @param xml [String] Styles XML content
      # @return [Array<Style>] Parsed styles
      # @raise [ArgumentError] if XML is invalid or missing styles element
      def parse(xml)
        require_relative '../style'

        doc = Nokogiri::XML(xml)
        styles = []

        doc.xpath('//w:style', WORDML_NS).each do |style_node|
          style = parse_style_node(style_node)
          styles << style if style
        end

        styles
      end

      private

      # Parse a single style node
      #
      # @param style_node [Nokogiri::XML::Element] The w:style element
      # @return [Style] Parsed style
      def parse_style_node(style_node)
        style = Style.new

        # Parse attributes
        style.type = style_node['w:type']
        style.id = style_node['w:styleId']
        style.default = style_node['w:default'] == '1'
        style.custom = style_node['w:customStyle'] == '1'

        # Parse elements with w:val attributes
        name_node = style_node.at_xpath('./w:name', WORDML_NS)
        style.name = name_node['w:val'] if name_node

        based_on_node = style_node.at_xpath('./w:basedOn', WORDML_NS)
        style.based_on = based_on_node['w:val'] if based_on_node

        next_node = style_node.at_xpath('./w:next', WORDML_NS)
        style.next_style = next_node['w:val'] if next_node

        link_node = style_node.at_xpath('./w:link', WORDML_NS)
        style.linked_style = link_node['w:val'] if link_node

        priority_node = style_node.at_xpath('./w:uiPriority', WORDML_NS)
        style.ui_priority = priority_node['w:val'].to_i if priority_node

        # Parse qFormat (boolean element without attributes)
        qformat_node = style_node.at_xpath('./w:qFormat', WORDML_NS)
        style.quick_format = !qformat_node.nil?

        # NEW: Parse property containers
        pPr_node = style_node.at_xpath('./w:pPr', WORDML_NS)
        style.paragraph_properties = parse_paragraph_properties(pPr_node) if pPr_node

        rPr_node = style_node.at_xpath('./w:rPr', WORDML_NS)
        style.run_properties = parse_run_properties(rPr_node) if rPr_node

        tblPr_node = style_node.at_xpath('./w:tblPr', WORDML_NS)
        style.table_properties = parse_table_properties(tblPr_node) if tblPr_node

        style
      end

      # Parse w:pPr (Paragraph Properties) into ParagraphProperties object
      #
      # @param pPr_node [Nokogiri::XML::Element] The w:pPr element
      # @return [Properties::ParagraphProperties] Parsed properties
      def parse_paragraph_properties(pPr_node)
        require_relative '../properties/paragraph_properties'
        require_relative '../properties/spacing'
        require_relative '../properties/indentation'
        require_relative '../properties/alignment'
        require_relative '../properties/style_reference'
        require_relative '../properties/outline_level'
        require_relative '../properties/numbering_id'
        require_relative '../properties/numbering_level'
        require_relative '../properties/borders'
        require_relative '../properties/border'
        require_relative '../properties/tabs'
        require_relative '../properties/tab_stop'
        require_relative '../properties/shading'

        props = Properties::ParagraphProperties.new

        # Style reference - create wrapper object
        if (pStyle = pPr_node.at_xpath('./w:pStyle', WORDML_NS))
          props.style = Properties::StyleReference.new(value: pStyle['w:val'])
        end

        # Alignment - create wrapper object
        if (jc = pPr_node.at_xpath('./w:jc', WORDML_NS))
          props.alignment = Properties::Alignment.new(value: jc['w:val'])
        end

        # Spacing (w:spacing) - create Spacing object
        if (spacing_node = pPr_node.at_xpath('./w:spacing', WORDML_NS))
          spacing_attrs = {}
          spacing_attrs[:before] = spacing_node['w:before']&.to_i if spacing_node['w:before']
          spacing_attrs[:after] = spacing_node['w:after']&.to_i if spacing_node['w:after']
          spacing_attrs[:line] = spacing_node['w:line']&.to_f if spacing_node['w:line']
          spacing_attrs[:line_rule] = spacing_node['w:lineRule'] if spacing_node['w:lineRule']

          props.spacing = Properties::Spacing.new(spacing_attrs)

          # Also set flat attributes for compatibility
          props.spacing_before = spacing_attrs[:before]
          props.spacing_after = spacing_attrs[:after]
          props.line_spacing = spacing_attrs[:line]
          props.line_rule = spacing_attrs[:line_rule]
        end

        # Indentation (w:ind) - create Indentation object
        if (ind_node = pPr_node.at_xpath('./w:ind', WORDML_NS))
          ind_attrs = {}
          ind_attrs[:left] = ind_node['w:left']&.to_i if ind_node['w:left']
          ind_attrs[:right] = ind_node['w:right']&.to_i if ind_node['w:right']
          ind_attrs[:first_line] = ind_node['w:firstLine']&.to_i if ind_node['w:firstLine']
          ind_attrs[:hanging] = ind_node['w:hanging']&.to_i if ind_node['w:hanging']

          props.indentation = Properties::Indentation.new(ind_attrs)

          # Also set flat attributes for compatibility
          props.indent_left = ind_attrs[:left]
          props.indent_right = ind_attrs[:right]
          props.indent_first_line = ind_attrs[:first_line]
          props.indent_first_line = -ind_attrs[:hanging] if ind_attrs[:hanging]
        end

        # Keep together options (boolean elements)
        props.keep_next = !pPr_node.at_xpath('./w:keepNext', WORDML_NS).nil?
        props.keep_lines = !pPr_node.at_xpath('./w:keepLines', WORDML_NS).nil?
        props.page_break_before = !pPr_node.at_xpath('./w:pageBreakBefore', WORDML_NS).nil?

        # Widow control (boolean element)
        widow_node = pPr_node.at_xpath('./w:widowControl', WORDML_NS)
        if widow_node
          # Check if explicitly disabled
          props.widow_control = widow_node['w:val'] != '0'
        end

        # Contextual spacing
        props.contextual_spacing = !pPr_node.at_xpath('./w:contextualSpacing', WORDML_NS).nil?

        # Bidirectional text
        props.bidirectional = !pPr_node.at_xpath('./w:bidi', WORDML_NS).nil?

        # Outline level - create wrapper object
        if (outlineLvl = pPr_node.at_xpath('./w:outlineLvl', WORDML_NS))
          props.outline_level = Properties::OutlineLevel.new(value: outlineLvl['w:val']&.to_i)
        end

        # Numbering properties (w:numPr)
        if (numPr = pPr_node.at_xpath('./w:numPr', WORDML_NS))
          if (numId = numPr.at_xpath('./w:numId', WORDML_NS))
            props.numbering_id = Properties::NumberingId.new(
              value: numId['w:val']&.to_i
            )
            props.num_id = numId['w:val'] # Flat alias for compatibility
          end
          if (ilvl = numPr.at_xpath('./w:ilvl', WORDML_NS))
            props.numbering_level = Properties::NumberingLevel.new(
              value: ilvl['w:val']&.to_i
            )
            props.ilvl = ilvl['w:val']&.to_i # Flat alias for compatibility
          end
        end

        # Shading (w:shd) - create Shading object
        if (shd = pPr_node.at_xpath('./w:shd', WORDML_NS))
          shading_attrs = {}
          shading_attrs[:pattern] = shd['w:val'] if shd['w:val']
          shading_attrs[:color] = shd['w:color'] if shd['w:color']
          shading_attrs[:fill] = shd['w:fill'] if shd['w:fill']

          props.shading = Properties::Shading.new(shading_attrs)

          # Also set flat attributes for compatibility
          props.shading_fill = shading_attrs[:fill]
          props.shading_color = shading_attrs[:color]
          props.shading_type = shading_attrs[:pattern]
        end

        # Borders (w:pBdr)
        if (pBdr = pPr_node.at_xpath('./w:pBdr', WORDML_NS))
          borders_hash = {}

          # Parse each border side
          %w[top bottom left right].each do |side|
            border_node = pBdr.at_xpath("./w:#{side}", WORDML_NS)
            next unless border_node

            border_attrs = {}
            border_attrs[:style] = border_node['w:val'] if border_node['w:val']
            border_attrs[:size] = border_node['w:sz']&.to_i if border_node['w:sz']
            border_attrs[:space] = border_node['w:space']&.to_i if border_node['w:space']
            border_attrs[:color] = border_node['w:color'] if border_node['w:color']

            unless border_attrs.empty?
              borders_hash[side.to_sym] =
                Properties::Border.new(border_attrs)
            end
          end

          props.borders = Properties::Borders.new(borders_hash) unless borders_hash.empty?
        end

        # Tabs (w:tabs)
        if (tabs_node = pPr_node.at_xpath('./w:tabs', WORDML_NS))
          tab_stops = []

          tabs_node.xpath('./w:tab', WORDML_NS).each do |tab_node|
            tab_attrs = {}
            tab_attrs[:alignment] = tab_node['w:val'] if tab_node['w:val']
            tab_attrs[:position] = tab_node['w:pos']&.to_i if tab_node['w:pos']
            tab_attrs[:leader] = tab_node['w:leader'] if tab_node['w:leader']

            tab_stops << Properties::TabStop.new(tab_attrs) unless tab_attrs.empty?
          end

          props.tabs = Properties::Tabs.new(tab_stops: tab_stops) unless tab_stops.empty?
        end

        # Suppress line numbers
        props.suppress_line_numbers = !pPr_node.at_xpath('./w:suppressLineNumbers', WORDML_NS).nil?

        # TODO: Add more complex properties:
        # - Frame properties (w:framePr)

        props
      end

      # Parse w:rPr (Run Properties) into RunProperties object
      #
      # @param rPr_node [Nokogiri::XML::Element] The w:rPr element
      # @return [Properties::RunProperties] Parsed properties
      def parse_run_properties(rPr_node)
        require_relative '../properties/run_properties'
        require_relative '../properties/run_fonts'
        require_relative '../properties/font_size'
        require_relative '../properties/color_value'
        require_relative '../properties/style_reference'
        require_relative '../properties/underline'
        require_relative '../properties/highlight'
        require_relative '../properties/vertical_align'
        require_relative '../properties/position'
        require_relative '../properties/character_spacing'
        require_relative '../properties/kerning'
        require_relative '../properties/width_scale'
        require_relative '../properties/emphasis_mark'
        require_relative '../properties/shading'
        require_relative '../properties/language'
        require_relative '../properties/text_fill'
        require_relative '../properties/text_outline'

        props = Properties::RunProperties.new

        # Style reference - create wrapper object
        if (rStyle = rPr_node.at_xpath('./w:rStyle', WORDML_NS))
          props.style = Properties::StyleReference.new(value: rStyle['w:val'])
        end

        # Font families (w:rFonts) - create RunFonts object
        if (rFonts = rPr_node.at_xpath('./w:rFonts', WORDML_NS))
          fonts_attrs = {}
          fonts_attrs[:ascii] = rFonts['w:ascii'] if rFonts['w:ascii']
          fonts_attrs[:h_ansi] = rFonts['w:hAnsi'] if rFonts['w:hAnsi']
          fonts_attrs[:east_asia] = rFonts['w:eastAsia'] if rFonts['w:eastAsia']
          fonts_attrs[:cs] = rFonts['w:cs'] if rFonts['w:cs']
          fonts_attrs[:hint] = rFonts['w:hint'] if rFonts['w:hint']

          props.fonts = Properties::RunFonts.new(fonts_attrs)
        end

        # Font size - create wrapper object
        if (sz = rPr_node.at_xpath('./w:sz', WORDML_NS))
          props.size = Properties::FontSize.new(value: sz['w:val']&.to_i)
        end

        # Complex script font size - create wrapper object
        if (szCs = rPr_node.at_xpath('./w:szCs', WORDML_NS))
          props.size_cs = Properties::FontSize.new(value: szCs['w:val']&.to_i)
        end

        # Bold (w:b)
        props.bold = !rPr_node.at_xpath('./w:b', WORDML_NS).nil?

        # Italic (w:i)
        props.italic = !rPr_node.at_xpath('./w:i', WORDML_NS).nil?

        # Underline (w:u) - create wrapper object
        if (u = rPr_node.at_xpath('./w:u', WORDML_NS))
          props.underline = Properties::Underline.new(value: u['w:val'] || 'single')
        end

        # Strike-through (w:strike)
        props.strike = !rPr_node.at_xpath('./w:strike', WORDML_NS).nil?

        # Double strike (w:dstrike)
        props.double_strike = !rPr_node.at_xpath('./w:dstrike', WORDML_NS).nil?

        # Caps formatting
        props.small_caps = !rPr_node.at_xpath('./w:smallCaps', WORDML_NS).nil?
        props.caps = !rPr_node.at_xpath('./w:caps', WORDML_NS).nil?
        props.all_caps = props.caps # Alias

        # Hidden text (w:vanish)
        props.hidden = !rPr_node.at_xpath('./w:vanish', WORDML_NS).nil?

        # Color - create wrapper object
        if (color = rPr_node.at_xpath('./w:color', WORDML_NS))
          props.color = Properties::ColorValue.new(value: color['w:val'])
        end

        # Highlight (w:highlight) - create wrapper object
        if (highlight = rPr_node.at_xpath('./w:highlight', WORDML_NS))
          props.highlight = Properties::Highlight.new(value: highlight['w:val'])
        end

        # Vertical alignment (w:vertAlign) - create wrapper object
        if (vertAlign = rPr_node.at_xpath('./w:vertAlign', WORDML_NS))
          props.vertical_align = Properties::VerticalAlign.new(value: vertAlign['w:val'])
        end

        # Character spacing (w:spacing in twips) - create wrapper object
        if (spacing = rPr_node.at_xpath('./w:spacing', WORDML_NS))
          props.character_spacing = Properties::CharacterSpacing.new(
            value: spacing['w:val']&.to_i
          )
          props.spacing = spacing['w:val']&.to_i # Flat alias for compatibility
        end

        # Position (raised/lowered text in half-points) - create wrapper object
        if (position = rPr_node.at_xpath('./w:position', WORDML_NS))
          props.position = Properties::Position.new(value: position['w:val']&.to_i)
        end

        # Kern (kerning threshold in half-points) - create wrapper object
        if (kern = rPr_node.at_xpath('./w:kern', WORDML_NS))
          props.kerning = Properties::Kerning.new(
            value: kern['w:val']&.to_i
          )
          props.kern = kern['w:val']&.to_i # Flat alias for compatibility
        end

        # Width scale (w:w as percentage 50-600) - create wrapper object
        if (w = rPr_node.at_xpath('./w:w', WORDML_NS))
          props.width_scale = Properties::WidthScale.new(
            value: w['w:val']&.to_i
          )
          props.w_scale = w['w:val']&.to_i # Flat alias for compatibility
        end

        # Emphasis mark (w:em) - create wrapper object
        if (em = rPr_node.at_xpath('./w:em', WORDML_NS))
          props.emphasis_mark = Properties::EmphasisMark.new(
            value: em['w:val']
          )
          props.em = em['w:val'] # Flat alias for compatibility
        end

        # Language (w:lang) - create Language object
        if (lang = rPr_node.at_xpath('./w:lang', WORDML_NS))
          lang_attrs = {}
          lang_attrs[:val] = lang['w:val'] if lang['w:val']
          lang_attrs[:bidi] = lang['w:bidi'] if lang['w:bidi']
          lang_attrs[:east_asia] = lang['w:eastAsia'] if lang['w:eastAsia']

          props.language = Properties::Language.new(lang_attrs)

          # Also set flat attributes for compatibility
          props.language_val = lang_attrs[:val]
          props.language_bidi = lang_attrs[:bidi]
          props.language_east_asia = lang_attrs[:east_asia]
        end

        # Shading (w:shd) - create Shading object
        if (shd = rPr_node.at_xpath('./w:shd', WORDML_NS))
          shading_attrs = {}
          shading_attrs[:pattern] = shd['w:val'] if shd['w:val']
          shading_attrs[:color] = shd['w:color'] if shd['w:color']
          shading_attrs[:fill] = shd['w:fill'] if shd['w:fill']

          props.shading = Properties::Shading.new(shading_attrs)

          # Also set flat attribute for compatibility
          props.shading_fill = shading_attrs[:fill]
        end

        # Text fill (w:textFill) - basic solid color support
        # Try to extract color from nested solidFill element
        if (textFill = rPr_node.at_xpath('./w:textFill',
                                         WORDML_NS)) && (solidFill = textFill.at_xpath(
                                           './w:solidFill', WORDML_NS
                                         ))
          if (schemeClr = solidFill.at_xpath('./w:schemeClr', WORDML_NS))
            props.text_fill = Properties::TextFill.new(color: schemeClr['w:val'])
          elsif (srgbClr = solidFill.at_xpath('./w:srgbClr', WORDML_NS))
            props.text_fill = Properties::TextFill.new(color: srgbClr['w:val'])
          end
        end

        # Text outline (w:textOutline) - basic support
        if (textOutline = rPr_node.at_xpath('./w:textOutline', WORDML_NS))
          outline_attrs = {}
          outline_attrs[:width] = textOutline['w:w']&.to_i if textOutline['w:w']

          # Try to extract color from nested fill element
          if (fill = textOutline.at_xpath('./w:solidFill', WORDML_NS))
            if (schemeClr = fill.at_xpath('./w:schemeClr', WORDML_NS))
              outline_attrs[:color] = schemeClr['w:val']
            elsif (srgbClr = fill.at_xpath('./w:srgbClr', WORDML_NS))
              outline_attrs[:color] = srgbClr['w:val']
            end
          end

          unless outline_attrs.empty?
            props.text_outline = Properties::TextOutline.new(outline_attrs)
          end
        end

        # TODO: Add more properties:
        # - Complex formatting (w:emboss, w:imprint, w:outline, w:shadow)

        props
      end

      # Parse w:tblPr (Table Properties) into TableProperties object
      #
      # @param tblPr_node [Nokogiri::XML::Element] The w:tblPr element
      # @return [Properties::TableProperties] Parsed properties
      def parse_table_properties(tblPr_node)
        require_relative '../properties/table_properties'

        props = Properties::TableProperties.new

        # Style reference
        if (tblStyle = tblPr_node.at_xpath('./w:tblStyle', WORDML_NS))
          props.style = tblStyle['w:val']
        end

        # Table width (w:tblW)
        if (tblW = tblPr_node.at_xpath('./w:tblW', WORDML_NS))
          props.width = tblW['w:w']&.to_i
          props.width_type = tblW['w:type'] # auto, dxa, pct, nil
        end

        # Table alignment (w:jc)
        if (jc = tblPr_node.at_xpath('./w:jc', WORDML_NS))
          props.alignment = jc['w:val']
        end

        # Table indent (w:tblInd)
        if (tblInd = tblPr_node.at_xpath('./w:tblInd', WORDML_NS))
          props.indent = tblInd['w:w']&.to_i
        end

        # Cell spacing (w:tblCellSpacing)
        if (cellSpacing = tblPr_node.at_xpath('./w:tblCellSpacing', WORDML_NS))
          props.cell_spacing = cellSpacing['w:w']&.to_i
        end

        # Table layout (w:tblLayout)
        if (tblLayout = tblPr_node.at_xpath('./w:tblLayout', WORDML_NS))
          props.layout = tblLayout['w:type'] # autofit, fixed
        end

        # Table borders (w:tblBorders)
        if (tblBorders = tblPr_node.at_xpath('./w:tblBorders', WORDML_NS))
          props.borders = true

          # Parse individual borders
          %w[top bottom left right insideH insideV].each do |side|
            border_node = tblBorders.at_xpath("./w:#{side}", WORDML_NS)
            next unless border_node

            # Store border properties as individual attributes
            case side
            when 'top'
              props.border_top_style = border_node['w:val']
              props.border_top_size = border_node['w:sz']&.to_i
              props.border_top_color = border_node['w:color']
            when 'bottom'
              props.border_bottom_style = border_node['w:val']
              props.border_bottom_size = border_node['w:sz']&.to_i
              props.border_bottom_color = border_node['w:color']
            when 'left'
              props.border_left_style = border_node['w:val']
              props.border_left_size = border_node['w:sz']&.to_i
              props.border_left_color = border_node['w:color']
            when 'right'
              props.border_right_style = border_node['w:val']
              props.border_right_size = border_node['w:sz']&.to_i
              props.border_right_color = border_node['w:color']
            when 'insideH'
              props.border_inside_h_style = border_node['w:val']
              props.border_inside_h_size = border_node['w:sz']&.to_i
              props.border_inside_h_color = border_node['w:color']
            when 'insideV'
              props.border_inside_v_style = border_node['w:val']
              props.border_inside_v_size = border_node['w:sz']&.to_i
              props.border_inside_v_color = border_node['w:color']
            end
          end
        end

        # Background color (w:shd)
        if (shd = tblPr_node.at_xpath('./w:shd', WORDML_NS))
          props.background_color = shd['w:fill']
        end

        # TODO: Add more properties:
        # - Table cell padding (w:tblCellMar)
        # - Conditional formatting (w:tblStyleRowBandSize, w:tblStyleColBandSize)
        # - BiDi (w:bidiVisual)

        props
      end

      # Extract StyleSet name from styles.xml
      #
      # The name is typically derived from the DocDefaults or
      # can be extracted from metadata. Falls back to generic name.
      #
      # @param xml [String] Styles XML content
      # @return [String] StyleSet name
      def extract_name(xml)
        Nokogiri::XML(xml)

        # Try to find a custom name in comments or metadata
        # For now, return a default that can be overridden
        'Custom StyleSet'
      rescue StandardError
        'Custom StyleSet'
      end

      # Count styles in XML without full parsing
      #
      # @param xml [String] Styles XML content
      # @return [Integer] Number of styles
      def count_styles(xml)
        doc = Nokogiri::XML(xml)
        style_nodes = doc.xpath('//w:style', WORDML_NS)
        style_nodes.count
      rescue StandardError
        0
      end
    end
  end
end
