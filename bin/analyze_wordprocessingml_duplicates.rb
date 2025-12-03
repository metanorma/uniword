#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

# Analyze critical WordProcessingML namespace duplicates
# Focus on elements that appear in BOTH:
# - lib/uniword/properties/
# - lib/uniword/wordprocessingml/

class WordProcessingMLDuplicateAnalyzer
  PROPERTIES_DIR = 'lib/uniword/properties'
  WORDML_DIR = 'lib/uniword/wordprocessingml'
  
  def initialize(base_dir)
    @base_dir = Pathname.new(base_dir)
  end

  def analyze
    puts "=" * 80
    puts "WORDPROCESSINGML DUPLICATE ANALYSIS"
    puts "=" * 80
    puts
    
    # Get all elements from properties dir
    properties_elements = scan_directory(@base_dir / PROPERTIES_DIR)
    
    # Get all elements from wordprocessingml dir
    wordml_elements = scan_directory(@base_dir / WORDML_DIR)
    
    # Find overlaps
    overlapping = properties_elements.keys & wordml_elements.keys
    
    if overlapping.empty?
      puts "✅ No overlapping elements found!"
      return
    end
    
    puts "Found #{overlapping.size} overlapping element(s):"
    puts
    
    overlapping.sort.each do |element|
      analyze_duplicate(element, properties_elements[element], wordml_elements[element])
    end
    
    puts
    puts "=" * 80
    puts "MERGE RECOMMENDATIONS"
    puts "=" * 80
    puts
    
    overlapping.sort.each do |element|
      props_file = properties_elements[element]
      wordml_file = wordml_elements[element]
      
      puts "Element: <#{element}>"
      puts "  Properties: #{props_file[:rel_path]}"
      puts "  WordML:     #{wordml_file[:rel_path]}"
      
      # Analyze which is better
      recommendation = determine_correct_version(props_file, wordml_file)
      puts "  ✅ KEEP: #{recommendation[:keep]}"
      puts "  ❌ DELETE: #{recommendation[:delete]}"
      puts "  📝 REASON: #{recommendation[:reason]}"
      puts
    end
  end

  private

  def scan_directory(dir)
    elements = {}
    
    dir.glob('**/*.rb').each do |file|
      next if file.basename.to_s.start_with?('.')
      
      content = file.read
      rel_path = file.relative_path_from(@base_dir)
      
      # Find element declarations
      content.scan(/element\s+['"](\w+)['"]/) do |match|
        element_name = match[0]
        next if element_name == 'root'
        
        # Extract more info
        class_name = extract_class_name(content)
        uses_wrappers = content.include?('map_element') && !content.include?('map_attribute')
        has_invalid_mappings = has_duplicate_attribute_mappings?(content)
        
        elements[element_name] = {
          file: file,
          rel_path: rel_path.to_s,
          class: class_name,
          uses_wrappers: uses_wrappers,
          invalid: has_invalid_mappings,
          lines: content.lines.count
        }
      end
    end
    
    elements
  end

  def extract_class_name(content)
    if content =~ /class\s+(\w+)/
      $1
    else
      'Unknown'
    end
  end

  def has_duplicate_attribute_mappings?(content)
    # Check for multiple map_attribute with same name
    attribute_mappings = content.scan(/map_attribute\s+['"](\w+)['"]/)
    attribute_mappings.size != attribute_mappings.uniq.size
  end

  def analyze_duplicate(element, props_info, wordml_info)
    puts "-" * 80
    puts "Element: <#{element}>"
    puts
    
    puts "  Properties version:"
    puts "    Path:     #{props_info[:rel_path]}"
    puts "    Class:    #{props_info[:class]}"
    puts "    Lines:    #{props_info[:lines]}"
    puts "    Wrappers: #{props_info[:uses_wrappers]}"
    puts "    Invalid:  #{props_info[:invalid]}"
    puts
    
    puts "  WordML version:"
    puts "    Path:     #{wordml_info[:rel_path]}"
    puts "    Class:    #{wordml_info[:class]}"
    puts "    Lines:    #{wordml_info[:lines]}"
    puts "    Wrappers: #{wordml_info[:uses_wrappers]}"
    puts "    Invalid:  #{wordml_info[:invalid]}"
    puts
  end

  def determine_correct_version(props_file, wordml_file)
    # Decision criteria (in order of priority):
    # 1. If one has invalid mappings, choose the other
    # 2. If one uses wrappers (proper OO), prefer it
    # 3. If one is longer/more complete, prefer it
    
    if wordml_file[:invalid] && !props_file[:invalid]
      return {
        keep: props_file[:rel_path],
        delete: wordml_file[:rel_path],
        reason: "WordML version has duplicate attribute mappings (invalid XML)"
      }
    end
    
    if props_file[:invalid] && !wordml_file[:invalid]
      return {
        keep: wordml_file[:rel_path],
        delete: props_file[:rel_path],
        reason: "Properties version has duplicate attribute mappings (invalid XML)"
      }
    end
    
    if props_file[:uses_wrappers] && !wordml_file[:uses_wrappers]
      return {
        keep: props_file[:rel_path],
        delete: wordml_file[:rel_path],
        reason: "Properties version uses proper wrapper objects (better OO design)"
      }
    end
    
    if wordml_file[:uses_wrappers] && !props_file[:uses_wrappers]
      return {
        keep: wordml_file[:rel_path],
        delete: props_file[:rel_path],
        reason: "WordML version uses proper wrapper objects (better OO design)"
      }
    end
    
    if props_file[:lines] > wordml_file[:lines] * 1.5
      return {
        keep: props_file[:rel_path],
        delete: wordml_file[:rel_path],
        reason: "Properties version is more complete (#{props_file[:lines]} vs #{wordml_file[:lines]} lines)"
      }
    end
    
    if wordml_file[:lines] > props_file[:lines] * 1.5
      return {
        keep: wordml_file[:rel_path],
        delete: props_file[:rel_path],
        reason: "WordML version is more complete (#{wordml_file[:lines]} vs #{props_file[:lines]} lines)"
      }
    end
    
    # Default: prefer properties version (more likely to be the refactored one)
    {
      keep: props_file[:rel_path],
      delete: wordml_file[:rel_path],
      reason: "Properties version preferred by convention (both seem equivalent)"
    }
  end
end

if __FILE__ == $0
  base_dir = File.expand_path('..', __dir__)
  analyzer = WordProcessingMLDuplicateAnalyzer.new(base_dir)
  analyzer.analyze
end