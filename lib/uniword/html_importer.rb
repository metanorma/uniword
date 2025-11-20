# frozen_string_literal: true

require 'nokogiri'
require_relative 'document'
require_relative 'paragraph'
require_relative 'run'
require_relative 'table'
require_relative 'table_row'
require_relative 'table_cell'
require_relative 'hyperlink'
require_relative 'image'

module Uniword
  # Imports HTML content into Uniword document structure
  #
  # Provides html2doc compatibility by converting HTML elements
  # into corresponding Uniword document elements.
  #
  # @example Basic import
  #   html = "<p>Hello <b>World</b></p>"
  #   doc = HtmlImporter.new(html).to_document
  #
  # @example With options
  #   importer = HtmlImporter.new(html,
  #     base_font: 'Arial',
  #     base_size: 24,
  #     image_dir: './images'
  #   )
  #   doc = importer.to_document
  class HtmlImporter
    # Default style mappings for headings
    HEADING_STYLES = {
      'h1' => 'Heading1',
      'h2' => 'Heading2',
      'h3' => 'Heading3',
      'h4' => 'Heading4',
      'h5' => 'Heading5',
      'h6' => 'Heading6'
    }.freeze

    # Default font sizes for headings (in half-points)
    HEADING_SIZES = {
      'h1' => 32,  # 16pt
      'h2' => 28,  # 14pt
      'h3' => 26,  # 13pt
      'h4' => 24,  # 12pt
      'h5' => 22,  # 11pt
      'h6' => 20   # 10pt
    }.freeze

    attr_reader :html, :options, :document

    # Create new HTML importer
    #
    # @param html [String] HTML content to import
    # @param options [Hash] Import options
    # @option options [String] :base_font Default font family
    # @option options [Integer] :base_size Default font size (half-points)
    # @option options [String] :image_dir Directory for image files
    # @option options [Boolean] :strip_styles Strip inline styles
    def initialize(html, **options)
      @html = html
      @options = {
        base_font: 'Times New Roman',
        base_size: 22,  # 11pt
        image_dir: nil,
        strip_styles: false
      }.merge(options)
      @document = Document.new
    end

    # Convert HTML to Uniword document
    #
    # @return [Document] The generated document
    def to_document
      doc = Nokogiri::HTML(@html)
      body = doc.at_css('body') || doc

      process_node(body, @document)
      @document
    end

    private

    # Process a node and its children
    #
    # @param node [Nokogiri::XML::Node] The node to process
    # @param container [Object] The container to add elements to
    def process_node(node, container)
      node.children.each do |child|
        case child.name
        when 'p'
          process_paragraph(child, container)
        when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
          process_heading(child, container)
        when 'table'
          process_table(child, container)
        when 'ul', 'ol'
          process_list(child, container)
        when 'br'
          add_line_break(container)
        when 'img'
          process_image(child, container)
        when 'text'
          process_text(child, container) if child.text.strip.length > 0
        else
          # Recursively process unknown elements
          process_node(child, container) if child.element?
        end
      end
    end

    # Process paragraph element
    #
    # @param node [Nokogiri::XML::Node] The paragraph node
    # @param container [Object] The container
    def process_paragraph(node, container)
      para = Paragraph.new

      # Apply paragraph-level styling
      apply_paragraph_style(node, para)

      # Process inline content
      process_inline_content(node, para)

      if container.respond_to?(:add_paragraph)
        container.add_paragraph(para)
      elsif container.respond_to?(:add_element)
        container.add_element(para)
      end
    end

    # Process heading element
    #
    # @param node [Nokogiri::XML::Node] The heading node
    # @param container [Object] The container
    def process_heading(node, container)
      para = Paragraph.new

      # Set heading style
      style_name = HEADING_STYLES[node.name]
      para.set_style(style_name) if style_name

      # Process inline content
      process_inline_content(node, para)

      # Apply bold formatting to heading if no explicit formatting
      if para.runs.all? { |r| !r.bold? }
        para.runs.each do |run|
          run.properties = Properties::RunProperties.new(
            bold: true,
            size: HEADING_SIZES[node.name] || 24
          )
        end
      end

      if container.respond_to?(:add_paragraph)
        container.add_paragraph(para)
      elsif container.respond_to?(:add_element)
        container.add_element(para)
      end
    end

    # Process inline content within a block element
    #
    # @param node [Nokogiri::XML::Node] The node
    # @param para [Paragraph] The paragraph to add runs to
    def process_inline_content(node, para)
      node.children.each do |child|
        case child.name
        when 'text'
          text = child.text
          next if text.strip.empty? && text.length < 2

          para.add_text(text, **base_run_properties)
        when 'b', 'strong'
          process_bold(child, para)
        when 'i', 'em'
          process_italic(child, para)
        when 'u'
          process_underline(child, para)
        when 's', 'strike', 'del'
          process_strike(child, para)
        when 'span'
          process_span(child, para)
        when 'a'
          process_link(child, para)
        when 'br'
          # Add line break run
          para.add_text("\n", **base_run_properties)
        when 'img'
          process_inline_image(child, para)
        else
          # Recursively process
          process_inline_content(child, para)
        end
      end
    end

    # Process bold element
    def process_bold(node, para)
      text = node.text
      return if text.strip.empty?

      para.add_text(text, bold: true, **base_run_properties)
    end

    # Process italic element
    def process_italic(node, para)
      text = node.text
      return if text.strip.empty?

      para.add_text(text, italic: true, **base_run_properties)
    end

    # Process underline element
    def process_underline(node, para)
      text = node.text
      return if text.strip.empty?

      para.add_text(text, underline: 'single', **base_run_properties)
    end

    # Process strike-through element
    def process_strike(node, para)
      text = node.text
      return if text.strip.empty?

      para.add_text(text, strike: true, **base_run_properties)
    end

    # Process span with possible inline styles
    def process_span(node, para)
      style = parse_inline_style(node['style'])
      props = base_run_properties.merge(style)

      node.children.each do |child|
        if child.text?
          text = child.text
          para.add_text(text, **props) unless text.strip.empty?
        else
          process_inline_content(child, para)
        end
      end
    end

    # Process hyperlink
    def process_link(node, para)
      href = node['href']
      text = node.text
      return if text.strip.empty?

      if href.start_with?('#')
        # Internal link (anchor)
        para.add_hyperlink(text, anchor: href[1..-1])
      else
        # External link
        para.add_hyperlink(text, url: href)
      end
    end

    # Process table element
    def process_table(node, container)
      table = Table.new

      node.css('tr').each do |tr|
        row = TableRow.new

        tr.css('td, th').each do |cell_node|
          cell = TableCell.new

          # Process cell content
          cell_node.children.each do |child|
            if child.name == 'p'
              process_paragraph(child, cell)
            elsif child.text?
              para = Paragraph.new
              para.add_text(child.text, **base_run_properties)
              cell.add_paragraph(para)
            end
          end

          row.add_cell(cell)
        end

        table.add_row(row)
      end

      if container.respond_to?(:add_table)
        container.add_table(table)
      elsif container.respond_to?(:add_element)
        container.add_element(table)
      end
    end

    # Process list element
    def process_list(node, container)
      # Simple list processing - convert to paragraphs with bullets/numbers
      is_ordered = node.name == 'ol'

      node.css('li').each_with_index do |li, index|
        para = Paragraph.new

        # Add bullet/number prefix
        prefix = is_ordered ? "#{index + 1}. " : "• "
        para.add_text(prefix, **base_run_properties)

        # Process list item content
        process_inline_content(li, para)

        container.add_paragraph(para) if container.respond_to?(:add_paragraph)
      end
    end

    # Process image element
    def process_image(node, container)
      para = Paragraph.new
      process_inline_image(node, para)
      if container.respond_to?(:add_paragraph)
        container.add_paragraph(para)
      elsif container.respond_to?(:add_element)
        container.add_element(para)
      end
    end

    # Process inline image
    def process_inline_image(node, para)
      src = node['src']
      alt = node['alt']
      width_attr = node['width']
      height_attr = node['height']

      # Convert HTML width/height to EMUs if provided
      # 1 pixel = 9525 EMUs at 96 DPI
      width_emus = width_attr ? width_attr.to_i * 9525 : nil
      height_emus = height_attr ? height_attr.to_i * 9525 : nil

      image = nil

      # Handle base64 images
      if src.start_with?('data:image')
        # Extract base64 data
        match = src.match(/data:image\/\w+;base64,(.+)/)
        if match
          base64_data = match[1]
          image = Image.from_base64(
            base64_data,
            width: width_emus,
            height: height_emus,
            alt_text: alt
          )
        end
      elsif src && !src.start_with?('http')
        # Local file path
        full_path = if @options[:image_dir]
                      File.join(@options[:image_dir], src)
                    else
                      src
                    end

        if File.exist?(full_path)
          # Load image data from file
          image_data = File.binread(full_path)
          image = Image.from_data(
            image_data,
            width: width_emus,
            height: height_emus,
            alt_text: alt,
            title: alt
          )
          image.filename = File.basename(full_path)
        end
      end

      # Add image to paragraph if successfully created
      para.add_run(image) if image
    end

    # Process plain text node
    def process_text(node, container)
      text = node.text.strip
      return if text.empty?

      para = Paragraph.new
      para.add_text(text, **base_run_properties)
      if container.respond_to?(:add_paragraph)
        container.add_paragraph(para)
      elsif container.respond_to?(:add_element)
        container.add_element(para)
      end
    end

    # Add line break
    def add_line_break(container)
      para = Paragraph.new
      para.add_text('', **base_run_properties)
      if container.respond_to?(:add_paragraph)
        container.add_paragraph(para)
      elsif container.respond_to?(:add_element)
        container.add_element(para)
      end
    end

    # Apply paragraph-level styling from HTML
    def apply_paragraph_style(node, para)
      style = parse_inline_style(node['style'])

      # Apply alignment
      if style[:alignment]
        para.properties = Properties::ParagraphProperties.new(
          alignment: style[:alignment]
        )
      end
    end

    # Parse inline CSS style attribute
    def parse_inline_style(style_attr)
      return {} unless style_attr

      props = {}
      style_attr.split(';').each do |decl|
        next if decl.strip.empty?

        key, value = decl.split(':').map(&:strip)
        case key
        when 'color'
          props[:color] = value.sub('#', '')
        when 'font-size'
          props[:size] = parse_font_size(value)
        when 'font-family'
          props[:font] = value.gsub(/["']/, '')
        when 'font-weight'
          props[:bold] = true if value == 'bold' || value.to_i >= 600
        when 'font-style'
          props[:italic] = true if value == 'italic'
        when 'text-decoration'
          props[:underline] = 'single' if value.include?('underline')
          props[:strike] = true if value.include?('line-through')
        when 'text-align'
          props[:alignment] = value
        end
      end

      props
    end

    # Parse font size from CSS value
    def parse_font_size(value)
      if value.end_with?('pt')
        value.to_f * 2  # Convert points to half-points
      elsif value.end_with?('px')
        (value.to_f * 0.75 * 2).to_i  # Convert px to half-points
      else
        @options[:base_size]
      end
    end

    # Get base run properties
    def base_run_properties
      {
        font: @options[:base_font],
        size: @options[:base_size]
      }
    end
  end
end