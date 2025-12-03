#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zip'
require 'nokogiri'
require 'fileutils'

class StyleComparisonAnalyzer
  NAMESPACES = {
    'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'r' => 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
  }.freeze

  def initialize
    @broken_doc = 'examples/demo_formal_integral.docx'
    @proper_doc = 'examples/demo_formal_integral_proper.docx'
    @styleset_doc = 'references/word-package/style-sets/Formal.dotx'
  end

  def analyze
    puts '=' * 80
    puts 'WORD DOCUMENT STYLE COMPARISON ANALYSIS'
    puts '=' * 80
    puts

    # Analyze each document
    analyze_document('BROKEN (Generated)', @broken_doc)
    puts "\n#{'=' * 80}\n"

    analyze_document('PROPER (Reference)', @proper_doc)
    puts "\n#{'=' * 80}\n"

    analyze_document('STYLESET (Formal.dotx)', @styleset_doc)
    puts "\n#{'=' * 80}\n"

    # Compare styles
    compare_styles
  end

  private

  def analyze_document(label, filepath)
    puts "#{label}: #{filepath}"
    puts '-' * 80

    unless File.exist?(filepath)
      puts 'ERROR: File not found!'
      return
    end

    Zip::File.open(filepath) do |zip|
      # 1. Extract and analyze styles
      analyze_styles(label, zip)
      puts

      # 2. Extract and analyze paragraphs
      analyze_paragraphs(label, zip)
      puts

      # 3. Extract and analyze theme
      analyze_theme(label, zip)
    end
  end

  def analyze_styles(_label, zip)
    puts "\n### STYLES (word/styles.xml) ###"

    styles_entry = zip.find_entry('word/styles.xml')
    unless styles_entry
      puts 'No styles.xml found'
      return
    end

    xml = Nokogiri::XML(styles_entry.get_input_stream.read)
    styles = xml.xpath('//w:style', NAMESPACES)

    puts "Total styles: #{styles.count}"
    puts

    # Group styles by type
    by_type = styles.group_by { |s| s['w:type'] }

    by_type.each do |type, type_styles|
      puts "--- #{type.upcase} STYLES (#{type_styles.count}) ---"

      type_styles.each do |style|
        style_id = style['w:styleId']
        next if style_id.nil?

        name_node = style.at_xpath('w:name', NAMESPACES)
        name = name_node ? name_node['w:val'] : 'N/A'

        based_on_node = style.at_xpath('w:basedOn', NAMESPACES)
        based_on = based_on_node ? based_on_node['w:val'] : 'none'

        puts "  Style ID: #{style_id}"
        puts "    Name: #{name}"
        puts "    Based On: #{based_on}"

        # Get key properties
        ppr = style.at_xpath('w:pPr', NAMESPACES)
        if ppr
          # Alignment
          jc = ppr.at_xpath('w:jc', NAMESPACES)
          puts "    Alignment: #{jc['w:val']}" if jc

          # Spacing
          spacing = ppr.at_xpath('w:spacing', NAMESPACES)
          if spacing
            puts "    Spacing Before: #{spacing['w:before']}" if spacing['w:before']
            puts "    Spacing After: #{spacing['w:after']}" if spacing['w:after']
            puts "    Line Spacing: #{spacing['w:line']}" if spacing['w:line']
          end
        end

        rpr = style.at_xpath('w:rPr', NAMESPACES)
        if rpr
          # Font
          fonts = rpr.at_xpath('w:rFonts', NAMESPACES)
          puts "    Font (ASCII): #{fonts['w:ascii']}" if fonts && fonts['w:ascii']

          # Size
          sz = rpr.at_xpath('w:sz', NAMESPACES)
          puts "    Font Size: #{sz['w:val']}" if sz

          # Color
          color = rpr.at_xpath('w:color', NAMESPACES)
          puts "    Color: #{color['w:val']}" if color

          # Bold
          bold = rpr.at_xpath('w:b', NAMESPACES)
          puts '    Bold: yes' if bold

          # Italic
          italic = rpr.at_xpath('w:i', NAMESPACES)
          puts '    Italic: yes' if italic
        end

        puts
      end
    end

    # Check for specific styles we care about
    puts "\n--- KEY STYLES CHECK ---"
    %w[Title Subtitle Date Heading1 Heading2 Normal].each do |style_name|
      style = styles.find { |s| s['w:styleId'] == style_name }
      if style
        puts "  ✓ #{style_name} found"
      else
        puts "  ✗ #{style_name} MISSING"
      end
    end
  end

  def analyze_paragraphs(_label, zip)
    puts "\n### PARAGRAPHS (word/document.xml) ###"

    doc_entry = zip.find_entry('word/document.xml')
    unless doc_entry
      puts 'No document.xml found'
      return
    end

    xml = Nokogiri::XML(doc_entry.get_input_stream.read)
    paragraphs = xml.xpath('//w:p', NAMESPACES)

    puts "Total paragraphs: #{paragraphs.count}"
    puts "\nFirst 10 paragraphs:"
    puts

    paragraphs.first(10).each_with_index do |para, idx|
      puts "--- Paragraph #{idx + 1} ---"

      # Get text content
      text = para.xpath('.//w:t', NAMESPACES).map(&:text).join
      puts "  Text: #{text.empty? ? '(empty)' : text[0..60]}#{'...' if text.length > 60}"

      # Get style reference
      ppr = para.at_xpath('w:pPr', NAMESPACES)
      if ppr
        pstyle = ppr.at_xpath('w:pStyle', NAMESPACES)
        if pstyle
          puts "  Style: #{pstyle['w:val']}"
        else
          puts '  Style: (none - using Normal)'
        end

        # Check for direct formatting
        jc = ppr.at_xpath('w:jc', NAMESPACES)
        puts "  Direct Alignment: #{jc['w:val']}" if jc

        spacing = ppr.at_xpath('w:spacing', NAMESPACES)
        if spacing
          puts "  Direct Spacing Before: #{spacing['w:before']}" if spacing['w:before']
          puts "  Direct Spacing After: #{spacing['w:after']}" if spacing['w:after']
        end
      else
        puts '  Style: (none - using Normal)'
      end

      # Check run properties
      runs = para.xpath('w:r', NAMESPACES)
      runs.each_with_index do |run, ridx|
        rpr = run.at_xpath('w:rPr', NAMESPACES)
        next unless rpr

        puts "  Run #{ridx + 1} formatting:"

        sz = rpr.at_xpath('w:sz', NAMESPACES)
        puts "    Font Size: #{sz['w:val']}" if sz

        bold = rpr.at_xpath('w:b', NAMESPACES)
        puts '    Bold: yes' if bold

        italic = rpr.at_xpath('w:i', NAMESPACES)
        puts '    Italic: yes' if italic

        color = rpr.at_xpath('w:color', NAMESPACES)
        puts "    Color: #{color['w:val']}" if color
      end

      puts
    end
  end

  def analyze_theme(_label, zip)
    puts "\n### THEME (word/theme/theme1.xml) ###"

    theme_entry = zip.find_entry('word/theme/theme1.xml')
    unless theme_entry
      puts 'No theme1.xml found'
      return
    end

    xml = Nokogiri::XML(theme_entry.get_input_stream.read)

    # Theme name
    theme_node = xml.at_xpath('//a:theme', NAMESPACES)
    puts "Theme Name: #{theme_node['name']}" if theme_node

    # Color scheme
    color_scheme = xml.at_xpath('//a:clrScheme', NAMESPACES)
    if color_scheme
      puts "\nColor Scheme: #{color_scheme['name']}"

      # Major colors
      %w[dk1 lt1 dk2 lt2 accent1 accent2 accent3 accent4 accent5 accent6 hlink
         folHlink].each do |color_name|
        color_node = color_scheme.at_xpath("a:#{color_name}", NAMESPACES)
        next unless color_node

        # Get color value
        srgb = color_node.at_xpath('.//a:srgbClr', NAMESPACES)
        sys = color_node.at_xpath('.//a:sysClr', NAMESPACES)

        if srgb
          puts "  #{color_name}: ##{srgb['val']}"
        elsif sys
          puts "  #{color_name}: #{sys['val']} (last=##{sys['lastClr']})"
        end
      end
    end

    # Font scheme
    font_scheme = xml.at_xpath('//a:fontScheme', NAMESPACES)
    return unless font_scheme

    puts "\nFont Scheme: #{font_scheme['name']}"

    major_font = font_scheme.at_xpath('a:majorFont/a:latin', NAMESPACES)
    minor_font = font_scheme.at_xpath('a:minorFont/a:latin', NAMESPACES)

    puts "  Major Font: #{major_font['typeface']}" if major_font
    puts "  Minor Font: #{minor_font['typeface']}" if minor_font
  end

  def compare_styles
    puts 'COMPARISON SUMMARY'
    puts '=' * 80
    puts

    # Load all three documents
    broken_styles = load_styles(@broken_doc)
    proper_styles = load_styles(@proper_doc)
    styleset_styles = load_styles(@styleset_doc)

    puts '### Style Count Comparison ###'
    puts "Broken:   #{broken_styles.keys.count} styles"
    puts "Proper:   #{proper_styles.keys.count} styles"
    puts "StyleSet: #{styleset_styles.keys.count} styles"
    puts

    puts '### Styles in Proper but missing in Broken ###'
    missing = proper_styles.keys - broken_styles.keys
    if missing.empty?
      puts '(none)'
    else
      missing.each { |s| puts "  - #{s}" }
    end
    puts

    puts '### Styles in Broken but missing in Proper ###'
    extra = broken_styles.keys - proper_styles.keys
    if extra.empty?
      puts '(none)'
    else
      extra.each { |s| puts "  - #{s}" }
    end
    puts

    puts '### Styles in StyleSet but missing in Broken ###'
    missing_from_styleset = styleset_styles.keys - broken_styles.keys
    if missing_from_styleset.empty?
      puts '(none)'
    else
      missing_from_styleset.each { |s| puts "  - #{s}" }
    end
    puts

    # Detailed comparison for key styles
    puts '### Detailed Comparison for Key Styles ###'
    %w[Title Subtitle Date Heading1 Normal].each do |style_id|
      puts "\n--- #{style_id} ---"

      broken = broken_styles[style_id]
      proper = proper_styles[style_id]
      styleset = styleset_styles[style_id]

      puts "Broken:   #{broken ? 'EXISTS' : 'MISSING'}"
      puts "Proper:   #{proper ? 'EXISTS' : 'MISSING'}"
      puts "StyleSet: #{styleset ? 'EXISTS' : 'MISSING'}"

      compare_style_details(style_id, broken, proper) if broken && proper
    end
  end

  def load_styles(filepath)
    return {} unless File.exist?(filepath)

    styles = {}
    Zip::File.open(filepath) do |zip|
      styles_entry = zip.find_entry('word/styles.xml')
      return {} unless styles_entry

      xml = Nokogiri::XML(styles_entry.get_input_stream.read)
      xml.xpath('//w:style', NAMESPACES).each do |style|
        style_id = style['w:styleId']
        styles[style_id] = style if style_id
      end
    end
    styles
  end

  def compare_style_details(_style_id, broken, proper)
    puts "\nProperty Differences:"

    # Compare name
    broken_name = broken.at_xpath('w:name', NAMESPACES)&.[]('w:val')
    proper_name = proper.at_xpath('w:name', NAMESPACES)&.[]('w:val')
    puts "  Name: '#{broken_name}' vs '#{proper_name}'" if broken_name != proper_name

    # Compare basedOn
    broken_base = broken.at_xpath('w:basedOn', NAMESPACES)&.[]('w:val')
    proper_base = proper.at_xpath('w:basedOn', NAMESPACES)&.[]('w:val')
    puts "  BasedOn: '#{broken_base}' vs '#{proper_base}'" if broken_base != proper_base

    # Compare font size
    broken_sz = broken.at_xpath('.//w:rPr/w:sz', NAMESPACES)&.[]('w:val')
    proper_sz = proper.at_xpath('.//w:rPr/w:sz', NAMESPACES)&.[]('w:val')
    puts "  Font Size: '#{broken_sz}' vs '#{proper_sz}'" if broken_sz != proper_sz

    # Compare alignment
    broken_jc = broken.at_xpath('.//w:pPr/w:jc', NAMESPACES)&.[]('w:val')
    proper_jc = proper.at_xpath('.//w:pPr/w:jc', NAMESPACES)&.[]('w:val')
    return unless broken_jc != proper_jc

    puts "  Alignment: '#{broken_jc}' vs '#{proper_jc}'"
  end
end

# Run the analysis
analyzer = StyleComparisonAnalyzer.new
analyzer.analyze
