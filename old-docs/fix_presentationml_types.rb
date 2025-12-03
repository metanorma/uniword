#!/usr/bin/env ruby
# frozen_string_literal: true

# Fix type declarations in generated PresentationML classes
# Changes: integer → :integer, string → :string

Dir.glob('lib/generated/presentationml/*.rb').each do |file|
  content = File.read(file)
  original = content.dup

  # Fix bare type identifiers to symbols
  content.gsub!(/, integer$/, ', :integer')
  content.gsub!(/, string$/, ', :string')

  if content != original
    File.write(file, content)
    puts "Fixed: #{File.basename(file)}"
  end
end

puts "\nAll PresentationML type declarations fixed!"
