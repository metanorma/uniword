#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zip'
require 'nokogiri'
require 'fileutils'

class StyleDocumentAnalyzer
  def initialize(broken_path, fixed_path)
    @broken_path = broken_path
    @fixed_path = fixed_path
  end

  def analyze
    puts '=' * 80
    puts 'WORD DOCUMENT STYLE ANALYSIS'
    puts '=' * 80
    puts

    # Extract both documents
    puts 'Extracting broken document...'
    broken_styles = extract_styles(@broken_path)

    puts 'Extracting fixed document...'
    fixed_styles = extract_styles(@fixed_path)

    puts
    puts '=' * 80
    puts 'COMPARISON RESULTS'
    puts '=' * 80
    puts

    # Compare styles
    compare_styles(broken_styles, fixed_styles)
  end

  private

  def extract_styles(docx_path)
    styles = {}

    Zip::File.open(docx_path) do |zip_file|
      entry = zip_file.find_entry('word/styles.xml')
      if entry
        content = entry.get_input_stream.read
        doc = Nokogiri::XML(content)

        # Save raw XML for inspection
        basename = File.basename(docx_path, '.docx')
        output_path = "#{basename}_styles.xml"
        File.write(output_path, doc.to_xml)
        puts "  Saved styles.xml to: #{output_path}"

        # Parse styles
        doc.xpath('//w:style',
                  'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main').each do |style_node|
          style_id = style_node['w:styleId']
          style_type = style_node['w:type']

          name_node = style_node.at_xpath('.//w:name', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
          name = name_node ? name_node['w:val'] : nil

          styles[style_id] = {
            type: style_type,
            name: name,
            raw_node: style_node
          }
        end
      end
    end

    styles
  end

  def compare_styles(broken, fixed)
    puts "Broken document has #{broken.size} styles"
    puts "Fixed document has #{fixed.size} styles"
    puts

    # Show styles that exist in both
    puts '-' * 80
    puts 'STYLES IN BOTH DOCUMENTS'
    puts '-' * 80

    both = broken.keys & fixed.keys
    both.sort.each do |style_id|
      broken_name = broken[style_id][:name]
      fixed_name = fixed[style_id][:name]

      if broken_name == fixed_name
        puts "✓  #{style_id}: name='#{broken_name}'"
      else
        puts "⚠️  #{style_id}:"
        puts "    Broken: name='#{broken_name}'"
        puts "    Fixed:  name='#{fixed_name}'"
      end
    end
    puts

    # Show styles only in broken
    only_broken = broken.keys - fixed.keys
    if only_broken.any?
      puts '-' * 80
      puts "STYLES ONLY IN BROKEN (#{only_broken.size})"
      puts '-' * 80
      only_broken.sort.each do |style_id|
        puts "  #{style_id}: name='#{broken[style_id][:name]}', type='#{broken[style_id][:type]}'"
      end
      puts
    end

    # Show styles only in fixed
    only_fixed = fixed.keys - broken.keys
    if only_fixed.any?
      puts '-' * 80
      puts "STYLES ONLY IN FIXED (#{only_fixed.size})"
      puts '-' * 80
      only_fixed.sort.each do |style_id|
        puts "  #{style_id}: name='#{fixed[style_id][:name]}', type='#{fixed[style_id][:type]}'"
      end
      puts
    end

    # Detailed comparison of key styles
    puts '-' * 80
    puts 'DETAILED COMPARISON OF KEY STYLES'
    puts '-' * 80

    %w[Title Subtitle Heading1 Heading2 Normal].each do |style_id|
      puts
      puts "Style ID: #{style_id}"
      if broken[style_id]
        puts '  BROKEN:'
        puts "    Name: #{broken[style_id][:name]}"
        puts "    Type: #{broken[style_id][:type]}"
        puts '    XML Preview:'
        puts broken[style_id][:raw_node].to_xml.lines.first(5).map { |l| "      #{l}" }.join
      else
        puts '  BROKEN: Not found'
      end

      if fixed[style_id]
        puts '  FIXED:'
        puts "    Name: #{fixed[style_id][:name]}"
        puts "    Type: #{fixed[style_id][:type]}"
        puts '    XML Preview:'
        puts fixed[style_id][:raw_node].to_xml.lines.first(5).map { |l| "      #{l}" }.join
      else
        puts '  FIXED: Not found'
      end
    end
  end
end

# Run analysis
broken_path = 'examples/demo_formal_integral.docx'
fixed_path = 'examples/demo_formal_integral_fixed.docx'

if File.exist?(broken_path) && File.exist?(fixed_path)
  analyzer = StyleDocumentAnalyzer.new(broken_path, fixed_path)
  analyzer.analyze
else
  puts 'Error: Required files not found'
  puts "  Broken: #{broken_path} - #{File.exist?(broken_path) ? 'Found' : 'Missing'}"
  puts "  Fixed:  #{fixed_path} - #{File.exist?(fixed_path) ? 'Found' : 'Missing'}"
  exit 1
end
