#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'fileutils'

# Fix references in wordprocessingml directory to use new Ooxml::WordProcessingML namespace

class WordProcessingMLFixer
  def initialize(base_dir)
    @base_dir = Pathname.new(base_dir)
    @updated = []
  end

  def fix_all
    puts "=" * 80
    puts "FIXING WORDPROCESSINGML REFERENCES"
    puts "=" * 80
    puts
    
    wordml_dir = @base_dir / 'lib/uniword/wordprocessingml'
    
    wordml_dir.glob('*.rb').each do |file|
      next if ['paragraph_properties.rb', 'run_properties.rb', 'table_properties.rb'].include?(file.basename.to_s)
      
      fix_file(file)
    end
    
    report
  end

  private

  def fix_file(file)
    content = file.read
    original = content.dup
    modified = false
    
    # Add require for new locations if file uses these classes
    needs_require = {
      'ParagraphProperties' => "require_relative '../ooxml/wordprocessingml/paragraph_properties'",
      'RunProperties' => "require_relative '../ooxml/wordprocessingml/run_properties'",
      'TableProperties' => "require_relative '../ooxml/wordprocessingml/table_properties'"
    }
    
    # Check which requires are needed
    requires_to_add = []
    needs_require.each do |class_name, require_line|
      if content =~ /\b#{class_name}\b/ && !content.include?(require_line)
        requires_to_add << require_line
      end
    end
    
    # Add requires after the existing require statements
    if requires_to_add.any?
      # Find the last require line
      lines = content.lines
      last_require_idx = lines.rindex { |line| line =~ /^require/ }
      
      if last_require_idx
        # Insert new requires after last existing require
        insert_point = last_require_idx + 1
        requires_to_add.reverse.each do |req|
          lines.insert(insert_point, "#{req}\n")
        end
        content = lines.join
        modified = true
      end
    end
    
    # Replace bare class names with fully qualified ones (within attribute and new calls only)
    replacements = {
      'attribute :properties, ParagraphProperties' => 'attribute :properties, Uniword::Ooxml::WordProcessingML::ParagraphProperties',
      'attribute :properties, RunProperties' => 'attribute :properties, Uniword::Ooxml::WordProcessingML::RunProperties',
      'attribute :properties, TableProperties' => 'attribute :properties, Uniword::Ooxml::WordProcessingML::TableProperties',
      'attribute :pPr, ParagraphProperties' => 'attribute :pPr, Uniword::Ooxml::WordProcessingML::ParagraphProperties',
      'attribute :rPr, RunProperties' => 'attribute :rPr, Uniword::Ooxml::WordProcessingML::RunProperties',
      'attribute :tblPr, TableProperties' => 'attribute :tblPr, Uniword::Ooxml::WordProcessingML::TableProperties',
      '||= ParagraphProperties.new' => '||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new',
      '||= RunProperties.new' => '||= Uniword::Ooxml::WordProcessingML::RunProperties.new',
      '||= TableProperties.new' => '||= Uniword::Ooxml::WordProcessingML::TableProperties.new',
      '= ParagraphProperties.new' => '= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new',
      '= RunProperties.new' => '= Uniword::Ooxml::WordProcessingML::RunProperties.new',
      '= TableProperties.new' => '= Uniword::Ooxml::WordProcessingML::TableProperties.new'
    }
    
    replacements.each do |old, new|
      if content.include?(old)
        content.gsub!(old, new)
        modified = true
      end
    end
    
    if modified
      file.write(content)
      rel_path = file.relative_path_from(@base_dir)
      @updated << rel_path.to_s
      puts "✅ Updated: #{rel_path}"
    end
  end

  def report
    puts
    puts "=" * 80
    puts "FIX SUMMARY"
    puts "=" * 80
    puts
    
    if @updated.empty?
      puts "No files needed updating."
    else
      puts "Updated #{@updated.size} file(s):"
      @updated.each { |f| puts "  #{f}" }
    end
  end
end

if __FILE__ == $0
  base_dir = File.expand_path('..', __dir__)
  fixer = WordProcessingMLFixer.new(base_dir)
  fixer.fix_all
end