# frozen_string_literal: true

require "nokogiri"

module Uniword
  module Transformation
    # Converts OOXML elements (Paragraph, Table, Run, etc.) to Word HTML
    # for MHTML output.
    #
    # Extracted from OoxmlToMhtmlConverter for separation of responsibilities.
    #
    # @api private
    class MhtmlElementRenderer
      def initialize(relationships = nil, image_parts = nil)
        @relationships = relationships
        @image_parts = image_parts
      end

      # Convert an OOXML element to HTML
      def element_to_html(element)
        case element
        when Uniword::Wordprocessingml::Paragraph
          paragraph_to_html(element)
        when Uniword::Wordprocessingml::Table
          table_to_html(element)
        else
          ""
        end
      end

      # Convert OOXML Paragraph to HTML
      def paragraph_to_html(paragraph)
        style_class = style_to_css_class(paragraph.style)

        content = paragraph_content_to_html(paragraph)

        # Use semantic heading tags for heading styles
        tag = heading_tag_for_style(paragraph.style)

        if content.strip.empty?
          %(<#{tag}#{style_class}><o:p>&nbsp;</o:p></#{tag}>)
        else
          %(<#{tag}#{style_class}>#{content}</#{tag}>)
        end
      end

      # Map heading styles to HTML heading tags
      def heading_tag_for_style(style)
        return "p" unless style

        style_value = style.is_a?(String) ? style : style.to_s

        case style_value
        when "Heading1", "Heading2", "Heading3",
             "Heading4", "Heading5", "Heading6"
          "h#{style_value[-1].to_i}"
        when "Title", "Title2"
          "h1"
        when "Subtitle"
          "h2"
        # h1-level ISO/IEC document styles
        when "ANNEX", "ForewordTitle", "IntroTitle", "section3"
          "h1"
        else
          "p"
        end
      end

      # Convert OOXML Run to HTML
      def run_to_html(run)
        # Handle breaks and drawings first (these never get style wrapping)
        return break_to_html(run.break) if run.break
        if run.drawings && !run.drawings.empty?
          return drawing_to_html(run.drawings.first)
        end

        # Handle footnote/endnote references (rendered as special markers)
        return footnote_reference_to_html(run) if run.footnote_reference
        return endnote_reference_to_html(run) if run.endnote_reference

        # Render content based on run type
        content = render_run_content(run)

        # Skip truly empty runs without formatting
        if content.nil? || content.empty?
          props = run.properties
          # Emit formatting tags for empty runs with bold/italic formatting
          if props && (props.bold || props.italic)
            content = ""
          else
            return ""
          end
        end

        # Apply character-level formatting (bold, italic, underline)
        # and style class wrapping
        props = run.properties
        if props
          content = apply_run_formatting(content, props) unless run.field_char || run.tab
          if props.style && props.style.value
            style_id = props.style.value.downcase
            # Skip wrapping for internal OOXML styles that shouldn't produce
            # visible HTML class wrappers
            is_internal_style = %w[stem hyperlink].include?(style_id)
            is_stem_spacer = (style_id == "stem") && run.text.to_s.strip.empty?
            unless is_internal_style || is_stem_spacer
              style_val = run_style_to_class(props.style.value)
              content = %(<span class="#{style_val}">#{content}</span>)
            end
          end
        end

        content
      end

      # Render the core content of a run based on its type
      def render_run_content(run)
        if run.field_char
          field_char_to_html(run)
        elsif run.instr_text
          instr_text_to_html(run)
        elsif run.tab
          tab_to_html(run)
        else
          text = run.text.to_s
          return "" if text.empty?
          escape_html(text)
        end
      end

      # Convert OOXML FootnoteReference to HTML
      def footnote_reference_to_html(run)
        %(<span class="MsoFootnoteReference"><span style="mso-special-character:footnote"></span></span>)
      end

      # Convert OOXML EndnoteReference to HTML
      def endnote_reference_to_html(run)
        %(<span class="MsoEndnoteReference"><span style="mso-special-character:endnote"></span></span>)
      end

      # Convert OOXML Break to HTML
      def break_to_html(brk)
        if brk.type == "page"
          %(<br clear="all" style="mso-special-character:line-break;page-break-before:always" />)
        else
          %(<br />)
        end
      end

      # Convert OOXML FieldChar to HTML span
      def field_char_to_html(run)
        type = run.field_char.fldCharType
        style_attr = case type
                     when "begin" then "mso-element:field-begin"
                     when "separate" then "mso-element:field-separator"
                     when "end" then "mso-element:field-end"
                     else return ""
                     end
        %(<span style="#{style_attr}"></span>)
      end

      # Convert OOXML InstrText to HTML
      def instr_text_to_html(run)
        text = run.instr_text.text.to_s
        return "" if text.empty?
        escape_html(text)
      end

      # Convert OOXML Tab to HTML
      def tab_to_html(run)
        # TOC tab leader: rendered as dotted leader
        %(<span style="mso-tab-count:1 dotted">. </span>)
      end

      # Convert an OOXML Drawing to HTML <img> tag
      def drawing_to_html(drawing)
        inline = drawing.inline
        return "" unless inline

        graphic_data = inline.graphic&.graphic_data
        return "" unless graphic_data

        pic = graphic_data.picture
        return "" unless pic

        embed_id = pic.blip_fill&.blip&.embed
        return "" unless embed_id

        # Resolve image target from image_parts
        image_target = resolve_image_target(embed_id)
        return "" unless image_target

        # Get dimensions from extent (EMU to px: 1px = 9525 EMU)
        width_px = nil
        height_px = nil
        if inline.extent
          width_px = (inline.extent.cx.to_i / 9525.0).round if inline.extent.cx
          height_px = (inline.extent.cy.to_i / 9525.0).round if inline.extent.cy
        end

        style_attrs = []
        style_attrs << "width:#{width_px}px" if width_px
        style_attrs << "height:#{height_px}px" if height_px
        style = style_attrs.empty? ? "" : " style='#{style_attrs.join(';')}'"

        %(<img src="#{image_target}"#{style}>)
      end

      # Resolve image target path from image_parts
      def resolve_image_target(embed_id)
        return nil unless @image_parts

        entry = @image_parts.find { |pair| pair[0] == embed_id }
        return nil unless entry

        image_data = entry[1]
        image_data[:target]
      end

      # Apply run formatting (text must already be HTML-escaped)
      # Uses HTML4 tags (<b>, <i>, <u>) for Word compatibility
      def apply_run_formatting(text, props)
        result = text

        # Bold/Italic: use <b>/<i> (HTML4) instead of <strong>/<em> (HTML5)
        result = "<b>#{result}</b>" if props.bold && props.bold.value != false
        result = "<i>#{result}</i>" if props.italic && props.italic.value != false
        result = "<u>#{result}</u>" if props.underline&.value

        result = %(<span style="color:#{props.color.value}">#{result}</span>) if props.color&.value

        if props.size&.value
          size_pt = props.size.value.to_f / 2
          result = %(<span style="font-size:#{size_pt}pt">#{result}</span>)
        end

        if props.font.respond_to?(:ascii) && props.font.ascii
          result = %(<span style="font-family:'#{props.font.ascii}'">#{result}</span>)
        elsif props.font.is_a?(String) && !props.font.empty?
          result = %(<span style="font-family:'#{props.font}'">#{result}</span>)
        end

        result
      end

      # Convert OOXML Hyperlink to HTML
      def hyperlink_to_html(hyperlink)
        url = resolve_hyperlink_url(hyperlink)
        return "" unless url

        content = hyperlink.runs.map { |r| run_to_html(r) }.join
        link_html = %(<a href="#{escape_html(url)}">#{content}</a>)

        # TOC hyperlinks (containing msotoctextspan1 runs) are wrapped in
        # MsoHyperlink span with mso-no-proof inner span
        if toc_hyperlink?(hyperlink)
          link_html = %(<span class="MsoHyperlink"><span style="mso-no-proof:yes">#{link_html}</span></span>)
        end

        link_html
      end

      # Check if a hyperlink is a TOC entry by inspecting its runs
      def toc_hyperlink?(hyperlink)
        hyperlink.runs.any? do |r|
          r.properties&.style&.value&.downcase == "msotoctextspan1"
        end
      end

      # Convert OOXML OMath to HTML (wrapped in stem span)
      def omath_to_html(o_math)
        xml = o_math.to_xml
        # Strip XML declaration and namespace prefixes for clean inline HTML
        xml = xml.gsub(/<\?[^>]+>\s*/, "")
        # Remove namespace declarations that Word HTML doesn't use
        xml = xml.gsub(/ xmlns(:[^=]+)?="[^"]+"/, "")
        # Ensure m: prefix on math elements for Word HTML compatibility
        %(<span class="stem">#{xml}</span>)
      end

      # Convert OOXML Table to HTML
      def table_to_html(table)
        rows = table.rows || []

        # Pre-compute vertical merge map: { [row_idx, col_idx] => :start | :continue }
        merge_map = build_vmerge_map(rows)

        rows_html = rows.each_with_index.map do |row, row_idx|
          cells = row.cells || []
          cells_html = cells.each_with_index.map do |cell, col_idx|
            # Skip vMerge continuation cells — they're absorbed by the start cell's rowspan
            merge_state = merge_map[[row_idx, col_idx]]
            next if merge_state == :continue

            # Compute rowspan from merge map
            rowspan = compute_rowspan(rows, row_idx, col_idx, merge_map)

            table_cell_to_html(cell, rowspan: rowspan)
          end.compact.join

          %(<tr>#{cells_html}</tr>)
        end.join("\n")

        <<~HTML
          <table>
          #{rows_html}
          </table>
        HTML
      end

      # Build a map of vMerge states for each cell position.
      # Returns { [row_idx, col_idx] => :start | :continue }
      # A cell with vMerge present whose cell-above does NOT have vMerge is :start.
      # A cell with vMerge present whose cell-above also has vMerge is :continue.
      def build_vmerge_map(rows)
        merge_map = {}
        prev_col_has_vmerge = {} # col_idx => true/false from previous row

        rows.each_with_index do |row, row_idx|
          cells = row.cells || []
          cells.each_with_index do |cell, col_idx|
            has_vmerge = cell.properties&.v_merge ? true : false

            if has_vmerge
              if prev_col_has_vmerge[col_idx]
                merge_map[[row_idx, col_idx]] = :continue
              else
                merge_map[[row_idx, col_idx]] = :start
              end
            end

            prev_col_has_vmerge[col_idx] = has_vmerge
          end
        end

        merge_map
      end

      # Compute rowspan for a vMerge start cell by counting continuation cells below.
      def compute_rowspan(rows, start_row_idx, col_idx, merge_map)
        return nil unless merge_map[[start_row_idx, col_idx]] == :start

        rowspan = 1
        (start_row_idx + 1...rows.size).each do |row_idx|
          break unless merge_map[[row_idx, col_idx]] == :continue
          rowspan += 1
        end

        rowspan > 1 ? rowspan : nil
      end

      # Convert OOXML TableCell to HTML
      # For simple cells (single plain paragraph), render text directly.
      # For complex cells (multiple paragraphs, styled text), wrap in <p>.
      # Header cells (<th>) use <th> tag instead of <td>.
      #
      # @param cell [TableCell] The cell to render
      # @param rowspan [Integer, nil] Rowspan from vMerge computation
      def table_cell_to_html(cell, rowspan: nil)
        paragraphs = cell.paragraphs || []
        tag = cell.header ? "th" : "td"

        # Build merge attributes
        attrs = []
        if cell.properties&.grid_span&.value && cell.properties.grid_span.value.to_i > 1
          attrs << "colspan=#{cell.properties.grid_span.value}"
        end
        attrs << "rowspan=#{rowspan}" if rowspan
        attr_str = attrs.empty? ? "" : " #{attrs.join(' ')}"

        if paragraphs.size == 1 && simple_cell_paragraph?(paragraphs.first)
          # Simple cell: render text content directly (no <p> wrapping)
          content = paragraph_content_to_html(paragraphs.first)
          %(<#{tag}#{attr_str}>#{content}</#{tag}>)
        else
          content = paragraphs.map do |para|
            paragraph_to_html(para)
          end.join("\n")

          <<~HTML
            <#{tag}#{attr_str}>
            #{content}
            </#{tag}>
          HTML
        end
      end

      # Check if a paragraph is simple enough to render without <p> wrapping
      # in a table cell. Single paragraphs with inline content (runs, hyperlinks)
      # are considered simple. Only block-level structures (SDTs, oMathPara)
      # make it complex.
      def simple_cell_paragraph?(para)
        return true if para.runs.empty? && para.hyperlinks.empty?
        # oMathPara is block-level and needs wrapping
        return false if para.o_math_paras && !para.o_math_paras.empty?
        # SDTs need wrapping
        return false if para.sdts && !para.sdts.empty?
        true
      end

      # Convert OOXML SDT block to inline MHT SDT
      def sdt_to_inline_html(sdt)
        return "" unless sdt.content

        sdt_props = sdt.properties
        sdt_content = sdt.content

        text = extract_sdt_text(sdt_content)

        sdt_attrs = build_sdt_attrs(sdt_props)

        if text.empty?
          %(<w:sdt#{sdt_attrs}><w:sdtPr></w:sdtPr></w:sdt>)
        else
          %(<w:sdt#{sdt_attrs}><w:sdtPr></w:sdtPr><w:sdtContent><span>#{escape_html(text)}</span></w:sdtContent></w:sdt>)
        end
      end

      # Map OOXML character style IDs (lowercase) to HTML class names
      # Note: "Hyperlink" style is NOT mapped here — it applies to runs inside
      # hyperlinks and should not produce visible span wrappers. The MsoHyperlink
      # class is only used on the wrapper span around <a> elements in TOC entries.
      RUN_STYLE_CLASS_MAP = {
        "zzmovetofollowing" => "zzMoveToFollowing",
        "stem" => "stem",
        "msofootnotereference" => "MsoFootnoteReference",
        "msotoctextspan1" => "MsoTocTextSpan",
      }.freeze

      # Convert OOXML run style ID to HTML class name
      def run_style_to_class(style_id)
        RUN_STYLE_CLASS_MAP.fetch(style_id.downcase, style_id)
      end

      # Map OOXML paragraph style ID to Word HTML CSS class
      # OOXML style IDs are used directly as CSS class names.
      PARAGRAPH_STYLE_CLASS_MAP = {
        "Heading1" => "MsoHeading1",
        "Heading2" => "MsoHeading2",
        "Heading3" => "MsoHeading3",
        "Heading4" => "MsoHeading4",
        "Heading5" => "MsoHeading5",
        "Heading6" => "MsoHeading6",
        "TOC1" => "MsoToc1",
        "TOC2" => "MsoToc2",
        "TOC3" => "MsoToc3",
        "TOC4" => "MsoToc4",
        "TOC5" => "MsoToc5",
        "TOC6" => "MsoToc6",
        "TOC7" => "MsoToc7",
        "TOC8" => "MsoToc8",
        "TOC9" => "MsoToc9",
        "zzSTDTitle" => "zzSTDTitle1",
        "FootnoteText" => "MsoFootnoteText",
        "h2annex" => "h2Annex",
        "h3annex" => "h3Annex",
        "h4annex" => "h4Annex",
        "h5annex" => "h5Annex",
        "note" => "Note",
        "figuretitle" => "FigureTitle",
        "tabletitle" => "TableTitle",
        "biblio" => "Biblio",
        "Normaali" => "MsoNormal",
      }.freeze

      # Map OOXML style to CSS class
      def style_to_css_class(style)
        return " class=MsoNormal" unless style

        style_value = style.is_a?(String) ? style : style.to_s

        css_class = PARAGRAPH_STYLE_CLASS_MAP[style_value]
        return " class=#{css_class}" if css_class

        # Direct mapping for known ISO paragraph styles
        case style_value
        when "Title", "Title2" then " class=MsoTitle"
        when "Subtitle" then " class=MsoSubtitle"
        else
          # Use the OOXML style ID directly as CSS class name
          " class=#{style_value}"
        end
      end

      private

      # Get paragraph content including runs, hyperlinks, SDTs, and oMath
      # Interleaves all element types in correct order using position markers.
      def paragraph_content_to_html(paragraph)
        run_count = paragraph.runs.size

        # Build position-indexed maps of hyperlinks and oMaths
        hl_by_pos = build_position_map(paragraph.hyperlinks, run_count)
        omath_by_pos = build_position_map(paragraph.o_maths, run_count)

        parts = []
        paragraph.runs.each_with_index do |run, idx|
          # Insert any oMaths that should appear at this position
          if omath_by_pos.key?(idx)
            omath_by_pos[idx].each { |om| parts << omath_to_html(om) }
          end

          # Insert any hyperlinks that should appear at this position
          if hl_by_pos.key?(idx)
            hl_by_pos[idx].each { |hl| parts << hyperlink_to_html(hl) }
          end

          if run.is_a?(Uniword::Wordprocessingml::StructuredDocumentTag)
            parts << sdt_to_inline_html(run)
          else
            parts << run_to_html(run)
          end
        end

        # Append any remaining oMaths at the end
        if omath_by_pos.key?(run_count)
          omath_by_pos[run_count].each { |om| parts << omath_to_html(om) }
        end

        # Append any remaining hyperlinks at the end
        if hl_by_pos.key?(run_count)
          hl_by_pos[run_count].each { |hl| parts << hyperlink_to_html(hl) }
        end

        paragraph.o_math_paras.each do |omp|
          # Block math: render each oMath inside the oMathPara
          omp.o_maths.each do |om|
            parts << omath_to_html(om)
          end
        end

        paragraph.sdts.each do |sdt|
          parts << sdt_to_inline_html(sdt)
        end

        parts.join
      end

      # Build position-indexed map from elements that have @_run_position markers
      def build_position_map(elements, fallback_pos)
        by_pos = {}
        elements.each do |el|
          pos = el.instance_variable_get(:@_run_position)
          pos ||= fallback_pos
          by_pos[pos] ||= []
          by_pos[pos] << el
        end
        by_pos
      end

      # Resolve hyperlink URL from relationship or anchor
      def resolve_hyperlink_url(hyperlink)
        return "##{hyperlink.anchor}" if hyperlink.anchor

        if hyperlink.id && @relationships
          rel = @relationships.relationships.find { |r| r.id == hyperlink.id }
          return rel.target if rel && rel.target_mode == "External"
        end

        nil
      end

      # Extract text from SDT content
      def extract_sdt_text(content)
        return "" unless content

        xml = content.to_xml
        doc = Nokogiri::HTML(xml)
        doc.text.gsub(/\s+/, " ").strip
      end

      # Build SDT attribute string
      def build_sdt_attrs(props)
        return "" unless props

        attrs = []

        attrs << %(w:id="#{props.id.value}") if props.id.respond_to?(:value) && props.id.value

        attrs << 'w:showingPlcHdr="t"' if props.showing_placeholder_header

        attrs << 'w:temporary="t"' if props.temporary

        if props.placeholder&.doc_part
          doc_part = props.placeholder.doc_part
          attrs << %(w:docPart="#{doc_part.value}") if doc_part.respond_to?(:value) && doc_part.value
        end

        attrs << %(w:text="#{props.text.value}") if props.text.respond_to?(:value) && props.text.value

        attrs << %(w:tag="#{escape_xml(props.tag.value)}") if props.tag.respond_to?(:value) && props.tag.value

        attrs << %(w:alias="#{escape_xml(props.alias_name.value)}") if props.alias_name.respond_to?(:value) && props.alias_name.value

        attrs.empty? ? "" : " #{attrs.join(' ')}"
      end

      # Escape HTML special characters
      def escape_html(text)
        text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&#39;")
      end

      # Escape XML special characters
      def escape_xml(text)
        text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&apos;")
      end
    end
  end
end
