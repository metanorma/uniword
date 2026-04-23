# frozen_string_literal: true

module Uniword
  module Transformation
    # SERVICE for converting OOXML elements to HTML.
    #
    # Pure functions - no state, no side effects.
    # Used by Transformer when target_format is :mhtml.
    #
    # @example Convert OOXML document to HTML
    #   html = OoxmlToHtmlConverter.document_to_html(doc)
    #   # => "<html>..."
    #
    class OoxmlToHtmlConverter
      # Convert OOXML Document to HTML string
      #
      # @param document [Uniword::Wordprocessingml::DocumentRoot] OOXML document
      # @return [String] HTML content
      def self.document_to_html(document)
        body = document.body
        return "" unless body

        elements_html = body.elements.map { |e| element_to_html(e) }.join("\n")
        wrap_html(elements_html, document)
      end

      # Convert a single OOXML element to HTML
      #
      # @param element [Object] OOXML element
      # @return [String] HTML string
      def self.element_to_html(element)
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
      #
      # @param paragraph [Uniword::Wordprocessingml::Paragraph]
      # @return [String] HTML <p> element
      def self.paragraph_to_html(paragraph)
        runs_html = paragraph.runs.map { |r| run_to_html(r) }.join
        style = paragraph_style(paragraph)
        "<p#{style}>#{runs_html}</p>"
      end

      # Convert OOXML Run to HTML
      #
      # @param run [Uniword::Wordprocessingml::Run]
      # @return [String] HTML text content with inline formatting
      def self.run_to_html(run)
        text = escape_html(run.text || "")
        return text if text.empty?

        props = run.properties
        return text unless props

        # Apply inline formatting
        text = "<strong>#{text}</strong>" if props.bold
        text = "<em>#{text}</em>" if props.italic
        text = "<u>#{text}</u>" if props.underline&.value
        text = "<span style=\"color:#{props.color&.value}\">#{text}</span>" if props.color&.value
        text = "<span style=\"font-size:#{font_size_to_html(props.size&.value)}\">#{text}</span>" if props.size&.value
        text = "<span style=\"font-family:'#{props.font&.ascii}'\">#{text}</span>" if props.font&.ascii

        text
      end

      # Convert OOXML Table to HTML
      #
      # @param table [Uniword::Wordprocessingml::Table]
      # @return [String] HTML <table> element
      def self.table_to_html(table)
        rows_html = table.rows.map { |row| table_row_to_html(row) }.join("\n")
        "<table>\n#{rows_html}\n</table>"
      end

      # Convert OOXML TableRow to HTML
      #
      # @param row [Uniword::Wordprocessingml::TableRow]
      # @return [String] HTML <tr> element
      def self.table_row_to_html(row)
        cells_html = row.cells.map do |cell|
          table_cell_to_html(cell)
        end.join("\n")
        "<tr>\n#{cells_html}\n</tr>"
      end

      # Convert OOXML TableCell to HTML
      #
      # @param cell [Uniword::Wordprocessingml::TableCell]
      # @return [String] HTML <td> element
      def self.table_cell_to_html(cell)
        paragraphs_html = cell.paragraphs.map do |p|
          paragraph_to_html(p)
        end.join("\n")
        "<td>\n#{paragraphs_html}\n</td>"
      end

      # Wrap HTML content in full HTML document
      #
      # @param body_html [String] Body content HTML
      # @param document [Uniword::Wordprocessingml::DocumentRoot]
      # @return [String] Full HTML document
      def self.wrap_html(body_html, document)
        title = document.title ? escape_html(document.title) : "Document"
        core_props = document.core_properties
        author = core_props.respond_to?(:creator) ? core_props.creator : nil

        meta_tags = []
        meta_tags << "<meta name=\"author\" content=\"#{escape_html(author)}\">" if author

        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <title>#{title}</title>
            #{meta_tags.join("\n")}
          </head>
          <body>
          #{body_html}
          </body>
          </html>
        HTML
      end

      # Extract paragraph style attribute
      #
      # @param paragraph [Uniword::Wordprocessingml::Paragraph]
      # @return [String] HTML class/style attribute or empty string
      def self.paragraph_style(paragraph)
        return "" unless paragraph.properties

        style = paragraph.properties.style
        return "" unless style

        " class=\"#{escape_html(style)}\""
      end

      # Convert OOXML font size (half-points) to HTML font size
      #
      # @param size_value [String, nil] Font size in half-points
      # @return [String] HTML font size with unit
      def self.font_size_to_html(size_value)
        return nil unless size_value

        # Convert half-points to points
        size_pts = size_value.to_f / 2
        "#{size_pts}pt"
      end

      # Escape HTML special characters
      #
      # @param text [String] Raw text
      # @return [String] Escaped text
      def self.escape_html(text)
        text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&#39;")
      end
    end
  end
end
