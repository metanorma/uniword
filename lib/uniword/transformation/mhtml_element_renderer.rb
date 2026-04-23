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
      def initialize(relationships = nil)
        @relationships = relationships
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

        if content.strip.empty?
          %(<p#{style_class}><o:p>&nbsp;</o:p></p>)
        else
          %(<p#{style_class}>#{content}</p>)
        end
      end

      # Convert OOXML Run to HTML
      def run_to_html(run)
        text = run.text.to_s
        return "" if text.empty?

        escaped = escape_html(text)

        props = run.properties
        escaped = apply_run_formatting(escaped, props) if props

        escaped
      end

      # Apply run formatting (text must already be HTML-escaped)
      def apply_run_formatting(text, props)
        result = text

        # Bold/Italic: element presence means true (value may be nil)
        result = "<strong>#{result}</strong>" if props.bold && props.bold.value != false
        result = "<em>#{result}</em>" if props.italic && props.italic.value != false
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

        text = hyperlink.runs.map { |r| r.text.to_s }.join

        %(<a href="#{escape_html(url)}">#{escape_html(text)}</a>)
      end

      # Convert OOXML Table to HTML
      def table_to_html(table)
        rows = table.rows || []

        rows_html = rows.map do |row|
          cells = row.cells || []
          cells_html = cells.map { |cell| table_cell_to_html(cell) }.join

          %(<tr>#{cells_html}</tr>)
        end.join("\n")

        <<~HTML
          <table>
          #{rows_html}
          </table>
        HTML
      end

      # Convert OOXML TableCell to HTML
      def table_cell_to_html(cell)
        paragraphs = cell.paragraphs || []

        content = paragraphs.map do |para|
          paragraph_to_html(para)
        end.join("\n")

        <<~HTML
          <td>
          #{content}
          </td>
        HTML
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

      # Map OOXML style to CSS class
      def style_to_css_class(style)
        return " class=MsoNormal" unless style

        style_value = style.is_a?(String) ? style : style.to_s

        case style_value
        when "Title" then " class=MsoTitle"
        when "Title2" then " class=MsoTitle2"
        when "Subtitle" then " class=MsoSubtitle"
        when "Heading1" then " class=MsoHeading1"
        when "Heading2" then " class=MsoHeading2"
        when "Heading3" then " class=MsoHeading3"
        when "Heading4" then " class=MsoHeading4"
        when "Heading5" then " class=MsoHeading5"
        when "Heading6" then " class=MsoHeading6"
        when "TOC1", "TOC2", "TOC3", "TOC4", "TOC5", "TOC6", "TOC7", "TOC8", "TOC9"
          " class=MsoToc1"
        when "SectionTitle" then " class=SectionTitle"
        else
          " class=MsoNormal"
        end
      end

      private

      # Get paragraph content including runs, hyperlinks, SDTs
      def paragraph_content_to_html(paragraph)
        parts = paragraph.runs.map do |run|
          if run.is_a?(Uniword::Wordprocessingml::StructuredDocumentTag)
            sdt_to_inline_html(run)
          else
            run_to_html(run)
          end
        end

        paragraph.hyperlinks.each do |hyperlink|
          parts << hyperlink_to_html(hyperlink)
        end

        paragraph.sdts.each do |sdt|
          parts << sdt_to_inline_html(sdt)
        end

        parts.join
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
