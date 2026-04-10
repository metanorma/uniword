# frozen_string_literal: true

module Uniword
  module Mhtml
    # Handles Word CSS stylesheet generation.
    #
    # Responsibility: Provide Word-compatible CSS styles for MHTML documents.
    # This includes default Word styles and custom style generation.
    #
    # @example Load default CSS
    #   css = WordCss.default_css
    #
    # @example Generate custom CSS
    #   css = WordCss.generate_style_css(styles_config)
    class WordCss
      # Get the default Word CSS stylesheet.
      #
      # @return [String] The default CSS content
      def self.default_css
        css_path = File.join(__dir__, 'wordstyle.css')
        if File.exist?(css_path)
          File.read(css_path, encoding: 'UTF-8')
        else
          # Fallback to basic CSS if file doesn't exist
          basic_css
        end
      end

      # Generate CSS for custom styles.
      #
      # @param styles_config [StylesConfiguration] The styles configuration
      # @return [String] The generated CSS
      def self.generate_style_css(styles_config)
        return '' unless styles_config

        css_rules = styles_config.styles.map do |style|
          build_style_rule(style)
        end

        css_rules.compact.join("\n")
      end

      # Generate CSS for list numbering.
      #
      # @param numbering_config [NumberingConfiguration] The numbering configuration
      # @return [String] The generated list CSS
      def self.generate_list_css(numbering_config)
        return '' unless numbering_config

        css_rules = numbering_config.instances.map do |instance|
          build_list_rule(instance)
        end

        css_rules.compact.join("\n")
      end

      # Generate CSS for document sections with page layout.
      #
      # @param sections [Array<Section>] The document sections
      # @return [String] The generated section CSS
      def self.generate_section_css(sections)
        return '' unless sections && !sections.empty?

        css_rules = []

        sections.each_with_index do |section, index|
          section_name = "Section#{index + 1}"
          css_rules << build_page_rule(section, section_name)
          css_rules << build_section_div_rule(section_name)
        end

        css_rules.compact.join("\n")
      end

      # Build @page CSS rule for a section.
      #
      # @param section [Section] The section
      # @param section_name [String] The section name
      # @return [String, nil] The CSS @page rule
      def self.build_page_rule(section, section_name)
        properties = section.respond_to?(:properties) ? section.properties : nil
        return nil unless properties

        rules = []

        # Page size
        width = properties.respond_to?(:page_width) && properties.page_width
        height = properties.respond_to?(:page_height) && properties.page_height
        if width && height
          # Convert from twips to inches (1 inch = 1440 twips)
          w_in = CssNumberFormatter.twips_to_in(width, precision: 1)
          h_in = CssNumberFormatter.twips_to_in(height, precision: 1)
          rules << "size: #{w_in} #{h_in}"
        else
          # Default letter size
          rules << 'size: 8.5in 11in'
        end

        # Margins
        if properties.respond_to?(:margin_top) && properties.margin_top
          rules << "margin-top: #{CssNumberFormatter.twips_to_in(properties.margin_top)}"
        end
        if properties.respond_to?(:margin_bottom) && properties.margin_bottom
          rules << "margin-bottom: #{CssNumberFormatter.twips_to_in(properties.margin_bottom)}"
        end
        if properties.respond_to?(:margin_left) && properties.margin_left
          rules << "margin-left: #{CssNumberFormatter.twips_to_in(properties.margin_left)}"
        end
        if properties.respond_to?(:margin_right) && properties.margin_right
          rules << "margin-right: #{CssNumberFormatter.twips_to_in(properties.margin_right)}"
        end

        # Header/Footer margins
        if properties.respond_to?(:header_margin) && properties.header_margin
          rules << "mso-header-margin: #{CssNumberFormatter.twips_to_in(properties.header_margin)}"
        end
        if properties.respond_to?(:footer_margin) && properties.footer_margin
          rules << "mso-footer-margin: #{CssNumberFormatter.twips_to_in(properties.footer_margin)}"
        end

        "@page #{section_name} {\n  #{rules.join(";\n  ")};\n}"
      end

      # Build div.Section CSS rule.
      #
      # @param section_name [String] The section name
      # @return [String] The CSS div rule
      def self.build_section_div_rule(section_name)
        "div.Word#{section_name} {\n  page: #{section_name};\n}"
      end

      # Build a CSS rule for a style.
      #
      # @param style [Style] The style
      # @return [String, nil] The CSS rule or nil
      def self.build_style_rule(style)
        return nil unless style

        properties = []

        # Font properties
        properties << "font-family: '#{style.font}'" if style.respond_to?(:font) && style.font
        if style.respond_to?(:font_size) && style.font_size
          properties << "font-size: #{CssNumberFormatter.format(style.font_size, 'pt',
                                                                precision: 1)}"
        end
        properties << 'font-weight: bold' if style.respond_to?(:bold) && style.bold
        properties << 'font-style: italic' if style.respond_to?(:italic) && style.italic

        # Paragraph properties
        if style.respond_to?(:alignment) && style.alignment
          properties << "text-align: #{style.alignment}"
        end

        return nil if properties.empty?

        selector = ".#{style.style_id}"
        "#{selector} {\n  #{properties.join(";\n  ")};\n}"
      end

      # Build a CSS rule for list numbering.
      #
      # @param instance [NumberingInstance] The numbering instance
      # @return [String, nil] The CSS rule or nil
      def self.build_list_rule(instance)
        return nil unless instance

        # Generate @list rule for Word
        "@list l#{instance.num_id} {\n  mso-list-id: #{instance.num_id};\n}"
      end

      # Get basic fallback CSS.
      #
      # @return [String] Basic CSS styles
      def self.basic_css
        <<~CSS
          /* Basic Word styles */
          p.MsoNormal, li.MsoNormal, div.MsoNormal {
            margin: 0;
            margin-bottom: .0001pt;
            font-size: 11pt;
            font-family: "Calibri", sans-serif;
          }
          h1 {
            margin-top: 12pt;
            margin-bottom: 0;
            page-break-after: avoid;
            font-size: 16pt;
            font-family: "Calibri Light", sans-serif;
            font-weight: normal;
          }
          h2 {
            margin-top: 10pt;
            margin-bottom: 0;
            page-break-after: avoid;
            font-size: 13pt;
            font-family: "Calibri Light", sans-serif;
            font-weight: normal;
          }
          h3 {
            margin-top: 10pt;
            margin-bottom: 0;
            page-break-after: avoid;
            font-size: 12pt;
            font-family: "Calibri Light", sans-serif;
            font-weight: normal;
          }
          table.MsoNormalTable {
            font-size: 11pt;
            font-family: "Calibri", sans-serif;
          }
          a:link, span.MsoHyperlink {
            color: blue;
            text-decoration: underline;
          }
        CSS
      end
    end
  end
end
