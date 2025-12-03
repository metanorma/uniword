#!/usr/bin/env ruby
# frozen_string_literal: true

def create_autoload_index(namespace_dir, namespace_module)
  files = Dir.glob("lib/generated/#{namespace_dir}/*.rb").sort

  # Extract class names from files
  autoloads = files.map do |file|
    content = File.read(file)
    class_match = content.match(/class (\w+) < Lutaml::Model::Serializable/)
    next unless class_match

    class_name = class_match[1]
    file_basename = File.basename(file)

    { class_name: class_name, file: file_basename }
  end.compact

  # Generate autoload file content
  content = <<~RUBY
    # frozen_string_literal: true

    # Autoload index for #{namespace_module} namespace
    # Generated from OOXML schema

    module Uniword
      module Generated
        module #{namespace_module}
  RUBY

  autoloads.each do |entry|
    content += "      autoload :#{entry[:class_name]}, "
    content += "File.expand_path('#{namespace_dir}/#{entry[:file].gsub('.rb', '')}', __dir__)\n"
  end

  content += "    end\n  end\nend\n"

  # Write to file
  output_file = "lib/generated/#{namespace_dir}.rb"
  File.write(output_file, content)

  puts "✅ Created #{output_file} with #{autoloads.size} autoloads"
  autoloads.size
end

puts '=' * 80
puts 'Creating Autoload Indexes'
puts '=' * 80
puts

# Create Custom XML autoload index
customxml_count = create_autoload_index('customxml', 'Customxml')

puts

# Create Bibliography autoload index
bibliography_count = create_autoload_index('bibliography', 'Bibliography')

puts
puts '=' * 80
puts 'COMPLETE'
puts '=' * 80
puts "Custom XML:    #{customxml_count} autoloads"
puts "Bibliography:  #{bibliography_count} autoloads"
puts "Total:         #{customxml_count + bibliography_count} autoloads"
puts '=' * 80
