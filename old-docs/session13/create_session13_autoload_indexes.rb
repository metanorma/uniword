#!/usr/bin/env ruby
# frozen_string_literal: true

# Create autoload indexes for Session 13 namespaces

def create_autoload_index(namespace, module_name)
  puts "Creating autoload index for #{namespace}..."

  # Get all Ruby files in the namespace directory
  files = Dir.glob("lib/generated/#{namespace}/*.rb").sort

  # Build autoload statements with File.expand_path
  autoloads = files.map do |file|
    basename = File.basename(file, '.rb')
    class_name = basename.split('_').map(&:capitalize).join
    "      autoload :#{class_name}, File.expand_path('#{namespace}/#{basename}', __dir__)"
  end

  # Create module content matching existing pattern
  content = <<~RUBY
    # frozen_string_literal: true

    # #{module_name} Namespace Autoload Index
    # Generated from: config/ooxml/schemas/#{namespace}.yml
    # Total classes: #{autoloads.size}

    module Uniword
      module Generated
        module #{module_name}
          # Autoload all #{module_name} classes
    #{autoloads.join("\n")}
        end
      end
    end
  RUBY

  # Write to file
  output_file = "lib/generated/#{namespace}.rb"
  File.write(output_file, content)

  puts "  ✅ Created #{output_file} with #{autoloads.size} autoloads"
end

puts '=' * 80
puts 'SESSION 13: Creating Autoload Indexes'
puts '=' * 80
puts

# Create autoload indexes
create_autoload_index('glossary', 'Glossary')
create_autoload_index('shared_types', 'SharedTypes')
create_autoload_index('document_variables', 'DocumentVariables')

puts
puts '=' * 80
puts 'AUTOLOAD INDEXES COMPLETE'
puts '=' * 80
puts
puts 'Next step: Test with test_session13_autoload.rb'
puts '=' * 80
