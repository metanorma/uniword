#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

# Script to find duplicate class definitions in the codebase
# Searches for lutaml-model classes with the same XML element name

class DuplicateFinder
  def initialize(base_dir)
    @base_dir = Pathname.new(base_dir)
    @element_map = Hash.new { |h, k| h[k] = [] }
  end

  def scan
    lib_dir = @base_dir / 'lib'
    
    lib_dir.glob('**/*.rb').each do |file|
      next if file.basename.to_s.start_with?('.')
      
      analyze_file(file)
    end
    
    report_duplicates
  end

  private

  def analyze_file(file)
    content = file.read
    relative_path = file.relative_path_from(@base_dir)
    
    # Extract class/module hierarchy
    class_stack = []
    namespace_stack = []
    current_namespace = nil
    
    content.each_line.with_index do |line, idx|
      line_num = idx + 1
      
      # Track module/class definitions
      if line =~ /^\s*module\s+(\w+)/
        namespace_stack << $1
      elsif line =~ /^\s*class\s+(\w+)/
        class_stack << $1
      elsif line =~ /^\s*end\s*$/
        if class_stack.any?
          class_stack.pop
        elsif namespace_stack.any?
          namespace_stack.pop
        end
      end
      
      # Look for xml namespace declarations
      if line =~ /namespace\s+['"](.*?)['"]/
        ns_uri = $1
        current_namespace = namespace_from_uri(ns_uri)
      end
      
      # Look for element declarations
      if line =~ /element\s+['"](\w+)['"]/
        element_name = $1
        next if element_name == 'root' # Skip root declarations
        
        full_class = (namespace_stack + class_stack).join('::')
        
        @element_map[element_name] << {
          file: relative_path.to_s,
          line: line_num,
          class: full_class,
          namespace: current_namespace
        }
      end
    end
  end

  def namespace_from_uri(uri)
    case uri
    when /wordprocessingml/i
      'WordProcessingML'
    when /drawingml/i
      'DrawingML'
    when /relationships/i
      'Relationships'
    when /mathml/i
      'MathML'
    when /extendedproperties/i
      'ExtendedProperties'
    when /customproperties/i
      'CustomProperties'
    when /coreproperties/i
      'CoreProperties'
    else
      'Unknown'
    end
  end

  def report_duplicates
    puts "=" * 80
    puts "DUPLICATE CLASS FINDER REPORT"
    puts "=" * 80
    puts
    
    duplicates = @element_map.select { |_elem, files| files.size > 1 }
    
    if duplicates.empty?
      puts "No duplicates found!"
      return
    end
    
    puts "Found #{duplicates.size} duplicate element(s):"
    puts
    
    duplicates.each do |element_name, occurrences|
      puts "-" * 80
      puts "Element: <#{element_name}>"
      puts
      
      # Group by namespace
      by_namespace = occurrences.group_by { |occ| occ[:namespace] }
      
      by_namespace.each do |ns, files|
        puts "  Namespace: #{ns}"
        files.each do |file_info|
          puts "    - #{file_info[:file]}:#{file_info[:line]}"
          puts "      Class: #{file_info[:class]}"
        end
        puts
      end
      
      # Flag if multiple files in SAME namespace
      same_namespace_dupes = by_namespace.select { |_ns, files| files.size > 1 }
      if same_namespace_dupes.any?
        puts "  ⚠️  WARNING: Multiple definitions in SAME namespace!"
        same_namespace_dupes.each do |ns, files|
          puts "    Namespace: #{ns}"
          files.each { |f| puts "      - #{f[:file]}" }
        end
        puts
      end
    end
    
    puts "=" * 80
    puts "SUMMARY"
    puts "=" * 80
    
    total_dupes = duplicates.values.flatten.size
    critical_dupes = duplicates.select do |_elem, occs|
      occs.group_by { |o| o[:namespace] }.any? { |_ns, files| files.size > 1 }
    end
    
    puts "Total elements with duplicates: #{duplicates.size}"
    puts "Total duplicate files: #{total_dupes}"
    puts "Critical duplicates (same namespace): #{critical_dupes.size}"
    puts
    
    if critical_dupes.any?
      puts "CRITICAL DUPLICATES TO FIX:"
      critical_dupes.each do |elem, occs|
        puts "  - <#{elem}>"
        occs.group_by { |o| o[:namespace] }.select { |_ns, f| f.size > 1 }.each do |ns, files|
          puts "    Namespace: #{ns}"
          files.each { |f| puts "      • #{f[:file]}" }
        end
      end
    end
  end
end

if __FILE__ == $0
  base_dir = File.expand_path('..', __dir__)
  finder = DuplicateFinder.new(base_dir)
  finder.scan
end