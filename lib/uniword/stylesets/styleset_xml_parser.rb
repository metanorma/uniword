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
        if pPr_node
          style.paragraph_properties = parse_paragraph_properties(pPr_node)
        end

        rPr_node = style_node.at_xpath('./w:rPr', WORDML_NS)
        if rPr_node
          style.run_properties = parse_run_properties(rPr_node)
        end

        tblPr_node = style_node.at_xpath('./w:tblPr', WORDML_NS)
        if tblPr_node
          style.table_properties = parse_table_properties(tblPr_node)
        end

        style
      end

      # Parse w:pPr (Paragraph Properties) into ParagraphProperties object
      #
      # @param pPr_node [Nokogiri::XML::Element] The w:pPr element
      # @return [Properties::ParagraphProperties] Parsed properties
      def parse_paragraph_properties(pPr_node)
        require_relative '../properties/paragraph_properties'

        props = Properties::ParagraphProperties.new

        # Style reference
        if (pStyle = pPr_node.at_xpath('./w:pStyle', WORDML_NS))
          props.style = pStyle['w:val']
        end

        # Alignment (w:jc)
        if (jc = pPr_node.at_xpath('./w:jc', WORDML_NS))
          props.alignment = jc['w:val']
        end

        # Spacing (w:spacing)
        if (spacing = pPr_node.at_xpath('./w:spacing', WORDML_NS))
          props.spacing_before = spacing['w:before']&.to_i
          props.spacing_after = spacing['w:after']&.to_i
          props.line_spacing = spacing['w:line']&.to_f
          props.line_rule = spacing['w:lineRule']
        end

        # Indentation (w:ind)
        if (ind = pPr_node.at_xpath('./w:ind', WORDML_NS))
          props.indent_left = ind['w:left']&.to_i
          props.indent_right = ind['w:right']&.to_i
          props.indent_first_line = ind['w:firstLine']&.to_i if ind['w:firstLine']

          # Handle hanging indent (negative first line)
          if ind['w:hanging']
            props.indent_first_line = -ind['w:hanging'].to_i
          end
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

        # Outline level
        if (outlineLvl = pPr_node.at_xpath('./w:outlineLvl', WORDML_NS))
          props.outline_level = outlineLvl['w:val']&.to_i
        end

        # Numbering properties (w:numPr)
        if (numPr = pPr_node.at_xpath('./w:numPr', WORDML_NS))
          if (numId = numPr.at_xpath('./w:numId', WORDML_NS))
            props.num_id = numId['w:val']
          end
          if (ilvl = numPr.at_xpath('./w:ilvl', WORDML_NS))
            props.ilvl = ilvl['w:val']&.to_i
          end
        end

        # Shading (w:shd)
        if (shd = pPr_node.at_xpath('./w:shd', WORDML_NS))
          props.shading_fill = shd['w:fill']
          props.shading_color = shd['w:color']
          props.shading_type = shd['w:val']
        end

        # Suppress line numbers
        props.suppress_line_numbers = !pPr_node.at_xpath('./w:suppressLineNumbers', WORDML_NS).nil?

        # TODO: Add more complex properties:
        # - Borders (w:pBdr)
        # - Tabs (w:tabs)
        # - Frame properties (w:framePr)

        props
      end

      # Parse w:rPr (Run Properties) into RunProperties object
      #
      # @param rPr_node [Nokogiri::XML::Element] The w:rPr element
      # @return [Properties::RunProperties] Parsed properties
      def parse_run_properties(rPr_node)
        require_relative '../properties/run_properties'

        props = Properties::RunProperties.new

        # Style reference
        if (rStyle = rPr_node.at_xpath('./w:rStyle', WORDML_NS))
          props.style = rStyle['w:val']
        end

        # Font families (w:rFonts)
        if (rFonts = rPr_node.at_xpath('./w:rFonts', WORDML_NS))
          props.font = rFonts['w:ascii'] || rFonts['w:hAnsi']
          props.font_ascii = rFonts['w:ascii']
          props.font_east_asia = rFonts['w:eastAsia']
          props.font_hint = rFonts['w:hint']
        end

        # Font size (w:sz in half-points)
        if (sz = rPr_node.at_xpath('./w:sz', WORDML_NS))
          props.size = sz['w:val']&.to_i
        end

        # Complex script font size
        if (szCs = rPr_node.at_xpath('./w:szCs', WORDML_NS))
          # Store if different from regular size
          cs_size = szCs['w:val']&.to_i
          props.size ||= cs_size
        end

        # Bold (w:b)
        props.bold = !rPr_node.at_xpath('./w:b', WORDML_NS).nil?

        # Italic (w:i)
        props.italic = !rPr_node.at_xpath('./w:i', WORDML_NS).nil?

        # Underline (w:u)
        if (u = rPr_node.at_xpath('./w:u', WORDML_NS))
          props.underline = u['w:val'] || 'single'
        end

        # Strike-through (w:strike)
        props.strike = !rPr_node.at_xpath('./w:strike', WORDML_NS).nil?

        # Double strike (w:dstrike)
        props.double_strike = !rPr_node.at_xpath('./w:dstrike', WORDML_NS).nil?

        # Caps formatting
        props.small_caps = !rPr_node.at_xpath('./w:smallCaps', WORDML_NS).nil?
        props.caps = !rPr_node.at_xpath('./w:caps', WORDML_NS).nil?
        props.all_caps = props.caps  # Alias

        # Hidden text (w:vanish)
        props.hidden = !rPr_node.at_xpath('./w:vanish', WORDML_NS).nil?

        # Color (w:color)
        if (color = rPr_node.at_xpath('./w:color', WORDML_NS))
          props.color = color['w:val']
        end

        # Highlight (w:highlight)
        if (highlight = rPr_node.at_xpath('./w:highlight', WORDML_NS))
          props.highlight = highlight['w:val']
        end

        # Vertical alignment (w:vertAlign)
        if (vertAlign = rPr_node.at_xpath('./w:vertAlign', WORDML_NS))
          props.vertical_align = vertAlign['w:val']
        end

        # Character spacing (w:spacing in twips)
        if (spacing = rPr_node.at_xpath('./w:spacing', WORDML_NS))
          props.spacing = spacing['w:val']&.to_i
          props.character_spacing = props.spacing  # Alias
        end

        # Position (raised/lowered text in half-points)
        if (position = rPr_node.at_xpath('./w:position', WORDML_NS))
          props.position = position['w:val']&.to_i
        end

        # Kern (kerning threshold in half-points)
        if (kern = rPr_node.at_xpath('./w:kern', WORDML_NS))
          props.kerning = kern['w:val']&.to_i
        end

        # Width scale (w:w as percentage 50-600)
        if (w = rPr_node.at_xpath('./w:w', WORDML_NS))
          props.w_scale = w['w:val']&.to_i
        end

        # Emphasis mark (w:em)
        if (em = rPr_node.at_xpath('./w:em', WORDML_NS))
          props.emphasis_mark = em['w:val']
        end

        # Language (w:lang)
        if (lang = rPr_node.at_xpath('./w:lang', WORDML_NS))
          props.language = lang['w:val']
          props.language_bidi = lang['w:bidi']
          props.language_east_asia = lang['w:eastAsia']
        end

        # Shading (w:shd)
        if (shd = rPr_node.at_xpath('./w:shd', WORDML_NS))
          props.shading = shd['w:fill']  # Store as string for now
        end

        # TODO: Add more properties:
        # - Text effects (w:textFill, w:textOutline)
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
          props.width_type = tblW['w:type']  # auto, dxa, pct, nil
        end

        #Table alignment (w:jc)
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
          props.layout = tblLayout['w:type']  # autofit, fixed
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
        doc = Nokogiri::XML(xml)

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