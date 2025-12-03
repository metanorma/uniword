#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

# Find invalid XML attribute mappings in lutaml-model classes:
# 1. Multiple map_attribute to same XML attribute name (impossible!)
# 2. map_element with nested map_attribute (should be wrapper class)

class InvalidMappingFinder
  def initialize(base_dir)
    @base_dir = Pathname.new(base_dir)
    @issues = {
      duplicate_attributes: [],
      nested_mappings: []
    }
  end

  def scan
    puts "=" * 80
    puts "INVALID ATTRIBUTE MAPPING FINDER"
    puts "=" * 80
    puts
    
    lib_dir = @base_dir / 'lib'
    
    lib_dir.glob('**/*.rb').each do |file|
      next if file.basename.to_s.start_with?('.')
      
      analyze_file(file)
    end
    
    report_issues
  end

  private

  def analyze_file(file)
    content = file.read
    rel_path = file.relative_path_from(@base_dir)
    
    # Check for duplicate map_attribute declarations
    check_duplicate_attributes(content, rel_path)
    
    # Check for nested map_attribute inside map_element
    check_nested_mappings(content, rel_path)
  end

  def check_duplicate_attributes(content, rel_path)
    # Extract all map_attribute calls
    attribute_mappings = {}
    
    content.scan(/map_attribute\s+['"](\w+)['"]\s*,\s*to:\s*:(\w+)/) do |xml_attr, ruby_attr|
      attribute_mappings[xml_attr] ||= []
      attribute_mappings[xml_attr] << ruby_attr
    end
    
    # Find duplicates
    duplicates = attribute_mappings.select { |_xml, rubys| rubys.size > 1 }
    
    if duplicates.any?
      @issues[:duplicate_attributes] << {
        file: rel_path.to_s,
        duplicates: duplicates
      }
    end
  end

  def check_nested_mappings(content, rel_path)
    # Find map_element with do...end blocks containing map_attribute
    nested_patterns = []
    
    lines = content.lines
    in_xml_block = false
    in_map_element_block = false
    current_element = nil
    block_start = nil
    
    lines.each_with_index do |line, idx|
      line_num = idx + 1
      
      # Track xml do block
      if line =~ /^\s*xml\s+do/
        in_xml_block = true
      elsif in_xml_block && line =~ /^\s*end\s*$/
        in_xml_block = false
        in_map_element_block = false
        current_element = nil
      end
      
      next unless in_xml_block
      
      # Check for map_element with block
      if line =~ /map_element\s+['"](\w+)['"]\s*,.*do/
        in_map_element_block = true
        current_element = $1
        block_start = line_num
      elsif in_map_element_block && line =~ /^\s*end/
        in_map_element_block = false
        current_element = nil
      end
      
      # Check for map_attribute inside map_element block
      if in_map_element_block && line =~ /map_attribute\s+['"](\w+)['"]/
        xml_attr = $1
        nested_patterns << {
          element: current_element,
          attribute: xml_attr,
          line: line_num
        }
      end
    end
    
    if nested_patterns.any?
      @issues[:nested_mappings] << {
        file: rel_path.to_s,
        patterns: nested_patterns
      }
    end
  end

  def report_issues
    puts "FINDING RESULTS"
    puts "=" * 80
    puts
    
    # Report duplicate attributes
    if @issues[:duplicate_attributes].any?
      puts "❌ ISSUE 1: DUPLICATE ATTRIBUTE MAPPINGS"
      puts "   (Multiple Ruby attributes mapped to same XML attribute - IMPOSSIBLE!)"
      puts
      
      @issues[:duplicate_attributes].each do |issue|
        puts "File: #{issue[:file]}"
        issue[:duplicates].each do |xml_attr, ruby_attrs|
          puts "  XML attribute '#{xml_attr}' mapped to:"
          ruby_attrs.each { |r| puts "    - :#{r}" }
        end
        puts
      end
    else
      puts "✅ No duplicate attribute mappings found"
      puts
    end
    
    # Report nested mappings
    if @issues[:nested_mappings].any?
      puts "❌ ISSUE 2: NESTED ATTRIBUTE MAPPINGS"
      puts "   (map_attribute inside map_element - should use wrapper class)"
      puts
      
      @issues[:nested_mappings].each do |issue|
        puts "File: #{issue[:file]}"
        issue[:patterns].each do |pattern|
          puts "  Line #{pattern[:line]}: Element <#{pattern[:element]}> with attribute '#{pattern[:attribute]}'"
          puts "    SHOULD BE: Create wrapper class for <#{pattern[:element]}>"
        end
        puts
      end
    else
      puts "✅ No nested attribute mappings found"
      puts
    end
    
    # Summary
    puts "=" * 80
    puts "SUMMARY"
    puts "=" * 80
    puts
    
    dup_count = @issues[:duplicate_attributes].size
    nested_count = @issues[:nested_mappings].size
    total_files = dup_count + nested_count
    
    if total_files == 0
      puts "✅ All attribute mappings are valid!"
    else
      puts "Found #{total_files} file(s) with invalid mappings:"
      puts "  - #{dup_count} file(s) with duplicate attribute mappings"
      puts "  - #{nested_count} file(s) with nested attribute mappings"
      puts
      puts "These MUST be fixed for proper XML serialization!"
    end
  end
end

if __FILE__ == $0
  base_dir = File.expand_path('..', __dir__)
  finder = InvalidMappingFinder.new(base_dir)
  finder.scan
end